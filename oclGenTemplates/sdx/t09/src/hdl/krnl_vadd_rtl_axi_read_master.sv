// /*******************************************************************************
// Copyright (c) 2018, Xilinx, Inc.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// 
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// 
// 
// 3. Neither the name of the copyright holder nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
// 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,THE IMPLIED 
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
// OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// *******************************************************************************/

///////////////////////////////////////////////////////////////////////////////
// Description: This is a multi-threaded AXI4 read master.  Each channel will
// issue commands on a different IDs.  As a result data may arrive out of 
// order.  The amount of data requested is equal to the ctrl_length variable.
// Prog full is set and sampled such that the FIFO will never overflow.  Thus 
// rready can be always asserted for better timing.
///////////////////////////////////////////////////////////////////////////////

`default_nettype none

module krnl_vadd_rtl_axi_read_master #( 
  //parameter integer C_ID_WIDTH         = 1,   // Must be >= $clog2(C_NUM_CHANNELS)
  parameter integer C_ADDR_WIDTH       = 64,
  parameter integer C_DATA_WIDTH       = 32,
  //parameter integer C_NUM_CHANNELS     = 1,   
  parameter integer C_LENGTH_WIDTH     = 32,  
  parameter integer C_BURST_LEN        = 256, // Max AXI burst length for read commands
  parameter integer C_LOG_BURST_LEN    = 8,
  parameter integer C_MAX_OUTSTANDING  = 3 
)
(
  // System signals
  input  wire                                          aclk,
  input  wire                                          areset,
  // Control signals 
  input  wire                      ctrl_start, 
  output wire                      ctrl_done, 
  input  wire [C_ADDR_WIDTH-1:0]   ctrl_offset,
  input  wire [C_LENGTH_WIDTH-1:0] ctrl_length,
  input  wire                      ctrl_prog_full,
  // AXI4 master interface                             
  output wire                      arvalid,
  input  wire                      arready,
  output wire [C_ADDR_WIDTH-1:0]   araddr,
  //output wire [C_ID_WIDTH-1:0]     arid,
  output wire                      arid,
  output wire [7:0]                arlen,
  output wire [2:0]                arsize,
  input  wire                      rvalid,
  output wire                      rready,
  input  wire [C_DATA_WIDTH - 1:0] rdata,
  input  wire                      rlast,
  //input  wire [C_ID_WIDTH - 1:0]   rid,
  input  wire                       rid,
  input  wire [1:0]                rresp,
  // AXI4-Stream master interface, 1 interface per channel.
  output wire                      m_tvalid,
  input  wire                      m_tready,
  output wire [C_DATA_WIDTH-1:0]   m_tdata
);

timeunit 1ps; 
timeprecision 1ps; 

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
localparam integer LP_MAX_OUTSTANDING_CNTR_WIDTH = $clog2(C_MAX_OUTSTANDING+1); 
localparam integer LP_TRANSACTION_CNTR_WIDTH = C_LENGTH_WIDTH-C_LOG_BURST_LEN;

///////////////////////////////////////////////////////////////////////////////
// Variables
///////////////////////////////////////////////////////////////////////////////
// Control logic
logic                                 done = '0;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] num_full_bursts;
logic                                 num_partial_bursts;
logic                                 start    = 1'b0;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] num_transactions;
logic                                 has_partial_burst;
logic [C_LOG_BURST_LEN-1:0]           final_burst_len;
logic                                 single_transaction;
logic                                 ar_idle = 1'b1;
logic                                 ar_done;
// AXI Read Address Channel
logic                                     fifo_stall;
logic                                     arxfer;
logic                                     arvalid_r = 1'b0; 
logic [C_ADDR_WIDTH-1:0]                  addr;
//logic [C_ID_WIDTH-1:0]                    id = {C_ID_WIDTH{1'b1}};
wire                                      id = 1'b0; //WN: hardwired as just one channel always
logic [LP_TRANSACTION_CNTR_WIDTH-1:0]     ar_transactions_to_go;
logic                                     ar_final_transaction;
logic                                     incr_ar_to_r_cnt;
logic                                     decr_ar_to_r_cnt;
logic                                     stall_ar;
logic [LP_MAX_OUTSTANDING_CNTR_WIDTH-1:0] outstanding_vacancy_count;
// AXI Data Channel
logic                                 tvalid;
logic [C_DATA_WIDTH-1:0]              tdata;
logic                                 rxfer;
logic                                 decr_r_transaction_cntr;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] r_transactions_to_go;
logic                                 r_final_transaction;
///////////////////////////////////////////////////////////////////////////////
// Control Logic 
///////////////////////////////////////////////////////////////////////////////

always @(posedge aclk) begin
  //for (int i = 0; i < C_NUM_CHANNELS; i++) begin 
    done <= rxfer & rlast & (rid == 0) & r_final_transaction ? 1'b1 : 
          ctrl_done ? 1'b0 : done; 
  //end
end
assign ctrl_done = &done;

// Determine how many full burst to issue and if there are any partial bursts.
assign num_full_bursts = ctrl_length[C_LOG_BURST_LEN+:C_LENGTH_WIDTH-C_LOG_BURST_LEN];
assign num_partial_bursts = ctrl_length[0+:C_LOG_BURST_LEN] ? 1'b1 : 1'b0; 

always @(posedge aclk) begin 
  start <= ctrl_start;
  num_transactions <= (num_partial_bursts == 1'b0) ? num_full_bursts - 1'b1 : num_full_bursts;
  has_partial_burst <= num_partial_bursts;
  final_burst_len <=  ctrl_length[0+:C_LOG_BURST_LEN] - 1'b1;
end

// Special case if there is only 1 AXI transaction. 
assign single_transaction = (num_transactions == {LP_TRANSACTION_CNTR_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

///////////////////////////////////////////////////////////////////////////////
// AXI Read Address Channel
///////////////////////////////////////////////////////////////////////////////
assign arvalid = arvalid_r;
assign araddr = addr;
assign arlen  = ar_final_transaction || (start & single_transaction) ? final_burst_len : C_BURST_LEN - 1;
assign arsize = $clog2((C_DATA_WIDTH/8));
assign arid   = id;

assign arxfer = arvalid & arready;
assign fifo_stall = ctrl_prog_full;

always @(posedge aclk) begin 
  if (areset) begin 
    arvalid_r <= 1'b0;
  end
  else begin
    arvalid_r <= ~ar_idle & ~stall_ar & ~arvalid_r & ~fifo_stall ? 1'b1 : 
                 arready ? 1'b0 : arvalid_r;
  end
end

// When ar_idle, there are no transactions to issue.
always @(posedge aclk) begin 
  if (areset) begin 
    ar_idle <= 1'b1; 
  end
  else begin 
    ar_idle <= start   ? 1'b0 :
               ar_done ? 1'b1 : 
                         ar_idle;
  end
end

// each channel is assigned a different id. The transactions are interleaved.
//always @(posedge aclk) begin 
//  if (start) begin 
//    id <= {C_ID_WIDTH{1'b1}};
//  end
//  else begin
//    id <= arxfer ? id - 1'b1 : id; 
//  end
//end
//WN: just one channel, so id hardwired to 0 at declaration



// Increment to next address after each transaction is issued.
always @(posedge aclk) begin 
  //for (int i = 0; i < C_NUM_CHANNELS; i++) begin
    addr <=  ctrl_start          ? ctrl_offset :
             arxfer && (id == 0) ? addr + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                   addr;
  //end
end

// Counts down the number of transactions to send.
krnl_vadd_rtl_counter #(
  .C_WIDTH ( LP_TRANSACTION_CNTR_WIDTH         ) ,
  .C_INIT  ( {LP_TRANSACTION_CNTR_WIDTH{1'b0}} ) 
)
inst_ar_transaction_cntr ( 
  .clk        ( aclk                   ) ,
  .clken      ( 1'b1                   ) ,
  .rst        ( areset                 ) ,
  .load       ( start                  ) ,
  .incr       ( 1'b0                   ) ,
  .decr       ( arxfer && id == 1'b0     ) ,
  .load_value ( num_transactions       ) ,
  .count      ( ar_transactions_to_go  ) ,
  .is_zero    ( ar_final_transaction   ) 
);

assign ar_done = ar_final_transaction && arxfer && id == 1'b0;

always_comb begin 
  //for (int i = 0; i < C_NUM_CHANNELS; i++) begin 
    incr_ar_to_r_cnt = rxfer & rlast & (rid == 0);
    decr_ar_to_r_cnt = arxfer & (arid == 0);
  //end
end

// Keeps track of the number of outstanding transactions. Stalls 
// when the value is reached so that the FIFO won't overflow.
krnl_vadd_rtl_counter #(
  .C_WIDTH ( LP_MAX_OUTSTANDING_CNTR_WIDTH                       ) ,
  .C_INIT  ( C_MAX_OUTSTANDING[0+:LP_MAX_OUTSTANDING_CNTR_WIDTH] ) 
)
//inst_ar_to_r_transaction_cntr[C_NUM_CHANNELS-1:0] ( 
inst_ar_to_r_transaction_cntr ( 
  .clk        ( aclk                           ) ,
  .clken      ( 1'b1                           ) ,
  .rst        ( areset                         ) ,
  .load       ( 1'b0                           ) ,
  .incr       ( incr_ar_to_r_cnt               ) ,
  .decr       ( decr_ar_to_r_cnt               ) ,
  .load_value ( {LP_MAX_OUTSTANDING_CNTR_WIDTH{1'b0}} ) ,
  .count      ( outstanding_vacancy_count      ) ,
  .is_zero    ( stall_ar                       ) 
);

///////////////////////////////////////////////////////////////////////////////
// AXI Read Channel
///////////////////////////////////////////////////////////////////////////////
assign m_tvalid = tvalid;
assign m_tdata = tdata;

always_comb begin 
  //for (int i = 0; i < C_NUM_CHANNELS; i++) begin
    tvalid = rvalid && (rid == 0); 
    tdata = rdata;
  //end
end

// rready can remain high for optimal timing because ar transactions are not issued
// unless there is enough space in the FIFO.
assign rready = 1'b1;
assign rxfer = rready & rvalid;

always_comb begin 
  //for (int i = 0; i < C_NUM_CHANNELS; i++) begin 
    decr_r_transaction_cntr = rxfer & rlast & (rid == 0);
  //end
end
krnl_vadd_rtl_counter #(
  .C_WIDTH ( LP_TRANSACTION_CNTR_WIDTH         ) ,
  .C_INIT  ( {LP_TRANSACTION_CNTR_WIDTH{1'b0}} ) 
)
//inst_r_transaction_cntr[C_NUM_CHANNELS-1:0] ( 
inst_r_transaction_cntr ( 
  .clk        ( aclk                          ) ,
  .clken      ( 1'b1                          ) ,
  .rst        ( areset                        ) ,
  .load       ( start                         ) ,
  .incr       ( 1'b0                          ) ,
  .decr       ( decr_r_transaction_cntr       ) ,
  .load_value ( num_transactions              ) ,
  .count      ( r_transactions_to_go          ) ,
  .is_zero    ( r_final_transaction           ) 
);


endmodule : krnl_vadd_rtl_axi_read_master

`default_nettype wire

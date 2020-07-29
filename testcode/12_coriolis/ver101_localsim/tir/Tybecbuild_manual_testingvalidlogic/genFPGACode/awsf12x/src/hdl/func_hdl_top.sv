// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      : S Waqar Nabi
// Template origin date : 2019.07.29
//
// Project Name         : TyTra
//
// Target Devices       : Xilinx Ultrascale (AWS)
//
// Generated Design Name: untitled
// Generated Module Name: func_hdl_top
// Generator Version    : R17.0
// Generator TimeStamp  : Thu Dec 19 17:56:07 2019
// 
// Dependencies         : <dependencies>
//
// =============================================================================
// General Description
// -----------------------------------------------------------------------------
// template for func_hdl_top.sv, required for SDx integration
// with TyBEC generated HDL
//
// This module is a light-weight wrapper that translates the packed AXI signals to
// unpacked signals for use by TyBEC generated modules, which have AXI-type
// signals but not with same names

// The top level function in TyTra-IR is ALWAYS "main", so this module will
// ALWYAS instantitate just one, MAIN module
//
// Based on template provided by Xilinx, their copy-right stuff follows
//
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
//============================================================================= 


`default_nettype none

`define TY_GVECT 1
  //legal values: 1, 2, 4, 8, 16 (for 32-bit scalar data type, i.e. int/float)
  //            : 1, 3, 4, 8     (for double)
  //maximum width is 512 bits
  //although this parameter is defined further up and passed down to this module
  //we need it here explicitly as well as for RTL sim this is the top module instantiated
  //in testbench

module func_hdl_top
#(
  // Data width of both input and output data (packed vector)
  // This is overwritten by parent, to a size equal to all  inputs coalesced
  parameter integer C_DATA_WIDTH   = 32 * `TY_GVECT  
)
(
  input wire                     aclk,
  input wire                     areset,

  input wire                     s_tvalid, //data at input is valid
  input wire  [C_DATA_WIDTH-1:0] s_tdata,  //data in
  output wire                    s_tready, //I am/aint ready (back pressure to predecessor)

  output wire                    m_tvalid, //data at output is valid
  output wire [C_DATA_WIDTH-1:0] m_tdata,  //data out
  input  wire                    m_tready,  //sink is ready (back pressure from successor)
  input  wire [32-1:0]           ctrl_xfer_size_in_bytes  
);

wire    ovalid;
wire    iready; 

assign  s_tready = iready;
assign  m_tvalid = ovalid;

//IVALID LOGIC

localparam PIPE_LAT  = 6;
//localparam DATA_SIZE = 64;
//localparam DATA_SIZE = 1024;

localparam PIPE_LAT_W   = 3;
localparam DATA_SIZE_W  = 32;

reg [PIPE_LAT_W-1:0]  pipe_lat_count;
reg [DATA_SIZE_W-1:0] data_count;

reg pipe_lat_enable;
wire [32-1:0] size_in_words = ctrl_xfer_size_in_bytes >> 2; //size in words = size in bytes / 4
//wire [32-1:0] size_in_words = DATA_SIZE; //size in words = size in bytes / 4

//enable pipe latency counter when data size reached
always @(posedge aclk) begin
  if(areset)
    pipe_lat_enable <= 1'b0;
  //else if((data_count==DATA_SIZE-1) && s_tvalid)
  else if((data_count==size_in_words-1) && s_tvalid)
    pipe_lat_enable <= 1'b1;
  else
    pipe_lat_enable <= pipe_lat_enable;
end

//pipe latency counter counts only when enabled (at the end of data counter)
always @(posedge aclk) begin
  if(areset || (pipe_lat_count==PIPE_LAT))
    pipe_lat_count <= 0;
  else if(pipe_lat_enable)
    pipe_lat_count <= pipe_lat_count + 1;
  else
    pipe_lat_count <= pipe_lat_count;
end

//data counter counts whenever input is valid
always @(posedge aclk) begin
  if(areset || (data_count==size_in_words))
  //if(areset || (data_count==DATA_SIZE))
    data_count <= 0;
  else if(s_tvalid)
    data_count <= data_count + 1;
  else
    data_count <= data_count;
end



//wire    ivalid = s_tvalid;
wire ivalid;
//ivalid is equal to external s_tvalid,
//until pipe counter is enabled at the end of the input data stream
//assign ivalid = (pipe_lat_enable)  ? (pipe_lat_count < PIPE_LAT)
//assign ivalid = (pipe_lat_enable)  ? (pipe_lat_count <= PIPE_LAT)
assign ivalid = (pipe_lat_enable)  ? 1
                                   : s_tvalid;

main 
#(
  //main is fed split up inputs (no longer coalesced inputs -- though vectorization coalescing may still be present)
  .STREAMW (32 * `TY_GVECT)
)main_i
(
   .clk     (aclk)
  ,.rst     (areset)
  ,.iready  (iready)
  ,.ivalid  (ivalid)
  ,.ovalid  (ovalid)
  ,.oready  (m_tready)
  ,.x_stream  (s_tdata[127:96])
  ,.u_stream  (s_tdata[95:64])
  ,.v_stream  (s_tdata[63:32])
  ,.y_stream  (s_tdata[31:0])
  ,.xn_stream  (m_tdata[127:96])
  ,.un_stream  (m_tdata[95:64])
  ,.vn_stream  (m_tdata[63:32])
  ,.yn_stream  (m_tdata[31:0])
  
);

endmodule : func_hdl_top

`default_nettype wire



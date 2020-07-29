// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      : S Waqar Nabi
// Template origin date : 2018.10.09
//
// Project Name         : TyTra
//
// Target Devices       : Xilinx Ultrascale (AWS)
//
// Generated Design Name: untitled
// Generated Module Name: func_hdl_top 
// Generator Version    : R17.0
// Generator TimeStamp  : Sun Nov  4 06:29:43 2018
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
  parameter integer C_DATA_WIDTH   = 32 * `TY_GVECT,  // Data width of both input and output data (packed vector)
  parameter integer C_NUM_CHANNELS = 2     // Number of input channels.  Only a value of 2 implemented.
)
(
  input wire                                         aclk,
  input wire                                         areset,

  input wire  [C_NUM_CHANNELS-1:0]                   s_tvalid, //data at input is valid
  input wire  [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0] s_tdata,  //data in
  output wire [C_NUM_CHANNELS-1:0]                   s_tready, //I am/aint ready (back pressure to predecessor)

  output wire                                        m_tvalid, //data at output is valid
  output wire [C_DATA_WIDTH-1:0]                     m_tdata,  //data out
  input  wire                                        m_tready  //sink is ready (back pressure from successor)
);

//translation between AXI stream signals, and tybec-hdl signals
//---------------------------------------------------------------
//the main difference is that the AXI handshake signals are separate for
//each IO channel, 
//whereas for tybec-hdl we have a single handshake signal for all 
//IO channels. This may change later  (TODO)

// the "iready" is back-pressure from the tybec-hdl's main
wire    iready; 

//the s_tready output (backpressure) depends on iready (backp) from tybec-rtl
assign s_tready = iready & (&s_tvalid) ? {C_NUM_CHANNELS{1'b1}} : {C_NUM_CHANNELS{1'b0}};

// input to tytra-hdl pipeline is valid if ALL AXI inputs are valid
wire    ivalid = &s_tvalid;

// AXI output(s) is valid if outptu from tybec-hdl is ready
wire    ovalid;
assign  m_tvalid = ovalid;


main 
#(
  .STREAMW (C_DATA_WIDTH)
)main_i
(
   .clk               (aclk)
  ,.rst               (areset)
  ,.iready            (iready)
  ,.ivalid            (ivalid)
  ,.ovalid            (ovalid)
  ,.oready            (m_tready)
  ,.vin1_stream_load  (s_tdata[1])
  ,.vout_stream_store  (m_tdata)
  ,.vin0_stream_load  (s_tdata[0])

);
  
endmodule : func_hdl_top

`default_nettype wire

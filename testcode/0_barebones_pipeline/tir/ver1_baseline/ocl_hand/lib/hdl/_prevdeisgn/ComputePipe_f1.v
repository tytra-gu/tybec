// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: ComputePipe_f1 
// Generator Version    : R0.03
// Generator TimeStamp  : Wed Aug 17 09:58:55 2016
// 
// Dependencies         : <dependencies>
//
// 
// =============================================================================

// =============================================================================
// General Description
// -----------------------------------------------------------------------------
// A generic pipelined module template for use by Tytra Back-End Compiler
// (TyBEC)
//
// ============================================================================= 

module ComputePipe_f1
#(  
  // ============================================================
  // ** Parameters 
  // ===========================================================
  // Parameters inherit from defines in include file. Default 
  // values defined here and must be overwritten as needed
  parameter DataW  = 32 
  , parameter STRM_a_W            = 32
  , parameter STRM_y_W            = 32
  , parameter STRM_b_W            = 32

)

(
// =============================================================================
// ** Ports 
// =============================================================================
  // standard kernel control ports
    input   clk   
  , input   rst   	
  , input   start  //asserted when first element is fed into the pipeline
  , input   stop   //asserted when the last element is fed into the pipe
  , output  ready  //asserted whenb first element exits the pipeline 
  , output  done   //asserted when the last element exits the pipeline 
  , output  reg cts    //for compatibility with SEQ Core

   
  , input	[STRM_a_W-1:0] strm_a 
  , output	[STRM_y_W-1:0] strm_y 
  , input	[STRM_b_W-1:0] strm_b

);

// =============================================================================
// ** Dataflow
// =============================================================================
// renamed for uniformity later
wire start_z0 = start;
wire stop_z0 = stop;

 
// -------- Pipeline Stage 0 -----------
// Pipelined unit for this stage
 
wire [DataW-1:0] strm_1;
 
PipePE_ui_add #(DataW) PE0 (clk, rst, , , strm_1, strm_a, strm_a);

 
// -------- Pipeline Stage 0 -----------
// Pipelined unit for this stage
 
wire [DataW-1:0] strm_2;
 
PipePE_ui_add #(DataW) PE1 (clk, rst, , , strm_2, strm_b, strm_b);
 
// -------- Pipeline Stage 1 -----------
// Pipelined unit for this stage
 
wire [DataW-1:0] strm_3;
 
PipePE_ui_mul #(DataW) PE2 (clk, rst, , , strm_3, strm_1, strm_2);

 
// -------- Pipeline Stage 2 -----------
// Pipelined unit for this stage
 
PipePE_ui_mul #(DataW) PE3 (clk, rst, , , strm_y, strm_3, strm_3);

 
// ------ CONTROL delay lines for stage 0 ------
wire start_z1, stop_z1;
delayline_z1 #(1) DL00 (clk, start_z1, start_z0 ); 
delayline_z1 #(1) DL10 (clk, stop_z1, stop_z0  ); 
 
// ------ CONTROL delay lines for stage 1 ------
wire start_z2, stop_z2;
delayline_z1 #(1) DL01 (clk, start_z2, start_z1 ); 
delayline_z1 #(1) DL11 (clk, stop_z2, stop_z1  ); 
 
// ------ CONTROL delay lines for stage 2 ------
wire start_z3, stop_z3;
delayline_z1 #(1) DL02 (clk, start_z3, start_z2 ); 
delayline_z1 #(1) DL12 (clk, stop_z3, stop_z2  ); 


//----------------------- output wires -----------------------------------------
// Use the (N-1)th START for READY (so _z3 for 4 stage pipeline)
assign ready = start_z2;

// Use the (Nth) STOP for DONE (so _z4 for 4 stage pipeline)
assign done = stop_z3;

//cts is asserted when the first element exits the pipeline
//(i.e. is when read is asserted for one tick) it remains asserted 
//as this is a pipeline that takes in a continuous stream
//of data, so it is always CTS
//It is used by parent to enable counting for destination counter
always @(posedge clk)
  if(ready || cts)
    cts <= 1'b1;
  else
    cts <= 1'b0;
 
endmodule 



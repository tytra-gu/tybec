// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernelTop_kernel_A 
// Generator Version    : R17.0
// Generator TimeStamp  : Sun Aug  6 17:23:22 2017
// 
// Dependencies         : <dependencies>
//
// 
// =============================================================================

// =============================================================================
// General Description
// -----------------------------------------------------------------------------
// A generic module template for leaf map nodes for use by Tytra Back-End Compile
// (TyBEC)
//
// ============================================================================= 

module kernelTop_kernel_A
#(  
   parameter DATAW     = 32
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input clk   
  , input rst   	
  , input stall
  
  , output [DATAW-1:0] ka_vout
  , input [DATAW-1:0]  ka_vin0
  , input [DATAW-1:0]  ka_vin1
);


wire [DATAW-1:0] local2;
wire [DATAW-1:0] local3;
wire [DATAW-1:0] local1;
wire [DATAW-1:0] local4;

kernel_A_local2 
kernel_A_local2_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (local2)
, .in2  (ka_vin1)
, .in1  (ka_vin0)
);

kernel_A_local3 
kernel_A_local3_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (local3)
, .in1  (local1)
, .in2  (local2)
);

kernel_A_local4 
kernel_A_local4_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (local4)
, .in1  (local1)
, .in2  (local3)
);

kernel_A_ka_vout 
kernel_A_ka_vout_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (ka_vout)
, .in1  (local1)
, .in2  (local4)
);

kernel_A_local1 
kernel_A_local1_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (local1)
, .in2  (ka_vin1)
, .in1  (ka_vin0)
);


endmodule 
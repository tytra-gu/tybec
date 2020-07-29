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
// Generator TimeStamp  : Thu Feb 15 18:26:47 2018
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
  
  , input [DATAW-1:0] ka_vin1
  , output [DATAW-1:0] ka_vout
  , input [DATAW-1:0] ka_vin0
);


wire [DATAW-1:0] local1;

kernel_A_local1 
kernel_A_local1_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (local1)
, .in2  (ka_vin1)
, .in1  (ka_vin0)
);

kernel_A_ka_vout 
kernel_A_ka_vout_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (ka_vout)
, .in2  (local1)
, .in1  (local1)
);


endmodule 
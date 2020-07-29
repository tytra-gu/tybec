// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernelTop_kernel_B 
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

module kernelTop_kernel_B
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
  
  , output [DATAW-1:0] kb_vout
  , input [DATAW-1:0] kb_vin
);



kernel_B_kb_vout 
kernel_B_kb_vout_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (kb_vout)
, .in2  (kb_vin)
, .in1  (kb_vin)
);


endmodule 
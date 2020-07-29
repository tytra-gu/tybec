// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernelTop_kernel_C 
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

module kernelTop_kernel_C
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
  
  , input [DATAW-1:0] kc_vin
  , output [DATAW-1:0] kc_vout
);



kernel_C_kc_vout 
kernel_C_kc_vout_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (kc_vout)
, .in2  (kc_vin)
, .in1  (kc_vin)
);


endmodule 
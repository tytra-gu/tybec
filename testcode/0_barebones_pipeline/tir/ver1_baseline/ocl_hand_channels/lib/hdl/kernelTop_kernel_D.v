// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernelTop_kernel_D 
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

module kernelTop_kernel_D
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
  
  , input [DATAW-1:0] kd_vin
  , output [DATAW-1:0] kd_vout
);



kernel_D_kd_vout 
kernel_D_kd_vout_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .out1  (kd_vout)
, .in2  (kd_vin)
, .in1  (kd_vin)
);


endmodule 
// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: main_kernelTop 
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

module main_kernelTop
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
  
  , input [DATAW-1:0] kt_vin0
  , input [DATAW-1:0] kt_vin1
  , output [DATAW-1:0] kt_vout
);


wire [DATAW-1:0] vconn_A_to_B;
wire [DATAW-1:0] vconn_B_to_C;
wire [DATAW-1:0] vconn_C_to_D;

kernelTop_kernel_A 
kernelTop_kernel_A_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .ka_vout  (vconn_A_to_B)
, .ka_vin0  (kt_vin0)
, .ka_vin1  (kt_vin1)
);

kernelTop_kernel_B 
kernelTop_kernel_B_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .kb_vout  (vconn_B_to_C)
, .kb_vin  (vconn_A_to_B)
);

kernelTop_kernel_C 
kernelTop_kernel_C_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .kc_vout  (vconn_C_to_D)
, .kc_vin  (vconn_B_to_C)
);

kernelTop_kernel_D 
kernelTop_kernel_D_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .kd_vout  (kt_vout)
, .kd_vin  (vconn_C_to_D)
);


endmodule 
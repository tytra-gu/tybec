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
// Generator TimeStamp  : Mon Oct 29 18:18:54 2018
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
   parameter STREAMW   = 32
)

(
// -----------------------------------------------------------------------------
// ** Ports 
// -----------------------------------------------------------------------------
    input   clk   
  , input   rst   	
  , output  iready 
  , input   ivalid 
  , output  ovalid 
  , input   oready  

  , input [STREAMW-1:0] kt_vin0_s0
  , input [STREAMW-1:0] kt_vin1_s0
  , output [STREAMW-1:0] kt_vout_s0  
);


// Data and control connection wires
wire ovalid_s0;
wire [STREAMW-1:0] vconn_A_to_B_s0;
wire valid_vconn_A_to_B_s0;
wire ready_vconn_A_to_B_s0;
wire iready_s0;
wire [STREAMW-1:0] vconn_B_to_C_s0;
wire valid_vconn_B_to_C_s0;
wire ready_vconn_B_to_C_s0;
wire [STREAMW-1:0] vconn_C_to_D_s0;
wire valid_vconn_C_to_D_s0;
wire ready_vconn_C_to_D_s0;

//glue logic for output control signals
assign ovalid = 
        ovalid_s0 & 
			  1'b1;
assign iready = 
        iready_s0 & 
			  1'b1;


// Instantiations
kernelTop_kernel_A 
kernelTop_kernel_A_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .ka_vout_s0  (vconn_A_to_B_s0)
, .ovalid (valid_vconn_A_to_B_s0)
, .oready (ready_vconn_A_to_B_s0)
, .ka_vin1_s0  (kt_vin1_s0)
, .ivalid (ivalid)
, .iready (iready_s0)
, .ka_vin0_s0  (kt_vin0_s0)
);

kernelTop_kernel_B 
kernelTop_kernel_B_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .kb_vout_s0  (vconn_B_to_C_s0)
, .ovalid (valid_vconn_B_to_C_s0)
, .oready (ready_vconn_B_to_C_s0)
, .kb_vin_s0  (vconn_A_to_B_s0)
, .ivalid (valid_vconn_A_to_B_s0)
, .iready (ready_vconn_A_to_B_s0)
);

kernelTop_kernel_C 
kernelTop_kernel_C_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .kc_vout_s0  (vconn_C_to_D_s0)
, .ovalid (valid_vconn_C_to_D_s0)
, .oready (ready_vconn_C_to_D_s0)
, .kc_vin_s0  (vconn_B_to_C_s0)
, .ivalid (valid_vconn_B_to_C_s0)
, .iready (ready_vconn_B_to_C_s0)
);

kernelTop_kernel_D 
kernelTop_kernel_D_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .kd_vout_s0  (kt_vout_s0)
, .ovalid (ovalid_s0)
, .oready (oready)
, .kd_vin_s0  (vconn_C_to_D_s0)
, .ivalid (valid_vconn_C_to_D_s0)
, .iready (ready_vconn_C_to_D_s0)
);


endmodule 

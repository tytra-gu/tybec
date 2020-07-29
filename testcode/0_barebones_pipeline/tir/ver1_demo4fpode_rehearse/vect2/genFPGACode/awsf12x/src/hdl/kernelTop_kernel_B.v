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
// Generator TimeStamp  : Sun Nov  4 06:37:15 2018
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

  , input [STREAMW-1:0] kb_vin_s0
  , output [STREAMW-1:0] kb_vout_s0  
);


// Data and control connection wires
wire ovalid_s0;
wire iready_s0;

//glue logic for output control signals
assign ovalid = 
        ovalid_s0 & 
			  1'b1;
assign iready = 
        iready_s0 & 
			  1'b1;


// Instantiations
kernel_B_kb_vout 
kernel_B_kb_vout_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  (kb_vout_s0)
, .ovalid (ovalid_s0)
, .oready (oready)
, .in2_s0  (kb_vin_s0)
, .ivalid (ivalid)
, .iready (iready_s0)
, .in1_s0  (kb_vin_s0)
);


endmodule 

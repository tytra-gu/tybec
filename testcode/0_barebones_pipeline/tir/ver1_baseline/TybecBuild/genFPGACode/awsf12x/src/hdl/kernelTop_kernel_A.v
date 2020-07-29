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
// Generator TimeStamp  : Thu Nov 29 14:02:26 2018
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
   parameter STREAMW   = 32
)

(
// -----------------------------------------------------------------------------
// ** Ports 
// -----------------------------------------------------------------------------
    input   clk   
  , input   rst   	
  , output  iready 
  , output  ovalid 
  , input ivalid_ka_vin0_s0
  , input ivalid_ka_vin1_s0

  , input oready_ka_vout_s0

//  , input   ivalid 
//  , input   oready  

  , output [STREAMW-1:0] ka_vout_s0
  , input [STREAMW-1:0] ka_vin0_s0
  , input [STREAMW-1:0] ka_vin1_s0  
);


// Data and control connection wires
wire ovalid_s0;
wire [STREAMW-1:0] local1_s0;
wire valid_local1_s0;
wire ready_local1_s0;
wire iready_s0;
wire ovalid_ka_vout_s0;

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_ka_vin0_s0
  & ivalid_ka_vin1_s0
  ;

assign oready = 1'b1
  & oready_ka_vout_s0
  ;


//glue logic for output control signals
assign ovalid = 
        ovalid_s0 & 
			  1'b1;
assign iready = 
        iready_s0 & 
			  1'b1;


// Instantiations
kernel_A_local1 
kernel_A_local1_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  (local1_s0)
, .ovalid (valid_local1_s0)
, .oready (ready_local1_s0)
, .in2_s0  (ka_vin1_s0)
, .ivalid (ivalid)
, .iready (iready_s0)
, .in1_s0  (ka_vin0_s0)
);

kernel_A_ka_vout 
kernel_A_ka_vout_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  (ka_vout_s0)
, .ovalid (ovalid_s0)
, .oready (oready)
, .in2_s0  (local1_s0)
, .ivalid (valid_local1_s0)
, .iready (ready_local1_s0)
, .in1_s0  (local1_s0)
);


endmodule 

// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_top_coriolis_ker1_subker0 
// Generator Version    : R17.0
// Generator TimeStamp  : Tue Aug 13 15:13:19 2019
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

module kernel_top_coriolis_ker1_subker0
#(  
   parameter STREAMW   = 34
)

(
// -----------------------------------------------------------------------------
// ** Ports 
// -----------------------------------------------------------------------------
    input   clk   
  , input   rst   	
  , output  iready 
  , output  ovalid 
  , input ivalid_un_s0
  , input ivalid_x_s0

  , input oready_xn_s0


  , input [STREAMW-1:0]  un_s0
  , output [STREAMW-1:0]  xn_s0
  , input [STREAMW-1:0]  x_s0  
);


// Data and control connection wires
wire [STREAMW-1:0]  mul_s0;
wire valid_mul;
wire ready_mul_s0;
wire iready_mul_s0;  
wire [STREAMW-1:0]  div_s0;
wire valid_div;
wire ready_div_s0;
wire iready_div_s0;  
wire ovalid_xn_s0;
wire iready_xn_s0;  
wire [STREAMW-1:0]  x_b_15_s0;
wire valid_x_xn_b;
wire ready_x_b_15_s0;
wire iready_x_xn_b_s0;  

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_un_s0
  & ivalid_x_s0
  ;
assign oready = 1'b1
  & oready_xn_s0
  ;

//glue logic for output control signals
assign ovalid = 
        ovalid_xn_s0 & 
			  1'b1;
assign iready = 
        iready_mul_s0 &
        iready_x_xn_b_s0 & 
        oready & 
			  1'b1;

//single iready from a successor node may connect to multiple
//predecssor nodes; make those connections here
wire iready_from_div;
wire iready_from_xn;
assign ready_div_s0 = 1'b1 & iready_from_xn;
assign ready_x_b_15_s0 = 1'b1 & iready_from_xn;
assign ready_mul_s0 = 1'b1 & iready_from_div;
        

// Instantiations
coriolis_ker1_subker0_mul 
coriolis_ker1_subker0_mul_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( mul_s0 )
, .ovalid (valid_mul)
, .oready (ready_mul_s0)
, .in1_s0  (  un_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_mul_s0)
);

coriolis_ker1_subker0_div 
coriolis_ker1_subker0_div_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( div_s0 )
, .ovalid (valid_div)
, .oready (ready_div_s0)
, .in1_s0  (  mul_s0 )
, .ivalid_in1_s0 (valid_mul)
, .iready (iready_from_div)
);

coriolis_ker1_subker0_xn 
coriolis_ker1_subker0_xn_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( xn_s0)
, .ovalid (ovalid_xn_s0)
, .oready (oready)
, .in1_s0  (  x_b_15_s0 )
, .ivalid_in1_s0 (valid_x_xn_b)
, .iready (iready_from_xn)
, .in2_s0  (  div_s0 )
, .ivalid_in2_s0 (valid_div)
);

coriolis_ker1_subker0_x_xn_b 
coriolis_ker1_subker0_x_xn_b_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( x_b_15_s0 )
, .ovalid_out1_s0 (valid_x_xn_b)
, .oready_out1_s0 (ready_x_b_15_s0)
, .in1_s0  (  x_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_x_xn_b_s0)
);


endmodule 

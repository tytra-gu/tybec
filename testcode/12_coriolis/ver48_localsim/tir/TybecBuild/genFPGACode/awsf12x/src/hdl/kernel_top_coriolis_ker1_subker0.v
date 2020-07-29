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
// Generator TimeStamp  : Mon Dec 16 13:08:16 2019
// 
// Dependencies         : <dependencies>
//
// 
// =============================================================================

// =============================================================================
// General Description
// -----------------------------------------------------------------------------
// A generic module template for hierarchical 
// map nodes for use by Tytra Back-End Compile
//
// ============================================================================= 

module kernel_top_coriolis_ker1_subker0
#(  
   parameter STREAMW   = 34
  ,parameter SCALARW   = 34
)

(
// -----------------------------------------------------------------------------
// ** Ports 
// -----------------------------------------------------------------------------
    input   clk   
  , input   rst   	
  , output  iready 
  , output  ovalid 
  , input ivalid_un
  , input ivalid_x

  , input oready_xn


, input [STREAMW-1:0]  un
, output [STREAMW-1:0]  xn
, input [STREAMW-1:0]  x  
);


// Data and control connection wires
wire [SCALARW-1:0]  x_buff15;
wire valid_x_buff15;
wire ready_x_buff15;
wire iready_x_buff15;  
wire ovalid_xn;
wire iready_xn;  
wire [SCALARW-1:0]  div;
wire valid_div;
wire ready_div;
wire iready_div;  
wire [SCALARW-1:0]  mul;
wire valid_mul;
wire ready_mul;
wire iready_mul;  

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_un
  & ivalid_x
  ;
assign oready = 1'b1
  & oready_xn
  ;

//glue logic for output control signals
assign ovalid = 
        ovalid_xn & 
			  1'b1;
assign iready = 
        iready_x_buff15 &
        iready_mul & 
        oready & 
			  1'b1;

//single iready from a successor node may connect to multiple
//predecssor nodes; make those connections here
wire iready_from_xn;
wire iready_from_div;
assign ready_mul = 1'b1 & iready_from_div;
assign ready_div = 1'b1 & iready_from_xn;
assign ready_x_buff15 = 1'b1 & iready_from_xn;
        

// Instantiations
coriolis_ker1_subker0_x_buff15 
coriolis_ker1_subker0_x_buff15_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( x_buff15 )
, .ovalid_out1 (valid_x_buff15)
, .oready_out1 (ready_x_buff15)
, .in1 (x)
, .ivalid_in1 (ivalid)
, .iready (iready_x_buff15)
);

coriolis_ker1_subker0_xn 
coriolis_ker1_subker0_xn_i (
  .clk    (clk)
, .rst    (rst)
, .out1  ( xn[33:0])
, .ovalid (ovalid_xn)
, .oready (oready)
, .in1 (x_buff15)
, .ivalid_in1 (valid_x_buff15)
, .iready (iready_from_xn)
, .in2 (div)
, .ivalid_in2 (valid_div)
);

coriolis_ker1_subker0_div 
coriolis_ker1_subker0_div_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( div )
, .ovalid (valid_div)
, .oready (ready_div)
, .in1 (mul)
, .ivalid_in1 (valid_mul)
, .iready (iready_from_div)
);

coriolis_ker1_subker0_mul 
coriolis_ker1_subker0_mul_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( mul )
, .ovalid (valid_mul)
, .oready (ready_mul)
, .in1 (un)
, .ivalid_in1 (ivalid)
, .iready (iready_mul)
);


endmodule 

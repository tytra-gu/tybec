// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_top_coriolis_ker1_subker1 
// Generator Version    : R17.0
// Generator TimeStamp  : Tue Aug 13 12:24:42 2019
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

module kernel_top_coriolis_ker1_subker1
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
  , input ivalid_vn_s0
  , input ivalid_y_s0

  , input oready_yn_s0


  , input [STREAMW-1:0]  vn_s0
  , output [STREAMW-1:0]  yn_s0
  , input [STREAMW-1:0]  y_s0  
);


// Data and control connection wires
wire [STREAMW-1:0]  mul1_s0;
wire valid_mul1;
wire ready_mul1_s0;
wire iready_mul1_s0;  
wire [STREAMW-1:0]  div2_s0;
wire valid_div2;
wire ready_div2_s0;
wire iready_div2_s0;  
wire ovalid_yn_s0;
wire iready_yn_s0;  
wire [STREAMW-1:0]  y_b_15_s0;
wire valid_y_yn_b;
wire ready_y_b_15_s0;
wire iready_y_yn_b_s0;  

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_vn_s0
  & ivalid_y_s0
  ;
assign oready = 1'b1
  & oready_yn_s0
  ;

//glue logic for output control signals
assign ovalid = 
        ovalid_yn_s0 & 
			  1'b1;
assign iready = 
        iready_mul1_s0 &
        iready_y_yn_b_s0 & 
        oready & 
			  1'b1;

//single iready from a successor node may connect to multiple
//predecssor nodes; make those connections here
wire iready_from_div2;
wire iready_from_yn;
assign ready_y_b_15_s0 = 1'b1 & iready_from_yn;
assign ready_mul1_s0 = 1'b1 & iready_from_div2;
assign ready_div2_s0 = 1'b1 & iready_from_yn;
        

// Instantiations
coriolis_ker1_subker1_mul1 
coriolis_ker1_subker1_mul1_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( mul1_s0 )
, .ovalid (valid_mul1)
, .oready (ready_mul1_s0)
, .in1_s0  (  vn_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_mul1_s0)
);

coriolis_ker1_subker1_div2 
coriolis_ker1_subker1_div2_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( div2_s0 )
, .ovalid (valid_div2)
, .oready (ready_div2_s0)
, .in1_s0  (  mul1_s0 )
, .ivalid_in1_s0 (valid_mul1)
, .iready (iready_from_div2)
);

coriolis_ker1_subker1_yn 
coriolis_ker1_subker1_yn_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( yn_s0)
, .ovalid (ovalid_yn_s0)
, .oready (oready)
, .in1_s0  (  y_b_15_s0 )
, .ivalid_in1_s0 (valid_y_yn_b)
, .iready (iready_from_yn)
, .in2_s0  (  div2_s0 )
, .ivalid_in2_s0 (valid_div2)
);

coriolis_ker1_subker1_y_yn_b 
coriolis_ker1_subker1_y_yn_b_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( y_b_15_s0 )
, .ovalid_out1_s0 (valid_y_yn_b)
, .oready_out1_s0 (ready_y_b_15_s0)
, .in1_s0  (  y_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_y_yn_b_s0)
);


endmodule 

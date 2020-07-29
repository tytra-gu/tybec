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
// Generator TimeStamp  : Thu Dec 19 17:56:07 2019
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

module kernel_top_coriolis_ker1_subker1
#(  
   parameter STREAMW   = 32
  ,parameter SCALARW   = 32
)

(
// -----------------------------------------------------------------------------
// ** Ports 
// -----------------------------------------------------------------------------
    input   clk   
  , input   rst   	
  , output  iready 
  , output  ovalid 
  , input ivalid_y
  , input ivalid_vn

  , input oready_yn


, output [STREAMW-1:0]  yn
, input [STREAMW-1:0]  y
, input [STREAMW-1:0]  vn  
);


// Data and control connection wires
wire [SCALARW-1:0]  mul1;
wire valid_mul1;
wire ready_mul1;
wire iready_mul1;  
wire ovalid_yn;
wire iready_yn;  
wire [SCALARW-1:0]  y_buff1;
wire valid_y_buff1;
wire ready_y_buff1;
wire [SCALARW-1:0]  div2;
wire valid_div2;
wire ready_div2;
wire iready_y_buff1;  
wire iready_div2;  

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_y
  & ivalid_vn
  ;
assign oready = 1'b1
  & oready_yn
  ;

//glue logic for output control signals
assign ovalid = 
        ovalid_yn & 
			  1'b1;
assign iready = 
        iready_mul1 &
        iready_y_buff1 & 
        oready & 
			  1'b1;

//single iready from a successor node may connect to multiple
//predecssor nodes; make those connections here
wire iready_from_yn;
wire iready_from_div2;
assign ready_mul1 = 1'b1 & iready_from_div2;
assign ready_div2 = 1'b1 & iready_from_yn;
assign ready_y_buff1 = 1'b1 & iready_from_yn;
        

// Instantiations
coriolis_ker1_subker1_mul1 
coriolis_ker1_subker1_mul1_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( mul1 )
, .ovalid (valid_mul1)
, .oready (ready_mul1)
, .in1 (vn)
, .ivalid_in1 (ivalid)
, .iready (iready_mul1)
);

coriolis_ker1_subker1_yn 
coriolis_ker1_subker1_yn_i (
  .clk    (clk)
, .rst    (rst)
, .out1  ( yn[31:0])
, .ovalid (ovalid_yn)
, .oready (oready)
, .in1 (y_buff1)
, .ivalid_in1 (valid_y_buff1)
, .iready (iready_from_yn)
, .in2 (div2)
, .ivalid_in2 (valid_div2)
);

coriolis_ker1_subker1_y_buff1 
coriolis_ker1_subker1_y_buff1_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( y_buff1 )
, .ovalid_out1 (valid_y_buff1)
, .oready_out1 (ready_y_buff1)
, .in1 (y)
, .ivalid_in1 (ivalid)
, .iready (iready_y_buff1)
);

coriolis_ker1_subker1_div2 
coriolis_ker1_subker1_div2_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( div2 )
, .ovalid (valid_div2)
, .oready (ready_div2)
, .in1 (mul1)
, .ivalid_in1 (valid_mul1)
, .iready (iready_from_div2)
);


endmodule 

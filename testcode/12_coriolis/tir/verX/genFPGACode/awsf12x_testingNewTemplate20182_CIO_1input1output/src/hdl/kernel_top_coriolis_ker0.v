// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_top_coriolis_ker0 
// Generator Version    : R17.0
// Generator TimeStamp  : Thu Jul 25 11:54:14 2019
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

module kernel_top_coriolis_ker0
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
  , input ivalid_v_s0
  , input ivalid_u_s0

  , input oready_un_s0
  , input oready_vn_s0


  , input [STREAMW-1:0]  v_s0
  , output [STREAMW-1:0]  un_s0
  , input [STREAMW-1:0]  u_s0
  , output [STREAMW-1:0]  vn_s0  
);


// Data and control connection wires
wire [STREAMW-1:0]  mul4_s0;
wire valid_mul4;
wire ready_mul4_s0;
wire iready_mul4_s0;  
wire [STREAMW-1:0]  mul1_s0;
wire valid_mul1;
wire ready_mul1_s0;
wire iready_mul1_s0;  
wire [STREAMW-1:0]  add_s0;
wire valid_add;
wire ready_add_s0;
wire iready_add_s0;  
wire [STREAMW-1:0]  mul_s0;
wire valid_mul;
wire ready_mul_s0;
wire ovalid_un_s0;
wire iready_un_s0;  
wire iready_mul_s0;  
wire [STREAMW-1:0]  mul5_s0;
wire valid_mul5;
wire ready_mul5_s0;
wire iready_mul5_s0;  
wire [STREAMW-1:0]  sub6_s0;
wire valid_sub6;
wire ready_sub6_s0;
wire iready_sub6_s0;  
wire ovalid_vn_s0;
wire iready_vn_s0;  

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_v_s0
  & ivalid_u_s0
  ;
assign oready = 1'b1
  & oready_un_s0
  & oready_vn_s0
  ;

//glue logic for output control signals
assign ovalid = 
        ovalid_un_s0 &
        ovalid_vn_s0 & 
			  1'b1;
assign iready = 
        iready_mul4_s0 &
        iready_mul1_s0 &
        iready_mul_s0 &
        iready_mul5_s0 & 
        oready & 
			  1'b1;

//single iready from a successor node may connect to multiple
//predecssor nodes; make those connections here
wire iready_from_add;
wire iready_from_un;
wire iready_from_sub6;
wire iready_from_vn;
assign ready_sub6_s0 = 1'b1 & iready_from_vn;
assign ready_mul1_s0 = 1'b1 & iready_from_add;
assign ready_mul_s0 = 1'b1 & iready_from_add;
assign ready_mul4_s0 = 1'b1 & iready_from_sub6;
assign ready_add_s0 = 1'b1 & iready_from_un;
assign ready_mul5_s0 = 1'b1 & iready_from_sub6;
        

// Instantiations
coriolis_ker0_mul4 
coriolis_ker0_mul4_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( mul4_s0 )
, .ovalid (valid_mul4)
, .oready (ready_mul4_s0)
, .in1_s0  (  v_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_mul4_s0)
);

coriolis_ker0_mul1 
coriolis_ker0_mul1_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( mul1_s0 )
, .ovalid (valid_mul1)
, .oready (ready_mul1_s0)
, .in1_s0  (  v_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_mul1_s0)
);

coriolis_ker0_add 
coriolis_ker0_add_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( add_s0 )
, .ovalid (valid_add)
, .oready (ready_add_s0)
, .in1_s0  (  mul_s0 )
, .ivalid_in1_s0 (valid_mul)
, .iready (iready_from_add)
, .in2_s0  (  mul1_s0 )
, .ivalid_in2_s0 (valid_mul1)
);

coriolis_ker0_un 
coriolis_ker0_un_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( un_s0)
, .ovalid (ovalid_un_s0)
, .oready (oready)
, .in1_s0  (  add_s0 )
, .ivalid_in1_s0 (valid_add)
, .iready (iready_from_un)
);

coriolis_ker0_mul 
coriolis_ker0_mul_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( mul_s0 )
, .ovalid (valid_mul)
, .oready (ready_mul_s0)
, .in1_s0  (  u_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_mul_s0)
);

coriolis_ker0_mul5 
coriolis_ker0_mul5_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( mul5_s0 )
, .ovalid (valid_mul5)
, .oready (ready_mul5_s0)
, .in1_s0  (  u_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_mul5_s0)
);

coriolis_ker0_sub6 
coriolis_ker0_sub6_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( sub6_s0 )
, .ovalid (valid_sub6)
, .oready (ready_sub6_s0)
, .in1_s0  (  mul4_s0 )
, .ivalid_in1_s0 (valid_mul4)
, .iready (iready_from_sub6)
, .in2_s0  (  mul5_s0 )
, .ivalid_in2_s0 (valid_mul5)
);

coriolis_ker0_vn 
coriolis_ker0_vn_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( vn_s0)
, .ovalid (ovalid_vn_s0)
, .oready (oready)
, .in1_s0  (  sub6_s0 )
, .ivalid_in1_s0 (valid_sub6)
, .iready (iready_from_vn)
);


endmodule 

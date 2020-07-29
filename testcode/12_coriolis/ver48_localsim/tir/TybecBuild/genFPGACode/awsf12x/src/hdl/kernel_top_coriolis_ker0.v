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

module kernel_top_coriolis_ker0
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
  , input ivalid_v
  , input ivalid_u

  , input oready_un
  , input oready_vn


, output [STREAMW-1:0]  un
, output [STREAMW-1:0]  vn
, input [STREAMW-1:0]  v
, input [STREAMW-1:0]  u  
);


// Data and control connection wires
wire [SCALARW-1:0]  mul1;
wire valid_mul1;
wire ready_mul1;
wire iready_mul1;  
wire ovalid_un;
wire iready_un;  
wire [SCALARW-1:0]  add;
wire valid_add;
wire ready_add;
wire ovalid_vn;
wire iready_vn;  
wire [SCALARW-1:0]  sub6;
wire valid_sub6;
wire ready_sub6;
wire iready_add;  
wire [SCALARW-1:0]  mul;
wire valid_mul;
wire ready_mul;
wire iready_mul;  
wire [SCALARW-1:0]  mul5;
wire valid_mul5;
wire ready_mul5;
wire iready_mul5;  
wire [SCALARW-1:0]  mul4;
wire valid_mul4;
wire ready_mul4;
wire iready_mul4;  
wire iready_sub6;  

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_v
  & ivalid_u
  ;
assign oready = 1'b1
  & oready_un
  & oready_vn
  ;

//glue logic for output control signals
assign ovalid = 
        ovalid_un &
        ovalid_vn & 
			  1'b1;
assign iready = 
        iready_mul1 &
        iready_mul &
        iready_mul5 &
        iready_mul4 & 
        oready & 
			  1'b1;

//single iready from a successor node may connect to multiple
//predecssor nodes; make those connections here
wire iready_from_un;
wire iready_from_vn;
wire iready_from_add;
wire iready_from_sub6;
assign ready_mul = 1'b1 & iready_from_add;
assign ready_sub6 = 1'b1 & iready_from_vn;
assign ready_mul5 = 1'b1 & iready_from_sub6;
assign ready_add = 1'b1 & iready_from_un;
assign ready_mul1 = 1'b1 & iready_from_add;
assign ready_mul4 = 1'b1 & iready_from_sub6;
        

// Instantiations
coriolis_ker0_mul1 
coriolis_ker0_mul1_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( mul1 )
, .ovalid (valid_mul1)
, .oready (ready_mul1)
, .in1 (v)
, .ivalid_in1 (ivalid)
, .iready (iready_mul1)
);

coriolis_ker0_un 
coriolis_ker0_un_i (
  .clk    (clk)
, .rst    (rst)
, .out1  ( un[33:0])
, .ovalid (ovalid_un)
, .oready (oready)
, .in1 (add)
, .ivalid_in1 (valid_add)
, .iready (iready_from_un)
);

coriolis_ker0_vn 
coriolis_ker0_vn_i (
  .clk    (clk)
, .rst    (rst)
, .out1  ( vn[33:0])
, .ovalid (ovalid_vn)
, .oready (oready)
, .in1 (sub6)
, .ivalid_in1 (valid_sub6)
, .iready (iready_from_vn)
);

coriolis_ker0_add 
coriolis_ker0_add_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( add )
, .ovalid (valid_add)
, .oready (ready_add)
, .in1 (mul)
, .ivalid_in1 (valid_mul)
, .iready (iready_from_add)
, .in2 (mul1)
, .ivalid_in2 (valid_mul1)
);

coriolis_ker0_mul 
coriolis_ker0_mul_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( mul )
, .ovalid (valid_mul)
, .oready (ready_mul)
, .in1 (u)
, .ivalid_in1 (ivalid)
, .iready (iready_mul)
);

coriolis_ker0_mul5 
coriolis_ker0_mul5_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( mul5 )
, .ovalid (valid_mul5)
, .oready (ready_mul5)
, .in1 (u)
, .ivalid_in1 (ivalid)
, .iready (iready_mul5)
);

coriolis_ker0_mul4 
coriolis_ker0_mul4_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( mul4 )
, .ovalid (valid_mul4)
, .oready (ready_mul4)
, .in1 (v)
, .ivalid_in1 (ivalid)
, .iready (iready_mul4)
);

coriolis_ker0_sub6 
coriolis_ker0_sub6_i (
  .clk    (clk)
, .rst    (rst)
, .out1 ( sub6 )
, .ovalid (valid_sub6)
, .oready (ready_sub6)
, .in1 (mul4)
, .ivalid_in1 (valid_mul4)
, .iready (iready_from_sub6)
, .in2 (mul5)
, .ivalid_in2 (valid_mul5)
);


endmodule 

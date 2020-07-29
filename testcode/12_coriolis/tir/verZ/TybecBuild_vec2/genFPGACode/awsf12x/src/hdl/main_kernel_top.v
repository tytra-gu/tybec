// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: main_kernel_top 
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

module main_kernel_top
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
  , input ivalid_u_s0
  , input ivalid_x_s0
  , input ivalid_v_s0
  , input ivalid_y_s0

  , input oready_yn_s0
  , input oready_un_s0
  , input oready_vn_s0
  , input oready_xn_s0


  , output [STREAMW-1:0]  yn_s0
  , input [STREAMW-1:0]  u_s0
  , output [STREAMW-1:0]  un_s0
  , output [STREAMW-1:0]  vn_s0
  , output [STREAMW-1:0]  xn_s0
  , input [STREAMW-1:0]  x_s0
  , input [STREAMW-1:0]  v_s0
  , input [STREAMW-1:0]  y_s0  
);


// Data and control connection wires
wire ovalid_coriolis_ker1_subker1_s0;
wire iready_coriolis_ker1_subker1_s0;  
wire [STREAMW-1:0]  vn_local_s0;
wire valid_coriolis_ker0;
wire ready_vn_local_s0;
wire [STREAMW-1:0]  y_b_23_s0;
wire valid_y_coriolis_ker1_subker1_2_b;
wire ready_y_b_23_s0;
wire [STREAMW-1:0]  un_local_s0;
wire ready_un_local_s0;
wire iready_coriolis_ker0_s0;  
wire [STREAMW-1:0]  un_local_b_22_s0;
wire valid_coriolis_ker0_0_un_b;
wire ready_un_local_b_22_s0;
wire iready_coriolis_ker0_0_un_b_s0;  
wire ovalid_un_s0;
wire iready_un_s0;  
wire [STREAMW-1:0]  vn_local_b_22_s0;
wire valid_coriolis_ker0_0_vn_b;
wire ready_vn_local_b_22_s0;
wire iready_coriolis_ker0_0_vn_b_s0;  
wire ovalid_vn_s0;
wire iready_vn_s0;  
wire ovalid_coriolis_ker1_subker0_s0;
wire iready_coriolis_ker1_subker0_s0;  
wire [STREAMW-1:0]  x_b_23_s0;
wire valid_x_coriolis_ker1_subker0_1_b;
wire ready_x_b_23_s0;
wire iready_x_coriolis_ker1_subker0_1_b_s0;  
wire iready_y_coriolis_ker1_subker1_2_b_s0;  

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_u_s0
  & ivalid_x_s0
  & ivalid_v_s0
  & ivalid_y_s0
  ;
assign oready = 1'b1
  & oready_yn_s0
  & oready_un_s0
  & oready_vn_s0
  & oready_xn_s0
  ;

//glue logic for output control signals
assign ovalid = 
        ovalid_coriolis_ker1_subker1_s0 &
        ovalid_un_s0 &
        ovalid_vn_s0 &
        ovalid_coriolis_ker1_subker0_s0 & 
			  1'b1;
assign iready = 
        iready_coriolis_ker0_s0 &
        iready_x_coriolis_ker1_subker0_1_b_s0 &
        iready_y_coriolis_ker1_subker1_2_b_s0 & 
        oready & 
			  1'b1;

//single iready from a successor node may connect to multiple
//predecssor nodes; make those connections here
wire iready_from_coriolis_ker1_subker1;
wire iready_from_coriolis_ker0_0_un_b;
wire iready_from_un;
wire iready_from_coriolis_ker0_0_vn_b;
wire iready_from_vn;
wire iready_from_coriolis_ker1_subker0;
assign ready_y_b_23_s0 = 1'b1 & iready_from_coriolis_ker1_subker1;
assign ready_x_b_23_s0 = 1'b1 & iready_from_coriolis_ker1_subker0;
assign ready_un_local_s0 = 1'b1 & iready_from_coriolis_ker0_0_un_b& iready_from_coriolis_ker1_subker0;
assign ready_vn_local_b_22_s0 = 1'b1 & iready_from_vn;
assign ready_un_local_b_22_s0 = 1'b1 & iready_from_un;
assign ready_vn_local_s0 = 1'b1 & iready_from_coriolis_ker1_subker1& iready_from_coriolis_ker0_0_vn_b;
        

// Instantiations
kernel_top_coriolis_ker1_subker1 
kernel_top_coriolis_ker1_subker1_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .yn_s0  ( yn_s0 )
, .oready_yn_s0 (oready)
, .ovalid (ovalid_coriolis_ker1_subker1_s0)
, .vn_s0  (  vn_local_s0 )
, .ivalid_vn_s0 (valid_coriolis_ker0)
, .iready (iready_from_coriolis_ker1_subker1)
, .y_s0  (  y_b_23_s0 )
, .ivalid_y_s0 (valid_y_coriolis_ker1_subker1_2_b)
);

kernel_top_coriolis_ker0 
kernel_top_coriolis_ker0_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .vn_s0  ( vn_local_s0 )
, .ovalid (valid_coriolis_ker0)
, .oready_vn_s0 (ready_vn_local_s0) 
, .un_s0  ( un_local_s0 )
, .oready_un_s0 (ready_un_local_s0) 
, .u_s0  (  u_s0 )
, .ivalid_u_s0 (ivalid)
, .iready (iready_coriolis_ker0_s0)
, .v_s0  (  v_s0 )
, .ivalid_v_s0 (ivalid)
);

kernel_top_coriolis_ker0_0_un_b 
kernel_top_coriolis_ker0_0_un_b_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( un_local_b_22_s0 )
, .ovalid_out1_s0 (valid_coriolis_ker0_0_un_b)
, .oready_out1_s0 (ready_un_local_b_22_s0)
, .in1_s0  (  un_local_s0 )
, .ivalid_in1_s0 (valid_coriolis_ker0)
, .iready (iready_from_coriolis_ker0_0_un_b)
);

kernel_top_un 
kernel_top_un_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( un_s0)
, .ovalid (ovalid_un_s0)
, .oready (oready)
, .in1_s0  (  un_local_b_22_s0 )
, .ivalid_in1_s0 (valid_coriolis_ker0_0_un_b)
, .iready (iready_from_un)
);

kernel_top_coriolis_ker0_0_vn_b 
kernel_top_coriolis_ker0_0_vn_b_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( vn_local_b_22_s0 )
, .ovalid_out1_s0 (valid_coriolis_ker0_0_vn_b)
, .oready_out1_s0 (ready_vn_local_b_22_s0)
, .in1_s0  (  vn_local_s0 )
, .ivalid_in1_s0 (valid_coriolis_ker0)
, .iready (iready_from_coriolis_ker0_0_vn_b)
);

kernel_top_vn 
kernel_top_vn_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( vn_s0)
, .ovalid (ovalid_vn_s0)
, .oready (oready)
, .in1_s0  (  vn_local_b_22_s0 )
, .ivalid_in1_s0 (valid_coriolis_ker0_0_vn_b)
, .iready (iready_from_vn)
);

kernel_top_coriolis_ker1_subker0 
kernel_top_coriolis_ker1_subker0_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .xn_s0  ( xn_s0 )
, .oready_xn_s0 (oready)
, .ovalid (ovalid_coriolis_ker1_subker0_s0)
, .un_s0  (  un_local_s0 )
, .ivalid_un_s0 (valid_coriolis_ker0)
, .iready (iready_from_coriolis_ker1_subker0)
, .x_s0  (  x_b_23_s0 )
, .ivalid_x_s0 (valid_x_coriolis_ker1_subker0_1_b)
);

kernel_top_x_coriolis_ker1_subker0_1_b 
kernel_top_x_coriolis_ker1_subker0_1_b_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( x_b_23_s0 )
, .ovalid_out1_s0 (valid_x_coriolis_ker1_subker0_1_b)
, .oready_out1_s0 (ready_x_b_23_s0)
, .in1_s0  (  x_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_x_coriolis_ker1_subker0_1_b_s0)
);

kernel_top_y_coriolis_ker1_subker1_2_b 
kernel_top_y_coriolis_ker1_subker1_2_b_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1_s0  ( y_b_23_s0 )
, .ovalid_out1_s0 (valid_y_coriolis_ker1_subker1_2_b)
, .oready_out1_s0 (ready_y_b_23_s0)
, .in1_s0  (  y_s0 )
, .ivalid_in1_s0 (ivalid)
, .iready (iready_y_coriolis_ker1_subker1_2_b_s0)
);


endmodule 

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
// Generator TimeStamp  : Thu Dec 12 16:02:07 2019
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

module main_kernel_top
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
  , input ivalid_x
  , input ivalid_v
  , input ivalid_y
  , input ivalid_u

  , input oready_un
  , input oready_xn
  , input oready_vn
  , input oready_yn


, output [STREAMW-1:0]  un
, output [STREAMW-1:0]  xn
, output [STREAMW-1:0]  vn
, input [STREAMW-1:0]  x
, input [STREAMW-1:0]  v
, input [STREAMW-1:0]  y
, output [STREAMW-1:0]  yn
, input [STREAMW-1:0]  u  
);


// Data and control connection wires
wire ovalid_un_s0;
wire iready_un_s0;  
wire [SCALARW-1:0]  un_local_buff22_s0;
wire valid_un_local_buff22_s0;
wire ready_un_local_buff22_s0;
wire ovalid_coriolis_ker1_subker1_s0;
wire iready_coriolis_ker1_subker1_s0;  
wire [SCALARW-1:0]  y_buff23_s0;
wire valid_y_buff23_s0;
wire ready_y_buff23_s0;
wire [SCALARW-1:0]  vn_local_s0;
wire valid_coriolis_ker0_s0;
wire ready_vn_local_s0;
wire [SCALARW-1:0]  un_local_s0;
wire ready_un_local_s0;
wire iready_coriolis_ker0_s0;  
wire ovalid_vn_s0;
wire iready_vn_s0;  
wire [SCALARW-1:0]  vn_local_buff22_s0;
wire valid_vn_local_buff22_s0;
wire ready_vn_local_buff22_s0;
wire iready_y_buff23_s0;  
wire ovalid_coriolis_ker1_subker0_s0;
wire iready_coriolis_ker1_subker0_s0;  
wire [SCALARW-1:0]  x_buff23_s0;
wire valid_x_buff23_s0;
wire ready_x_buff23_s0;
wire iready_un_local_buff22_s0;  
wire iready_x_buff23_s0;  
wire iready_vn_local_buff22_s0;  

//And input valids  and output readys
assign ivalid = 1'b1
  & ivalid_x
  & ivalid_v
  & ivalid_y
  & ivalid_u
  ;
assign oready = 1'b1
  & oready_un
  & oready_xn
  & oready_vn
  & oready_yn
  ;

//glue logic for output control signals
assign ovalid = 
        ovalid_un_s0 &
        ovalid_coriolis_ker1_subker1_s0 &
        ovalid_vn_s0 &
        ovalid_coriolis_ker1_subker0_s0 & 
			  1'b1;
assign iready = 
        iready_coriolis_ker0_s0 &
        iready_y_buff23_s0 &
        iready_x_buff23_s0 & 
        oready & 
			  1'b1;

//single iready from a successor node may connect to multiple
//predecssor nodes; make those connections here
wire iready_from_un_s0;
wire iready_from_coriolis_ker1_subker1_s0;
wire iready_from_vn_s0;
wire iready_from_coriolis_ker1_subker0_s0;
wire iready_from_un_local_buff22_s0;
wire iready_from_vn_local_buff22_s0;
assign ready_un_local_buff22_s0 = 1'b1 & iready_from_un_s0;
assign ready_x_buff23_s0 = 1'b1 & iready_from_coriolis_ker1_subker0_s0;
assign ready_vn_local_buff22_s0 = 1'b1 & iready_from_vn_s0;
assign ready_y_buff23_s0 = 1'b1 & iready_from_coriolis_ker1_subker1_s0;
assign ready_un_local_s0 = 1'b1 & iready_from_coriolis_ker1_subker0_s0& iready_from_un_local_buff22_s0;
assign ready_vn_local_s0 = 1'b1 & iready_from_vn_local_buff22_s0& iready_from_coriolis_ker1_subker1_s0;
        

// Instantiations
kernel_top_un 
kernel_top_un_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1  ( un[33:0])
, .ovalid (ovalid_un_s0)
, .oready (oready)
, .in1 (un_local_buff22_s0)
, .ivalid_in1 (valid_un_local_buff22_s0)
, .iready (iready_from_un_s0)
);

kernel_top_coriolis_ker1_subker1 
kernel_top_coriolis_ker1_subker1_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .yn ( yn[33:0] )
, .ovalid (ovalid_coriolis_ker1_subker1_s0)
, .oready_yn (oready)
, .y (y_buff23_s0)
, .ivalid_y (valid_y_buff23_s0)
, .iready (iready_from_coriolis_ker1_subker1_s0)
, .vn (vn_local_s0)
, .ivalid_vn (valid_coriolis_ker0_s0)
);

kernel_top_coriolis_ker0 
kernel_top_coriolis_ker0_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .un ( un_local_s0 )
, .ovalid (valid_coriolis_ker0_s0)
, .oready_un (ready_un_local_s0)
, .vn ( vn_local_s0 )
, .oready_vn (ready_vn_local_s0)
, .u (u[33:0])
, .ivalid_u (ivalid)
, .iready (iready_coriolis_ker0_s0)
, .v (v[33:0])
, .ivalid_v (ivalid)
);

kernel_top_vn 
kernel_top_vn_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1  ( vn[33:0])
, .ovalid (ovalid_vn_s0)
, .oready (oready)
, .in1 (vn_local_buff22_s0)
, .ivalid_in1 (valid_vn_local_buff22_s0)
, .iready (iready_from_vn_s0)
);

kernel_top_y_buff23 
kernel_top_y_buff23_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1 ( y_buff23_s0 )
, .ovalid_out1 (valid_y_buff23_s0)
, .oready_out1 (ready_y_buff23_s0)
, .in1 (y[33:0])
, .ivalid_in1 (ivalid)
, .iready (iready_y_buff23_s0)
);

kernel_top_coriolis_ker1_subker0 
kernel_top_coriolis_ker1_subker0_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .xn ( xn[33:0] )
, .ovalid (ovalid_coriolis_ker1_subker0_s0)
, .oready_xn (oready)
, .un (un_local_s0)
, .ivalid_un (valid_coriolis_ker0_s0)
, .iready (iready_from_coriolis_ker1_subker0_s0)
, .x (x_buff23_s0)
, .ivalid_x (valid_x_buff23_s0)
);

kernel_top_un_local_buff22 
kernel_top_un_local_buff22_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1 ( un_local_buff22_s0 )
, .ovalid_out1 (valid_un_local_buff22_s0)
, .oready_out1 (ready_un_local_buff22_s0)
, .in1 (un_local_s0)
, .ivalid_in1 (valid_coriolis_ker0_s0)
, .iready (iready_from_un_local_buff22_s0)
);

kernel_top_x_buff23 
kernel_top_x_buff23_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1 ( x_buff23_s0 )
, .ovalid_out1 (valid_x_buff23_s0)
, .oready_out1 (ready_x_buff23_s0)
, .in1 (x[33:0])
, .ivalid_in1 (ivalid)
, .iready (iready_x_buff23_s0)
);

kernel_top_vn_local_buff22 
kernel_top_vn_local_buff22_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .out1 ( vn_local_buff22_s0 )
, .ovalid_out1 (valid_vn_local_buff22_s0)
, .oready_out1 (ready_vn_local_buff22_s0)
, .in1 (vn_local_s0)
, .ivalid_in1 (valid_coriolis_ker0_s0)
, .iready (iready_from_vn_local_buff22_s0)
);


endmodule 

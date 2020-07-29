// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: main 
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
// template for main (top-level synthesized module)
// (TyBEC)
//
//============================================================================= 

module main
#(  
  parameter STREAMW     = 32
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input  clk   
  , input  rst   	
  , output iready 
  , input  ivalid 
  , output ovalid 
  , input  oready 


  , output [STREAMW-1:0]  vn_stream
  , input [STREAMW-1:0]  y_stream
  , output [STREAMW-1:0]  un_stream
  , input [STREAMW-1:0]  u_stream
  , input [STREAMW-1:0]  v_stream
  , output [STREAMW-1:0]  xn_stream
  , input [STREAMW-1:0]  x_stream
  , output [STREAMW-1:0]  yn_stream
);

// ============================================================================
// ** Instantiations
// ============================================================================


// Data and control connection wires
wire ovalid_kernel_top_s0;
wire iready_kernel_top_s0;  
wire ovalid_kernel_top_s1;
wire iready_kernel_top_s1;  

//glue logic for output control signals
assign ovalid = 
        ovalid_kernel_top_s0 &
        ovalid_kernel_top_s1 & 
			  1'b1;
assign iready = 
        iready_kernel_top_s0 &
        iready_kernel_top_s1 & 
			  1'b1;

//Exception fields for flopoco                                         
//A 2-bit exception field                                              
//00 for zero, 01 for normal numbers, 10 for infinities, and 11 for NaN
wire [1:0] fpcEF = 2'b01;                                              
        

// if input data to kernel_top module is flopoco floats (with 2 control bits)
// those two bits will be appended here during instantiation

//if output data from kernel_top module is flopoco floats (with 2 control bits)
//they will be connected to narrower data signals here, so as to truncate the top-most 
//2 bits
    

// Instantiations
main_kernel_top 
main_kernel_top_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .yn_s0  ( yn_stream[31:0] )
, .oready_yn_s0 (oready)
, .ovalid (ovalid_kernel_top_s0)
, .vn_s0  ( vn_stream[31:0] )
, .oready_vn_s0 (oready)
, .un_s0  ( un_stream[31:0] )
, .oready_un_s0 (oready)
, .xn_s0  ( xn_stream[31:0] )
, .oready_xn_s0 (oready)
, .y_s0  ( {fpcEF, y_stream[31:0] })
, .ivalid_y_s0 (ivalid)
, .iready (iready_kernel_top_s0)
, .x_s0  ( {fpcEF, x_stream[31:0] })
, .ivalid_x_s0 (ivalid)
, .v_s0  ( {fpcEF, v_stream[31:0] })
, .ivalid_v_s0 (ivalid)
, .u_s0  ( {fpcEF, u_stream[31:0] })
, .ivalid_u_s0 (ivalid)
);

main_kernel_top 
main_kernel_top_i_s1 (
  .clk    (clk)
, .rst    (rst)
, .yn_s0  ( yn_stream[63:32] )
, .oready_yn_s0 (oready)
, .ovalid (ovalid_kernel_top_s1)
, .vn_s0  ( vn_stream[63:32] )
, .oready_vn_s0 (oready)
, .un_s0  ( un_stream[63:32] )
, .oready_un_s0 (oready)
, .xn_s0  ( xn_stream[63:32] )
, .oready_xn_s0 (oready)
, .y_s0  ( {fpcEF, y_stream[63:32] })
, .ivalid_y_s0 (ivalid)
, .iready (iready_kernel_top_s1)
, .x_s0  ( {fpcEF, x_stream[63:32] })
, .ivalid_x_s0 (ivalid)
, .v_s0  ( {fpcEF, v_stream[63:32] })
, .ivalid_v_s0 (ivalid)
, .u_s0  ( {fpcEF, u_stream[63:32] })
, .ivalid_u_s0 (ivalid)
);



endmodule 
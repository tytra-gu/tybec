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
// Generator TimeStamp  : Thu Dec 19 17:56:07 2019
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


  , output [STREAMW-1:0]  un_stream
  , output [STREAMW-1:0]  vn_stream
  , input [STREAMW-1:0]  u_stream
  , output [STREAMW-1:0]  xn_stream
  , input [STREAMW-1:0]  x_stream
  , output [STREAMW-1:0]  yn_stream
  , input [STREAMW-1:0]  y_stream
  , input [STREAMW-1:0]  v_stream
);

// ============================================================================
// ** Instantiations
// ============================================================================


// Data and control connection wires
wire ovalid_kernel_top;
wire iready_kernel_top;  

//glue logic for output control signals
assign ovalid = 
        ovalid_kernel_top & 
			  1'b1;
assign iready = 
        iready_kernel_top & 
			  1'b1;

        

// if input data to kernel_top module is flopoco floats (with 2 control bits)
// those two bits will be appended here during instantiation

//if output data from kernel_top module is flopoco floats (with 2 control bits)
//we need to extract data.
//if vector words, then we create local wires for connecting to child, 
//and then extract data bits from it to connect to ports

    

// Instantiations
main_kernel_top 
main_kernel_top_i (
  .clk    (clk)
, .rst    (rst)
, .yn ( yn_stream )
, .ovalid (ovalid_kernel_top)
, .oready_yn (oready)
, .vn ( vn_stream )
, .oready_vn (oready)
, .un ( un_stream )
, .oready_un (oready)
, .xn ( xn_stream )
, .oready_xn (oready)
, .y (y_stream)
, .ivalid_y (ivalid)
, .iready (iready_kernel_top)
, .x (x_stream)
, .ivalid_x (ivalid)
, .v (v_stream)
, .ivalid_v (ivalid)
, .u (u_stream)
, .ivalid_u (ivalid)
);



endmodule 
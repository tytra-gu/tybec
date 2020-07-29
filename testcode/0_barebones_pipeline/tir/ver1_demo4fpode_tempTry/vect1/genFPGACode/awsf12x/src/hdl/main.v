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
// Generator TimeStamp  : Sun Nov  4 13:19:03 2018
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
  parameter STREAMW   = 32
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


  , input [STREAMW-1:0] vin0_stream_load
  , output [STREAMW-1:0] vout_stream_store
  , input [STREAMW-1:0] vin1_stream_load
);
// ============================================================================
// ** Instantiations
// ============================================================================


// Data and control connection wires
wire ovalid_s0;
wire iready_s0;

//glue logic for output control signals
assign ovalid = 
        ovalid_s0 & 
			  1'b1;
assign iready = 
        iready_s0 & 
			  1'b1;


// Instantiations
main_kernelTop 
main_kernelTop_i_s0 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[31:0])
, .ovalid (ovalid_s0)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[31:0])
, .ivalid (ivalid)
, .iready (iready_s0)
, .kt_vin0_s0  (vin0_stream_load[31:0])
);



endmodule 
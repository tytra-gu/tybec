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
// Generator TimeStamp  : Thu Feb 15 18:26:47 2018
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
// Note that the OVALID logic does not propagate IVALID(~STALL) through the 
// kernel pipeline latency. It simply follows IVALID with one cycle delay
// so that we can deal with asynchronous STALLS of the testbench/OCL-shell.
// SO: in the TB, data is valid ONLY when OVALID *and* the lincount indicates
// we have waited long enough for the kernel latency to pass. 
//============================================================================= 

module main
#(  
   parameter DATAW     = 32
  ,parameter LAT       = 5

)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input   clk   
  , input   rst   	
  , input   stall
  , output  ovalid          
  
  , input [DATAW-1:0] vin1_stream_load
  , output [DATAW-1:0] vout_stream_store
  , input [DATAW-1:0] vin0_stream_load
);
// ============================================================================
// ** Instantiations
// ============================================================================



main_kernelTop 
main_kernelTop_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .kt_vout  (vout_stream_store)
, .kt_vin1  (vin1_stream_load)
, .kt_vin0  (vin0_stream_load)
);


// ============================================================================
// ** ovalid
// ============================================================================
wire            ivalid          = !stall;
reg             ivalid_r;

//one cycle delayed ivalid used to negate ovalid 
//(in case we have a stall)
always @(posedge clk)
  if(rst)
    ivalid_r <= 0;
  else
    ivalid_r <= ivalid;

assign ovalid    = ivalid_r;

endmodule 
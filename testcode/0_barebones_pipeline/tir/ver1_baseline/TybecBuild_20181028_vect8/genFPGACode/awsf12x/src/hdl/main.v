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
// Generator TimeStamp  : Mon Oct 29 18:32:29 2018
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


  , input [STREAMW-1:0] vin1_stream_load
  , input [STREAMW-1:0] vin0_stream_load
  , output [STREAMW-1:0] vout_stream_store
);
// ============================================================================
// ** Instantiations
// ============================================================================


// Data and control connection wires
wire ovalid_s0;
wire iready_s0;
wire ovalid_s1;
wire iready_s1;
wire ovalid_s2;
wire iready_s2;
wire ovalid_s3;
wire iready_s3;
wire ovalid_s4;
wire iready_s4;
wire ovalid_s5;
wire iready_s5;
wire ovalid_s6;
wire iready_s6;
wire ovalid_s7;
wire iready_s7;

//glue logic for output control signals
assign ovalid = 
        ovalid_s0 &
        ovalid_s1 &
        ovalid_s2 &
        ovalid_s3 &
        ovalid_s4 &
        ovalid_s5 &
        ovalid_s6 &
        ovalid_s7 & 
			  1'b1;
assign iready = 
        iready_s0 &
        iready_s1 &
        iready_s2 &
        iready_s3 &
        iready_s4 &
        iready_s5 &
        iready_s6 &
        iready_s7 & 
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

main_kernelTop 
main_kernelTop_i_s1 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[63:32])
, .ovalid (ovalid_s1)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[63:32])
, .ivalid (ivalid)
, .iready (iready_s1)
, .kt_vin0_s0  (vin0_stream_load[63:32])
);

main_kernelTop 
main_kernelTop_i_s2 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[95:64])
, .ovalid (ovalid_s2)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[95:64])
, .ivalid (ivalid)
, .iready (iready_s2)
, .kt_vin0_s0  (vin0_stream_load[95:64])
);

main_kernelTop 
main_kernelTop_i_s3 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[127:96])
, .ovalid (ovalid_s3)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[127:96])
, .ivalid (ivalid)
, .iready (iready_s3)
, .kt_vin0_s0  (vin0_stream_load[127:96])
);

main_kernelTop 
main_kernelTop_i_s4 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[159:128])
, .ovalid (ovalid_s4)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[159:128])
, .ivalid (ivalid)
, .iready (iready_s4)
, .kt_vin0_s0  (vin0_stream_load[159:128])
);

main_kernelTop 
main_kernelTop_i_s5 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[191:160])
, .ovalid (ovalid_s5)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[191:160])
, .ivalid (ivalid)
, .iready (iready_s5)
, .kt_vin0_s0  (vin0_stream_load[191:160])
);

main_kernelTop 
main_kernelTop_i_s6 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[223:192])
, .ovalid (ovalid_s6)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[223:192])
, .ivalid (ivalid)
, .iready (iready_s6)
, .kt_vin0_s0  (vin0_stream_load[223:192])
);

main_kernelTop 
main_kernelTop_i_s7 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[255:224])
, .ovalid (ovalid_s7)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[255:224])
, .ivalid (ivalid)
, .iready (iready_s7)
, .kt_vin0_s0  (vin0_stream_load[255:224])
);



endmodule 
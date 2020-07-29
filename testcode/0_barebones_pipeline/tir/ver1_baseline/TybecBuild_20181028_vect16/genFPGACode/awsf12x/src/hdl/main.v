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
// Generator TimeStamp  : Mon Oct 29 18:32:39 2018
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
  , output [STREAMW-1:0] vout_stream_store
  , input [STREAMW-1:0] vin0_stream_load
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
wire ovalid_s8;
wire iready_s8;
wire ovalid_s9;
wire iready_s9;
wire ovalid_s10;
wire iready_s10;
wire ovalid_s11;
wire iready_s11;
wire ovalid_s12;
wire iready_s12;
wire ovalid_s13;
wire iready_s13;
wire ovalid_s14;
wire iready_s14;
wire ovalid_s15;
wire iready_s15;

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
        ovalid_s8 &
        ovalid_s9 &
        ovalid_s10 &
        ovalid_s11 &
        ovalid_s12 &
        ovalid_s13 &
        ovalid_s14 &
        ovalid_s15 & 
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
        iready_s8 &
        iready_s9 &
        iready_s10 &
        iready_s11 &
        iready_s12 &
        iready_s13 &
        iready_s14 &
        iready_s15 & 
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

main_kernelTop 
main_kernelTop_i_s8 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[287:256])
, .ovalid (ovalid_s8)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[287:256])
, .ivalid (ivalid)
, .iready (iready_s8)
, .kt_vin0_s0  (vin0_stream_load[287:256])
);

main_kernelTop 
main_kernelTop_i_s9 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[319:288])
, .ovalid (ovalid_s9)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[319:288])
, .ivalid (ivalid)
, .iready (iready_s9)
, .kt_vin0_s0  (vin0_stream_load[319:288])
);

main_kernelTop 
main_kernelTop_i_s10 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[351:320])
, .ovalid (ovalid_s10)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[351:320])
, .ivalid (ivalid)
, .iready (iready_s10)
, .kt_vin0_s0  (vin0_stream_load[351:320])
);

main_kernelTop 
main_kernelTop_i_s11 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[383:352])
, .ovalid (ovalid_s11)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[383:352])
, .ivalid (ivalid)
, .iready (iready_s11)
, .kt_vin0_s0  (vin0_stream_load[383:352])
);

main_kernelTop 
main_kernelTop_i_s12 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[415:384])
, .ovalid (ovalid_s12)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[415:384])
, .ivalid (ivalid)
, .iready (iready_s12)
, .kt_vin0_s0  (vin0_stream_load[415:384])
);

main_kernelTop 
main_kernelTop_i_s13 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[447:416])
, .ovalid (ovalid_s13)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[447:416])
, .ivalid (ivalid)
, .iready (iready_s13)
, .kt_vin0_s0  (vin0_stream_load[447:416])
);

main_kernelTop 
main_kernelTop_i_s14 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[479:448])
, .ovalid (ovalid_s14)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[479:448])
, .ivalid (ivalid)
, .iready (iready_s14)
, .kt_vin0_s0  (vin0_stream_load[479:448])
);

main_kernelTop 
main_kernelTop_i_s15 (
  .clk    (clk)
, .rst    (rst)
, .kt_vout_s0  (vout_stream_store[511:480])
, .ovalid (ovalid_s15)
, .oready (oready)
, .kt_vin1_s0  (vin1_stream_load[511:480])
, .ivalid (ivalid)
, .iready (iready_s15)
, .kt_vin0_s0  (vin0_stream_load[511:480])
);



endmodule 
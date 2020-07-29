// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_top_coriolis_ker0_0_vn_b 
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
// Template for axi4 stream compatible buffer used in TyBEC synchronize parallel
// paths with mismatched latencies. 
// Can be used to generate buffer with multiple "taps" for the same data
// ============================================================================= 

module kernel_top_coriolis_ker0_0_vn_b
#(  
    parameter STREAMW = 34
  , parameter SIZE    = 23
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                     clk   
  , input                     rst   	
  , output                    iready
  , input                     ivalid_in1_s0
  , input      [STREAMW-1:0]  in1_s0
  
  , output                    ovalid_out1_s0

  , input                     oready_out1_s0

  , output     [STREAMW-1:0]  out1_s0 // at delay = 23 

);

//shift register bank for data, and ovalid(s)
reg [STREAMW-1:0] offsetRegBank [0:SIZE-1];   
reg               valid_shifter [0:SIZE-1];   

//local oready only asserted when *all* outputs are ready
assign oready = 1'b1
  & oready_out1_s0
  ;

//iready when all oready's asserted
assign iready = oready;
              
//tap at relevant delays
//the valid shifter takes care of the initial latency of filling up the buffer
//if ivalid is negated anytime during operation, we simply freeze the stream buffer
//so the valid shifter never gets a "0" in there (and the data shift register never reads 
//invalid data). This contiguity of *valid* data ensures that data of a certain "offset" is 
//always available at a fixed location

assign ovalid_out1_s0 = valid_shifter[23-1] & ivalid_in1_s0;

assign out1_s0 = offsetRegBank[23-1]; // at delay = 23 

//SHIFT write

always @(posedge clk) begin 
  if(ivalid_in1_s0) begin
    offsetRegBank[0]  <=  in1_s0; 
    valid_shifter[0]  <=  ivalid_in1_s0;
    offsetRegBank[1]  <=  offsetRegBank[1-1];
    valid_shifter[1]  <=  valid_shifter[1-1];
    offsetRegBank[2]  <=  offsetRegBank[2-1];
    valid_shifter[2]  <=  valid_shifter[2-1];
    offsetRegBank[3]  <=  offsetRegBank[3-1];
    valid_shifter[3]  <=  valid_shifter[3-1];
    offsetRegBank[4]  <=  offsetRegBank[4-1];
    valid_shifter[4]  <=  valid_shifter[4-1];
    offsetRegBank[5]  <=  offsetRegBank[5-1];
    valid_shifter[5]  <=  valid_shifter[5-1];
    offsetRegBank[6]  <=  offsetRegBank[6-1];
    valid_shifter[6]  <=  valid_shifter[6-1];
    offsetRegBank[7]  <=  offsetRegBank[7-1];
    valid_shifter[7]  <=  valid_shifter[7-1];
    offsetRegBank[8]  <=  offsetRegBank[8-1];
    valid_shifter[8]  <=  valid_shifter[8-1];
    offsetRegBank[9]  <=  offsetRegBank[9-1];
    valid_shifter[9]  <=  valid_shifter[9-1];
    offsetRegBank[10]  <=  offsetRegBank[10-1];
    valid_shifter[10]  <=  valid_shifter[10-1];
    offsetRegBank[11]  <=  offsetRegBank[11-1];
    valid_shifter[11]  <=  valid_shifter[11-1];
    offsetRegBank[12]  <=  offsetRegBank[12-1];
    valid_shifter[12]  <=  valid_shifter[12-1];
    offsetRegBank[13]  <=  offsetRegBank[13-1];
    valid_shifter[13]  <=  valid_shifter[13-1];
    offsetRegBank[14]  <=  offsetRegBank[14-1];
    valid_shifter[14]  <=  valid_shifter[14-1];
    offsetRegBank[15]  <=  offsetRegBank[15-1];
    valid_shifter[15]  <=  valid_shifter[15-1];
    offsetRegBank[16]  <=  offsetRegBank[16-1];
    valid_shifter[16]  <=  valid_shifter[16-1];
    offsetRegBank[17]  <=  offsetRegBank[17-1];
    valid_shifter[17]  <=  valid_shifter[17-1];
    offsetRegBank[18]  <=  offsetRegBank[18-1];
    valid_shifter[18]  <=  valid_shifter[18-1];
    offsetRegBank[19]  <=  offsetRegBank[19-1];
    valid_shifter[19]  <=  valid_shifter[19-1];
    offsetRegBank[20]  <=  offsetRegBank[20-1];
    valid_shifter[20]  <=  valid_shifter[20-1];
    offsetRegBank[21]  <=  offsetRegBank[21-1];
    valid_shifter[21]  <=  valid_shifter[21-1];
    offsetRegBank[22]  <=  offsetRegBank[22-1];
    valid_shifter[22]  <=  valid_shifter[22-1];

  end else begin
    offsetRegBank[0]  <=  offsetRegBank[0];
    valid_shifter[0]  <=  valid_shifter[0];
    offsetRegBank[1]  <=  offsetRegBank[1];
    valid_shifter[1]  <=  valid_shifter[1];
    offsetRegBank[2]  <=  offsetRegBank[2];
    valid_shifter[2]  <=  valid_shifter[2];
    offsetRegBank[3]  <=  offsetRegBank[3];
    valid_shifter[3]  <=  valid_shifter[3];
    offsetRegBank[4]  <=  offsetRegBank[4];
    valid_shifter[4]  <=  valid_shifter[4];
    offsetRegBank[5]  <=  offsetRegBank[5];
    valid_shifter[5]  <=  valid_shifter[5];
    offsetRegBank[6]  <=  offsetRegBank[6];
    valid_shifter[6]  <=  valid_shifter[6];
    offsetRegBank[7]  <=  offsetRegBank[7];
    valid_shifter[7]  <=  valid_shifter[7];
    offsetRegBank[8]  <=  offsetRegBank[8];
    valid_shifter[8]  <=  valid_shifter[8];
    offsetRegBank[9]  <=  offsetRegBank[9];
    valid_shifter[9]  <=  valid_shifter[9];
    offsetRegBank[10]  <=  offsetRegBank[10];
    valid_shifter[10]  <=  valid_shifter[10];
    offsetRegBank[11]  <=  offsetRegBank[11];
    valid_shifter[11]  <=  valid_shifter[11];
    offsetRegBank[12]  <=  offsetRegBank[12];
    valid_shifter[12]  <=  valid_shifter[12];
    offsetRegBank[13]  <=  offsetRegBank[13];
    valid_shifter[13]  <=  valid_shifter[13];
    offsetRegBank[14]  <=  offsetRegBank[14];
    valid_shifter[14]  <=  valid_shifter[14];
    offsetRegBank[15]  <=  offsetRegBank[15];
    valid_shifter[15]  <=  valid_shifter[15];
    offsetRegBank[16]  <=  offsetRegBank[16];
    valid_shifter[16]  <=  valid_shifter[16];
    offsetRegBank[17]  <=  offsetRegBank[17];
    valid_shifter[17]  <=  valid_shifter[17];
    offsetRegBank[18]  <=  offsetRegBank[18];
    valid_shifter[18]  <=  valid_shifter[18];
    offsetRegBank[19]  <=  offsetRegBank[19];
    valid_shifter[19]  <=  valid_shifter[19];
    offsetRegBank[20]  <=  offsetRegBank[20];
    valid_shifter[20]  <=  valid_shifter[20];
    offsetRegBank[21]  <=  offsetRegBank[21];
    valid_shifter[21]  <=  valid_shifter[21];
    offsetRegBank[22]  <=  offsetRegBank[22];
    valid_shifter[22]  <=  valid_shifter[22];

  end
end

endmodule 
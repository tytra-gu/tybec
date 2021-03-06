// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_top_y_buff23 
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
// Template for axi4 stream compatible buffer used in TyBEC synchronize parallel
// paths with mismatched latencies. 
// Can be used to generate buffer with multiple "taps" for the same data
// ============================================================================= 

module kernel_top_y_buff23
#(  
    parameter STREAMW = 34
  , parameter SIZE    = 24
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                     clk   
  , input                     rst   	
  , output                    iready
  , input                     ivalid_in1
  , input      [STREAMW-1:0]  in1
  
  , output                    ovalid_out1

  , input                     oready_out1

  , output     [STREAMW-1:0]  out1 // at delay = 24 

);

//shift register bank for data, and ovalid(s)
reg [STREAMW-1:0] offsetRegBank [0:SIZE-1];   
reg               valid_shifter [0:SIZE-1];   

//local oready only asserted when *all* outputs are ready
assign oready = 1'b1
  & oready_out1
  ;

//iready when all oready's asserted
assign iready = oready;
              
//tap at relevant delays
//the valid shifter takes care of the initial latency of filling up the buffer
//if ivalid is negated anytime during operation, we simply freeze the stream buffer
//so the valid shifter never gets a "0" in there (and the data shift register never reads 
//invalid data). This contiguity of *valid* data ensures that data of a certain "offset" is 
//always available at a fixed location

assign ovalid_out1 = valid_shifter[24-1] & ivalid_in1;

assign out1 = offsetRegBank[24-1]; // at delay = 24 

//SHIFT write

always @(posedge clk) begin 
  if (rst) begin
    offsetRegBank[0]  <=  32'b0;
    valid_shifter[0]  <=  1'b0;
    offsetRegBank[1]  <=  32'b0;
    valid_shifter[1]  <=  1'b0;
    offsetRegBank[2]  <=  32'b0;
    valid_shifter[2]  <=  1'b0;
    offsetRegBank[3]  <=  32'b0;
    valid_shifter[3]  <=  1'b0;
    offsetRegBank[4]  <=  32'b0;
    valid_shifter[4]  <=  1'b0;
    offsetRegBank[5]  <=  32'b0;
    valid_shifter[5]  <=  1'b0;
    offsetRegBank[6]  <=  32'b0;
    valid_shifter[6]  <=  1'b0;
    offsetRegBank[7]  <=  32'b0;
    valid_shifter[7]  <=  1'b0;
    offsetRegBank[8]  <=  32'b0;
    valid_shifter[8]  <=  1'b0;
    offsetRegBank[9]  <=  32'b0;
    valid_shifter[9]  <=  1'b0;
    offsetRegBank[10]  <=  32'b0;
    valid_shifter[10]  <=  1'b0;
    offsetRegBank[11]  <=  32'b0;
    valid_shifter[11]  <=  1'b0;
    offsetRegBank[12]  <=  32'b0;
    valid_shifter[12]  <=  1'b0;
    offsetRegBank[13]  <=  32'b0;
    valid_shifter[13]  <=  1'b0;
    offsetRegBank[14]  <=  32'b0;
    valid_shifter[14]  <=  1'b0;
    offsetRegBank[15]  <=  32'b0;
    valid_shifter[15]  <=  1'b0;
    offsetRegBank[16]  <=  32'b0;
    valid_shifter[16]  <=  1'b0;
    offsetRegBank[17]  <=  32'b0;
    valid_shifter[17]  <=  1'b0;
    offsetRegBank[18]  <=  32'b0;
    valid_shifter[18]  <=  1'b0;
    offsetRegBank[19]  <=  32'b0;
    valid_shifter[19]  <=  1'b0;
    offsetRegBank[20]  <=  32'b0;
    valid_shifter[20]  <=  1'b0;
    offsetRegBank[21]  <=  32'b0;
    valid_shifter[21]  <=  1'b0;
    offsetRegBank[22]  <=  32'b0;
    valid_shifter[22]  <=  1'b0;
    offsetRegBank[23]  <=  32'b0;
    valid_shifter[23]  <=  1'b0;
 
  end
  else if (ivalid_in1) begin
    offsetRegBank[0]  <=  in1; 
    valid_shifter[0]  <=  ivalid_in1;
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
    offsetRegBank[23]  <=  offsetRegBank[23-1];
    valid_shifter[23]  <=  valid_shifter[23-1];

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
    offsetRegBank[23]  <=  offsetRegBank[23];
    valid_shifter[23]  <=  valid_shifter[23];

  end
end

endmodule 
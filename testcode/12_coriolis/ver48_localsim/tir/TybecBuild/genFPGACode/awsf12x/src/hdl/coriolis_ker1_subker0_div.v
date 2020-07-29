// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: coriolis_ker1_subker0_div 
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
// A generic module template for leaf map nodes for use by Tytra Back-End Compile
// (TyBEC)
//
// ============================================================================= 

module coriolis_ker1_subker0_div
#(  
   parameter STREAMW   = 34
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                     clk   
  , input                     rst   	
  , output                    ovalid 
  , output     [STREAMW-1:0]    out1
  , input                     oready     
  //, output                    iready
  , output                   iready
//<inputReadys> <-- deprecated
  , input ivalid_in1

  , input      [34-1:0]  in1

);

//if FP, then I need to attend this constant 2 bits for flopoco units
wire [1:0] fpcEF = 2'b01;


//registered inputs
reg [34-1:0] in1_r;


//And input valids  and output readys
assign ivalid = ivalid_in1 &  1'b1;


//If any input operands are constants, assign them their value here
wire [STREAMW-1:0] in2_r = {fpcEF, 32'h447a0000 };

//dont stall if input valid and slave ready
wire dontStall = ivalid & oready;

//perform datapath operation, or instantiate module
//--------------------------------------------------
FPDiv_8_23_F500_uid2  fpDiv
  ( .clk (clk)     
  , .rst (rst)     
  , .stall (~dontStall)     
  , .X   (in1_r)     
  , .Y   (in2_r)     
  , .R   (out1)
);

//if output is ready (and no locally generated stall), I am ready
assign iready = oready;

//registered input
//-----------------
always @(posedge clk) begin
  if(rst) begin
    in1_r <= 0;
  end  
  else if (dontStall) begin
    in1_r <= in1;
  end
  else begin
    in1_r <= in1_r;
  end  
end

//ovalid logic
//-----------------
//output valid
//follows ivalid with an N-cycle delay (latency of this unit)
//Also, only asserted with no back-pressure (oready asserted)
reg [13-1:0] valid_shifter;
always @(posedge clk) begin
  if(ivalid) begin
    valid_shifter[0] <= ivalid;
    valid_shifter[1]  <=  valid_shifter[1-1];
    valid_shifter[2]  <=  valid_shifter[2-1];
    valid_shifter[3]  <=  valid_shifter[3-1];
    valid_shifter[4]  <=  valid_shifter[4-1];
    valid_shifter[5]  <=  valid_shifter[5-1];
    valid_shifter[6]  <=  valid_shifter[6-1];
    valid_shifter[7]  <=  valid_shifter[7-1];
    valid_shifter[8]  <=  valid_shifter[8-1];
    valid_shifter[9]  <=  valid_shifter[9-1];
    valid_shifter[10]  <=  valid_shifter[10-1];
    valid_shifter[11]  <=  valid_shifter[11-1];
    valid_shifter[12]  <=  valid_shifter[12-1];
  end
  else begin
    valid_shifter[0]  <=  valid_shifter[0];
    valid_shifter[1]  <=  valid_shifter[1];
    valid_shifter[2]  <=  valid_shifter[2];
    valid_shifter[3]  <=  valid_shifter[3];
    valid_shifter[4]  <=  valid_shifter[4];
    valid_shifter[5]  <=  valid_shifter[5];
    valid_shifter[6]  <=  valid_shifter[6];
    valid_shifter[7]  <=  valid_shifter[7];
    valid_shifter[8]  <=  valid_shifter[8];
    valid_shifter[9]  <=  valid_shifter[9];
    valid_shifter[10]  <=  valid_shifter[10];
    valid_shifter[11]  <=  valid_shifter[11];
    valid_shifter[12]  <=  valid_shifter[12];
  end //else
end //always

assign ovalid = valid_shifter[13-1] & oready;


endmodule 
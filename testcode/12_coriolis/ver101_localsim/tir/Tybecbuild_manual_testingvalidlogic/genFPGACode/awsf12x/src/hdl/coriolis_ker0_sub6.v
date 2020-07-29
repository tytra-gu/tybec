// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: coriolis_ker0_sub6 
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
// A generic module template for leaf map nodes for use by Tytra Back-End Compile
// (TyBEC)
//
// ============================================================================= 

module coriolis_ker0_sub6
#(  
   parameter STREAMW   = 32
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
  , input ivalid_in2

  , input      [32-1:0]  in1
  , input      [32-1:0]  in2

);

//if FP, then I need to attend this constant 2 bits for flopoco units


//registered inputs
reg [32-1:0] in1_r;
reg [32-1:0] in2_r;


//And input valids  and output readys
assign ivalid = ivalid_in1 & ivalid_in2 &  1'b1;


//If any input operands are constants, assign them their value here


//dont stall if input valid and slave ready
wire dontStall = ivalid & oready;

//perform datapath operation, or instantiate module
//--------------------------------------------------

assign out1 = in1_r - in2_r;

//if output is ready (and no locally generated stall), I am ready
assign iready = oready;

//registered input
//-----------------
always @(posedge clk) begin
  if(rst) begin
    in1_r <= 0;
    in2_r <= 0;
  end  
  else if (dontStall) begin
    in1_r <= in1;
    in2_r <= in2;
  end
  else begin
    in1_r <= in1_r;
    in2_r <= in2_r;
  end  
end

//ovalid logic
//-----------------
//output valid
//follows ivalid with an N-cycle delay (latency of this unit)
//Also, only asserted with no back-pressure (oready asserted)
reg ovalid_pre;
always @(posedge clk) begin
  if(rst)
    ovalid_pre <= 0;
//When stalled, SAVE the ovalid, so that pipeline continues without having to reload
  else if (~dontStall)
    ovalid_pre <= ovalid_pre;
  else
    ovalid_pre <= ivalid & oready;
end
//response to dontStall needs to be immediate, as I want to _halt_ the pipeline when there is a stall

assign ovalid = ovalid_pre & dontStall;


endmodule 
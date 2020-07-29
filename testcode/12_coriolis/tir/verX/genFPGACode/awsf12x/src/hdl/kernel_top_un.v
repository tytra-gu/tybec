// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_top_un 
// Generator Version    : R17.0
// Generator TimeStamp  : Thu Jul 25 11:54:14 2019
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

module kernel_top_un
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
  , output reg [STREAMW-1:0]    out1_s0
  , input                     oready     
  , output                    iready
//<inputReadys> <-- deprecated
  , input ivalid_in1_s0

  , input      [STREAMW-1:0]  in1_s0


);

//if FP, then I need to attend this constant 2 bits for flopoco units


//unregistered output
wire [STREAMW-1:0] out1_pre_s0;

//And input valids  and output readys
assign ivalid = ivalid_in1_s0 &  1'b1;


//If any input operands are constants, assign them their value here


//dont stall if input valid and slave ready
wire dontStall = ivalid & oready;

//perform datapath operation, or instantiate module

assign out1_pre_s0 = in1_s0;

//if I'm not stalling, I am ready
//assign iready = dontStall;

//if output is ready (and no locally generated stall), I am ready
//assign iready = oready & local_stall;
assign iready = oready;

//fanout iready to all inputs <-- deprecated
//

//registered output
always @(posedge clk) begin
  if(rst)
    out1_s0 <= 0;
  else if (dontStall)
    out1_s0 <= out1_pre_s0;
  else 
    out1_s0 <= out1_s0;
end


//output valid
//follows ivalid with an N-cycle delay (latency of this unit)
//Also, only asserted with no back-pressure (oready asserted)
reg [1-1:0] valid_shifter;
always @(posedge clk) begin
  if(ivalid) begin
    valid_shifter[0] <= ivalid;
  end
  else begin
    valid_shifter[0]  <=  valid_shifter[0];
  end //else
end //always

assign ovalid = valid_shifter[1-1] & oready;


endmodule 
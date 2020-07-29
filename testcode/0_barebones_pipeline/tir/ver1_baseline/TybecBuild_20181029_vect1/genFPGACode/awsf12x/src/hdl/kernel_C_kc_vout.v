// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_C_kc_vout 
// Generator Version    : R17.0
// Generator TimeStamp  : Mon Oct 29 16:59:19 2018
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

module kernel_C_kc_vout
#(  
   parameter STREAMW   = 32
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                     clk   
  , input                     rst   	
  , output                    iready 
  , input                     ivalid 
  , output reg                ovalid 
  , input                     oready     
  , output reg [STREAMW-1:0]  out1_s0
  , input      [STREAMW-1:0]  in1_s0
  , input      [STREAMW-1:0]  in2_s0  
);

//unregistered output
wire [STREAMW-1:0] out1_pre_s0;

//perform datapath operation, or instantiate module

assign out1_pre_s0 = in1_s0 * in2_s0;

//dont stall if input valid and slave ready
wire dontStall = ivalid & oready;

//if downstream ready, I am ready (instantly, no  cycle delay)
assign iready = oready;

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
//follows ivalid with a one-cycle delay (i.e. latency of this unit)
always @(posedge clk) begin
  if(rst)
    ovalid <= 0;
  else 
    ovalid <= ivalid;
end

endmodule 
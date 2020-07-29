// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_B_kb_vout 
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
// A generic module template for leaf map nodes for use by Tytra Back-End Compile
// (TyBEC)
//
// ============================================================================= 

module kernel_B_kb_vout
#(  
   parameter DATAW     = 32
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                 clk   
  , input                 rst   	
  , input                 stall
  , output reg[DATAW-1:0] out1
  , input     [DATAW-1:0] in1
  , input     [DATAW-1:0] in2  
);

//unregistered output
wire [DATAW-1:0] out1_pre;

//perform datapath operation, or instantiate module
assign out1_pre = in1 + in2;

//registered output
always @(posedge clk) begin
  if(rst)
    out1 <= 0;
  else if (stall)
    out1 <= out1;
  else 
    out1 <= out1_pre;
end

endmodule 
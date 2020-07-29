// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: <design_name>
// Generated Module Name: <module_name> 
// Generator Version    : <gen_ver>
// Generator TimeStamp  : <timeStamp>
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

module <module_name>
#(  
   parameter STREAMW   = <streamw>
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                     clk   
  , input                     rst   	
  , output                    ovalid 
  , output     <oStrWidth>    out1
  , input                     oready     
  //, output                    iready
  , output                   iready
//<inputReadys> <-- deprecated
<inputIvalids>
<inputports>
);

//if FP, then I need to attend this constant 2 bits for flopoco units
<fpcEF>

//registered inputs
<intputregs>

//And input valids  and output readys
<inputIvalidsAnded>

//If any input operands are constants, assign them their value here
<assignConstants>

//dont stall if input valid and slave ready
wire dontStall = ivalid & oready;

//perform datapath operation, or instantiate module
//--------------------------------------------------
<datapath>

//if output is ready (and no locally generated stall), I am ready
assign iready = oready;

//registered input
//-----------------
always @(posedge clk) begin
  if(rst) begin
<resetbranch>
  end  
  else if (dontStall) begin
<dontstallbranch>
  end
  else begin
<defaultbranch>
  end  
end

//ovalid logic
//-----------------
<ovalidLogic>

endmodule 
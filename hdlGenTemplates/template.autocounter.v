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
// A generic module template for autocounters
// This is an upcounter, with wrapping
// OVALID maintained for consistency with AXI-STREAM, but it is always "valid"
// Creates an output trigger when wrapping, to allow creation of nested counters
// If vectorized, then different behaviour depending on 
// whether it is a leaf counter or a hierarchical one
// Since vectors lanes are synchronous, 
// so s0 lane only is ok to use for input control signals ============================================================================= 

<nestingcomment>
module <module_name>
#(
  parameter COUNTERW = <counterw>
)
(
// =============================================================================
// ** Ports 
// =============================================================================
    input                     clk   
  , input                     rst   	
<ports_trig_count>
<ports_ivalid>
<ports_ovalid>
<ports_trig_wrap>
<ports_outputdata>
);

//localparam COUNTERW = <counterw>;
localparam STARTAT  = <startat> ;
localparam WRAPAT   = <wrapat>  ;
localparam VECT     = <vect>    ;

//assign ovalid     = 1'b1;
//counter output is valid whenever input (that is, its parent stream) is valid 
//this is not necessarily same as trigger as this may counter may be nested on top of another
<assign_ovalids>
//assign ovalid     = trig_count;

//generate trigger if reached wrap (max) value
assign trig_wrap_s0  = (counter_value_s0 == WRAPAT);

// trig_count may be locked in an asserted state by a nested 
// counter even though input is not valid
// so check for BOTH trig_count and input valid before counting up
always @(posedge clk) begin

  if(rst) begin
<branch_rst>
  end
  
  else if (trig_count_s0 & ivalid_s0) begin
    if(trig_wrap_s0) begin
<branch_wrap>
    end
    else begin
<branch_count>
    end
  end
  
  else begin
<branch_donothing>
  end

end

endmodule 
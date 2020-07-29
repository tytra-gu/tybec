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
// Template for axi4 stencil buffer (no "smart" caching)
// ============================================================================= 

module <module_name>
#(  
    parameter STREAMW = <streamw>
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                 clk   
  , input                 rst   	
<ireadys>
<ovalids>
<ivalids>
<inputs>  
<oreadys>
<outputs>
);

//smache custom design parameters
localparam MAXP = <maxp>;
localparam MAXN = <maxn>;
localparam VECT = <vect>;
localparam SIZE = <size>;
  //vect * ceil((maxP+maxN+(2*vect-1)) / vect)
localparam OFFSET_IDX0_S0 = <offsetIdx0S0>; 
  //maxP + (vect-1)


//shift register bank for data, and ovalid(s)
reg [STREAMW-1:0] offsetRegBank [0:SIZE-1];   
reg               valid_shifter [0:SIZE-1];   

//local oready only asserted when *all* outputs are ready
<oreadysAnd>

//iready when all oready's asserted
<assign_ireadys>
              
//tap at relevant delays
//the valid shifter takes care of the initial latency of filling up the buffer
//if ivalid is negated anytime during operation, we simply freeze the stream buffer
//so the valid shifter never gets a "0" in there (and the data shift register never reads 
//invalid data). This contiguity of *valid* data ensures that data of a certain "offset" is 
//always available at a fixed location


//ovalid picked up from location where IDX 0 is available. Vector outputs are synhronized so this should work.
<assign_ovalids>

//buffer index = Offset for index 0, scalar 0 - offset distance - current scalar position
<assign_dataouts>
//SHIFT write

always @(posedge clk) begin 
  if(ivalid_s0) begin
<shift_data_and_valid_idx0>
<shift_data_and_valid>
  end else begin
    offsetRegBank[0]  <=  offsetRegBank[0];
    valid_shifter[0]  <=  valid_shifter[0];
<dont_shift_data_and_valid>
  end
end

endmodule 
// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      : Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : NONE
//
// 
// =============================================================================

// =============================================================================
// General Description
// -----------------------------------------------------------------------------
// This is a basic, parameterizeable node for MAP operations
// A simple simulator to test and verify TyTra dataflow scheduler 
// ============================================================================= 

module mapnode
#(  
    parameter GL_CNTR_W = 16  
  , parameter DATAW     = 32
  , parameter FI_CNTR_W = 2  
  , parameter LAT       = 1
  , parameter LFI       = 1
  , parameter AFI       = 1
  , parameter FPO       = 1
  , parameter SD        = 1
)

(
// =============================================================================
// ** Ports 
// =============================================================================
  // standard kernel control ports
    input                 clk   
  , input                 rst   	
  , input [GL_CNTR_W-1:0] gl_cntr
  , input                 stall
  , input [DATAW-1:0]     datain
  , output[DATAW-1:0]     dataout 
);

//active
//------
reg active;
always @(posedge clk) begin
  if (rst)              //startign delay has  happened
    active <= 0;
  else if (active)      //once active, remain active until reset
    active <= 1;
  else if (gl_cntr==SD-1) //activate when starting-delay reached
    active <= 1;
  else  
    active <= active;
end

//FI counter
//-----------
reg [FI_CNTR_W-1:0] fi_cntr;
always @(posedge clk) begin
  if(rst || (fi_cntr == AFI-1)) //reset when reached limit
    fi_cntr <= 0;
  else if (stall)             //global stall... do nothing
   fi_cntr <= fi_cntr;
  else if(active)             //increment only when active
    fi_cntr <= fi_cntr+1;
  else
   fi_cntr <= fi_cntr;
end

//firing condition
//----------------
//assign firing_cond = ((gl_cntr==SD-1) || (fi_cntr == AFI-1));
assign firing_cond = (~stall && ((gl_cntr==SD-1) || (fi_cntr == AFI-1)));

  //first condition checks for FIRST fire, the second for all subsequent fires

//fire FU
//-------
//simulate latency by a shift FIFO register
reg [DATAW-1:0] dataout_r [0:LAT-1];

//output assigned on first clock, then we simulate latency
always @(posedge clk)
 if(firing_cond)
  dataout_r[0] <= datain+1;
  
//for loop to simulate latency 
integer i;
always @(posedge clk)
 if(firing_cond)
  for (i = 0; i < LAT-1; i = i + 1)
    dataout_r[i+1] <= dataout_r[i];

//actual output is MS-word
assign dataout = dataout_r[LAT-1]; 
 
  
  
  
  
  
endmodule 
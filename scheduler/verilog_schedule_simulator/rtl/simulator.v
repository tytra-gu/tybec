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
// A simple simulator to test and verify TyTra dataflow scheduler inside a 
// synchronous domain (SD)
//
// ============================================================================= 

`define LAT1 1
`define LAT2 1
`define LAT3 1
`define LAT4 1
`define FPO1 1
`define FPO2 1
`define FPO3 1
`define FPO4 1

module sd_sim
#(  
    parameter GL_CNTR_W = 16  
  , parameter DATAW     = 32
)

(
    input             clk   
  , input             rst
  , input             stall
  , input [DATAW-1:0] datain
  , output[DATAW-1:0] dataout   
);

//global counter
//---------------
reg [GL_CNTR_W-1:0] gl_cntr;

always @(posedge clk) begin
  if(rst ) 
    gl_cntr <= 0;
  else if (stall)
    gl_cntr <= gl_cntr;
  else 
    gl_cntr <= gl_cntr+1;
end

//Instantiating nodes
//-------------------
//NOTE: When changing AFI, make sure the FI_CNTR_W is wide enough
wire [DATAW-1:0] data_1_2;
wire [DATAW-1:0] data_2_3;
wire [DATAW-1:0] data_3_4;


mapnode 
#( 
   . GL_CNTR_W (GL_CNTR_W)
  ,. DATAW     (DATAW)
  ,. FI_CNTR_W (3)
  ,. LAT       (1)
  ,. LFI       (1)
  ,. AFI       (1)
  ,. FPO       (1)
  ,. SD        (0)  
) node1
(
   .clk     (clk   )
  ,.rst   	(rst   	)
  ,.gl_cntr (gl_cntr)
  ,.stall   (stall)
  ,.datain  (datain)
  ,.dataout (data_1_2)
);
 
 
mapnode 
#( 
   . GL_CNTR_W (GL_CNTR_W)
  ,. DATAW     (DATAW)
  ,. FI_CNTR_W (3)
  ,. LAT       (1)
  ,. LFI       (1)
  ,. AFI       (1)
  ,. FPO       (1)
  ,. SD        (1)  
) node2
(
   .clk     (clk   )
  ,.rst   	(rst   	)
  ,.gl_cntr (gl_cntr)
  ,.stall   (stall)
  ,.datain  (data_1_2)
  ,.dataout (data_2_3)
); 
 
 
rednode 
#( 
   . GL_CNTR_W (GL_CNTR_W)
  ,. DATAW     (DATAW)
  ,. FI_CNTR_W (3)
  ,. LAT       (1)
  ,. LFI       (1)
  ,. AFI       (1)
  ,. FPO       (10)
  ,. SD        (2)  
) node3
(
   .clk     (clk   )
  ,.rst   	(rst   	)
  ,.gl_cntr (gl_cntr)
  ,.stall   (stall)
  ,.datain  (data_2_3)
  ,.dataout (data_3_4)
); 

mapnode 
#( 
   . GL_CNTR_W (GL_CNTR_W)
  ,. DATAW     (DATAW)
  ,. FI_CNTR_W (4)
  ,. LAT       (1)
  ,. LFI       (1)
  ,. AFI       (10)
  ,. FPO       (1)
  ,. SD        (12)  
) node4
(
   .clk     (clk   )
  ,.rst   	(rst   	)
  ,.gl_cntr (gl_cntr)
  ,.stall   (stall)
  ,.datain  (data_3_4)
  ,.dataout (dataout)
); 
 
endmodule 



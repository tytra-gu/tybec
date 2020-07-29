// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: kernel_top_x_buff2 
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
// Template for axi4 stream compatible buffer used in TyBEC synchronize parallel
// paths with mismatched latencies. 
// Can be used to generate buffer with multiple "taps" for the same data
// ============================================================================= 

module kernel_top_x_buff2
#(  
    parameter STREAMW = 32
  , parameter SIZE    = 3
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                     clk   
  , input                     rst   	
  , output                    iready
  , input                     ivalid_in1
  , input      [STREAMW-1:0]  in1
  
  , output                    ovalid_out1

  , input                     oready_out1

  , output     [STREAMW-1:0]  out1 // at delay = 3 

);

//shift register bank for data, and ovalid(s)
reg [STREAMW-1:0] offsetRegBank [0:SIZE-1];   
reg               valid_shifter [0:SIZE-1];   

//local oready only asserted when *all* outputs are ready
assign oready = 1'b1
  & oready_out1
  ;

//iready when all oready's asserted
assign iready = oready;
              
//tap at relevant delays
//the valid shifter takes care of the initial latency of filling up the buffer
//if ivalid is negated anytime during operation, we simply freeze the stream buffer
//so the valid shifter never gets a "0" in there (and the data shift register never reads 
//invalid data). This contiguity of *valid* data ensures that data of a certain "offset" is 
//always available at a fixed location

assign ovalid_out1 = valid_shifter[3-1] & ivalid_in1;

assign out1 = offsetRegBank[3-1]; // at delay = 3 

//SHIFT write

always @(posedge clk) begin 
  if (rst) begin
    offsetRegBank[0]  <=  32'b0;
    valid_shifter[0]  <=  1'b0;
    offsetRegBank[1]  <=  32'b0;
    valid_shifter[1]  <=  1'b0;
    offsetRegBank[2]  <=  32'b0;
    valid_shifter[2]  <=  1'b0;
 
  end
  else if (ivalid_in1) begin
    offsetRegBank[0]  <=  in1; 
    valid_shifter[0]  <=  ivalid_in1;
    offsetRegBank[1]  <=  offsetRegBank[1-1];
    valid_shifter[1]  <=  valid_shifter[1-1];
    offsetRegBank[2]  <=  offsetRegBank[2-1];
    valid_shifter[2]  <=  valid_shifter[2-1];

  end else begin
    offsetRegBank[0]  <=  offsetRegBank[0];
    valid_shifter[0]  <=  valid_shifter[0];
    offsetRegBank[1]  <=  offsetRegBank[1];
    valid_shifter[1]  <=  valid_shifter[1];
    offsetRegBank[2]  <=  offsetRegBank[2];
    valid_shifter[2]  <=  valid_shifter[2];

  end
end

endmodule 
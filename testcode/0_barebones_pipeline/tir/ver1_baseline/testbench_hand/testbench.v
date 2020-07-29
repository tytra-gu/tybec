//`timescale 1 ns / 1 ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   
// Design Name:   
// Module Name:   
// Project Name:  TyTra
// Target Device:  
// Tool versions:  
// Description: Testbench for SimpleVectorOps 
//
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

//Should I simulate stalls?
//`define SIMSTALL

`define DATAW       32
`define SIZE        32
`define IN_OUT_LAT  5

//utilities
`include "./util.v"
 
module testbench;

// =============================================================================
// ** Parameters, and Locals
// =============================================================================
// Inputs to uut
reg   clk ;
reg   rst ;
reg   stall;
 
//use dataw instead of calculated widths to make opencl compatible
reg  [`DATAW-1:0]  lincount; 
wire [`DATAW-1:0]  vin0_data;        
wire [`DATAW-1:0]  vin1_data;        
wire [`DATAW-1:0]  vout_data;        


wire    done_ker;       //done from kernel (temp)
integer wi_count;       //keep a count of work instance
integer clk_count;
reg               ivalid;

//wire [63:0] lio_dut;  //linear index output from DUT
 
 //reg success;
 //reg endsim;
// -----------------------------------------------------------------------------
// ** File handlers
// -----------------------------------------------------------------------------
//integer fhandle1;
integer flog;	    // output for man
integer fverify;	// output for machine

initial
begin
  flog = $fopen("LOG.log");
  fverify = $fopen("verifyhdl.dat");	
end


// -----------------------------------------------------------------------------
// ** Stop Sim
// -----------------------------------------------------------------------------
always @(posedge clk)
  if (rst)
    clk_count <= 0;
  else
    clk_count <= clk_count+1;

// =============================================================================
// ** Instantiations
//=============================================================================  

//arrays in the dram
reg [`DATAW-1:0]  vin0  [0:`SIZE-1+`IN_OUT_LAT];    
reg [`DATAW-1:0]  vin1  [0:`SIZE-1+`IN_OUT_LAT];    
reg [`DATAW-1:0]  vout  [0:`SIZE-1+`IN_OUT_LAT];    

reg [`DATAW-1:0]  resultfromC     [0:(`SIZE*3)];  
reg [`DATAW-1:0]  resultfromHDL   [0:(`SIZE*3)];  
integer           index;

//fill up the  buffer with data
initial 
  for (index=0; index < `SIZE; index = index + 1) begin
    vin0[index] = index;
    vin1[index] = index;
    vout[index] = 0;
  end
  
//zero padding  
initial 
  for (index=`SIZE; index < `SIZE+`IN_OUT_LAT; index = index + 1) begin
    vin0[index] = 0;
    vin1[index] = 0;
    vout[index] = 0;
  end

initial
//golden result from C
$readmemh("verifyChex.dat", resultfromC);


main main_i(
   .clk   (clk)
  ,.rst   (rst)
  ,.stall (stall)
  ,.vin0_stream_load  (vin0_data)
  ,.vin1_stream_load  (vin1_data)
  ,.vout_stream_store (vout_data)
 );


// -----------------------------------------------------------------------------
// ** CLK and RST_N
// -----------------------------------------------------------------------------
initial 
  clk   <= 0;
  
always
  #(5) clk = ~clk;
  
initial 
begin
  // RESET PULSE
  rst <= 1'b1; 
  @(posedge clk);
  @(posedge clk);  
  rst <= 1'b0; 
end

// -----------------------------------------------------------------------------
// ** control signals/counters
// -----------------------------------------------------------------------------
    
//a little counter to make ivalid last longer
reg [1:0] ivalid_count;

always @(posedge clk) begin
  if(rst)
   ivalid_count <=0;
  else
   ivalid_count <= ivalid_count + 1;
end
    
//ivalid to DUT (randomly negate to simulate SHELL behaviour)
//-----------------------------------------------------------
//generate a random number, and then use it to create a boolean
//that is negated for ~10% of the time
always @(posedge clk) begin
`ifdef SIMSTALL
  //if ivalid was negated, and the count is not zero (75% probability), then keep it negated
  //should occassionally ivalid negated longer, upto 3 (4?) cycles
  if (!(ivalid) && (ivalid_count !=0))
    ivalid <= ivalid;
  //otherwise, assign ivalid = 1 unless this following, infrequent condition is satisfied
  else
  //  ivalid <= ~(($urandom%(`LINM))==0);   //less frequent ivalid negations
  ivalid <= ~(($urandom%(`LINM/4))==0); //more frequent 
  //ivalid <= ~(($urandom%10)==0);  
`else
  ivalid <= 1;  
`endif  
  //$display("lincount = %d, ivalid = %d, ovalid = %d", lincount, ivalid, ovalid); 
end
  
//linear index counter to keep track of where we are, and input to the DUT
//------------------------------------------
always @(posedge clk)
  if(rst)
    lincount <= 0;
  else if (lincount==`SIZE-1+`IN_OUT_LAT)
    lincount <= 0;
  else if (ivalid)
    lincount <= lincount + 1;
  else  
    lincount <= lincount;
    
// -----------------------------------------------------------------------------
// ** reading/writing the "dram" arrays 
// -----------------------------------------------------------------------------

wire [31:0] effaddr = lincount-`IN_OUT_LAT-1;

assign vin0_data = vin0[lincount];
assign vin1_data = vin1[lincount];
                            
// writing back to drams...
always @(posedge clk) 
  if(lincount >= `IN_OUT_LAT) begin
    vout[effaddr] <= vout_data;
  end

  // -----------------------------------------------------------------------------
// ** Logging/displaying results
// -----------------------------------------------------------------------------
initial 
      $fdisplay(fverify, "\t\t           time   lincount     lincount+LAT          j   resultfromC[j] vout_data");


integer j=0;
integer k=0;
integer success;
integer endsim;


initial begin
  success = 1;
  endsim = 0;
end

always @ (posedge clk)  begin
    //log results on the last work instance
    if (lincount >= `IN_OUT_LAT) begin 
      resultfromHDL[j] <= vout_data;
    end
    k=k+1;
end    
    

always @ (posedge clk)  begin
    if(lincount >= `IN_OUT_LAT)   begin    
      $fdisplay(fverify, $time/(5*2), "%d\t%d\t%d\t%d", lincount, lincount-`IN_OUT_LAT, j, resultfromC[j], vout_data);
      if(resultfromC[j]!=vout_data) begin
        $display("Result Verification failed at j=%d, expected = %d, calc = %d",j,resultfromC[j], vout_data);
        success=0;
      end
      j=j+1;
      
      if(j==`SIZE) begin
        if(success)
          $display("TEST PASSED WITH NO ERRORS!");
        else
          $display("TEST FAIL!!!");
        $stop;
      end
   end//if        
end//always
  
  
endmodule

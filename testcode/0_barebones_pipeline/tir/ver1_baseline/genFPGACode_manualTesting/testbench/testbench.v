// ******** NOTE: This testbench requires expected results to be placed in ../../../../../../c/verifyChex.dat **********
//                The generated code should automatically be at this position relative to the C folder            
          

//Should I simulate stalls?
//`define SIMSTALL

//utilities
`include "../rtl/util.v"
 
`define DATAW       32
`define SIZE        32
`define IN_OUT_LAT  5


module testbench;

// -----------------------------------------------------------------------------
// ** Parameters, and Locals
// -----------------------------------------------------------------------------
// Inputs to uut
reg   clk ;
reg   rst_n ;
reg   stall;
reg   ivalid;
wire  ovalid;

//index and WI counters
reg  [`DATAW-1:0] lincount; 
reg  [`DATAW-1:0] wi_count; 

//arrays in the dram
wire [`DATAW-1:0] vin1_stream_load_data;
wire [`DATAW-1:0] vin0_stream_load_data;
wire [`DATAW-1:0] vout_stream_store_data;


//other variables
reg [`DATAW-1:0]  resultfromC     [0:(`SIZE*3)];  
integer           success;
integer           endsim;

// -----------------------------------------------------------------------------
// ** File handlers
// -----------------------------------------------------------------------------
////integer fhandle1;
integer flog;	    // output for man
integer fverify;	// output for machine
//
initial
begin
  flog    = $fopen("LOG.log");
  fverify = $fopen("verifyhdl.dat");	
end

// -----------------------------------------------------------------------------
// ** Initialize
// -----------------------------------------------------------------------------

//arrays in the dram
reg [`DATAW-1:0]  vin1  [0:`SIZE-1+`IN_OUT_LAT];
reg [`DATAW-1:0]  vin0  [0:`SIZE-1+`IN_OUT_LAT];
reg [`DATAW-1:0]  vout  [0:`SIZE-1+`IN_OUT_LAT];


//fill up the  buffer with data
integer index0;
initial 
  for (index0=0; index0 < `SIZE; index0 = index0 + 1) begin
    vin1[index0] = index0+1;
    vin0[index0] = index0+1;
    vout[index0] = 0;

  end
  
//zero padding  
integer index1;
initial 
  for (index1=`SIZE; index1 < `SIZE+`IN_OUT_LAT; index1 = index1 + 1) begin
vin1[index1] = 0;
vin0[index1] = 0;
vout[index1] = 0;
  
  end

initial
//golden result from C
$readmemh("../../../../../c/verifyChex.dat", resultfromC);

// -----------------------------------------------------------------------------
// ** Instantiations
// -----------------------------------------------------------------------------

func_hdl_top 
#(
  .DATAW (`DATAW) 
  )
ktop
(
   .clock             (clk)
  ,.resetn            (rst_n)
  ,.ivalid            (ivalid)
  ,.iready            ()
  ,.ovalid            (ovalid)
  ,.oready            ()
, .vin1_stream_load  (vin1_stream_load_data)
, .vin0_stream_load  (vin0_stream_load_data)
, .vout_stream_store  (vout_stream_store_data)
  
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
  rst_n <= 1'b0; 
  @(posedge clk);
  @(posedge clk);  
  rst_n <= 1'b1; 
end

// -----------------------------------------------------------------------------
// ** control signals/counters
// -----------------------------------------------------------------------------
    
//a little counter to make ivalid last longer
reg [1:0] ivalid_count;

always @(posedge clk) begin
  if(~rst_n)
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
  ivalid <= ~(($urandom%(`SIZE))==0);   //less frequent ivalid negations
  //ivalid <= ~(($urandom%(`SIZE/4))==0); //more frequent 
  //ivalid <= ~(($urandom%11)==0);        //much more frequent
`else
  ivalid <= 1;  
`endif  
end
  
//linear index counter to keep track of where we are, and input to the DUT
//------------------------------------------
always @(posedge clk)
  if(~rst_n)
    lincount <= 0;
  else if (lincount==`SIZE-1+`IN_OUT_LAT)
    lincount <= 0;
  else if (ivalid)
    lincount <= lincount + 1;
  else  
    lincount <= lincount;
    
//work instance counter    
//------------------------------------------
always @(posedge clk)
  if(~rst_n)
    wi_count <= 0;
  else if ((lincount==`SIZE-1+`IN_OUT_LAT) && ivalid)
    wi_count <= wi_count + 1;
  else
    wi_count <= wi_count;  
    
// -----------------------------------------------------------------------------
// ** reading/writing the "dram" arrays 
// -----------------------------------------------------------------------------

wire [31:0] effaddr = lincount-`IN_OUT_LAT;
assign vin1_stream_load_data = vin1[lincount];
assign vin0_stream_load_data = vin0[lincount];

                            
// writing back to drams...
always @(posedge clk) 
  if(lincount >= `IN_OUT_LAT) begin
    vout[effaddr] <= vout_stream_store_data;

  end

  
  
// -----------------------------------------------------------------------------
// ** Logging/displaying results
// -----------------------------------------------------------------------------
initial 
  $fdisplay(fverify, "\t\t           time   index    resultfromC[index]  vout[index]");

initial begin
  success = 1;
  endsim = 0;
end

wire  checkResultCond  = (lincount==`SIZE-1+`IN_OUT_LAT); 
reg   checkResultCond_r;
always @(posedge clk)
 checkResultCond_r <= checkResultCond;

integer index;
always @ (posedge clk)  begin
  if(checkResultCond_r) begin
    for(index = 0; index < `SIZE; index=index+1 ) begin
      $fdisplay(fverify, $time/(5*2), "%d\t||%d\t%d"
                       , index
                       , resultfromC[index]
                       , vout[index]
                );
        if(resultfromC[index]!==vout[index]) begin
          $display("FAIL: Verification failed at index=%d, expected = %d, calc = %d"
                    ,index
                    ,resultfromC[index]
                    ,vout[index]
                   );
          success=0;
        end//if
    end//for
    
    if(success)
      $display("TEST PASSED WITH NO ERRORS!");
    else
      $display("TEST FAIL!!!");
    
    $fclose(flog);
    $fclose(fverify);
    $stop;
  end//if
end//always
  
  
endmodule

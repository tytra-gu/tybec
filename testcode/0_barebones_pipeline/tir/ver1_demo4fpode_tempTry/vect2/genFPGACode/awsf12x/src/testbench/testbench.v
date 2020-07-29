// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: testbench 
// Generator Version    : R17.0
// Generator TimeStamp  : Sun Nov  4 13:20:39 2018
// 
// Dependencies         : <dependencies>
//
// 
// =============================================================================

// =============================================================================
// General Description
// -----------------------------------------------------------------------------
//============================================================================= 


// ******** NOTE: This testbench requires expected results to be placed in ../../../../../../../c/verifyChex.dat **********
//                The generated code should automatically be at this position relative to the C folder            
// NOTE: above comment is obsolete?
// obsolete?
//Should I simulate stalls?
//`define SIMSTALL

//utilities
//`include "../rtl/util.v"
 
 
`define TY_GVECT    16 
`define DATAW       32
`define STREAMW     32
`define SIZE        1048576
`define NINPUTS     2
`define NOUPUTS     1
//`define IN_OUT_LAT  5
//`define STREAMW     32 
  //


//verify results up to how many decimal places
`define VERPRECBITS 1
`define VERPREC     10**`VERPRECBITS

module testbench;
 

// -----------------------------------------------------------------------------
// ** Parameters, and Locals
// -----------------------------------------------------------------------------
// Inputs to uut
reg   clk ;
reg   rst_n ;

//AXI-stream control signals to DUT  
reg  ivalid_todut  ;
wire oready_todut  = 1'b1;
wire iready_fromdut;
wire ovalid_fromdut;

//index and WI counters
reg  [`DATAW-1:0] lincount; 
reg  [`DATAW-1:0] wi_count; 

//wires for accessing child ports
wire [`STREAMW-1:0] vout_stream_store_data_s0;
wire [`STREAMW-1:0] vout_stream_store_data_s1;
wire [`STREAMW-1:0] vout_stream_store_data_s2;
wire [`STREAMW-1:0] vout_stream_store_data_s3;
wire [`STREAMW-1:0] vout_stream_store_data_s4;
wire [`STREAMW-1:0] vout_stream_store_data_s5;
wire [`STREAMW-1:0] vout_stream_store_data_s6;
wire [`STREAMW-1:0] vout_stream_store_data_s7;
wire [`STREAMW-1:0] vout_stream_store_data_s8;
wire [`STREAMW-1:0] vout_stream_store_data_s9;
wire [`STREAMW-1:0] vout_stream_store_data_s10;
wire [`STREAMW-1:0] vout_stream_store_data_s11;
wire [`STREAMW-1:0] vout_stream_store_data_s12;
wire [`STREAMW-1:0] vout_stream_store_data_s13;
wire [`STREAMW-1:0] vout_stream_store_data_s14;
wire [`STREAMW-1:0] vout_stream_store_data_s15;
wire [`STREAMW-1:0] vin0_stream_load_data_s0;
wire [`STREAMW-1:0] vin0_stream_load_data_s1;
wire [`STREAMW-1:0] vin0_stream_load_data_s2;
wire [`STREAMW-1:0] vin0_stream_load_data_s3;
wire [`STREAMW-1:0] vin0_stream_load_data_s4;
wire [`STREAMW-1:0] vin0_stream_load_data_s5;
wire [`STREAMW-1:0] vin0_stream_load_data_s6;
wire [`STREAMW-1:0] vin0_stream_load_data_s7;
wire [`STREAMW-1:0] vin0_stream_load_data_s8;
wire [`STREAMW-1:0] vin0_stream_load_data_s9;
wire [`STREAMW-1:0] vin0_stream_load_data_s10;
wire [`STREAMW-1:0] vin0_stream_load_data_s11;
wire [`STREAMW-1:0] vin0_stream_load_data_s12;
wire [`STREAMW-1:0] vin0_stream_load_data_s13;
wire [`STREAMW-1:0] vin0_stream_load_data_s14;
wire [`STREAMW-1:0] vin0_stream_load_data_s15;
wire [`STREAMW-1:0] vin1_stream_load_data_s0;
wire [`STREAMW-1:0] vin1_stream_load_data_s1;
wire [`STREAMW-1:0] vin1_stream_load_data_s2;
wire [`STREAMW-1:0] vin1_stream_load_data_s3;
wire [`STREAMW-1:0] vin1_stream_load_data_s4;
wire [`STREAMW-1:0] vin1_stream_load_data_s5;
wire [`STREAMW-1:0] vin1_stream_load_data_s6;
wire [`STREAMW-1:0] vin1_stream_load_data_s7;
wire [`STREAMW-1:0] vin1_stream_load_data_s8;
wire [`STREAMW-1:0] vin1_stream_load_data_s9;
wire [`STREAMW-1:0] vin1_stream_load_data_s10;
wire [`STREAMW-1:0] vin1_stream_load_data_s11;
wire [`STREAMW-1:0] vin1_stream_load_data_s12;
wire [`STREAMW-1:0] vin1_stream_load_data_s13;
wire [`STREAMW-1:0] vin1_stream_load_data_s14;
wire [`STREAMW-1:0] vin1_stream_load_data_s15;


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
reg [`DATAW-1:0]  vout  [0:`SIZE-1];
reg [`DATAW-1:0]  vin0  [0:`SIZE-1];
reg [`DATAW-1:0]  vin1  [0:`SIZE-1];


//fill up the  buffer with data
integer index0;
initial 
  for (index0=0; index0 < `SIZE; index0 = index0 + 1) begin
    vout[index0] = 0;
    vin0[index0] = index0+1;
    vin1[index0] = index0+1;

  end
  
////zero padding  
//integer index1;
//initial 
//  for (index1=`SIZE; index1 < `SIZE+`IN_OUT_LAT; index1 = index1 + 1) begin
//<zeropadarrays-not>  
//  end
//
initial begin
////golden result from C
$readmemh("../../../../../../../c/verifyChex.dat", resultfromC);

end

// -----------------------------------------------------------------------------
// ** Instantiations
// -----------------------------------------------------------------------------

wire [(`STREAMW*`TY_GVECT*`NINPUTS)-1:0]  packed_data_in;
wire [(`STREAMW*`TY_GVECT)-1         :0]  packed_data_out;

assign packed_data_in  =  {
                           vin0_stream_load_data_s15
                          ,vin0_stream_load_data_s14
                          ,vin0_stream_load_data_s13
                          ,vin0_stream_load_data_s12
                          ,vin0_stream_load_data_s11
                          ,vin0_stream_load_data_s10
                          ,vin0_stream_load_data_s9
                          ,vin0_stream_load_data_s8
                          ,vin0_stream_load_data_s7
                          ,vin0_stream_load_data_s6
                          ,vin0_stream_load_data_s5
                          ,vin0_stream_load_data_s4
                          ,vin0_stream_load_data_s3
                          ,vin0_stream_load_data_s2
                          ,vin0_stream_load_data_s1
                          ,vin0_stream_load_data_s0
                          ,vin1_stream_load_data_s15
                          ,vin1_stream_load_data_s14
                          ,vin1_stream_load_data_s13
                          ,vin1_stream_load_data_s12
                          ,vin1_stream_load_data_s11
                          ,vin1_stream_load_data_s10
                          ,vin1_stream_load_data_s9
                          ,vin1_stream_load_data_s8
                          ,vin1_stream_load_data_s7
                          ,vin1_stream_load_data_s6
                          ,vin1_stream_load_data_s5
                          ,vin1_stream_load_data_s4
                          ,vin1_stream_load_data_s3
                          ,vin1_stream_load_data_s2
                          ,vin1_stream_load_data_s1
                          ,vin1_stream_load_data_s0
};

assign { vout_stream_store_data_s15 ,vout_stream_store_data_s14 ,vout_stream_store_data_s13 ,vout_stream_store_data_s12 ,vout_stream_store_data_s11 ,vout_stream_store_data_s10 ,vout_stream_store_data_s9 ,vout_stream_store_data_s8 ,vout_stream_store_data_s7 ,vout_stream_store_data_s6 ,vout_stream_store_data_s5 ,vout_stream_store_data_s4 ,vout_stream_store_data_s3 ,vout_stream_store_data_s2 ,vout_stream_store_data_s1 ,vout_stream_store_data_s0 } = packed_data_out;

func_hdl_top 
//#(
//   .C_DATA_WIDTH   (`DATAW) 
//  ,.C_NUM_CHANNELS (2)
//  )
func_hdl_top_i
(
   .aclk      (clk)
  ,.areset    (~rst_n)
  ,.s_tvalid  ({ivalid_todut, ivalid_todut})
  ,.s_tdata   (packed_data_in)
  ,.s_tready  ()           
  ,.m_tvalid  (ovalid_fromdut)
  ,.m_tdata   (packed_data_out)
  ,.m_tready  (oready_todut)
  
 );

//<connectchildports-not>  


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
  if (!(ivalid_todut) && (ivalid_count !=0))
    ivalid_todut <= ivalid_todut;
  //otherwise, assign ivalid = 1 unless this following, infrequent condition is satisfied
  else
  ivalid_todut <= ~(($urandom%(`SIZE))==0);   //less frequent ivalid negations
  //ivalid <= ~(($urandom%(`SIZE/4))==0); //more frequent 
  //ivalid <= ~(($urandom%11)==0);        //much more frequent
`else
  ivalid_todut <= 1;  
`endif  
end
  
//linear index counter to keep track of where we are, and input to the DUT
//------------------------------------------
always @(posedge clk)
  if(~rst_n)
    lincount <= 0;
  else if (lincount>=`SIZE-1)
    lincount <= 0;
  else if (ivalid_todut)
    lincount <= lincount + `TY_GVECT;
  else  
    lincount <= lincount;
    
//linear index counter to keep track of where we are at the output
//------------------------------------------
reg [31:0] effaddr;

always @(posedge clk)
  if(~rst_n)
    effaddr <= 0;
  else if (effaddr==`SIZE-`TY_GVECT)
    effaddr <= 0;
  //increment if output from DUT valid
  else if (ovalid_fromdut)
    effaddr <= effaddr + `TY_GVECT;
  else  
    effaddr <= effaddr;    
    
//work instance counter    
//------------------------------------------
always @(posedge clk)
  if(~rst_n)
    wi_count <= 0;
  else if ((lincount==`SIZE-`TY_GVECT) && ivalid_todut)
    wi_count <= wi_count + 1;
  else
    wi_count <= wi_count;  
    
// -----------------------------------------------------------------------------
// ** reading/writing the "dram" arrays 
// -----------------------------------------------------------------------------

//wire [31:0] effaddr = lincount-(`IN_OUT_LAT*16);

assign vin0_stream_load_data_s0 = vin0[lincount+0];
assign vin0_stream_load_data_s1 = vin0[lincount+1];
assign vin0_stream_load_data_s2 = vin0[lincount+2];
assign vin0_stream_load_data_s3 = vin0[lincount+3];
assign vin0_stream_load_data_s4 = vin0[lincount+4];
assign vin0_stream_load_data_s5 = vin0[lincount+5];
assign vin0_stream_load_data_s6 = vin0[lincount+6];
assign vin0_stream_load_data_s7 = vin0[lincount+7];
assign vin0_stream_load_data_s8 = vin0[lincount+8];
assign vin0_stream_load_data_s9 = vin0[lincount+9];
assign vin0_stream_load_data_s10 = vin0[lincount+10];
assign vin0_stream_load_data_s11 = vin0[lincount+11];
assign vin0_stream_load_data_s12 = vin0[lincount+12];
assign vin0_stream_load_data_s13 = vin0[lincount+13];
assign vin0_stream_load_data_s14 = vin0[lincount+14];
assign vin0_stream_load_data_s15 = vin0[lincount+15];
assign vin1_stream_load_data_s0 = vin1[lincount+0];
assign vin1_stream_load_data_s1 = vin1[lincount+1];
assign vin1_stream_load_data_s2 = vin1[lincount+2];
assign vin1_stream_load_data_s3 = vin1[lincount+3];
assign vin1_stream_load_data_s4 = vin1[lincount+4];
assign vin1_stream_load_data_s5 = vin1[lincount+5];
assign vin1_stream_load_data_s6 = vin1[lincount+6];
assign vin1_stream_load_data_s7 = vin1[lincount+7];
assign vin1_stream_load_data_s8 = vin1[lincount+8];
assign vin1_stream_load_data_s9 = vin1[lincount+9];
assign vin1_stream_load_data_s10 = vin1[lincount+10];
assign vin1_stream_load_data_s11 = vin1[lincount+11];
assign vin1_stream_load_data_s12 = vin1[lincount+12];
assign vin1_stream_load_data_s13 = vin1[lincount+13];
assign vin1_stream_load_data_s14 = vin1[lincount+14];
assign vin1_stream_load_data_s15 = vin1[lincount+15];

                            
// writing back to drams...
always @(posedge clk) 
  if(ovalid_fromdut) begin 
    vout[effaddr+0] <= vout_stream_store_data_s0;
    vout[effaddr+1] <= vout_stream_store_data_s1;
    vout[effaddr+2] <= vout_stream_store_data_s2;
    vout[effaddr+3] <= vout_stream_store_data_s3;
    vout[effaddr+4] <= vout_stream_store_data_s4;
    vout[effaddr+5] <= vout_stream_store_data_s5;
    vout[effaddr+6] <= vout_stream_store_data_s6;
    vout[effaddr+7] <= vout_stream_store_data_s7;
    vout[effaddr+8] <= vout_stream_store_data_s8;
    vout[effaddr+9] <= vout_stream_store_data_s9;
    vout[effaddr+10] <= vout_stream_store_data_s10;
    vout[effaddr+11] <= vout_stream_store_data_s11;
    vout[effaddr+12] <= vout_stream_store_data_s12;
    vout[effaddr+13] <= vout_stream_store_data_s13;
    vout[effaddr+14] <= vout_stream_store_data_s14;
    vout[effaddr+15] <= vout_stream_store_data_s15;

  end



// -----------------------------------------------------------------------------
// ** Logging/displaying results
// -----------------------------------------------------------------------------
initial  begin
  $fdisplay(fverify, ":: Time stamp = Sun Nov  4 13:20:39 2018 ::\n\n");
  $fdisplay(fverify, "\t\t           time   index    resultfromC[index]  vout[index]");
end

initial begin
  success = 1;
  endsim = 0;
end

wire  checkResultCond  = (effaddr==`SIZE-`TY_GVECT); 
reg   checkResultCond_r;
always @(posedge clk)
 checkResultCond_r <= checkResultCond;


integer index;
always @ (posedge clk)  begin
  if(checkResultCond_r) begin
    for(index = 0; index < `SIZE; index=index+1 ) begin
      $fdisplay(fverify, $time/(5*2), "%d\t||%d\t%d"
      //$fdisplay(fverify, $time/(5*2), "%d\t||\t%d"
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
  
// // -----------------------------------------------------------------------------
// // ** Logging/displaying results
// // -----------------------------------------------------------------------------
// initial 
//   $fdisplay(fverify, "\t\t           time   index    resultfromC[index]  vout[index]");
// 
// initial begin
//   success = 1;
//   endsim = 0;
// end
// 
// //wire  checkResultCond  = (lincount>=`SIZE-1+(`IN_OUT_LAT*16)); 
// wire  checkResultCond  = (lincount==`SIZE-1+(`IN_OUT_LAT*16)); 
// reg   checkResultCond_r;
// always @(posedge clk)
//  checkResultCond_r <= checkResultCond;
// 
// 
//  
// integer index;
// integer scalarResGold;
// integer scalarResCalc;
// integer scalarResGold2Compare;
// integer scalarResCalc2Compare;
// 
// always @ (posedge clk)  begin
//   if(checkResultCond_r) begin
//     for(index = 0; index < `SIZE; index=index+1 ) begin
//        scalarResGold = resultfromC[index];
//        scalarResCalc = vout[index];
//        scalarResGold2Compare=scalarResGold;
//        scalarResCalc2Compare=scalarResCalc;
// 
//        $display("Comparing at index=%d, Gold = %d, Calc = %d"
//                  ,index
//                  , scalarResGold2Compare
//                  , scalarResCalc2Compare
//                 );       
//        
//       $fdisplay(fverify, $time/(5*2), "%d\t||%d\t%d"
//                        , index
//                        , scalarResGold
//                        , scalarResCalc
//                 );
//         if(scalarResGold2Compare!=scalarResCalc2Compare) begin
//           $display("FAIL: Verification failed at index=%d, expected = %d, calc = %d"
//                     ,index
//                     , scalarResGold
//                     , scalarResCalc
//                    );
//           success=0;
//         end//if
//     end//for
//     
//     if(success)
//       $display("TEST PASSED WITH NO ERRORS!");
//     else
//       $display("TEST FAIL!!!");
//     
//     $fclose(flog);
//     $fclose(fverify);
//     $stop;
//   end//if
// end//always
//   
//   

endmodule

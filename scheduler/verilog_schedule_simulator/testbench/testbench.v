`define GL_CNTR_W 16  
`define DATAW     32
`define NETLAT    2   //Net latency input to output


module testbench;

// =============================================================================
// ** Parameters, and Locals
// =============================================================================
	// Inputs to uut
	reg   clk ;
	reg   rst ;
	reg   stall ;

  reg  [`DATAW-1:0] datain;        
  wire [`DATAW-1:0] dataout;

//integer fhandle1;
integer flog;	// file handler of log file

initial
begin
  flog = $fopen("LOG.log");
end

// -----------------------------------------------------------------------------
// ** Instantiations
// -----------------------------------------------------------------------------
// =============================================================================

sd_sim
#(  
   .GL_CNTR_W(`GL_CNTR_W)  
  ,.DATAW    (`DATAW    )
) sd_sim_dut
(
   .clk    (clk    )
  ,.rst    (rst    )
  ,.stall  (stall  )
  ,.datain (datain )
  ,.dataout(dataout)   
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
// ** DATAIN
// -----------------------------------------------------------------------------
always @(posedge clk)
  if(rst)
    datain <= 0;
  else
    datain <= datain+1;


// -----------------------------------------------------------------------------
// ** STALL
// -----------------------------------------------------------------------------
always @(posedge clk)
  if(rst)
    stall <= 0;
  else
    stall <= stall;

// -----------------------------------------------------------------------------
// ** Stop Sim
// -----------------------------------------------------------------------------
initial begin
  repeat (100) @(posedge clk);
  $fclose(flog);
  $stop;
end

// -----------------------------------------------------------------------------
//LOG
// -----------------------------------------------------------------------------
initial
  $fdisplay(flog, "				        TIME\t datain\t  dataout\t ");
always @ (posedge clk)  begin
  if(!rst) begin
    $fdisplay(flog, $time/(5*2), "\t%d \t%d"
    ,datain
    ,dataout
    );
  end
end
     
endmodule
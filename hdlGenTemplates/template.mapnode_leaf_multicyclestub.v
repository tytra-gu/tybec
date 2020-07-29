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
// A template for creating multi-cycle stub modules for testing.
// The stub function is integer addition
//
// ===========================================================================

module <module_name>
#(  
    parameter STREAMW   = <streamw>
   ,parameter ITERLAT   = <iterlat>
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input                     clk   
  , input                     rst   	
  , output                    ovalid 
  , output [STREAMW-1:0]      out1
  , input                     oready     
  , output                    iready
//<inputReadys> <-- deprecated
  , input ivalid_in1
  , input ivalid_in2

  , input      [STREAMW-1:0]  in1
  , input      [STREAMW-1:0]  in2

);


localparam ITERLATW = <iterlatw>;

//registered inputs
reg [32-1:0] in1_r;
reg [32-1:0] in2_r;

//And input valids  and output readys
assign ivalid = ivalid_in1 & ivalid_in2 &  1'b1;

//dont stall if input valid and slave ready
wire dontStall = ivalid & oready;

//perform datapath operation, or instantiate module
//use this version if you want stub do not do anything, and simply pass on input at the 0th port to output
assign out1 = in1_r;// + in2_r; 

//use this version if you want the stub function to perform addition
//assign out1 = in1_r + in2_r;

//this version will add the two inputs
//assign out1_s0 = in1_s0_r + in2_s0_r;

//------------------------------------------------
//latency simulator (state machine and ouput logic)
//------------------------------------------------

reg   [ITERLATW-1:0] latcount;

reg cstate;
reg nstate;
parameter READY=0, RUNNING=1;


always @(*) begin 
  //ready state: increment and move to RUNNING if dontStall (i.e., you get new data)
  if(cstate==READY) 
    if (dontStall) 
      nstate = RUNNING;
    else     
      nstate = READY; 
  else if(cstate==RUNNING) 
    if(latcount==ITERLAT-1)
      nstate = READY;
    //else if(oready) 
    //  nstate = RUNNING;
    else  
      nstate = RUNNING;    
  else 
      nstate  = nstate;
end

//cstate
always @(posedge clk)
  if (rst)
    cstate <= 0;
  else
    cstate <= nstate;

//latcount    
always @(posedge clk) begin
  //reset
  if(rst) begin
    latcount  <= 0;
    //cstate    <= READY;
  end
  
  //ready state: increment and move to RUNNING if dontStall (i.e., you get new data)
  else if(cstate==READY) 
    if (dontStall) begin //this is the condition where you latch input data
      latcount  <= latcount+1;
      //cstate     <= RUNNING;
    end  
    else begin
      latcount  <= latcount;
      //cstate     <= READY; 
    end      
  //running state: stay here and increment until all iteration count completes      
  else if(cstate==RUNNING) 
    if(latcount==ITERLAT-1) begin
      latcount  <= 0;
      //cstate     <= READY;
    end      
    else if(oready) begin //iterate only when output is ready (conservative iteration) 
      latcount  <= latcount+1;
      //cstate     <= RUNNING;
    end      
    else  begin
      latcount  <= latcount;
      //cstate     <= RUNNING;    
    end      
  
  //catch-all
  else begin
    latcount <= latcount;  
    //cstate    <= cstate;  
  end      
end


//registered output and ovalid
reg ovalid_pre;

always @(posedge clk) begin
  if(rst) begin
    ovalid_pre  <= 0;
    in1_r    <= 0;
    in2_r    <= 0;
  end
  //latch input only once when dontStall and in READY state
  else if ((dontStall) && (cstate==READY)) begin 
    ovalid_pre   <= 0;
    in1_r     <= in1;
    in2_r     <= in2;
  end
  //when iterations complete, retain input, assert ovalid  
  else if ((cstate==RUNNING) && (latcount==ITERLAT-1)) begin
    ovalid_pre   <= 1;
    in1_r     <= in1_r;
    in2_r     <= in2_r;
  end
  //for subsequent iterations, retain inputs, negate ovalid
  else begin 
    ovalid_pre   <= 0;
    in1_r     <= in1_r;
    in2_r     <= in2_r;
  end
end

//when using multi-cycle stalling stubs (does not work with floats; why?)
//NO: This is counting the same dontStall signal twice... It is already accounted for
//in generating ovalid_pre.
//(This is unlike non-stalling nodes, where ovalid responds _immediately_ to  stalls)
//assign ovalid = ovalid_pre & dontStall;

// This is the correct way to do it for stalling nodes
assign ovalid = ovalid_pre;


assign iready = (cstate==READY) && oready;
//assign iready = (  (state==READY) 
//                || ((state==RUNNING) && (latcount==ITERLAT-1))
//                )
//                && oready
//                ; //ready only when in READY state, or valid condition to enter READY state from RUNNING


endmodule 
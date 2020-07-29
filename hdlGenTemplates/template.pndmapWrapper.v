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
// A generic module template for hierarchical 
// map nodes for use by Tytra Back-End Compile
//
// ============================================================================= 

module <module_name>
#(  
   parameter STREAMW   = <streamw>
)

(
// -----------------------------------------------------------------------------
// ** Ports 
// -----------------------------------------------------------------------------
    input       clk   
  , input       rst   	
  , output      iready 
  , output  reg ovalid 
<ivalids>
<oreadys>
<ports>  
);

//how many child threads
localparam NTHREADS = <nthreads>;
<connections>

//And input valids  and output readys
<ivalidsAnd>
<oreadysAnd>
//iready is the OR of all ireadys. 
//If ANY thread is ready, it means the parent is ready
<ireadysOr>
//we are ready to load when input valid and I am ready              
wire load  = ivalid & iready;

//counter for round-robin-ing over threads
//incremenet whenever new data to load
//reset back to zeroth thread when count complete
reg [<th_rr_counter_w>-1:0] thr_rr_count;

// obsolete, buggy
//always @(posedge clk)
//  if(rst)
//    thr_rr_count <= 0;
//  else if (load)
//    thr_rr_count <= thr_rr_count+1;
//  else if (thr_rr_count==NTHREADS-1)
//    thr_rr_count <= 0;
//  else
//    thr_rr_count <= thr_rr_count;

//when I see load, I should _first_ check if I need to cycle counter    
always @(posedge clk)
  if(rst)
    thr_rr_count <= 0; 
  else if (load)
    if (thr_rr_count==NTHREADS-1)
      thr_rr_count <= 0;
    else 
      thr_rr_count <= thr_rr_count+1;
  else
    thr_rr_count <= thr_rr_count;
        
    
//demux for distributing IVALID and DATA to threads
always @(*) begin
  case (thr_rr_count)
<demux>
  endcase                
end    

//collect all ovalids to create the select signal for the mux
//creates "one-shot" code
wire [NTHREADS-1:0] all_ovalids = {<ovalidsConcat>};

//mux for collecting OVLAIDS and DATA from threads
always @(*) begin
  case(all_ovalids)
<mux>
    default : begin
      ovalid      = 0;
<mux_def>                
    end  
  endcase
end

//multiple "threads" of execution of this module
<instances>
endmodule 

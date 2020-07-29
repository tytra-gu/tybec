[Also see ./DONE_TOCONTINUE]

# General notes related to the TyBEC compiler (parse, cost, generate).

Started: Waqar Nabi, Gainesville FL, Jul 2017.

1. These notes are not comprehensive. For more notes and comments:
  - Comments in the perl code
  - These hashtags in my (Waqar's) Google keep: #tybec, #tybec17
  - documents in ./docs
  - Design document in the /publish
  - google doc (AWS)
     https://docs.google.com/document/d/17bUyUWYpTv-BpbUmyZVyYWGSAY1cOW0MiocNYhyY84Q/edit?usp=sharing
       

# TIR: Constraints and Limitations on Syntax and Semantics (Parsing and/or Code Generation)

+ Identifiers cannot start with numbers
+ Don't have identifiers ending in _N, where N is any integer; as numbers are added to identifiers by TyBEC 
  (and again internally removed to get to root identifier
+ Constant operands can _only_ be the second operand in a 2-op primitive instruction. This is a problem with non-commutative  instructions. Silly limitation, just need to debug code-gen.
+ LOADING constants does not work; in fact, any case where ALL operands are constants does not work (I should be folding here anyway). The DFG depends on nodes having
preds and succs, or being special nodes like arguments, counters etc. HAving primitive instructions with constant input args only breaks this rule.
+ Mixed data types not supported (yet). Either i32 only, or float32 only.
+ offset streams
  ;--currently, I have this artificial limitation that offset streams cannot be created
  ;--from these implicit connection wires between kernels. So I explicitly assign them
  ;--to local variables before creating streams from them
+ I am currently not allowing _same_ stream to be _both_ input and output. But that should be easily doable. TODO.
+ output arguments in hier nodes can only be output of a primitive instruction. They can't be input themselves to anothet node, or they cant be outputs of child function(s)?  
+ If I am using a multi-cycle stub node, I cannot have constant operands....     

+ Having xple child modules feed outputs of a parent module, when those child modules could have different latencies, causes an error in the code gen DFG. (The ouput ports loop  back to buffers). FIXME.
  - work-around: have a final, _single_ child module to collect all outputs, so that output to parent is fed by a single module

+ In reduction operations, the input port that is also the outptu reduction MUST be the _second_ input port
+ Only "tail" folding allowed. That is, folding operations must be the last one in the DFG of the relevant function. 
+ Fold instructions can ONLY be the TERMINAL instruction of a function, and that function can have just ONE output, which is that folded value.     

+ if I have multi-cycle nodes and I pndmap around them, then _sometimes_ any bypass paths around that node fall out of synch (i.e., they keep firing and emitting valid data, but it is dropped at the output as the overall ovalid is asserted with a latency due to the pndmap node). pndmap node should result in >1 latency and inferred buffers in parallel paths, but in case of 2dshallow-water's top, when I put a pndmap around `updates()` then some bypass outputs remained in-synch, and some fell out of synch. I can avoid thid pitfall by _not_ allowing bypass paths in the CG pipeline; that means every stream should be strung through _every_ node in the CG pipeline. This is something that should be fixable though. FIXME

+ Vectorization vs Array Sizes
  + The _total_ size, as well as size in each _dimension_, must be divisible by the 
  vectorization factor
  + Maximum stencil offsets have to be divisible by the vectorization factor (?)

+ The back-end has not been tested for a depth of more than: 
  + That is: main --> top --> CG pipeline of leaf kernels (with inferred autoindices, stencil buffers)



# GENERAL NOTES SECTION

2017.07


2. When I am generating OCL code and its HDL wrapper, I am not taking any specific measures to connect ports/args correctly by position in various parts of the code (e.g. .cl, .h, main.cpp etc all require knowledge of sequence of ports). Simply cycling through the hash $main::CODE{main}{allocaports} seems to always give the same sequence of ports, which is what I need (i.e. determinism). So I guess I am ok with the current approach unless it breaks.



2017.09.05:

3. Working with floating points, I experimented with 32-bit SP floats on Quartus, noting that if I optimize for freq (at 200 MHz on S5), then I get a latency of 5, 400 LUTs.
I will use this in my costing/scheduling for now, and should perform more experiments to make this more compreshensive. TODO
Also, think about how to incorporate floats in code generation. TODO

4. in version 2:
;-- the floating operation does not make any sense as it is
;-- working on integer inputs and assigning to integer output
;-- but it serves the purpose, i.e., introduces unbalanced
;-- parallel paths


5. ** Because output ports in hierarchical functions are not SSA themselves, so their CONSUMES and PRODUCES end up being the same thing; but we have to indentify that this is NOT a reduction.


2017.09.15
--
6.  When playing with illustraion.tirl ver1 (hipeac example), I came across the case where the scheduling leads to the two outputs out of step (this does not violate any scheduling conditions). But that will not work when that function is used in the parent, so I have to make sure all outputs are in-step, by buffering any that are computed earlier.



7.	SMACHE and offset variables: These are separate nodes in the DFG, but effectively represent a single hardware entity, so I have to be careful about how I treat their cost and scheduling. This is my approach:
a.	The registers/resources required by the smache module are included in the inferred smache node: there may be (usually are) multiple offset variables being created from a single smache node, so the smache node should reflect the total resources required by all (i.e. enough for the maximum offset). There is no meaning of latency for a smache node as each child will have a different one? [TODO: think about this; do we want to synch all outputs from the smache node? That makes sense!! That is how it works in reality in the  way I am making the smache nodes? In such a case, the SMACHE node WILL have a single latency, equal to the largest offset. That is correct actually; otherwise we will start inferring buffers for child offsets, which is redundant as we already have buffers for all of them in the single smache node.]
b.	The impscalar DFG node for the offset variables will have zero cost, and 1 latency(?), as it is really a place holder for a particular offset distance from the SMACHE module.


8. For the cost model 
 

 2017.09.19
 

8. SCALAR CONSTANTS: Looking at how LLVM deals with scalar constants, I don't see any different treatment between const int and int. So I am not doing anything in TIR as well. But there should be a way to identify "streams" from constants, as then the buffering/synch requirements change. TODO

2017.09.26


## The DFG generator flow (the call back routine at the end of parsing a function)

createDFG(pass=1) --> localScheduler --> createDFG(pass=2) --> globalScheduler

createDFG(pass=1): Adds all explicit (non-inferred) nodes.  no DOT edges yet as buffers may be added, and I cant undo DOT edges. But abstract-DFG requires edges for localScheduler to function, and are added.

localScheduler: 
  #  - Schedules inside function
  #  - does not calculate global function parameters yet (edges to inferred buffers not added yet)
  #  - Also infer buffers (adds new nodes)
  #  - REMOVES any previous edges where new buffers have been inferred

createDFG(pass=2):
  #  - second pass, adds new abstract edges for inferred buffers
  #  - creates ALL DOT edges

globalScheduler:
 -  calculates function's black-box parameters (the scheduling tuple)




2017.09.26

// Note that the OVALID logic of the generated pipeline does not propagate IVALID(STALL) through the 
// kernel pipeline latency. It simply follows IVALID with one cycle delay
// so that we can deal with asynchronous STALLS of the testbench/OCL-shell.
// SO: in the TB, data is valid ONLY when OVALID *and* the lincount indicates
// we have waited long enough for the kernel latency to pass. 

2018.04.04:

* Creating CG pipelines in OCL (to enable introduction of OCL-based smart buffering later)
* My current approach is:
- always create input and output kernels that access global memories
- turn all TOP level kernels into OCL kernels (i.e., main --> theOneKernelinMain --> **topOCLKernels**)
- introduce stencil buffer between these kernels if needed


MOVING TO AWS-SDx

+ See following notes
+ also see this google doc https://docs.google.com/document/d/17bUyUWYpTv-BpbUmyZVyYWGSAY1cOW0MiocNYhyY84Q/edit?usp=sharing




2018.10.09

- Now that I have moved to SDx, some things are changing.

- I am using this opp to move to completely asynch scheduling using AXI-stream type handshaking

- For code generation, I want to retain whatever progress I'd made for AOCl code generation, so I am adopting the following approach:
  -- Core HDL (generated by the HdlCodeGen.pm module), should be SAME irrespective of target*.
  -- The OCL shell/wrapper generation would obviously be different depending on target, so I will have separate modules for generating
  AOCL shell vs SDx shell code (and the same approach could be extended to Maxeler)
  * This will breakdown when I introduce hand-shake based synchronization in the HDL, as the AOCL shell currently can only deal
  with fixed latency, fully sych scheduling only

- Assuming single output at the top (and for now, two inputs streams)  

- I am also assuming a single producer-consumer (that is, one node only connects to one other node) model at this barebones level; but this has to change obviously

- Having a single node "func-arg" which is both a NODE and an ARG makes code awkward. Maybe split them to separate nodes when 
 parsing? TODO

 
-
2018.10.22
-

* I am looking to vectorize the SDx code now. 
* My previous work with vectorization "vectorized" EACH node separately (that is, I don't simply replicate the top module, but create replicated datapath
at the lowest node leaf. So vectorization does not ADD to the total number of modules/nodes, but vectorized each and every node in the path)
* So I have can work off the previous vectorization of the datapath, and now I have to ensure that:
  - the AXI4 read and write masters are "vectorized" (i.e. wider width)
  - the AXI-stream inter-kernel communication are "vectorized (i.e. wider width)
* If we want to use multiple banks, we need ONE INTERFACE PER BANK. the opencl option --max_memory_ports creates
 ONE INTERFACE PER ARGUMENT, so that potentially each argument can access a bank on its own. But this means I'll
limited to 16 arguments, as that is the max interfaces allowed.
* This is probably a good approach to begin with (i.e. MAX 16 globably memory arguments), and if more needed, we 
can assign multiple args per interface (up to 10 args per interface)
* See "using multiple DDR banks" in the sdaccel opt guide
* Use the RTL wizard's generated main.cpp file to see how different banks might be used 
  



* :: DRAM interfaces and memory banks::

+ I created three separate GMEM interfaces here (one for each vector); the sample code
created three separate masters for each interface (which is ok), but also 3 separate compute kernels
for each (which I dont want), and this needlessly complicates the situation.
It SHOULD be possible to use this template to do what I want to do, but still, it needlessly
complicated things at this early state, so I am going to try to vectorize over a single interface.
BUT I should come back to separate interfaces, and separate banks TODO

* From manual RTL integration guidelines:
- Use an AXI data width that matches the 
native  memory controller AXI data width, typically 512 bits. 
-Use burst transfer as large as possible (up to 4KByte AXI4 protocol limit) 
  
* The "read master" (of 1 interface) can reads on a data bus that can be upto 512-bits wide, and can handle multiple   
CHANNELS, (which is how we handle multiple args on the same interface). The read-master does an interleaved READ from the channels
each read is BURST-SIZE*READ-WORD-SIZE, so best to use maximum of both for maximum throughput.

* VECTORIZATION
-
+ When I am vectorizing, one trivial option is to ALWAYS vectorize GLOBALLY. That means the entire pipeline is replicated AT THE TOP level, and the data fed is loaded/stored in a vectorized fashion from the GMEM.
+ However, I should have the ability to vectorize at the node level. That means I am able to split single nodes into "vector nodes", and 
they EXPECT to get vectorized data at the input.
#idea:: to provide vectorized data, I can create a VECTORIZATION WRAPPER for the node, only needed IF the previous/subsequent nodes are not vectorized (or not vectorized by the SAME amount). This is becomign very similar to split/merge, but I see no other way.
  
* For TESTBENCH code generation, refer to previous tb gen for AOCL which was quite ok, and was working for floats as well. Just needs
some small modifications for sdx integration

*  Currently I have separate template for each vector size for LEAF NODES; no need for this, I can generate them from a template; TODO
(However, since I am currently vectorizing at the CG level only, so this is not immediately relevant)

* TODO: I have currently tested only for 2 inputs, on a commutative operation, so I can't detect errors if inputs are mixed up/used in the wrong sequence.
I should try subtraction e.g. to confirm.



2018.11.13


* INDICES AND BOUNDARIES


*  The most practical option for accessing indices on FPGAs is to create a counter, and tell it how to count (so that it can e.g. create
  2D indices).
  
* boundary check booleans
  TODO: LLVM-IR treats these compund conditions in a very 
  different way 
  It generates a series of branch statement, one for each condition
  translating that to the following code is not straightforward
  See testcode/8_.../c2llvmExp for generated LL code
  
  
## AXI stream rules

* Multiple AXI stream inputs to a module (multiple ivalids)
-

GENERAL::
* Looking into Kahn Process Networks, and other dataflow related models and programming paradigms.
* Ref [1], if I have blocking writed (KPN dont as they assume infinite FIFOs), then there is a chance of 
an artificial deadlock. The way to avoid is to have bounded buffers B, whose size can be calculated (which I kinda do).
* The above forms the rationale for having buffers, as I DO have blocking writes in AXI-stream protocol (IREADY)


LEAF NODES::
* There would almost always be multiple inputs to a node, and we SHOULD NOT make assumptions about
their synchronized VALIDITY. 
* So: we AND all IVALIDS (and also OREADYS), and only give a common IREADY to preceding nodes when all inputs and output nodes are good to go.
* Multiple input valids are handled INSIDE the node, as it is independent of structure outside the node. We always AND
the IVALIDS of ALL inputs
* Multiple outputs (That is FAN OUT, *not* multiple different output streams which I currently dont allow) are not visible
to the node, so we have a single output port. If we need to fan out this output to multiple nodes (which may have different
READY states), we need a *FAN-OUT* node.
* In case of vectorization, I always choose _s0 signals for IVALID (or OREADY) as vector elements can be expectedd to be synchronous

HIER NODES::

VIEW #1:
* Hierchichal nodes will always represent a map or a fold, consuming a TUPLE.
* However, not ALL of those inputs will be consumed immediately of a necessity. E.g. one input may be a counter
used in a SELECT node at the end of the pipeline. Also, there is a possibility of false deadlocks (see above) as we one
node might block a path which is also blocks the path of one of its predecessor nodes.
* SO, I will need to introduce buffers with SAFE BOUNDS computed to avoid deadlocks. 
* Also note the requirement of MONOTONICITY and CONTINUITY as described in Kuhn's paper; use for my paper.
* Relevant links:
http://www1.cs.columbia.edu/sedwards/papers/kahn1974semantics.pdf
http://daedalus.liacs.nl/details.html
https://en.wikipedia.org/wiki/Reactive_programming
https://en.wikipedia.org/wiki/Flow-based_programming
https://en.wikipedia.org/wiki/Petri_net
http://www.usingcsp.com/cspbook.pdf
https://en.wikipedia.org/wiki/Dataflow_programming
https://apps.dtic.mil/dtic/tr/fulltext/u2/a278687.pdf (look at the TOKEN model, this is NB
https://infoscience.epfl.ch/record/207992/files/EPFL_TH6653.pdf (thesis, good one, basis of Daedalus))
https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=808566


<DISCARD>
* We can expect them to have syncrhonized consumption/emission of results, even if leaf nodes inside
them have different latencies etc.
* There may be corner cases where consuming differnt inputs (or producing differnt outputs) asynchronously from a
hier node would leaf some perf improvement; seems unlikely when I think about it, but come back to it if needed. 

VIEW #2 (DISCARD)
* Hierchichal nodes are a modularizing abstraction, not a "real" boundary. 
* What this means is that if it has multiple inputs (as it almost always will), there is no presumption that they would
be consumed synchronously INSIDE the node (whereas such assumption is valid for leaf/primitive nodes). Those inputs may or may not connect to the same leaf node inside, or there may be another hierarchy of nodes etc. 
* This means no need to AND then and create a single IVALID input
* What about IREADY? :: following this logic, IREADY should be the same (that is, separate for each input).
*
<\DISCARD>

* Multiple AXI stream _outputs_ from a module (multiple ovalids)
--
* A hier node may have multiple outputs. Internally, one of them may be available earlier than 
the other(s). So while in theory we could have separate, unsynch ovalids, it breaks the unity of the node in a DFG. Each DFG is currently identified with a single tuple of params (specifically, LATENCY), which is used to infer buffers and their minimum sizes. This rules out multiple ovalids (I can keep multiple ovalid signals for the convenience of making connections, but they all must map to the same signal. Better to keep the same name of ovalid for _all_ output signals, i.e., name ovalid after the module, not the identifier of the output node. See comment for 2017.07.15).
* The exception is the latency fifo buffers, which may have multiple taps with their own ovalids. 


********************************************
## MY Rules for handshake signals in LEAF nodes::
********************************************

* IVALID: input  :: all input ivalids ANDED to create a single IVALID; 

* OREADY: input  :: I assume a single output (SSA), so a single OREADY
                    (If multiple consumers for the same output, then multiple OREADYs have to be externally handled)
* IREADY: output :: IVALID & OREADY
                    i.e.: all inputs valid, and output ready
                    (internally, I connect IREADY to my "dontStall" signal)
                    
* OVALID: output :: Latency delayed version of IVALID

********************************************
##  Rules for handshake signals in HIER nodes **
********************************************

* IVALID: input  :: all input ivalids ANDED to create a single IVALID; this IVALID connected to all internal nodes in the "first" stage (i.e. any node that directly reads from an input port)

* IREADY: output :: Only asserted when ALL FIRST stage modules IREADY asserted

* OREADY: input  :: And them all to generate OREADY for all LAST STAGE  nodes.

* OVALID: output :: AND all last stage OVALIDs to create this.
  EXCEPT: fifobuffers with multiple taps, which can be valid at different times
(this is ok for all)

  
** Placement of handshake signal reduction and 
** their Naming rules in HDL module ports for handshake signals

+ ivalids:: are input separately to a hierarchical module
- ivalid_<signalName>_s0
- they are anded *inside* the heirarchical module

+ oreadys:: are input separately to a hierarchical module, and need different names.
- oready_<signalName>_s0  
- they are anded *inside* the heirarchical module

+ iready:: emitted as a single output
- iready
- created inside the module

+ ovalid:: emitted as a single output
- ovalid
- created inside the module

  
# Naming rules for RTL code generation
  
2018.12.03


* The TVALID TREADY handshake of AXI allows three scenarions:
- VALID before READY
- READY before VALID
- both together

I seem to be having both cases in operation.
* Genreally iready is asserted when ALL invalids are ready
* Buffer asserts IREADY all the time, and reads in data 
when IVALID is asserted


## Naming rules of data and control signals, with vectorization involved
+ Vectorization happens inside the TOP kernel
+ Until func-hdl-top, all data is coalesced into 1 input and 1 output. func-hdl-top then slices into different IOs
+ vectors remain coalesced until they are _inside_ the TOP kernel. There they are slices for use in the CG pipeline.
+ The _sX suffixed are needed _externally_ for all connections at TOP, as multiple lanes would be present in the same scope.
+ The _sX suffixes internally:
  ++ Needed for atomics like smache and autoindex (they are vectorization aware nodes)
  ++ NOT needed for all others (they are _not_ vectorization aware)

# BUFFERN INFERENCE
* I an using a FIFO buffer with 2^N size, so it will
in most cases be larger than required synch (e.g. ther emay be a 5 cycle synch needed, and the FIFO buffer will be 8 words deep then).
* I read from the FIFO only when output says it is ready.
* Output will only say it is ready when ALL its inputs
are VALID  
  
2019.02.05::
-
+ oready port name in child module's port list was incorrect, correcting it
+ Not sure why I prepend "conn" to signal names in code generation Don't want to break things now but should come back and make it more uniform: TODO
+   
  

# How I generate hierarchical nodes: flow
+ go to gen HDL
+ get ALL nodes
+ identify connected groups
+ for each connected group (HDL module)
  + if MAIN
    + call gen_hier for MAIN (as it is never a NODE in another parent graph)
  + for each node (item) in group
    + if leaf node (impscal or func-arg)
      + call gen leaf node
    + if fifo buffer
      + call gen fifo buffer
    + if MAIN
      + call 
    + if hier code
      + call gen_hier_node
    
    
+ gen_hier_node()
  + set data type
  + find connected group for this module/hier node
  + get its ident in $ident
    + for each item in this group
      //ports
      + if arg OR func-arg
        + create data ports
        + create ivalid (wires, and AND logic)
      + if alloca
        + create port
      //instantiate child modules
      + if impscal, func-arg, funcall, OR fifobuffer
        + for each vector word
          + begin module instantiation
          + if func-arg (//it has no explicit consumer)
            + output port connection to child
            + if output (wont it ALWAYS be output?)
              + ovalid and oready connection to child
              + create ovalid wire
              + append to ovalids AND string
          + for each consumer
            + data port connection in child module
            + ovalid wire
            + append ovalids and string
            + if consumer is module (not a port)
              + create data  peer connection wire
              + create valid peer connection wire
              + create ready peer connection wire
              + connect ovalid port in child module
              + connect oready port in child module
            + else (consumer is port)
              + connect ovalid port in child module
              + connect oready port in child module
          + for each producer
            + data port connection in child module
            + create iready wire
            + append ireadys string (if producer is port)
            + if producer is module
              + create data  peer connection wire
              + create valid peer connection wire
              + create ready peer connection wire
              + connect ivalid in child port
              + connect iready in child port
            + else (producer is port)
              + connect ivalid in child port
              + connect iready in child port
          + remove duplicates
          + close open-ended code lines


# General Notes Continues
        
2019.02.11

+ Temp change in focus to (for Systems talk): integrate with MSc project to go from opencl with pipes all the way to vectorized solution (rather than from TyTra-IR). so back to testcase 0].

+ Tried MSC students' python code, but too many integration issues, so switched to my own
recdescent based parser (re-using a lot from c2llvm2tir). 

+ See lib-intern/ocl2tir/README for more


2019.04.03

+ Detour again, for Hindawi, going back to FPODE version of TyBEC which was generating correct code for testcode 0 (barebones) with vectorization
+ Reverted to old version, now on ../TyBEC_Releases\TyBEC_R17.0_20181030
+ updated BOLAMA to have TyBEC managed by "module"
+ For Hindawi, working off revision r11027  (load tybec/2018.4.r11027 from module)
+ The later branch is tybec/2019.1.rCurrent, but it is under development so was broken and not suitable for Hindawi results.

+ Also, I added a new script for generating AFI after synthesis. It is only in one example in ../TyBEC_Releases\TyBEC_R17.0_20181030
/home/tytra/Work/_TyTra_BackEnd_Compiler_/TyBEC_Releases/TyBEC_R17.0_20181030/testcode/0_barebones_pipeline/tir/ver1_baseline/TybecBuild_20190401/genFPGACode/awsf12x

TODO: add it to automatically generated sdx code

2019.05.29

+ Coming back to main branch of development now (r.2019.current) 

+ I used to have separate iready's for each input, but redundant, a single should
  #be used
  
+ I follow if VALID *after* READY protocol; otherwise data starts propagating when iready not asserted
  That is, the producer should assert its ovalid (i.e. ivalid of consumer) *if* it sees its oready (so iready  at the consumer) asserted. 
  This is why all ovalids now depend on oready's being asserted
  
  - This means my IREADYS cannot in turn depend on IVALIDs, otherwise I have a deadlock due to mutual dependence.
  - IREADYs are now asserted only by looking at if all OREADYs are asserted; IVALID may or may not be asserted.
  - It takes a few cycles for the oready --> iready to propagate from sink (which ideally is always ready but we can't depend on that), all the way back to the first stage of the pipeline and on to the source, which only asserts DATA and IVALID if it sees IREADY downstream.
  
  
+ When a node has multiple predecessor, then its single IREADY  output would connect to multiple
predecssor nodes's respective OREADY signals. This fan-out will be done in the parent module's glue logic.

+ When a (HIER( node has multiple outputs, it will have multiple successors, and it will have mulitple OREADYs feeding it, which are  ANDED *internally*. 

+ However, LEAF nodes *always* have single outputs, but those may be fed to different nodes, so we need a FANOUT node (basically, externally AND the respective OREADYs to create a single OREADY) 

+ Even in HIER nodes, we may have a fanout from one of the outputs, so it needs to be handled as per the previous point.

+ There are 4 producer consumer cases (and OREADYS and IVALIDS must be dealt accordingly:
(When I two Ps or Cs, e.g P1, P2; it means it can be P1...PN)
(leaf can have only one output)

* both hier and leaf
- P1_sig1 <> C1

- P1_sig1 <> C1
  P1_sig1 <> C2

* hier only
- P1_sig1 <> C1
  P1_sig2 <> C1
  
- P1_sig1 <> C1
  P1_sig2 <> C2
  
(See notes in notebook 2019_01)

2019.06.10


+ The FIFO buffer does not fare well when I need a single cycle delay. (so the FIFO buffer size is 2^0 = 1. Looks like the minimal viable size is 2^2 = 4. Think about creating your own minimal FIFO shift register based on FPGA registers (rather than BRAM) -> get a core from my RTL work on smache. May be required anyway is I need multiple taps from the buffer, and the core I am using is unyielding.

+ Following on from the above, the FIFO buffer IP I was using is actually unsuitable as it acts as a FIFO, and NOT as delay line with an exact latency! The FIFO was declared as a 2^N memory anyway, which does not suit me.

+ #if producer is fifobuffer, it can have multiple ovalids AND oreadys (this is the only case where we would have multiple ovalid and oreadys) so the ovalids/oreadys are appended with relevant output data identifieer
  
2019.06.12

+ movign (back) to floats in the new asynch hand-shake scheme
+ Note simulations run on Xilins ISE. Modelsim not allowing mixed HDL.
+ Using vivado on Bolama works, as Xilinx ISE on local machine was not compatible with SV 
(i.e., I need a sim tool that allows SV, V and VHDL together)

2019.06.17

+ The FP solution working as of 2019.06.17 (testcode/3_...)
+ Required ivalid propagation in the leaf nodes (hier nodes were already doing it)
+ FP testbench also being generated
+ Regression test with integer version (testcode/0_...) also ok
+ The key next remaining task is stencil buffers, then I am ready to experimet with 2d-shallow
+ AFTER this, look into branches and loops
+ Then into vectorization (again) with all of the above
+ Then do Hindawi revision  

2019.16.13

+ Saving the primary development branch as back-up today, both on SVN and locally on laptop.
+ Going on to calcualte costs for different problems, for Cris's paper.
+ When I come back, see ./DONE_TOCONTINUE for 2018.11.13
+ 

2019.16.13

+ Looking at c --> llvmir --> tir for SOR, 2dshallow, etc+
+ SOR ok (though I want to re-forest it


+ Note that for the c2llvm2tir pass, I am using a combination of gen  the LLVM-IR code, then manually using parts of
it that are useful to generate the TuTra-Ir (I could probably automate that quickly)

+ Things I need to do to the C code to make the LLVM-IR behave:
- scalarize (remove loops, replace array accesses by scalars)
- Write  floating point constants like this: eg. 5.0f (otherwise LLVM-IR is cluttered with double-float converions
- have a stub definition of ABS/fabs function that is used in the code
- output global variables must be pointers, and assignments to them have to be accordingly made (*out = a + b)

+ Things I am currentlt manually changing from llvm-ir to make it work as TIR
(I should be able to do all this automagically)
- call to stub functions (e.g. ABS) is handled differently
- floating point immediate constants are written without e (do I really need to make this change)
- store instructions (to pointed variables) is removed, and output is directly assigned
- output variables are not pointers anymore
- LHS variables have to preceded by type
- all floats have to replaced by float32 (or data_t)
- #define fadd add
#define fsub sub
#define fmul mul
#define fdiv udiv
#define data_t float32



2019.06.18

+ Looking at SOR, 2dshallow etc
+ CONSTANTS: The least painful way to deal with them for now is to either write them as immediate operands in the TIR, or #define them if you want to use their identifiers
+ 

2019.06.19

+ Re: discussion with Cris
+ In order for the split/merge optimizations to be of use, there must be nodes that  have a *throughput* of _less_ than 1 output/cycle (Or, say, CPI of > 1)
+ Latency of > 1 but CPI at 1 is still optimized, with further optimization possible only by vectorization. Latency in this context is not relevant. So floating point arithmetic units using pipelined units (e.g. the kind produced by flopoco) are not suitable candidates.
+ We also don't count folds (or equivalently, dimension reduction operations), for such optimization, as they still consume an element every cycle and we don't get anything by splitting them. Here too, only vectorization will help).
+ The only case where we benefit from split/merge optimizations is when there are multi-cycle _map_ operations, resulting in a _throughput_ of less than one (or, equivalently, CPI of > 1).
+ Such  nodes will the same number of (more than 1) cycles to _both_ consume input and produce output.
+ A good example of such nodes, frequently encountered in scientific code, is transcendental functions like cos, sin, exp, etc, which are multi-cycle but _not_ pipelined (see cordic algorithms). 
+ Any functions containting one or more such instructions would benefit from split/merge optimizations. What exactly is split by the CL depends on the granularity of _nodes_ made visible to it. A naive approach would expose an entire function as a candidate, when only one of its instructions might be the multi-cycle bottleneck, since functions are opaque to CL.
+ Such a first-order approach would still yield better/optimal peformance, but would waste resources by replicating entire functions, when only one instruction was the bottleneck.
+ This could be solved by fission/re-forestation, creating finer-grained kernels that expose 



2016.06.20

I can't allow output arguments in hierarhichial functions to *also* be intermediate
arguments between peer kernels
That's because each module/node has to be synchronized at the output, so allow
outputs must be valid _at the same index_ at the same time.
o te following is not ok (note un and vn)

define void @kernel_top(  data_t %u, data_t %v, data_t %x, data_t %y, data_t %un, data_t %vn,data_t %xn, data_t %yn) pipe
{
  call @coriolis_ker0 (  data_t %u, data_t %v, data_t %un, data_t %vn) 
  call @coriolis_ker1 ( data_t %x, data_t %y, data_t %un, data_t %vn, data_t %x, data_t %yn)  
}

See testcode/12_... to see what _is_ ok

2019.06.25

+ To experiment with iterative nodes (multi CPI/CPO), I am artificially insering POW function
into SOR.
+ The POW stub function should by recognized as an intrinsic function and dealt with as an opaque node (imported from Flopoco in my case)
+ TODO: Look at how AFI is caculated for a FUNCTION which has a PRIMITIVE instruction of AFI of > 1
 - rethink terms AFI, FPO, (use CPI, CPO?, and derived, IPO)
 - 

2019.07.01

+ Back to critical path, with focus on Hindawi paper
+ *Vectorization*, with *stencils*
  - See earlier notes on vectorization (search for "vector")
  - Since I am vectorizing at the CG level (the entire kernel pipeline), it means the internal stencil buffers
    would be also be _naively_ replicated. This should work for the Hindawi paper, as I  want to test with 
    interesting real examples, e.g. the 2dshallow water. 
  - The more interesting approach is to have a single stream buffer that issues vectorized stencils, but I want to explore that separately.
+ Using a streams offsets, without using it itself in a kernel, caused tybect to hand, not sure why (FIXME)
e.g. 
define void @kernel_A ( 
    i32 %kt_vin0
  , i32 %kt_vin0_ip1_j
  , i32 %kt_vin0_im1_j
  , i32 %kt_vin0_i_jp1
  , i32 %kt_vin0_i_jm1
  , i32 %kt_vin1
  , i32 %ka_vout
  ) pipe {
  i32 %9       = add i32 %kt_vin0_im1_j, %kt_vin0_ip1_j
  i32 %10      = add i32 %kt_vin0_i_jm1, %kt_vin0_i_jp1
  i32 %11      = add i32 %9, %10
  i32 %12      = add i32 %kt_vin0, %kt_vin1 ;--OK
  i32 %12      = add i32 %kt_vin1, %kt_vin1 ;--HANGS
  i32 %ka_vout = add i32 %11, %12
  ret void
}
  

+ #This following redundant; no need to have nodes in the DFG for each offstream
  #The smache module should be treated as just another module with a latency
  #that emits multiple outputs. Otherwise we break the opaque uniformity of nodes
   --> #-
    #offset stream node
    #-
    #Entry in the symbol table for the created stream, which effectively is 
    #treated as just another impscalar. What it "consumes" is the 
    #"pre" stream created from the offset module.
    
+ Variable Identifiers in TIR:
  - LLVM-IR allows number to be used for variable identifiers
  - TIR uses variable names in verilog, which does not allow numbers, so I could have either updated by backend to prepend
  variable names with non-numeric characters (e.g. data_12), or restrict TIR to using identiders that begin with non-numeric characters.
  - I am going with the latter, least painful (perhaps!)
  - SO: LLVM-IR identifiers should begind with non-numeric characters.

+ smache
  -   #the output is "valid" when the maximum POSITIVE offset is in (and thus the *current index* is now at 0)
      #if, at this point, you try to generate and access and _negative_ offsets, you will get garbage values
      #as the current index is at 0, and negative indices dont exist
      #boundary conditions in the subsequent nodes should take care of this (OR, we can emit strobe signals 
      #from the smache
  
+ TIR: Any expressions used in place of constants (e.g operands, offsets, etc) must be enclosed in parenthesis

+ autoindex:
  - nestOver is more useful, as the outer counters are effected by the nesting (their triggers are based on 
  wrap triggers of "child" counters.
  - nestOver is now _necessary_
  - nestUnder is valid, but redundant (put in the tokens hash but then ignored)

2019.07.05
  
+ Major milestone: testcode 8complete (autoindex, compare, select, boundaries, and stencils) . OK  MAJOR MILESTONE
+ Should be ready for 2dshallow now.
 

2019.07.09

+ DFG:
  ;-- I can't allow output arguments in hierarhichial functions to *also* be intermediate
  ;-- arguments between peer kernels
  ;-- That's because each module/node has to be synchronized at the output, so all
  ;-- outputs must be valid _at the same index_ at the same time.
  ;-- If I put delay buffers to synchronize such local-use-also ouputs to other outputs,
  ;-- then their local consumption will suffer latency, delaying the other outputs further still, so 
  ;-- and so on ad inifintum...
+ DFG:
  - there is an additional constraint on the SD that can only be considered on a second pass over all
  - OUTPUT nodes: All output nodes must have the *same* OPD (output delay), where
    - OPD = SD + LAT
      (in case all output nodes have the same lat, then we simply need to match their SDs. If not, then 
      there SDs need to be staggered to ensure output is emitted synchronously)
      
    
  - equal to the maximum OPD of all nodes (already calculated in the previous loop). This SD/OPD constraint, unlike others, is NOT
  - dependent on a predecessor,  but on "peers", which is why we need an additional pass to set this SD on 
  - all output nodes    


2019.07.15:

+ My code-gen was presuming a fully, _weakly_ connected graph for each module/function
(See definition here: https://math.stackexchange.com/questions/1073558/weakly-connected-graphs/1073602)

+ However, there could be functions with completely unconnected graphs, in which case my code gen fails. So currently, I am limited to costraning function to _at least_ weakly connected graphs. (FIXME)

+ OVALIDS of hierarchical nodes
- All nodes (hier or leaf) have synchronized outputs, so a single OVALID
- If such nodes have multiple outputs, they may very well be going to different nodes, and each outptu signal willm
need its own OVALID. So: ovalids from hierarchical modules should be named after the _module_, rather than the _signal_. That way the same ovalid signal could be re-used for all the different output data.

+ If one operand is constant in a leaf node, it MUST be the SECOND operand. This is a silly limitation, will fail in non-commutative operations anyway. FIXME.

+ Flopoco:
  + added div and sub units (stallable version). Also hdl required some re-sgtructuring as synth was not allowing certain branching structures under clocked procedures.

+ DFG
  + synch at output: The synch of peer nodes at the output of a hierarchical module need have to be synchronous _at the output_. I was (naively) synching their starting delays (SDs), whereas if they have different internal latencies (LAT), then synched SD's wont work. So now I synch there delay-at-output first (OPD), and their work back to their SD from it (depending on their latency).
  + The above correction means now my coriolis (scalar) is corrcect.
  + This is a major checkpoint
  
#bug report
-
+ on OCX-HDL integration hdl-emulations, some times a bug in your rtl (e.g. multiple drivers) manifests as "ERROR: [XSIM 43-3225] Cannot find design unit xil_defaultlib.emu_wrapper in library work located at xsim.dir/work." in the log file. See you last RTL changes if you come across this bug.
  + Generally theunderlying bug relates to port connections (but not always)
  + Best way to debug this is to run simulation in _vivado_ (not modelsim), and first ensure that compiles (and ideally, runs) bug free there.

+ If you have multiple inputs defined in the AXI control logic, then make sure your host, xml etc are also compatible. Otherwise the simulation hangs if e.g. you dont use one of the inputs (when 2 are defined in the AXI controller).

+ Hardwiring output signals to a value for debugging for some stupid unexplained reason does not work in ocx-hdl integration in 2018.2 (worked ok in 2017.8 ver). No clue why this happens. Thank you xilinx...
  + OK:     assign m_tdata[127:96]= s_tdata[127:96]+32'habcd;
  + NOT OK: assign m_tdata[127:96]= 32'habcd;

+ The packed array format used in systemverilog (in my previous func_hdl_top, based on 2017.4 template) does not seem to work with 2018.2 template. E.g., even when there is no packing (CHANNELS=1), sliced access to vectors did not work.

+ in "", make sure the AXI buses are named correctly (should match the XML file):
  + ipx::associate_bus_interfaces -busif m_axi_gmem -clock ap_clk [ipx::current_core]
  + incorrect name manifested differently depending on template version; either it said missing clock, or unable to find some IP...

+ Buffer 4KB alignment requirement:
    + Device buffers MUST be 4KB aligned. So either define your size that way (e.g. 1024 ints/floats or multiples thereof), or explicitly define buffer addresses to be 4KB aligned.
      + This did not cause problem before, maybe a 2017.4 vs 2018.2 issue?

+ SDx: ocl-hdl sim not completing with message indicating that writing to the write pointer in memory did not complete.
    Would should read e.g. 8KB and write 4KB (when both should have been same at 8KB). 
    So when I changed the write size to half (like following) it compelte. 

    inst_axi_write_master (
      .aclk                    ( aclk                    ) ,
      .areset                  ( areset                  ) ,
      .ctrl_start              ( ap_start                ) ,
      .ctrl_done               ( write_done              ) ,
      .ctrl_addr_offset        ( ctrl_addr_offset_wr     ) ,
      .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes >> 1) , //WN
      .m_axi_awvalid           ( m_axi_awvalid           ) ,      
  
    - I solved it like so: XXXX
    
+ AWS CLI will not accept your access credentials if your systems time is out of synch with the actual time by a few minutes (around 5 minutes). 
It will _not_ say so when it fails, it will just effing fail. You will note that no .awsxclbin is created, and no text in the AFID.txt file.
https://github.com/mitchellh/vagrant-aws/issues/372

+ SDX/OCL only allows AXI MEM WIDTH to be:: 
ERROR: [VPL 19-3461] Value '192' is out of the range for parameter 'AXI DATA WIDTH(C_AXI_DATA_WIDTH)' for BD Cell 'sim_axi_perf_mon2_0' . Valid values are - 8, 16, 32, 64, 128, 256, 512, 1024
  + So your input and output widths need to add up to these, and if not, they need to be padded #TODO


+ use bigint;
  + in the perl code gen module, for the log2 func, *do not* use bigint as it messes up the results.

+ OpenCL host: Using enqueNDrange (with local and global sizes 1, 1) _should_ be same as enqueuTask, but does not give me the same kind of results.
This happened when I was testing testcode 6 (2dshallow).
  
  
# TARGET PLATFORM IN THE AWS-F1 - OCX-HDL INTEGRATION

2019.07.18


+ SDX-HDL Integration
  - The parameter "DATA_WIDTH" should ideally be set to _64 *BYTES*_ as per xilinx's recommendations (to match 512-bit data bus width)
  - For 32-bit data-type (int, float), this means a vectorization of x16 would be optimal
  - Note though that if there multiple IOs (as there would be), then they would be multiplexed over the SAME interface of 512 bits. To optimize this, I should have additional interfaces.
  - Ideally, one argument/interface, and one interface/bank (if I can afford this)
  
+ HIERARCHY (2018.2)
  - testbench / OCL SHELL
    - sdx_kernel_wizard_0
      - sdx_kernel_wizard_0_control_s_axi
      - sdx_kernel_wizard_0_example
        - sdx_kernel_wizard_0_example_vadd
          - sdx_kernel_wizard_0_example_axi_read_master
          - sdx_kernel_wizard_0_example_adder (USER LOGIC/MODULES) <--
            - 
          - sdx_kernel_wizard_0_example_axi_write_master
    - control_sdx_kernel_wizard_0_vip (master control, likely only for TB)
    - slv_m00_axi_vip                 (Slave MM, likely only for TB)
  - ../component.xml
          
+ HIERARCHY OF PREVIOUS VERSION (2017.4, as used in OCL-HDL code)
  - krnl_vadd_rtl
    - krnl_vadd_rtl_int
      - krnl_vadd_rtl_control_s_axi
      - krnl_vadd_rtl_axi_read_master
      - xpm_fifo_sync
      - func_hdl_top (USER LOGIC/MODULES) <--
      - krnl_vadd_rtl_axi_write_master
  - ../kernel.xml

  
  
  
This platform targets the Virtex UltraScale+ AWS VU9P F1  Acceleration Development Board with VU13P. This high-performance acceleration platform features four channels of DDR4-2400 DIMMs, the expanded partial reconfiguration flow for high fabric resource availability, and Xilinx DMA Subsystem for PCI Express with PCIe Gen3 x16 connectivity.

FPGA part:			xcvu9p-flgb2104-2-i
Number of DDRs:		four
Memory type:		ddr4
Memory size:		64 GB
Interface:			PCIe gen3x16  
  
* Creating SDx project (for using the RTL wizard for creating templates)::
- You need to target a platform when creating an SDx project, so need the platform file.
- if you have loaded sdaccel on your machine the way instructed in AWS-F1 sdacccel's  doc (I have put all that
in a bash file in ), then you will have the platform name in: 
[tytra@bolama ]$ echo $AWS_PLATFORM_DYNAMIC_5_0 
/extra/workTyTra/aws-fpga/SDAccel/aws_platform/xilinx_aws-vu9p-f1-04261818_dynamic_5_0/xilinx_aws-vu9p-f1-04261818_dynamic_5_0.xpfm
- When sdx asks you for the platform, direct it to the folder that contains this XPFM file.


## Flow:

>> Go to Sdx 
>> create a SDX project 
  + This is my standard location (workspace) for creating these template projects:
    + /home/tytra/Work/_TyTra_BackEnd_Compiler_/TyBEC/hdlGenTemplates/sdx_projects_2018_2
  + Project Type: Application
      + Platform:
         + Type: Platform
         + Custom Platform
         + Get parent diretory of $AWS_PLATFORM_DYNAMIC_5_0 
      + Empty project
>> Open RTL wizard
  + Make sure kernel name is exactly this: `krnl_vadd_rtl` 
    (makes integration with TyBEC's github based templates simpler)
>> set args etc as needed and generate
    + has reset = 1
    + interface
      + one scalar input (for size)
      + one interface
      + 2 arguments (input and output combined)
      + Keep default name of buses and arguments
      + 
    +
>> Vivado will open: if needed, modify/add RTL code, then go to:  Generate RTL Kernel --> Source-only kernel packages 
>> Exit vivado and return to Sdx
>> Unpack XO file
>> Use!
  + Add your own RTL
  + Make sure scripts/package_kernel.tcl has all the interfaces with corret names connected to clocks
      ipx::associate_bus_interfaces -busif m_axi_gmem -clock ap_clk [ipx::current_core] 
        TO
      ipx::associate_bus_interfaces -busif m00_axi -clock ap_clk [ipx::current_core]
  + The template has the device reading and writing to the _same_ address in global memory.
  + To change that, make sure that the read master and write master are passed different addresses
   + That is, in krnl_vadd_rtl_example.sv, instead of just one argument:
      .ctrl_addr_offset        ( axi00_ptr0              ),
     which eventually gets passed to _both_ reader and writer, you need two different ones. See template used for coriolis.
         .ctrl_addr_offset_rd     ( axi00_ptr0              ),
         .ctrl_addr_offset_wr     ( axi00_ptr1              ),
      
        // NOTE THOUGH: assign ctrl_addr_offset to a 4kB aligned starting address.
        // 
        
  + In krnl_vadd_rtl_example.sv
    + localparam integer  LP_DEFAULT_LENGTH_IN_BYTES = 16384; //FIXME???
  
  + Insert your RTL top in the file: krnl_vadd_rtl_example_vadd.sv
    + update AXI signal connection names if needed
  + Update host as needed
  + run "local_hwemu...sh" script that tybec generates
  + if you make changes to host only, then run "local_host_only...sh" script
  + Once happy with simulation, go on to full synthesis: "local_hwSynt...sh"
  + Next: run on F1


## RUNNING ON AWS

+ The provided bash scripts will have created the xclbin file already. Note that HW build takes several hours.
+ The ./local_build_afi.sh that is copied into the custom build folder should now be run to turn this bin to an AFI on the S3 storage. Note that this can take several minutes.


+ Then you are good to log into the F1 instance, copy in your host binary and the awsxclbin file created by he above script, and run your code.
+ use the move_files_to_github_for_awsf1.sh script to copy files from your build folder the local github repo synch folder (fixed in the script)
+  then log on to F1, and git clone: https://github.com/waqarnabi/awsCode.git
  + username: waqarnabi
  + pass: iso...80
+ if any change in original:
  + git pull origin master
  
  (_obsolete_ 
  again generate files, put them on git-sync local folder, commit to git, and then again _clone_ from git on F1 
  git clone https://github.com/waqarnabi/awsCode.git)
  

  OR

+ Try  scp for copying files (scp from local/BOLAMA, into F1)
- scp to F1 will require using ssh key, as follows (e.g on BOLAMA)
scp -i /.ssh/tytra-ireland.pem -r LOCAL_FILE centos@<F1-instance-address-from-aws-console>:<DEST_FOLDER>

(+SVN worked well but with more restrictions at the school, F1 instance cant access the repo
    + You could try instaling VPN on the amazon instance for more convenient SVN route? [https://www.gla.ac.uk/myglasgow/it/vpn/#/downloadvpnclientforyourdevice,connecttovpnoffcampus]
)

+ On F1, if you havent already got it, download the aws-fpga respository, and soruce sdaccel_setup.sh.
$ git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR #this is probably not needed unless you just created a fresh instance
$ cd $AWS_FPGA_REPO_DIR 
$ source sdaccel_setup.sh

+ Install run-time drivers on the F1, and run in sudo mode:
sudo -E sh #-E ensures we keep env variables
export VIVADO_TOOL_VERSION=2018.2
source $AWS_FPGA_REPO_DIR/sdaccel_runtime_setup.sh 
./host xclbin/*awsxclbin




[See this link: https://github.com/aws/aws-fpga/tree/master/SDAccel for more details]
  

## NOTES ON SDX (OCL) RTL INTEGRATION (
--
+ The default names proposed by the RTL kernel wizard are m00_axi
and m01_axi. If not changed, these names will have to be used when assigning a DDR bank
through the --sp option.

+ A transfer takes place when both TVALID
and TREADY are asserted.
https://www.xilinx.com/support/documentation/ip_documentation/axis_interconnect/v1_1/pg035_axis_interconnect.pdf

+ // Set the data width of the interface (AXI GMEM Interface)
  // Range: 32, 64, 128, 256, 512, 1024

* :: SDX Hardware Emulation, Profiliing, Synthesis, Etc::

+ See this link on profiling information etc you can get from sdx hardware emulation
https://www.xilinx.com/html_docs/xilinx2017_4/sdaccel_doc/xsw1504034356419.html




# GENERAL NOTES CONTINUE

 
2019.07.29
## OCX (OCL) HDL Integration
+ Coriolis-12 now successfully integrated, with coalesced inputs and outputs (4 each), floating point data and units, etc
+ Tested for OCX-HDL integration, bugs removed (see #bug report)
+ Code generation now uses sdx template t09, which is based on template _generated_ by sdx (rather than the t01 
which was  based on template on github).
+ Coalesced IOs now operational, with the limitation that same numbner of inputs and outputs should be there. This is artificial, needs to be removed later: FIXME
+ Single DDR bank and interface used. This can be improved as well. TODO


2019.07.31
+ I was usign the 2018.2 HDL wrapper tempalte that I generated from SDAccel, for 1 input, 1 ouput. This synthesized correctly, but did not give any performance improvement in the vector versions on the F1. My guess is that is because the new template does not have an explicit "length_r" argument. It does have (what I thought was) an equivalent localparam, but it seems that is not entirely equivalent.
+ So the version as of today's commit generated code based on the template mentioned in the prev point, but  I am going to switch over to the OLD tempalte (based on example on github), which is now giving me correct result.
+ If this is the _last_ line in notes, then the generator is tuned to the NEW template, which does NOT give improved performane.
[I later found out problem was timing measurement  ignore entry]



2019.08.12
+ This is the version used for Hindawi Journal R1 submission. (It synchs with local SVN version: 11543)
+ Note notes for 2019.07.31: _after_ I switced to old template, I realized the problem was my timing measurement (I was measuring CPU cycles, not wall-clock time), so the new template _should_ be fine too. Next I will check that.



2019.08.12: Onwards
+ Now testing if new template also gives me ok results. If it does, then I can integrate it back into the flow  BUT I want to pass sizes as argument
+ The OLD vs NEW template situation is interesting
  - The OLD template gives better _relative_ improvement as we go increase vectorization.
  - the NEW template gives better absolute performance though
  - Why?
      [The old template might be giving worse absolute performance as the axi-reader I used was designed for multiple channels and has mechanism for handling multiple read calls on the fly; even if I use it for a single read channel, that may still impact peformance. I cannnot think of any other obvious reason].
  - See results in: .\testcode\12_coriolis\docs
[OLD = the template from xilinx's github repositiry examples]
[NEW = the template generated by SDx, 2018.2]

2019.08.15
+ New template now integrated, see results in .\testcode\12_coriolis\docs. I am going to continue with new template now as it is generated from SDx, which is what I prefer as I expect to require to require more template pattern (differnet IOs, more interfaces/banks, etc).
+ This marks an important milestone.


2019.08.21

+ Leaving stencils and focussing on multi-cycle units, with split-merge incorporation
+ The register-at-output mechanism of leaf nodes was flawed, exposed with multi-cycle units. Data is guaranteed valid at input WHEN IVALID asserted. If it is not registered at input, then invalid data may be allowed to propagate to (possibly multi-cycle units), or valid data at input may be missed. Makes much more sense to register at input.
+ I have made that transition, with regression test on barebones 0 at least. Still TODO: regression test for compare/select operations, as well as FLOATS.

+ Now successfully testing a simply multi-cycle testcode (#16, ver1). A painful bug was pipeline halting problem; when the pipeline is loaded from time 0 onwards, the ovalids are propagated as they should be. However, this is not the same as halting (as we will when there is multi-cycle latency) and re-starting the pipeline. In the this latter case, we need to _hold_ the staate of the pipeline and then re-start it from where it was (and not propagate ivalid again all the way through). This required a small change in the ovalid logic of leaf nodes. I have NOT yet updated FLOAT leaf nodes for this consideration, which should be done (TODO)/

2019.08.22
+ Successfully tested a [pndmap 2] wrapper, for an N cycle iterative stub function, for different N's. See docs/split_merge_ip_sketch

+ Using the _same_ connection to feed multiple inputs in the CG pipeline (so e.g. kernelA has output op1, which is fed to BOTH in1 and in2 in kernel B) does not work. If you want to do this, get a single input to second kernel, and re-use that input INSIDE the kernel.

2019.08.26
MILESTONE
+ PNDMAP: split/merge code generatio now tested, with testcode 16, ver3. 
+ A wrapper module is generated and for pndmap module(s). 
+ Tests completed (testcode 16, one multi-cycle unit at fi=7)
  - pndmap = 2
  - pndmap = 4
  - one input, two inputs
  - _not_ xple outputs yet (may be buggy, TODO)
+ I should be able to replicate this with _real_ multi-cycle units like pow, etc (as long as they follow the interface that I have in the stub multi-cycle unit)

2019.08.29

+ Auto-indices should have a latency of 0, not 1 (they do not _wait_ a clock cycle before updating output)+
+ Added signed support to testebench. Since integer operations in 2's complement take care of themselves, signed or unsigned, no change needed in DUT code.

+ I am currently not allowing _same_ stream to be _both_ input and output. But that should be easily doable. TODO.

2019.09.04

+ _Complete_ 2d shallow water, including all branches, stencils, etc, now generating from TyTra-IR, INTEGER version only though. Some limitations (e.g. having first operand constant in a non-comm operation) needs to be sorted.
+ Also, dis-jointed sub-graphs in a function not being allowed causes problems, requiring non-intuitive fixes to the TIR code that may be difficult for a front-end system to target. 
+ NOTE that testebench that is generated randomly chooses which output to check against GOLDEN results from C; it may not be the one you want, so manually change that if needed.


2019.09.04

+ pndmap on one of the two select branches does not work, as the axi stream interfaces do not sort out. 
+ I am bypassing this problem for CGO by adding stub operations to MULTIPLE update kernels


+ Anytime I have a case where paths are converging, and I don't have either (a) continuosly valid data on both paths OR (b) synchronously valid/invalid data, the current mechanism will fail. That would be the case if e.g. multi-cycle path on one and not on another, or at a differnt sequence such that they emit ovalids asyhcnorously, never arriving at the destination together.


2019.09.06
+ I have to first and foremost handle the issue of asynchronous branches
+ I _must_ then get rid of these artificial constraints to be able to do meaningful experiments:
  - nodes inside a function must be weakly connected
  - FOLD operations (at least unoptimized versions)
  - input and output must have same number of ports
  - constants can only be second operands
  - floats are not tested and integrated with latest features/examples (2dshallow water should work)
  - dataflow branches around nodes are not allowed
  - multi-cycle units have to simulated (why not actual ones from flopoco)
  - 

  
## DFG Handshaking, for asychronous parallel paths
+ IF we make the assumption that ALL nodes trace their inputs to at least ONE GMEM input, then _ANY_ node stalling should stall the entire pipeline.
+ In such a case, I don't need matching buffers any more, as the stalling node should stall _everything_. 
  - SO, I need synch buffers _only_ for matching _latencies_, given the _firing intervals_ are the same. If firing intervals are different, (and under the assumption that FI and LAT are same, which seems sensible), then mismatched FI's do NOT require latency matching buffers.
+ So nodes can either have LAT > 1, or F1 > 1, not both. F1 > 1 (with LAT=1) will ensure no buffers are inferred, and handshakes take care of everything.
  - HOWEVER: When we add PNDMAP to a node with LFT > 1, that _does_ add a latency to it, which WILL required a synchronization buffer on the other path. 
+   #lat is set by pndmap if pndmap is > 1
  #what happend though if there is an internal latency > 1 in addition to pndmap? Do I allow that?  
  
+ In other words, we can have 4 kind of nodes (from the perspective of LAT/FI, and their effect on parallel DF paths)
  - LAT = 1, FI = 1 ::  No effect on parallel DF paths
  - LAT > 1, F1 = 1 ::  Latency matching buffers needed on parallel DF paths
  - LAT = 1, F1 > 1 ::  No latency buffers needed, as when the node with F1 > 1 is not firing, it will stall its inputs, 
                        which would propagate this stall all the way to global inputs, which would effectively stall 
                        the entire pipeline, including any parallel paths.
  - LAT > 1, F1 > 1 ::  This will _only_ happen when we PNDMAP a node with F1 > 1. The FI in such a case will have a value 
                        which may be a fraction (e.g. if we PNDMAP 3 a node with FI of 7, it will fire 3/7 cycles). 
                        The pndmapped node will also now have a _latency_ > 1 (equal to pndmap factor), so any parallel
                        paths will need latency matching buffers
                        
NOTE that the above is a PUSH model of dataflow, which is why the latency matching buffers need to be of an exact size.                        

2019.09.11
--
+ Back to 2dshallow with modifications to how I handle multi-cycle nodes in parallel paths
+ Introduced in dyn1, failed. Go back to dyn1 unit test and try there, and try to debug.


## Autoindex counters and stalling nodes
When a node stalls the pipeline, its stall should propagate all the way to global inputs, including the counters being auto-generated from these global streams.
However, as counter _outputs_ were ALWAYS VALID, this failed. 
Since the parent stream is expected to be in synch with the global IVALID of the parent module, so I can simply connect the counter's ivalid to the global ivalid.
trig_count may be locked in an asserted by a nested counter even though input is not valid
so check for BOTH trig_count and input valid

2019.09.23

+ Disconnected graphs inside a hierarhical node; This is now ok as I use the token list to find all nodes in a function, though I then go on to use the DFG to generate the HDL as before. Important checkpoint.

2019.09.24

##FOLDS
+ I have gotten a barebones example working, where FOLD is the final operation in a kernel (it always will be), and that kernel is the final one in the CG pipeline.
+ However, it is not completely correct still as the OVALID is asserted as if it is still a map node (that is, continuously after an initial latency). So I need to create an internal counter that asserts ovalid for one cycle when the folding count is over (the value is given as meta-parameter in the IR). 
+ Next would be to test this fold on a concurrent path with a map, and see how that works.
+ Will also have to look at code generation outside the DUT (both for verilog TB and OCL shell) that can handle reduction outputs.

2019.09.30

##FOLDS 
+ See illustration on google keep for today's date.
+ The FPO of the final reduction instruction in a FOLDING function is used to find the FPO of the overall function
+ Fold instructions can ONLY be the TERMINAL instruction of a function, and that function can have just ONE output, which is that folded value.
+ I am able to create a fold function with "FPO" > 1, and which OVALIDS only when the reduction item  is ready, based on its size given as metadata.
+ CASE A: This is the CASE A from the picture mentioned earlier, i.e.: MEM -> f1_map -> f2_map -> f3_map -> f4_fold -> MEM.
  - The TB verilog code is not currently compatible and so I just checked for correctness in the waveform.
  - I should update Testbench to deal with it next.
+ CASE B: MEM -> f1_map -> f2_map -> f3_fold -> f4_map -> MEM
  - the output of the FOLD is _still a stream_, albeit at a slower throughput. It is used as such, and should be transparent in the code as well as the circuit.
+ CASE C: MEM |-> f1_map  -> | f3_map -> MEM
              |-> f2_fold -> | 
  - this is trickier: the ouput of fold is not usable as just another slower stream as it is *out of synch* with parallel node (it has to go _before_ it). I need explicit syntax for these semantics, and this will have impact on the code generation as well. See image on google keep.                


##General notes continue  

2019.10.14

+ For the moment I am putting the CASE C of Fold on hold, in order to get better results for CC.
+ For CC, I need to incorporate asymmetrical IOs in the first place, possibly floats too (though I should _first_ get better results?)
+
  
+ Going back to ocl-hdl integration, a new bug was introduced, where the write would not complete in the simulation, and the simulation would time out waiting for _enough_ writes from the kernel.

+ The "hack" I used to solve it was as follows: 
  - In krnl_vadd_rtl_example_vadd.sv
  inst_axi_write_master (
    ...
    //.ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes ) ,
    .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes >> 1) , //WN
  - in main
     int size_in_bytes_coal = size_in_bytes * NINPUTS * 2;
      //the "2" at the end should _not_ have been required, but since writer seems to be able to write half of what can be read, this somehow works.
  - I suspect the problem might be change from input registered to output registered?                       
  
+ now trying this:

      `#$str_ovalidLogic  .= "\nassign ovalid = ovalid_pre & dontStall;\n";`
      `$str_ovalidLogic  .= "\nassign ovalid = ovalid_pre;\n"; #WN`
  >>>> This turned out to be the issue. I am not sure if this will re-appear if I move back to units with latencies.
  >>>> I need to make this change at *2 places*
    + HDL code gen for leaf node
    + template for multicycle stubs (template.mapnode_leaf_multicyclestub.v)
    
       
       (It may be because I am shutting down the pipeline the moment I get a stall; this does not cater to the situation when the input stream has _ended_, which means input is "stalled", but the pipeline has not "flushed". This can be solved by the writer always trying to write slightly less items than the reader reads (and the reader would have to read some garbage values). Alternatively, I need to differentiate between "internal" and "external" stalls. I tried reading 100 less items at output (for a total size of 1024) but that did not work. It seems with the "dontStall" anded for ovalid, I get _half_ as many outputs as inputs, not clear why.
       
  + _BUT_ : When I tested 2d-shallow (int) version again, it failed  unless I reverted to the previous version (ovalid = ovalid_pre & dontStall;)
  + Will have to sort this
       
2019.10.21

## 2d shallow water 

+ For CC, the plan is to have a regular 2d-shallow water, followed by one with a multi-cycle unit (cos/sin). 
+ For showing DSE, we may have a cos/sin LUT+interporlation based version.
+ The plan:
  + (same port width issue sort first?)  _Not needed as 2d-shallow water IOs are (almost) symmetrical anyway_
  + Re-run integer version
    + Cycle count (cost)  **ok**
    + Resource count (cost) _later_
    + Estimates _later_
  + float version  **ok**
    + This requires me to integrate mixed data types (e.g. integers for select/counters, etc)
    + Testing that with a minimal prototype. **ok**
      + It seems to work more or less out of the box, except that (a) I am using i32 even for single-bit binaries, and (b) my backend adds flopoco control bits even to these integer data types, which _should_ be ignored when using them in modules which accept a single bit input
      + See testcode/21..., where I have tested and verified mixed data types. I am using a minmalist approach; the condition variable is not a binary  but an integer. The Tybec appends flopoco control bits to it as it assumed everything is a float, but they are truncated since I use only 1 bit from the cond variable. Also, the date types _still_ have to be of the same width; this is currently only tested with floats  + ints.
    + Now onwards to float version of 2dshallow with mixed signals
    + see last committed version on 2109.10.21 for this version.  
  + float version with cos/sin (flopoco)
  + float version with cos/sin (flopoco), now with pndmap
  + float version with cos/sin (memoization and interpolation~) <-- do I need the full synthesized version of this, or just costs?

  + integrate with OCX 
  + full synth run
  + ocx-integration
  + ocx-integration
  + update costs with new target (sdx)
  
  
+ the "less than" instruction in floats is not implemented, even in flopoco. Currently I am treating it as an integer comparison, but that is not functionally correct. TODO, FIXME.
  + This should not have an impact on results if u_new[], if NTOT = 1, as the instruction is in the updates function, and only updates wet.
  
  
2019.10.28

+ Can I run pndmap on coarse-grained nodes that have more than one instructions, only one of which is a multi-cycle instruction?
    + Yes, I can now, earlier there was a bug preventing it.
    
+ Sim was not ending because of a mistake I had made in the testbench end testing condition:
  + I was testing counter (effaddr) when IVALID, when I should have been doind that at OVALID. 
  + The wront logic worked as long as last stage was single-cycle. It failed when I added multi-cycle units.
  + Now the new logic is as follows:
```
  always @(posedge clk)
  if(~rst_n)
    effaddr <= 0;
  //increment if output from DUT valid
  else if (ovalid_fromdut)
    if (effaddr==`SIZE-`TY_GVECT)
      effaddr <= 0;
    else 
      effaddr <= effaddr + `TY_GVECT;
  else  
    effaddr <= effaddr;
```    

2019.10.30
+ I can now simulate the 3 stalling (stub) nodes, each pndmapped to a different degree, and get the correct results.

There is a limitation here (if we want to get correct results :): the stalling nodes downstream must be pndmapped to a _higher_ factor than those upstream; or in other words, when upstream nodes give them data, they must always be able to receive it. That’s because (for some reason) the back-pressure signalling is not working in case of successive pndmapped nodes, the way it is for other conventional ones. I need to debug that eventually, but right now I’d rather get some results for CC. FIXME

+ Also, note for ***#sdx integration***::
  +I am not differentiating between:
    + stalls due to stalling nodes, or stalling memory read master 
    + ivalid negation because the stream has ended at the input
  + In the former case, I should stall the entire pipeline immediately. This is my approach so this case is fine.
  + In the latter case however, this "stall immediately" approach fails, as I need cycles _after_ IVALID has been negated at the memory reader, for the data to porpagate to the output.
  + This error does not manifest in case of verilog TB as I keep feeding data even after one iteration over the grid is complete.
  + However, in OCX-HDL integration, this is (probably) what leads to deadlock. FIXME
    

## Stencil Buffer Integration with Vectorization
_#vectorization_
_#smache_

2019.08.15
+ Integrating stencils with vectorization now
+ First step would be to carry out replication one level lower than current status.
  - Currently I replicate "main_kernelTop" VECT times in the parent function "main".
  - But smache is not visible at this level, so it is replicated too, but since the two instanaces of main_kernelTop work are given interleaved data, this will lead to incorrect functionality
  - We want to have a _single_ smache module servicing ALL vector lanes. So the replication has to happen INSIDE a SINGLE main_kernelTop, where smache is visible.
  - So, when vectorizing, we need to replicate ALL functions at the _first_ hierarchy level inside main_kernelTop. 
  - This approach presumes/limits smache only at this, one hierarchy (direct child of main_kernelTop); smache inference WITH vectorization will not work at a deeper (or higher) level.
+ To test this approach, first test vectorization at one lower level on BAREBONES which does NOT have stencils (maybe also on 12_coriolis).
+ Then bring this back to testcode 8.

2019.11.04

+ See figure on google keep for today, tag tybec
+ I will continue to treat vectorization as a _global_ parameter; that is, I am not allowing vectorization of individual nodes
+ I am now vectoizing the _top_ module inside main *Major change*
+ This means replicating all leaf/hier nodes, but some special nodes remain unified:
  + smache
  + autoindex
  + inferred buffers?
+ If any node is vectorized (and current policy is to only vectorize `top`), then my rule is to:
  + Always have coalesced IO ports for that module
  + Slicing and packing happens inside the module being vectorized
+ Since I have  made a design decision to have only global vectorization, happening at the top level, so I am removing the redundat "s0" from 
  names of ports and wires.
+ In terms of code generation patterns, I have the followign categories:
    + testbench (unique)
    + func-hdl-top
    + hierarchical  
      + main
      + top (<-- vectorization happens here _only_)
      + pndmapped
      + all others
    + leaf
      + int
      + float
 
*Integrating vectors with stencils buffers* 
+ The functional nodes at top, when vectorized, are replicated; so internally, they are not aware of vectorization, and hence their 
  ports need not have the "sV" suffixes.
+ However, *atomic* nodes like the stencil-buffers and autoindex that are _not_ replicated for vectorization do have to have to be "aware"
  of vectorization, and hence their ports _are_ sufffixed with "sV".
+ *Atomic Nodes* Nodes that are _not_ replicated when the parent node is pipelined. They remain unified for cohrency.
    + stencil buffers
    + auto-index nodes
+ Stencils-buffers with vectorization:
    + If I have stencil buffer as part of a top kernel that is vectorized, then it will have _vectorized-inputs_, in addition to the vectorized outputs. 
    + Look at <tybec>/docs/stencilbuffers_withvectorization_calculations.xlsx and stencils_and_vect_animation_vectX.pptx for the reasoning behind the design
    + NEXT: incorporate the reasoning into the code generation:
      + 
      
2019.11.18    

+ Now generating vectorized stencils, see docs/stencils_and_vect_animation_XXX for the reasoning, and also stencilbuffers_withvectorization_calculations.xlxs
+ Also updated parent (top) instantiation and wire connection logic to instantiate a single stencil buffer.
+ Now, autoindex design and parent-level instantiation has been updated as well. 
+ Next, I need to test it.

+ The stencil buffer reads in vector data in Low-Endian order
[lowest index scalar is at lower address]
whereas the buffer is shift right, resulting in High-Endianinsm 
at the vector-word level 
[highest index vector word is lowest address]
This means mu 0th address in the buffer contains the lowest scalar of the highest vector word. 
See picture below-right (in <>/docs/stencils_and_vect_animation_compare_all, for the vect 2 case as shown.
From address 0 onwards, it stores data as follows:
 18, 19, 16, 17, 14, 15, 12, 13

Hence to get to IDX 0 (the 0th scalar of output word), we  need to offset first by the maxP which gets us to the end of the current vector word, and then move fiurther by vect-1

WN: MILESTONE :: First working prototype of vectorization and stencils working together. See testcode22, docs, and notes.  

2019.11.21
+ Now returning to OCX-HDL with Coriolis
  + testcode 12, Corilolis, ver40, passes ok with floats and no vectorization, on RTL simulation, but hangs on OCX-HDL simulation.

+ I have to sort this out:: Differentiating between stalls from memory, internal stalls (if allowed), and end of stream from memory.

+ I am now able to get ver40 working again, as it was for Hindawi. Next, do vectorization, get results, and then test on F1. THEN, compare with OCX only version. Put in paper. Now move on to 2dshallow.

+ _Floats_ + _Vectorization_::
  + The 2 bit prefix required by flopoco, I was incorrectly prefixing to the vector word, whereas it has to be interleaved at the scalar level.
  + This was not an issue before where the vector lanes had been split _before_ (one level above) the module where we prepend the 2 bits.
  + Now that vectorization has been lowered one level, we need to interleave.
  
  + Similarly, for data on the way out, simply ignoring the top 2 bits of the word is no longer ok if vectorized.
  + We need to extract the interleaved data (i.e. ignore ignore interleaved prefixes)
  
+ WN: Milestone :: coriolis (testcode/12_), vect=1 and vect=2, tested ok both on RTL and Hybrid _simulations_. (I had vectorized Coriolis running earlier already, but this is after major change to vectorization --- lowering it by one level).
Changes required to how I deal with flopoco control prefixes (see previous point)

2019.12.13

## OCL only vs OCL/TyTra Hybrid
+ I see a *3 order of magnitude* improvement with TyTra. Have to do a sanity check on it.
+ Runs on F1 are not giving correct results, whereas the hybrid simulation results were givign correct results. I see no reason why any bugs from simulation to synthesis would have perfomance impacts.
+ The OCL only host code uses C++ bindigns, the Hybrid code uses C; could that have an impact?

2019.12.04

+ Coming back to 2dhallow water, for ocl vs hybrid comparison.
  + int
    + hdl: run prev int version    - OK
    + hdl: run new gen int version - OK
    + hybrid-sim: run prev gen int version - OK (incorrect results)
    + hybrid-sim: run new gen int version - OK  (incorrect results)
    + ocl-manual-sim: on-going, committed, debug now
    + ocl-manual-synth: 
  
  + float
    + hdl: run prev float version - runs indef
    + hdl: run new gen float version - same
    + hybrid-sim: run prev gen float version
    + hybrid-sim: run new gen float version
    + ocl-manual-sim: 
    + ocl-manual-synth: 
  
+ SDX/OCL only allows AXI MEM WIDTH to be:: 
ERROR: [VPL 19-3461] Value '192' is out of the range for parameter 'AXI DATA WIDTH(C_AXI_DATA_WIDTH)' for BD Cell 'sim_axi_perf_mon2_0' . Valid values are - 8, 16, 32, 64, 128, 256, 512, 1024

+ Results are not consistent, when movign from corilolis to 2dshallow.
  + I should a) have the similar host code, use C only API, for all (coriolos ocl-only host has c++ ocl bindings)
             b) use a consistend timing measurement mechanism.
             c) swap arrays on host (just in case there is some optimizations under the hood)


+ Current status of testcode: see <>/docs/testcode_status.xlsx
  + coriolis
  + 2dshallow

20191209

+ I updatede host code for 12, coriolis, ocl-only (manual) [which earlier had C++ bindings] to be compatible with the host code of hybrid (generated) cases [which doesn't], just to make sure the host code hasn't any effect on the timings. It doesn't seem to. 
  (see point (a) two bullets up)
+ 
  
20191210

+ Trying to debug incorrect results on F1 instances (HW runs) when using flopoco (when hw_emu runs give correct results).
  + The sdx design seems to be targetted at 250MHz, whereas flopoco units were generated for 300MHz
  + Try re-generating and testing
  + I started getting _correct_ results for corilis on F1. It was off by 4 indices compared to host data, when you adjust for that, the results were completely accurate. 
    + HOWEVER, this is finicky.
    + happened ok only for size 1024. When I changed to 1024 x 1024, I get incorrect results again.
    + Also, when I interleaved another application run (the manual OCL version), and then ran the hybrid again with _same_ configuration, I could not get back to getting correct results.
    + I could not get the same results back even after restarting the node :(
    + Whiskey Tango Foxtrot.
    
Note these remarks on sdaccel website:: (https://www.xilinx.com/html_docs/xilinx2018_2/sdaccel_doc/debug-and-verification-considerations-xyj1504034326596.html)

Debug and Verification Considerations
RTL kernels should be verified in their own test bench using advanced verification techniques including verification components, randomization, and protocol checkers. The AXI Verification IP (AXI VIP) is available in the Vivado® IP catalog and can help with the verification of AXI interfaces. The RTL kernel example designs contain an AXI VIP based test bench with sample stimulus files.
The hardware emulation flow should not be used for functional verification because it does not accurately represent the range of possible protocol signaling conditions that real AXI traffic in hardware can incur. Hardware emulation should be used to test the host code software integration or to view the interaction between multiple kernels.    
  
20191219
+ I've been trying to debug the full synthesis functional errors (see previous comment).
+ One strategy I tried was to use a counter to count the ivalids, ovalids, and cycles at func_hdl_top.
  + But it gives buggy results too. HDL only sim is fine, hyrbid sim and synthesis give confusing results.
  + The final value I read seems to depend on the last value I CHECK in the previous code block
  + so, if how_many_words_to_compare is 256, then the value of counter, _even at the final word at DATA_SIZE, is still 256
  + when I change how_many_words_to_compare to 1024, that's the counter value I get as well.
  + But somehow other values seesm to give garbage (2048 gives 121, etc).
  + also, the same binary, in emulation, gives different results dependign on exact structure of pring statement in the prvious block
  + I seem to get correct counter value for DATA_SIZE 1024, but not for others, not sure why
+ I am going to work on an integer version of coriolis now, and see if I can get correct results there.  

+ I did some back of envelope calculations, see docs/cycle_count_estimates_from_real_time.xlsx, and my measured time seems to pass the sanity check, as I get ~1.4 cycles per index, which sounds right for a single-cycle pipeline. 
+ Also, I _once or twice_ got correct _floating_ point data (see comment from 20191210), so together with previously noted sane times, and correct simulation results, I can be reasonably confident my times are correct.
    + IF I can get correct integer results though, that would be a lot better.
    
+ The problem of ivalid negation at the _end_ of input stream (and not due to internal or external stalls) is easily solved I think if we just
feed in a little extra data (equal to the depth of pipeline) so that all _relevant_ data is flushed before the ivalid-due-to-end-of-stream negation at the input.
    
+ 12_coriolis, ver 101 , integer, where in one of the build versions, I am testing logic for ivalid (beyond end of input stream), manually, hangs when run on F1, although the simulation completes. And once it hangs, then other versions hang as well, unless I shut down the instance (for a few minutes at least, instantly re-starting did not help). 


20191220
+ Back to the drawing board for debug, see testcode/23_...
+ I am making a "groundup", example now, based on testcode_0, and checking for functional correctness all the way to F1 execuution. Incrementally build up to all the features in coriolis. 

20200128
+ New targets:
  + Building up hotspot and lavamd examples for Cris
  + Doing some end-to-end example on TyTra, with simulation results (+synthesis for freq and resource count).
    + _close_ tytra
  + Go back to groundup debug example 
+ 


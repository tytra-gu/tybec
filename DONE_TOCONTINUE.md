[Also see ./Notes.txt]

DN = Done
TC = To Continue, do this (typically on-going task, or just about to start.)
TD = To Do (after TC tasks)

2017.09.05::
------------
DN: Generate RTL (testcase 0, barebones, only)
DN: Generate RTL testbench
DN: Generate OCL (host, device-wrapper)

DN: test generated RTL and testbench for correctness #2017.10.25: tested for barebones ver1
TC: test generated RTL and testbench for correctness (float, hipeac, etc)

DN: incorporate IVALID signals
TC: test generated OCL for correctness
<<<<<<< .mine
	This is almost done. I get only one error (a missing output) when I compare with the OCL. 
 

=======
    This is *almost* correct now. Only one data output missing. 
    See /home/tytra/Work/_TyTra_BackEnd_Compiler_/TyBEC/testcode/0_barebones_pipeline/tir/ver1_baseline/oclGen.backup.20171026.hwbuild/host
    for the latest version. Once the bug is gone, then TODO: compare this 
    manually hacked version with generated version, and update code generation 
    to match.


>>>>>>> .r10206
DN: manually write channelized OCL+HDL code
TD: generate channelized OCL+HDL code

DN: infer synch-buffers for fine-grained scheduling (inside kernels); i.e., introduce multi-cycle (float) instructions
DN: I am inferrign buffer sizes and adding node to DFG: add this node to hash, with its cost, and update edges to insert this node in DFG
 	(Removed the bug with multiple edge, and also now coalescing all buffered versions of the same source into a single buffer)
DN: cost it
TD: generate code for it
TD: test it

DN: Inferring buffers for coarse-grained scheduling
    (putting kernels in parallel on parallel paths with different latencies works correctly).

DN: Checking I am dealing with reductions correctly (single path)

DN: infer synch-buffers for CG scheduling (map and fold on separate path) <***>
	(There are some limitations.... see ../doc/notes_wn.docx)
TD: cost it
TD: generate code for it
TD: test it

DN: test Hipeac example (baseline)
	(see commit/backup on 2017.09.15)

DN: Deal with constant arguments (inputs/outputs)
TD: Constants become streams when they are connected to child functions. Since child functions have no awareness that these are constants, they will infer buffers for them 
    if e.g. needed for synchronization. There should be a way around this. TODO. 

DN: update tybec to parse split/merge
    (see version 4's DFG)
DN: incorporate it in DFG generation
DN: updated to have separate nodes for split-outputs
DN: debugged cost for ver4, hipeac

TD: See if I need sycnh buffers on split paths, and also, if I need to look into scheudling/synch of split/merge in general...
TD: cost it
TD: generate code for it
TD: test it

TD: 

TD: integrate with smart-caching

TD: Test with 2d-shallow water
TD: Test witd 2d-shallow water on multiple devices

DN: See that cost-generation is sensible with the new flow
DN: Re-introduced batch runs, and I comparing costs in a table for all the variants

TD: When I split a FOLD kernel, its latency should be updated reflect this. How will it happen? explicit update of the metadata? Or implicit inference by backend?


2017.05.05:
-----------
I am more or less correctly building DFG from the HIPEAC example. These are the most obvious next steps:
- label explicit edges --- ok
- How am I dealing with the reduction! --- ok
- DEbug the errors (e.g. disconnected ouput pport in kernelTop, parsing main and connecting it up. --- ok
- Annotate the nodes with data, have it display --- ok
- Split and Merge incorporation --- ok
- Remove explicit synch buffers --- ok
- The cost of compute functions is being updated, but not uniformly across the design. Also, other cost updates (performance) should be removed, so that hereon only CALCULATED costs are there (both in the hash and on the  DFG). Also remove redundancy in cost paramters storage --- ok
- create a barebones example -- ok
- I have now cleaned up the tokens' hash considerable, and have connected the cost function for simple computation instructions.

- Start using formular unknown scheduling parameters, and schedule the entire pipeline (display it accordingly)
- Infer buffers (for the simple casE)
- cost and 
- generate
- test generated circuit (for correct results)
- generate testbench?
- Start introducing complexities into the circuit until it gets to illustration
- Introduce floating point
- Keep incrementing changes until I can do 2D shallow water

- Cleaning up TyBEC code, moving MOST entries to SYMBOL table,so that I can  start scheduling now
- Local Scheduling via buffers inside OPAQUE functions
- Make these annotations REAL (that is based on cost model)
- Global Scheduling (look up notes from Wims meeting)
- Generate
- Scale to multiple devices/nodes

2017.04.13: 
-----------
+ CALLBACKS for FUNCTION CALLS
+ SPLIT AND MERGE!
+ offset buffers
+ Analysis
+ Cost
+ Floating point integration (or multi-cycle operation in general) (i.e. integration of LATENCY of individual instructions)
- The resulting requirement for synchronization buffers
+ Creating synchronization buffers for coarse-grained syncronization (explicit, implicit(AUTO)) due to disbalanced maps and folds

2018.02.15
----------
WN: Updated code generation of HDL to make it compatable with HDL that interfaces correcttly with AOCL, as observed in the smache experiments. HDL simulation tested to work correctly (with generated test bench). Next step is to generate OCL that is compatible with smache, and test that. Then I will have first prototype of correctly functional HDL code. Check it against/integrate c2llvm as well.

2018.03.08
-----------
* Incorporating IO vectorization (memory access coalescing)
* DONE: pass a vect parameter and whole RTL+Testbench vectorizes 
* DONE: tested for correctness for various vector widths

2018.03.16
-----------
* Incorporating floating point datapath from flopocp
* DONE: generated float32 arithmetic cores from Flopoco, and tested
* DONE: integrated flopoco units successfuly into barebones example and tested
        (currently units are pre-generated)
* TC  : Check OCL version    
//#notes// 2018.04.03
-The flopoco design in OCL was giving erroneous results
-So I reverted to RTL testbench, introduced stalls, and that was erroneous too
-So I manually converted flopoco units to have stall signals
-Still barebones giving error
-So I regressed to single operation kernel - success (RTL sim with stalls)
-two operation (still just one) kernel - success (RTL sim with stalls) 
-To check that my changes to flopoco were working, I used non-stallable original flopoco cores, which failed
-DN: Tested full barebones (addition only, no mult) with flopoco-stalled versions, and stalling in RTL testbench
-TC: Integration of floating point code with OCL shell gives errors, not sure why...  
    
* TC  : Infer buffers on unbalanced paths and check...        
* TD  : Integrate with vectorization and test peformance
* TD  : Check C-to-gates flow
* TD  : Handle branches, scalars, constants
* TD  : Create separate kernel+ocl-shell units, and CG pipeline out of that...
* TD  : Move to 2D-shallow water, infer smart caching buffers
* TD  : Integrate vectorization with smart-caching buffers
* TD  : Do comparison experiments of 2D-shallow water with CPU and baseline FPGA
* TD  : Expand experiments to other benchmarks


=======================================================================
2018.10.01: Moving to Sdaccel / AWS
=======================================================================
(copied in from C:\WAQAR\GU\Work\201808_AWSF1_MyCode_Sdaccel\DONE_TOCONTINUE on 2018.10.15, and then continued onwards here)

Done / To-Continue

DN:Complete flow from RTL → synthesis → AFI creation on S3 buckets → 
DN: access to F1 instance
DN: C-based simulation on AWS instance
DN: Dumping and viewing wave file on local machine
DN: Make small change in RTL, test

DN: Manually insert small TyBEC code (generated offline)
DN: ASYNCH design; Convert barebones generated code to complete ASYNCH design
DN: Install sdaccel 2017.4 locally, and do equicalent hw_emu... yay!!
DN: Test kernel halting the entire pipeline...
DN: Create an  RTL testbench to test tybec-rtl locally

TD: Generate solution from TyBEC
  DN: Create kernel pipeline (use "pipes")
  DN: AXI connections in CG pipeline (hier-nodes)
  DN: AXI connections in leaf nodes 
  DN: generate shell code (sdx) (custom for this example)
  TD: generate shell code (sdx) (generic)
  DN: Generate test-bench (verilog)
  DN: test complete generated code (barebones)

DN: Do vectorized load
    Tested vectors 1,2,4,8,16. Approach taken is around single AXI-4 Master interface for DDR though, which is not the most effecient.
    Only sim testing though
DN: Do vectorized load plus vectorized kernel 
DN: Generate RTL testbench for vectorized design test
  
DN: get actual FPGA synthes and runs AWS

TD: Deal with branches: branches similar to llvm-ir should be allowed in tytra-ir

TD: Split and Merge
TD: Folds

TD: smache
TD: 2d-shallow water (with at least streaming buffers)

TD: Use the pipeline RTL example from Xilinx for TyBEC code insertion (?)
TD: Create kernel pipeline (CL kernels for read and write to global memory)
TD: generate the above
TD: Complete FPGA synthesis of above, do actual run, compare result with CL only solution

TD: Separate axi signals for EACH data stream (vs EACH   "NODE" as it is now) [needed?]
TD: Oerlapped host-device data transfer, and kernel execution (see Chapter 8, page 71, sdaccel opt guide, 2017.4)

Re-Focus, 2018.11.09
----------------------

TC: convert barebonesStencil.c to TIR, then test parse, cost, code-gen

REFOCUS:
DN: Incorporate streaming (only) buffer for stencils
DN: re-introduce floats (flopoco)
DN: Deal with scalars
DN: predicated (select) execution

TD: split and merge incorporate
TD: Arbitrary number of  IO ports
TD: update cost model for AWS-F1
TD: 2d-shallow-water

TD: Use multiple IO banks and test effect
TD: folds

2018.11.13
--------------
DN: autoindex parsing; 
DN: make sense of nested autoindices in the DFG
DN: check finak DFG for testcode/8_
TD: generate code for above
  DN: generate compare, or
  DN: generate select
  DN: generate assign/load
  DN: CONSTANT operand code generation
  DN: confirm correct generation of parent module with select (3 ops, diff widths), assign (1 op)
  DN: correct HIER node generation
  DN: Buffer inference
  DN: correct HIER node generation WITH buffer inference
  DN: handling syncrhonization buffers with handshakes
  DN: _debug_ main generated multiple times
  DN: document flow of code generation for easy debugging
  DN: _debug_ iready in main
  DN: _debug_ iready name incorrect in child function port
  
  DN: Test the above (2019.06.04, testcode #8, ver1)
  DN: re-introduce floats?
  DN: buffer inference on unbalanced paths <-- some other testcode than #8?
  DN: window buffer inference (vanilla smache)
  DN: auto-index generation code
  TD: implement fold logic in code gen <-- had done this earlier, but re-check
  DN: floating point immediate constants
  DN: implement select/branching
  DN: allow hierachical modules to have multiple outputs, and *synch* them (not just smache)
  
  TD: 2019.06.06: Testcode sequence
      - 8 minimal (plain integer CG pipeline)   OK
      - 0 minimal OK
      - 0 (plan integer CG pipeline, one buffer inference, with one tap) OK
      - 0 (plan integer CG pipeline, one buffer inference, with two taps) OK
      - 3 (float version of 0) - OK
      - 4 (buffer inference, more) - NOT NEEDED; move on...
      - 8, minmimal (now with stencils) - OK
      - 8, complete (autoindex, compare, select, boundaries, and stencils) . OK --- MAJOR MILESTONE
      - 15 (select/branching) - OK
      - branch to hindawi updates, see notes for 2019.07.01
   
      
      - 1 (folds, constants) - <--- LATER, AFTER HINDAWI
      - vectorize (all) < important
      - multiple inputs in SDX (e.g. testcase 15) 
      - example code for Hindawi
      - 1 (now with splits, merges) <--- LATER, AFTER HINDAWI
      - 2dshallow water
      - Buffer inference to ensure synchronization on output nodes (see testcode/12.../ver1)
      - sdx comparison
      - ocl to fpga via tybec
      - split and merge, DSE
      - document
TD: GOTO REFOCUS

2019.02.11
-----------
[Brief de-tour for Systems talk: integrate with MSc project to go from opencl with pipes all the way to vectorized solution (rather than from TyTra-IR). so back to testcase 0].

DN: Generating TIR code from OpenCL code (same example as student project) based on my own perl/recdescent based approach
DN: test Tybec on this generated code
DN: Test with the global channels rather than passed arguments
TC: Test with loops?
TC: Also, move to sdx/opencl syntax rather than AOCL

TC: test with fancier code?
TD: Go back to TyBEC updates, so then come back to this and integrate with James's stuff...

2019.04.03
----------
+ See the above date in ./NOTES.txt
+ See TD list under 2018.11.13

2019.16.13
-----------
+ Saving the primary development branch as back-up today, both on SVN and locally on laptop.
+ When I come back, see 2018.11.13
+ Should be able to continue onwards from this new branch as the cost updates should note effect code generation efforts

+ THIS branch::

DN: SOR 
DN: Get correct costs for SOR
DN: SOR, with re-forestation
DN: 2d-shallow-water, dyn1
DN: 2d-shallow-water, dyn2
DN: 2d-shallow-water, shapiro
DN: 2d-shallow-water, updates
DN: Get correct costs for all of the above

TD: james's nn

TD: Get SOR code automatically
TD: 2d-shallow water TIR code generated fully automatically

2019.07.01
-----------
+ Back to critical path, with focus on Hindawi paper
+ Look at test-code sequence TODO 
+ Experimenting with coriolis (test case #12)
  + DN: Add coriolis TIR
  + DN: Generating HDL
  + DN: Test HDL on bolama   <-- Here at this update. Major update, see notes for 2019.17.17. 
                              -- Test code 12, ver 2 now operational
  + DN: Test vectorized HDL on bolama
  + DN: Update SDX shell code to deal with multiple IOs
    + DN: Coalesce inputs and outputs for simpler integration with SDX
    + DN: Test coalesce access of IOs with vectorization
    + DN: Deal with internal pre-pending and removal or Flopoco data prefixe
  + DN: Test coriolis ocl-hdl _sim_ on bolama (scalar)
  + DN: Test coriolis ocl-hdl _sim_ on bolama (vector)
  + DN: Test coriolis ocl-hdl _hw_ on bolama (sector)
  + DN: Test coriolis ocl-hdl _hw_ on bolama (vector)
  + DN: Compare agains SDAccel-only version (partially;l OCL-only was waaaaaay to slow, too good(bad) to be true
  + DN: Compile results and put in paper
  + DN: Update paper
  + TD: Add CNN example
  
2019.08.13: Fresh list
======================
Target: FPGA, DATE, or DAC (Or IJRC)

+ DN: testcode 12, test vect1 and vect2 with new template(sim)
+ DN: testcode 12, test vect1 and vect2 with new template(synth)
+ DN: Integrate with code-gen, test again
+ DN: Code-gen for multi-cycle (stub) node (testcode 16)
+ DN: code gen for split/merge <-- MILESTONE
+ TD: 2d-shallow water test (local RTL)
  + DN: dyn1, with all branches, int, parsed 
  + DN: dyn1 code gen, test
  + DN: dyn2 unit
  + DN: shapiro unit
  + DN: integrate 
  + TD: reforest
  + DN: multi-cycle stub  <-- here 
  + DN: multi-cycle stub with pndmap 
  + TD: OCL baseline
  + TD: with floats
+ TD: 2d-shallow water test (ocx integration)
  + TD: Sort asymmetrical IOs
  + TD: Test ocx-hdl-sim
  + TD: Test ocx-hdl-synth
  

+ TD: Investigate multiple interfaces/banks (Coriolis is a good case study)
+ TD: code gen for vectorized stencils
+ TD: code gen (
+ TD: code gen from OCL
+ TD: code model updae for AWS
+ TD: backend DSE (vectorization, split/merge, banks)
+ TD: Try to integrate SDx generated testbench

+ TD: ocl2tir: work with branches, see Wim's test code...

+ TD: additional testcases 
+ TD: write and publish

2019.09.10
----------
+ TD: Minimal example that exposes asynch stalling issue
+ TD: Solve it; simulate in HDL as well as OCX-HDL
+ TD: Go back to larger examples with this modification
+ TD: Introduce FOLDS
  - DN: Case A: generated code for a reduction example; 
  - DN: Now gen correct TB, test it
  - DN: Case B (Reduction not in the terminal kernel,  but in between, See  NOTES)
  - TD: Case C (Reduction on parallel paths) --> on-going; completed C, now look at the TIR
  - TD: test similar example with reduction at different positions (having a predecessor instruction e.g.)
+ TD: Solve these issues:
  - nodes inside a function must be weakly connected _DONE_
  - dataflow branches around nodes are not allowed _DONE
  - input and output must have same number of ports
  - constants can only be second operands
  - floats are not tested and integrated with latest features/examples, specifically ndmap(2dshallow water should work)
  - multi-cycle units have to simulated (why not actual ones from flopoco) 
+ TD: Revist cost model, update for F1 device
+ TD: Estimate cost of memory readers/writers

2109.10.18
----------
+ TD for CC:
    - 2d shallow water, with floating point integration: How will that work with conditional variables being ints?
    - Integrate multi-cycle units, along with split/merge integration. 
  
2019.11.07
----------
Fresh TODOs
+ TD: Integrate stencils and vectors
  + TD: barebones stencil without vect, with new naming
  + TD: incorporate vectorization, simulate
  + TD: 2d shallow, no vector
  + TD: 2d shallow, vect
  + TD: 2d shallow float, no vect
  + TD: 2d shallow float, vect
  + TD: Ocx-Hdl  integration of all of the above
  + TD: Compare with OCX-only baseline
  + TD: 2 other experiments
+ TD: Test with folds, no staging
+ TD: Test with folds, with staging
+ TD: Document
+ TD: Repository upload  
  
  

// ver 1 //
+ Disconnected kernels
+ Float
+ Used for generating costs for Cris's paper (Reconfig)

// ver 2 //
+ Disconntected kernels unit tested, and COMPLETE CG pipeline also tested
+ Int
+ This one tested for correctness of gen rtl on 2019.09.04

// ver 3 //
+ Connected kernels in a CG pipeline
+ Int
+ Re-forested in order to introduce a few multi-cycle "pow" instructions, in anticipation of testing split/merge optimizations

// ver 4 //
+ Stripped down version of ver 3, to remove all dataflow branches (selects, or by-passes), for CGO results.
+ Int

// ver 5 //
+ Copying in ver2, starting afresh after pndmap debugged, and attempting to reintroduce multi-cycle nodes and pndmaps

// ver 6 // 2019.10.21
+ INT
+ Copying in ver2 again, starting afresh, for full OCX integration testing

// ver 7 // 2019.10.21
+ FLOAT
+ Copy in ver2, make it float...

// ver 8 // 2019.10.28
+ Copy of ver 6 (integer version of 2dshallow)
+ Injected multi-cycle nodes for CC 2019 results...



# WN, Glasgow, 2019.06.19

+ The Coriolis code is taken from Kampf text book.
+ It was manually converted to HDL back in 2014, and formed the basis of the TIR language.
+ That project is now obsolete, available in Work\MiniProj_Ocean_Coriolis
+ This branch now being developed as a test case (with Cordic functions) for tybec.

*To run* TYBEC: tybec.pl --i coriolis.tirl --g --cio --iov <vect-factor>

*NOTE*  
+ Versions before 40 followed old directory structure (tir and c were parent folders, each having equivalent version sub folders)
From 40 onwards, folders are of new structure, with ver at top, so this README has description from ver40 onwards.
For earlier ones, see ./tir/README


+ Most versions do not differ in the source TIR, but only in the flags, code generation templates, and other back-end related features used, all of which happens after you run tybec on them locally. So all versions may not be available if you are seeing this in a repo.


## ver 40
+ floating point
+ Copy of ver 30:
+ SIZE = 1024*1204
+ VECT = 1

## ver 41
+ floating point
+ Copy of ver 40:
+ SIZE = 1024*1204
+ VECT = 2

## ver 42
+ floating point
+ Copy of ver 40:
+ SIZE = 1024*1204
+ VECT = 4

## ver 43
+ floating point
+ Copy of ver 40:
+ SIZE = 1024*1204
+ VECT = 8

## ver 44
+ floating point
+ Copy of ver 40:
+ SIZE = 1024*1204
+ VECT = 1
+ Updated (Virtex 6, 500 MHz) flopoco cores uses (stallable)

## ver 45
+ floating point
+ Copy of ver 40:
+ SIZE = 1024*1204
+ VECT = 1
+ Updated (Virtex 6, 500 MHz) flopoco cores uses (stallable)
+ Underclocking @ 100 MHz 
(https://www.xilinx.com/html_docs/xilinx2019_1/sdaccel_doc/wrj1504034328013.html, search for --kernel_frequency <arg>)

## ver 46 
  *Don't rebuild*
+ floating point
+ Copy of ver 40:
+ SIZE = 1024*1204
+ VECT = 1
+ Testing integration with SDX generated HDL testbench
  + The build folder had manual modifications, after initial build on 2019.12.12.

## ver 47
+ floating point
+ Copy of ver 40:
+ SIZE = 1024*1024
+ VECT = 1
+ Inserting "token counters" that ensure that the correct number of data items have passed through the pipeline. 

## ver 48
+ floating point
+ Copy of ver 47:
+ SIZE = 1024*1024
+ VECT = 1
+ Inserting "token counters" that ensure that the correct number of data items have passed through the pipeline. 
+ Adding "initial" blocks to the counters for testing

## ver 101
+ *integer*
+ Copy of ver 40:
+ SIZE = 1024*1204
+ VECT = 1
+ In one of the build versions, I am testing logic for ivalid (beyond end of input stream), manually.

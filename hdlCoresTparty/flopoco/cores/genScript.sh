#!/bin/bash -x

# Command line operations
#   target=<string>:      target FPGA (default Virtex5) (sticky option)
#   Supported targets: Stratix2...5, Virtex2...6, Cyclone2...5,Spartan3



flopoco FPAdd 	frequency=300                     \
                wE=8 wF=23                        \
                pipeline=yes                      \
                target=Virtex6                   \
                outputFile=FPAddSingleDepth7.vhdl \
#                Testbench n=10 file=1

flopoco FPSub 	frequency=300                     \
                wE=8 wF=23                        \
                pipeline=yes                      \
                target=Virtex6                   \
                sub=1                             \
                outputFile=FPSubSingleDepth7.vhdl \
 #               Testbench n=10 file=1

flopoco FPMult 	frequency=300                   \
                wE=8 wF=23                          \
                pipeline=yes                        \
                target=Virtex6                     \
                outputFile=FPMultSingleDepth3.vhdl  \
#                Testbench n=10 fil

flopoco FPDiv 	frequency=300                       \
                wE=8 wF=23                          \
                pipeline=yes                        \
                target=Virtex6                     \
                outputFile=FPDivSingleDepth12.vhdl  \
#                Testbench n=10 file=1


#FPPowr_8_23__F300_uid2
flopoco FPPow   frequency=300                       \
                wE=8 wF=23                          \
                inTableSize=16                      \
                target=Virtex6                     \
                outputFile=FPPowr_8_23__F300_uid2.vhdl  \
#                Testbench n=10 file=1


#Sin/Cos
flopoco CordicSinCos lsb=-23 wE=8 wF=23 wIn=32          \
                outputFile=XXX.vhdl  \
                Testbench n=10 file=1

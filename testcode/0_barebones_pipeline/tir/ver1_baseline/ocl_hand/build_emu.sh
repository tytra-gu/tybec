#!/bin/bash -x

#Run this script to build the aocx file (with HDL lib)
#Note that you cannot RUN this build as this is emulation, and that is not exectuable when using an HDL lib
#So the only purpose for running this would be to test syntax

perl make_lib.pl
aoc -v --report -march=emulator --board p385_hpc_d5 -l hdl_lib.aoclib -L lib -I lib kernels.cl
make --directory host

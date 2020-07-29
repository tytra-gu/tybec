#!/bin/bash -x

#Run this script to build the aocx file (with HDL lib)

perl make_lib.pl
aoc -v --report --board p385_hpc_d5 -l hdl_lib.aoclib -L lib -I lib  kernels.cl
cp kernels.aocx host
make --directory host

#!/bin/bash -x

#Run this script to build the aocx file (with HDL lib)

echo -e "** Did you run the script with 2 dots? **\n"
echo -e "================================"
echo -e "Making lib"
echo -e "================================="
perl make_lib.pl
echo -e "================================="
echo -e "Building Kernel"
echo -e "================================="
aoc -v --report --profile --board p385_hpc_d5 -l hdl_lib.aoclib -L lib -I lib  kernels.cl
#aoc -v --report --board p385_hpc_d5  kernels.cl
echo -e "================================="
echo -e "Building Host\n"
echo -e "================================="
make --directory host
echo -e "================================="
echo -e "Moving Kernel\n"
echo -e "================================="
mv kernels.aocx host
#cd host
#./host kernels.aocx
#cd ..


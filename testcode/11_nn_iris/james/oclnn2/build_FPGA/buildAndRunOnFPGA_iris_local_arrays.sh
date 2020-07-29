#!/bin/bash -x

#Run this script to build and run AOCL emulation
#Run it with two dots like this: . ./<scriptName>.sh

echo -e "** Did you run the script with 2 dots like this: . ./<scriptName>.sh **"
echo -e "================================="
echo -e "Clean previous build and output files"
echo -e "================================="
rm -f iris_tensorflow_local_buffers.exe error.log out.dat ../device/iris_local_arrays-profile.aoco ../device/iris_local_arrays-profile.aocx
echo -e "================================="
echo -e "Building Kernel"
echo -e "================================="
cd ../device
aoc -v --report --profile --board p385_hpc_d5 -o iris_local_arrays-profile.aocx iris_local_arrays.cl
echo -e "================================="
echo -e "Building Host"
echo -e "================================="
cd ../build_FPGA
make iris_local_buffers
echo -e "================================="
echo -e "Executing"
echo -e "================================="
./iris_tensorflow_local_buffers.exe iris_local_arrays-profile.aocx
mv profile.mon profile_local_arrays.mon

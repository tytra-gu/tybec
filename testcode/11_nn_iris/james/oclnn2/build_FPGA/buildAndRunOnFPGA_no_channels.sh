#!/bin/bash -x

#Run this script to build and run AOCL emulation
#Run it with two dots like this: . ./<scriptName>.sh

echo -e "** Did you run the script with 2 dots like this: . ./<scriptName>.sh **"
echo -e "================================="
echo -e "Clean previous build and output files"
echo -e "================================="
rm -f iris_tensorflow_no_channels.exe error.log out.dat ../device/iris_no_channels-profile.aoco ../device/iris_no_channels-profile.aocx
echo -e "================================="
echo -e "Building Kernel"
echo -e "================================="
cd ../device
aoc -v --profile --report --board p385_hpc_d5 -o iris_no_channels-profile.aocx iris_no_channels.cl
echo -e "================================="
echo -e "Building Host"
echo -e "================================="
cd ../build_FPGA
make iris_no_channels
echo -e "================================="
echo -e "Executing"
echo -e "================================="
./iris_tensorflow_no_channels.exe iris_no_channels-profile.aocx
mv profile.mon profile_no_channels.mon

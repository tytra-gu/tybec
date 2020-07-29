#!/bin/bash -x




echo -e "** Did you run the script with 2 dots like this: . ./<scriptName>.sh **"
echo -e "================================="
echo -e "Clean previous build and output files"
echo -e "================================="
rm -f iris_tensorflow_no_weight_passing.exe error.log out.dat ../device/iris_local_arrays-emulator.aoco ../device/iris_local_arrays-emulator.aocx
echo -e "================================="
echo -e "Building Kernel"
echo -e "================================="
cd ../device
aoc -v --report -march=emulator --board p385_hpc_d5 -o iris_local_arrays-emulator.aocx iris_local_arrays.cl
echo -e "================================="
echo -e "Building Host"
echo -e "================================="
cd ../build_FPGA
make iris_local_buffers
echo -e "================================="
echo -e "Executing"
echo -e "================================="
env CL_CONTEXT_EMULATOR_DEVICE_ALTERA=1 ./iris_tensorflow_local_buffers.exe iris_local_arrays-emulator.aocx

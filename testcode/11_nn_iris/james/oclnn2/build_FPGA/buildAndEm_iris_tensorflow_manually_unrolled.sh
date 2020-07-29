#!/bin/bash -x




echo -e "** Did you run the script with 2 dots like this: . ./<scriptName>.sh **"
echo -e "================================="
echo -e "Clean previous build and output files"
echo -e "================================="
rm -f iris_tensorflow.exe error.log out.dat ../device/iris_tensorflow_manually_unrolled-emulator.aoco ../device/iris_tensorflow_manually_unrolled-emulator.aocx
echo -e "================================="
echo -e "Building Kernel"
echo -e "================================="
cd ../device
aoc -v --report -march=emulator --board p385_hpc_d5 -o iris_tensorflow_manually_unrolled-emulator.aocx iris_tensorflow_manually_unrolled.cl
echo -e "================================="
echo -e "Building Host"
echo -e "================================="
cd ../build_FPGA
make iris_tensorflow
echo -e "================================="
echo -e "Executing"
echo -e "================================="
env CL_CONTEXT_EMULATOR_DEVICE_ALTERA=1 ./iris_tensorflow.exe iris_tensorflow_manually_unrolled-emulator.aocx

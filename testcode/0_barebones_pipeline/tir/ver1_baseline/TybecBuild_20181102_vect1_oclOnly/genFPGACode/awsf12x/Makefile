COMMON_REPO := $(AWS_FPGA_REPO_DIR)/SDAccel/examples/xilinx_2017.4
#COMMON_REPO := ../../..

#Common Includes
include $(COMMON_REPO)/utility/boards.mk
include $(COMMON_REPO)/libs/xcl2/xcl2.mk
include $(COMMON_REPO)/libs/opencl/opencl.mk

# Host Application
host_SRCS=./src/host.cpp $(oclHelper_SRCS) $(xcl2_SRCS)
host_HDRS=$(xcl2_HDRS)
host_CXXFLAGS=-I./src/ $(opencl_CXXFLAGS) $(xcl2_CXXFLAGS) $(oclHelper_CXXFLAGS) -std=c++0x
host_LDFLAGS=$(opencl_LDFLAGS)
EXES=host


# Kernel
computeKernel_SRCS=./src/computeKernel.cl

XOS=computeKernel

computeKernel_XOS=computeKernel

XCLBINS=computeKernel

#computeKernel_KERNEL := computeKernel

#EXTRA_CLEAN=tmp_kernel_pack* packaged_kernel* $(computeKernel_KERNEL).xo

# check
check_EXE=host
check_XCLBINS=computeKernel
#check_NTARGETS=$(computeKernel_NTARGETS)

CHECKS=check

include $(COMMON_REPO)/utility/rules.mk

AOCL_COMPILE_CONFIG=$(shell aocl compile-config)
AOCL_LINK_CONFIG=$(shell aocl link-config)

LDLIBS                 = $(AOCL_LINK_CONFIG)
CXXFLAGS               = $(AOCL_COMPILE_CONFIG) -std=c++11 -O2 -lpthread -DLINUX -DTARGET=FPGA
HOST_SRCS              = ../host/iris_tensorflow.cpp
CXX                    = g++
HOST_EXE	           = iris_tensorflow.exe
HOST_EXE_LOCAL_BUFFERS = iris_tensorflow_local_buffers.exe
HOST_EXE_NO_CHANNELS   = iris_tensorflow_no_channels.exe
OUTPUTFILES            = *.mon error.log out.dat results/results*

#Opencl 2.0 for pipes
#CXXFLAGS += -cl-std=CL2.0

iris_local_buffers: $(HOST_EXE_LOCAL_BUFFERS)

$(HOST_EXE_LOCAL_BUFFERS): $(HOST_SRCS)
	$(CXX) $(CXXFLAGS) -DLOCAL_BUFFERS -DUSECHANNELS $< -o $@ $(LDLIBS)


iris_no_channels: $(HOST_EXE_NO_CHANNELS)

$(HOST_EXE_NO_CHANNELS): $(HOST_SRCS)
	$(CXX) $(CXXFLAGS) $(BUILDFLAGS) $< -o $@ $(LDLIBS)

iris_tensorflow: $(HOST_EXE)

$(HOST_EXE): $(HOST_SRCS)
	$(CXX) $(CXXFLAGS) -DUSECHANNELS $< -o $@ $(LDLIBS)
	
clean: 
	rm -f $(HOST_EXE) $(HOST_EXE_NO_CHANNELS) $(HOST_EXE_LOCAL_BUFFERS) $(OUTPUTFILES)

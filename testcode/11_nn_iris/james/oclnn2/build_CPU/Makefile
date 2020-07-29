# LDLIBS                 = -l OpenCL
# CXXFLAGS               = -std=c++11 -g -DIntel -lpthread -DTARGET=CPU
# BUILDFLAGS             = -O2
# HOST_SRCS              = ../host/iris_tensorflow.cpp
# CXX                    = g++
# HOST_EXE	           = iris_tensorflow.exe
# HOST_EXE_LOCAL_BUFFERS = iris_tensorflow_local_buffers.exe
# HOST_EXE_LOCAL_NO_OPT  = iris_tensorflow_local_buffers-no-opt.exe
# OUTPUTFILES            = error.log out.dat results/result*

# #Opencl 2.0 for pipes
# #CXXFLAGS += -cl-std=CL2.0

# iris_local_buffers: $(HOST_EXE_LOCAL_BUFFERS)

# $(HOST_EXE_LOCAL_BUFFERS): $(HOST_SRCS)
# 	$(CXX) $(CXXFLAGS) $(BUILDFLAGS) -DLOCAL_BUFFERS $< -o $@ $(LDLIBS)

# iris_local_buffers_no_opt: $(HOST_EXE_LOCAL_NO_OPT)

#  $(HOST_EXE_LOCAL_NO_OPT): $(HOST_SRCS)
# 	$(CXX) $(CXXFLAGS) -DLOCAL_BUFFERS $< -o $@ $(LDLIBS)

# iris_tensorflow: $(HOST_EXE)
# $(HOST_EXE): $(HOST_SRCS)
# 	$(CXX) $(CXXFLAGS) $< -o $@ $(LDLIBS)
	
# clean: 
# 	rm -f $(HOST_EXE) $(HOST_EXE_LOCAL_BUFFERS) $(HOST_EXE_LOCAL_NO_OPT) $(OUTPUTFILES)

LDLIBS                 = -l OpenCL
CXXFLAGS               = -std=c++11 -g -DIntel -lpthread -DTARGET=CPU
BUILDFLAGS             = -O2
HOST_SRCS              = ../host/iris_tensorflow.cpp
CXX                    = g++
HOST_EXE	           = iris_tensorflow.exe
HOST_EXE_LOCAL_BUFFERS = iris_tensorflow_local_buffers.exe
HOST_EXE_LOCAL_NO_OPT  = iris_tensorflow_local_buffers-no-opt.exe
HOST_EXE_NO_CHANNELS   = iris_tensorflow_no_channels.exe
OUTPUTFILES            = error.log out.dat results/result*

#Opencl 2.0 for pipes
#CXXFLAGS += -cl-std=CL2.0

iris_local_buffers: $(HOST_EXE_LOCAL_BUFFERS)

$(HOST_EXE_LOCAL_BUFFERS): $(HOST_SRCS)
	$(CXX) $(CXXFLAGS) $(BUILDFLAGS) -DLOCAL_BUFFERS -DUSECHANNELS $< -o $@ $(LDLIBS)

iris_no_channels: $(HOST_EXE_NO_CHANNELS)

$(HOST_EXE_NO_CHANNELS): $(HOST_SRCS)
	$(CXX) $(CXXFLAGS) $(BUILDFLAGS) $< -o $@ $(LDLIBS)

iris_local_buffers_no_opt: $(HOST_EXE_LOCAL_NO_OPT)

 $(HOST_EXE_LOCAL_NO_OPT): $(HOST_SRCS)
	$(CXX) $(CXXFLAGS) -DLOCAL_BUFFERS -DUSECHANNELS $< -o $@ $(LDLIBS)

iris_tensorflow: $(HOST_EXE)
$(HOST_EXE): $(HOST_SRCS)
	$(CXX) $(CXXFLAGS) -DUSECHANNELS $< -o $@ $(LDLIBS)
	
clean: 
	rm -f $(HOST_EXE) $(HOST_EXE_NO_CHANNELS) $(HOST_EXE_LOCAL_BUFFERS) $(HOST_EXE_LOCAL_NO_OPT) $(OUTPUTFILES)

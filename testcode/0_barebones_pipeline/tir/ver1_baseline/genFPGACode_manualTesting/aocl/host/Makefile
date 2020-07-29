AOCL_COMPILE_CONFIG=$(shell aocl compile-config)
AOCL_LINK_CONFIG=$(shell aocl link-config)

CXXFLAGS += -Iinc 
CXXFLAGS += -DLINUX 
CXXFLAGS += -pthread 
CXXFLAGS += -O2 
CXXFLAGS += -DAOCL
#CXXFLAGS += -lrt 
	#aocl v16 seems to need this

host : src/ACLHostUtils.cpp  src/ACLThreadUtils.cpp  src/main.cpp  src/timer.cpp
	/usr/bin/g++ -o host src/ACLHostUtils.cpp  src/ACLThreadUtils.cpp  src/main.cpp  src/timer.cpp $(AOCL_COMPILE_CONFIG) $(AOCL_LINK_CONFIG) $(CXXFLAGS)

clean:
	rm host	
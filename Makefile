# Simple makefile

EXES := bin/sdl_cpu bin/sdl_cuda

SOURCES=$(wildcard code/core/*.cc)
OBJECTS_CPU=$(SOURCES:.cc=_cpu.o)
OBJECTS_CUDA=$(SOURCES:.cc=_cuda.o)
OBJECTS_ROCM=$(SOURCES:.cc=_rocm.o)
OBJECTS=$(OBJECTS_CPU) $(OBJECTS_CUDA) $(OBJECTS_ROCM)

CXX         = g++
CXXFLAGS    = -g -O2 -Wall -fPIC -Wshadow -Woverloaded-virtual -Wno-unused-function -fno-var-tracking -std=c++17
INCLUDEFLAGS= -ISDL -I$(shell pwd) -Icode -Icode/core -I${ALPAKA_ROOT}/include -I/${BOOST_ROOT}/include $(shell rooutil-config --include) -I$(shell root-config --incdir) -I${CMSSW_BASE}/src
ifdef CMSSW_RELEASE_BASE
INCLUDEFLAGS:= ${INCLUDEFLAGS} -I${CMSSW_RELEASE_BASE}/src
endif
LDFLAGS     = -g -O2 $(SDLLIB) -L${TRACKLOOPERDIR}/SDL $(shell rooutil-config --libs) $(shell root-config --libs)
LDFLAGS_CUDA= -L${CUDA_HOME}/lib64 -lcudart
LDFLAGS_ROCM= -L${ROCM_ROOT}/lib -lamdhip64
ALPAKAFLAGS = -DALPAKA_DEBUG=0
CUDAINCLUDE = -I${CUDA_HOME}/include
ROCMINCLUDE = -I${ROCM_ROOT}/include
ALPAKA_CPU  = -DALPAKA_ACC_CPU_B_SEQ_T_SEQ_ENABLED
ALPAKA_CUDA = -DALPAKA_ACC_GPU_CUDA_ENABLED -DALPAKA_HOST_ONLY
ALPAKA_ROCM = -DALPAKA_ACC_GPU_HIP_ENABLED -DALPAKA_HOST_ONLY -DALPAKA_DISABLE_VENDOR_RNG -D__HIP_PLATFORM_HCC__ -D__HIP_PLATFORM_AMD__
EXTRAFLAGS  = -ITMultiDrawTreePlayer -Wunused-variable -lTMVA -lEG -lGenVector -lXMLIO -lMLP -lTreePlayer -fopenmp -DLST_STANDALONE
DOQUINTUPLET =
PTCUTFLAG    =
CUTVALUEFLAG =
CUTVALUEFLAG_FLAGS = -DCUT_VALUE_DEBUG

PRIMITIVEFLAG = 
PRIMITIVEFLAG_FLAGS = -DPRIMITIVE_STUDY

all: rooutil efficiency $(EXES)

cutvalue: CUTVALUEFLAG = ${CUTVALUEFLAG_FLAGS}
cutvalue: rooutil efficiency $(EXES)

primitive: PRIMITIVEFLAG = ${PRIMITIVEFLAG_FLAGS}
primitive: rooutil efficiency $(EXES)

cutvalue_primitive: CUTVALUEFLAG = ${CUTVALUEFLAG_FLAGS}
cutvalue_primitive: PRIMITIVEFLAG = ${PRIMITIVEFLAG_FLAGS}
cutvalue_primitive: rooutil efficiency $(EXES)


bin/sdl_cpu: SDLLIB=-lsdl_cpu
bin/sdl_cpu: bin/sdl_cpu.o $(OBJECTS_CPU)
	$(CXX) $(LDFLAGS) $(EXTRAFLAGS) $(INCLUDEFLAGS) $(ALPAKAFLAGS) $^ $(ROOTLIBS) $(PTCUTFLAG) $(CUTVALUEFLAG) $(PRIMITIVEFLAG) $(DOQUINTUPLET) $(ALPAKA_CPU) -o $@
bin/sdl_cuda: SDLLIB=-lsdl_cuda
bin/sdl_cuda: bin/sdl_cuda.o $(OBJECTS_CUDA)
	$(CXX) $(LDFLAGS) $(EXTRAFLAGS) $(INCLUDEFLAGS) $(ALPAKAFLAGS) $^ $(ROOTLIBS) $(PTCUTFLAG) $(CUTVALUEFLAG) $(PRIMITIVEFLAG) $(DOQUINTUPLET) $(ALPAKA_CUDA) $(LDFLAGS_CUDA) -o $@
bin/sdl_rocm: SDLLIB=-lsdl_rocm
bin/sdl_rocm: bin/sdl_rocm.o $(OBJECTS_ROCM)
	$(CXX) $(LDFLAGS) $(EXTRAFLAGS) $(INCLUDEFLAGS) $(ALPAKAFLAGS) $^ $(ROOTLIBS) $(PTCUTFLAG) $(CUTVALUEFLAG) $(PRIMITIVEFLAG) $(DOQUINTUPLET) $(ALPAKA_ROCM) $(LDFLAGS_ROCM) -o $@

%_cpu.o: %.cc rooutil
	$(CXX) $(CXXFLAGS) $(EXTRAFLAGS) $(INCLUDEFLAGS) $(ALPAKAFLAGS) $(PTCUTFLAG) $(CUTVALUEFLAG) $(PRIMITIVEFLAG) $(DOQUINTUPLET) $(ALPAKA_CPU) $< -c -o $@
%_cuda.o: %.cc rooutil
	$(CXX) $(CXXFLAGS) $(EXTRAFLAGS) $(INCLUDEFLAGS) $(ALPAKAFLAGS) $(PTCUTFLAG) $(CUTVALUEFLAG) $(PRIMITIVEFLAG) $(DOQUINTUPLET) $(ALPAKA_CUDA) $(CUDAINCLUDE) $< -c -o $@
%_rocm.o: %.cc rooutil
	$(CXX) $(CXXFLAGS) $(EXTRAFLAGS) $(INCLUDEFLAGS) $(ALPAKAFLAGS) $(PTCUTFLAG) $(CUTVALUEFLAG) $(PRIMITIVEFLAG) $(DOQUINTUPLET) $(ALPAKA_ROCM) $(ROCMINCLUDE) $< -c -o $@

rooutil:
	$(MAKE) -C code/rooutil/

efficiency: rooutil
	$(MAKE) -C efficiency/

clean:
	rm -f $(OBJECTS) bin/*.o $(EXES) bin/sdl
	rm -f code/rooutil/*.so code/rooutil/*.o
	rm -f bin/sdl.o
	rm -f SDL/*.o
	cd efficiency/ && make clean

.PHONY: rooutil efficiency

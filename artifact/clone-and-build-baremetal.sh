#!/bin/bash
# Fetch Mallob
#
#
source /nfs/software/setup.sh  
# spack add cmake gcc jemalloc openmpi curl gdb
# spack unload gcc openmpi jemalloc cmake culr gdb meson
#
#
echo gcc
spack load gcc@14.2.0%gcc@11.4.1 arch=linux-rocky9-x86_64
echo openmpi
spack load openmpi@5.0.5 arch=linux-rocky9-x86_64
echo jemalloc
spack load jemalloc@5.3.0%gcc@14.2.0 arch=linux-rocky9-x86_64
echo gdb
spack load gdb@14.2%gcc@14.2.0 arch=linux-rocky9-x86_64
echo meson
spack load meson@1.5.1%gcc@14.2.0 arch=linux-rocky9-x86_64
echo rust
spack load rust@1.85.0%gcc@14.2.0 arch=linux-rocky9-x86_64
echo autoconf
spack load /ckknjix   # autoconf
echo cmake
spack load /gqf7fyv   # cmake
echo curl
spack load /glmghui   # curl
echo automake
spack load /hjacese   # automake
echo libtool
spack load libtool@2.4.7%gcc@14.2.0 arch=linux-rocky9-x86_64
echo zlib-ng
spack load zlib-ng@2.2.1%gcc@11.4.1 arch=linux-rocky9-x86_64
echo "zlib-ng CPATH, LIBRARY_PATH"
# To let it find zlib.h ...
export CPATH="$(spack location -i zlib-ng@2.2.1%gcc@11.4.1 arch=linux-rocky9-x86_64)/include:$CPATH"
export LIBRARY_PATH="$(spack location -i zlib-ng@2.2.1%gcc@11.4.1 arch=linux-rocky9-x86_64)/lib:$LIBRARY_PATH"
echo gmp
spack load gmp@6.3.0%gcc@11.4.1 arch=linux-rocky9-x86_64
echo "gmp LIBRARY_PATH"
export LIBRARY_PATH="$(spack location -i gmp@6.3.0%gcc@11.4.1 arch=linux-rocky9-x86_64)/lib:$LIBRARY_PATH"

	echo ""
	echo GDB
	gdb --version
	echo ""
	echo JEMALLOC
	jemalloc-config --version
	echo ""
	echo CMAKE
	cmake --version
	echo ""
	echo MAKE
	make --version
	echo ""
	echo GCC
	gcc --version
	echo "" 
	echo MESON
	meson --version
	echo "" 
	echo CURL
	which curl
	curl --version
	echo ""


#to use the system curl which has proper CA certificates (?)
export PATH="/usr/bin:$PATH"

rm -rf mallob/

git clone https://github.com/domschrei/mallob 
cd mallob
git checkout  dbd4a35643fcbbee6c32e169016b2c17c595e2ee

sed -i 's|#include "app/sat/proof/palrup_caller.hpp"|// #include "app/sat/proof/palrup_caller.hpp"|' src/app/sat/job/forked_sat_job.cpp

bash scripts/setup/cmake-make.sh build \
-DMALLOB_MAX_N_APPTHREADS_PER_PROCESS=64 -DMALLOB_APP_SMT=1 -DMALLOB_APP_MAXSAT=1 -DMALLOB_APP_PALRUPCHECK=0 \
-DMALLOB_BUILD_IMPCHECK=1  2>&1 | tee build.log

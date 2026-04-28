#!/bin/bash

#for dry runs outside of docker
#use in combination with NO_DOCKER=1 variable
#i.e.
# NO_DOCKER=1 sudo -E ./scripts/run-test-smoke.sh

#If on server that uses Spack Environments
echo "(nondocker) prepare environment"

source scripts/nondocker_create_env.sh

#for bitwuzla rust/cargo linker
export CC=gcc
ln -s gcc ~/.user_spack/environments/mallob_env/.spack-env/view/bin/cc

rm -rf mallob/

# Fetch Mallob
echo "(nondocker) fetch Mallob"
git clone https://github.com/domschrei/mallob 
cd mallob 
git checkout dbd4a35643fcbbee6c32e169016b2c17c595e2ee

# Patch out unnecessary include when compiling with PALRUPCHECK=0 anyways
sed -i 's|#include "app/sat/proof/palrup_caller.hpp"|//#include "app/sat/proof/palrup_caller.hpp"|' src/app/sat/job/forked_sat_job.cpp

echo "(nondocker) build Mallob"
# Build Mallob (fetching and building all dependencies)
bash scripts/setup/cmake-make.sh build \
-DMALLOB_MAX_N_APPTHREADS_PER_PROCESS=64 -DMALLOB_APP_SMT=1 -DMALLOB_APP_MAXSAT=1 \
-DMALLOB_APP_PALRUPCHECK=0 \
-DMALLOB_BUILD_IMPCHECK=1 

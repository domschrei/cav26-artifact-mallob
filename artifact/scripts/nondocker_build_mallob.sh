#!/bin/bash

#for dry runs outside of docker
#use in combination with NO_DOCKER=1 variable
#i.e.
# NO_DOCKER=1 sudo -E ./scripts/run-test-smoke.sh

# Fetch Mallob
git clone https://github.com/domschrei/mallob 
cd mallob 
git checkout dbd4a35643fcbbee6c32e169016b2c17c595e2ee

#If on server that uses Spack Environments
source scripts/nondocker_create_env.sh

# Build Mallob (fetching and building all dependencies)
bash scripts/setup/cmake-make.sh build \
-DMALLOB_MAX_N_APPTHREADS_PER_PROCESS=64 -DMALLOB_APP_SMT=1 -DMALLOB_APP_MAXSAT=1 \
-DMALLOB_BUILD_IMPCHECK=1

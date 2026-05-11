#!/bin/bash

set -e

MALLOB_HASH=d70f5949cee65eeb23298cd1e9dd69e77f771997

tstart=$(date +%s)

cd artifact

    # Prepare Docker image
    sed -i 's/^git checkout .*/git checkout '$MALLOB_HASH'/g' ../Dockerfile
    docker build --progress=plain -f ../Dockerfile -t mallob-cav26 .
    docker save mallob-cav26 | gzip -9 > mallob-cav26-img.tar.gz

    # Prepare bare-metal Mallob installation
    rm -rf mallob-cav26
    git clone https://github.com/domschrei/mallob mallob-cav26
    cd mallob-cav26
        git checkout $MALLOB_HASH

        # Need to call the build script so that all dependencies are fetched
        bash scripts/setup/cmake-make.sh build -DMALLOB_MAX_N_APPTHREADS_PER_PROCESS=64 -DMALLOB_APP_SMT=0 -DMALLOB_APP_MAXSAT=0 -DMALLOB_APP_SATWITHPRE=0 -DMALLOB_BUILD_IMPCHECK=1

        # Then remove the binaries manually
        rm -rf build
        for d in lib/*/ ; do cd $d ; echo $d ; bash clean.sh ; cd ../.. ; done
    cd ..
    zip -r mallob-cav26.zip mallob-cav26

cd ..

# Bundle everything into a single ZIP
cp Dockerfile artifact/
zip -r cav26-mallob-artifact.zip artifact/{data,Dockerfile,LICENSE.txt,README.md,mallob-cav26.zip,mallob-cav26-img.tar.gz}

tend=$(date +%s)

echo "Whole procedure took $(($tend - $tstart))s"

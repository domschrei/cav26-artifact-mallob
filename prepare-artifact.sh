#!/bin/bash

set -e

cd artifact

    # Prepare Docker image
    docker build --progress=plain -f ../Dockerfile -t mallob-cav26 .
    docker save -o mallob-cav26-img.tar mallob-cav26
    gzip -9 mallob-cav26-img.tar

    if false; then
    # Prepare bare-metal Mallob installation
    git clone https://github.com/domschrei/mallob mallob-cav26
    cd mallob-cav26
        git checkout d64483557ab76cd6b524e93f206e267861ca1fe0

        # Need to call the build script so that all dependencies are fetched
        bash scripts/setup/cmake-make.sh build -DMALLOB_MAX_N_APPTHREADS_PER_PROCESS=64 -DMALLOB_APP_SMT=1 -DMALLOB_APP_MAXSAT=1 -DMALLOB_BUILD_IMPCHECK=1

        # Then remove the binaries manually
        rm -rf build
        for d in lib/*/ ; do cd $d ; bash clean.sh ; cd ../.. ; done
    cd ..
    zip -r mallob-cav26.zip mallob-cav26
    fi

cd ..

# Bundle everything into a single ZIP
zip -r cav26-mallob-artifact.zip artifact/{LICENSE.txt,README.md,mallob-cav26.zip,mallob-cav26-img.tar.gz}

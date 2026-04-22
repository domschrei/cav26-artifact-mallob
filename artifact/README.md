
# CAV 2026 Artifact for Paper #39


Paper title: **Mallob: Scalable Automated Reasoning On Demand**  
Claimed badges: **Available + Functional + Reusable**  

Justification for the badges:

* **Functional:** The artifact supports the claims on the capabilities of the tool presented in the paper. It provides a readily usable installation of Mallob in a Docker container, which supports all major features outlined in the paper at a shared-memory level.

  - Since our tool paper does not come with its own original experiments but instead discusses and re-examines experimental results from earlier papers, we reference the supplements of the according papers for reproducing these precise experiments. In the scope of this artifact, we decided to provide a broad experimental demonstration of all major capabilities of the Mallob system at a shared-memory level, showing some speedups for each application at small scales.

* **Reusable:** Mallob is MIT-licensed (+ LGPL dual license) and comes with extensive documentation.

Requirements:

* Smoke test:
  - 32 GB RAM
  - 8 physical cores
  - one hour
* Short shared-memory demonstration:
  - 64 GB RAM
  - 32 physical cores
  - 12 hours
* Full shared-memory demonstration:
  - 64 GB RAM
  - 32 physical cores
  - three days
* External connectivity: NOT required.


## Setup

We assume that [Docker is properly installed on your system](https://get.docker.com/).

- Import the docker image from `mallob-cav26-img.tar.gz`:

  ```bash
  docker load -i mallob-cav26-img.tar.gz
  ```
  This will import the docker image named `mallob-cav26`, which can take a few moments.

- Start a docker container:
  ```bash
  docker run -v $(pwd)/share:/app/share -it --rm mallob-cav26
  ```
  This will spin up a new docker container in which all subsequent steps should be executed. You can now reproduce the tests and experiments as explained below.
  
  Result files will be exported to your host machine's directory `./share` (relative to from where you executed the `docker run` command).

- Execute the command `exit` to leave the shell and exit the image at any point.


## Smoke Test

Start the smoke test with
```
scripts/run-test-smoke.sh
```

which should, at the end, print a line as follows:
```
************************************************************
All runs done. Find output at /app/share/mallob-fadd131f2af1-1776866726
************************************************************
```

Evaluate the test with:
```
scripts/eval-test-smoke.sh /app/share/mallob-fadd131f2af1-1776866726
```
(replace the directory according to the output of the test run).

**TODO** Plots and tables


## Full Review

**TODO** Instructions for running, evaluating, getting plots and tables


## Bare Metal Setup

For distributed experiments beyond the scope of this artifact's reproducibility, we also provide a bare metal setup of Mallob, i.e., for usage **outside** of the provided Docker container.

The following packages must be installed on your host system (assuming an Ubuntu-like OS):

```bash
git cmake build-essential zlib1g-dev libopenmpi-dev wget unzip build-essential zlib1g-dev cmake python3 build-essential gfortran curl libjemalloc-dev libjemalloc2 gdb psmisc meson python3-mesonpy ninja-build libgmp-dev pkgconf libmpfr-dev cargo bc
```

You should then be able to unpack and build Mallob as follows:

```bash
unzip mallob-cav26.zip
cd mallob-cav26
bash scripts/setup/cmake-make.sh build -DMALLOB_MAX_N_APPTHREADS_PER_PROCESS=64 -DMALLOB_APP_SMT=1 -DMALLOB_APP_MAXSAT=1 -DMALLOB_BUILD_IMPCHECK=1
```

If you are working with a SLURM-managed HPC cluster, please consult the SLURM-specific documentation for Mallob at the sub-directory `mallob-cav26/docs/clusters.md`. Otherwise, any subsequent steps heavily depend on your hardware and system environment, which unfortunately means that we cannot provide any specific instructions beyond this point.

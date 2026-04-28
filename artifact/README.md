
# CAV 2026 Artifact for Paper #39


Paper title: **Mallob: Scalable Automated Reasoning On Demand**  
Claimed badges: **Available + Functional + Reusable**  

Justification for the badges:

* **Functional:** The artifact supports the claims on the capabilities of the tool presented in the paper. It provides a readily usable installation of Mallob in a Docker container, which supports all major features outlined in the paper at a shared-memory level.

  - Since our tool paper does not come with its own original experiments but instead discusses and re-examines experimental results from earlier papers, we refer to the supplements of the according papers for reproducing these precise experiments. In the scope of this artifact, we decided to instead provide a **broad experimental demonstration** of all major capabilities of the Mallob system at a shared-memory level, showing speedups for each application at a small scale.

  - We also provide the resources required to run distributed experiments; however, since these are heavily dependent on the concrete computational environment at hand, we cannot offer a self-contained, end-to-end scripting pipeline in this setting.

* **Reusable:** Mallob is MIT-licensed (+ LGPL dual license) and comes with extensive documentation and tests.

Requirements:

* Smoke test:
  - 32 GB RAM
  - 8 physical cores
  - one hour
* Short shared-memory demonstration:
  - 64 GB RAM
  - 32 physical cores
  - 12-24 hours
* Full shared-memory demonstration:
  - 64 GB RAM
  - 32 physical cores
  - roughly one week
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


## Benchmarks

This artifact comes with a number of diverse benchmark sets based on the following benchmarks:

* SAT: [International SAT Competition 2025](https://satcompetition.github.io/2025/downloads.html)
* IncSAT: [Incremental SAT benchmark set](https://doi.org/10.5281/zenodo.18330440) from three application tools (Bitwuzla, 2LS, Lilotane), as introduced by Schreiber et al. (2026), "Real-time Proof Checking for Distributed Incremental SAT Solving" (TACAS'26).
* SMT: [Selection of SMT-LIB benchmarks](https://doi.org/10.5281/zenodo.17478480) as introduced by Schreiber et al. (2026), "Massively Parallel Bit-precise Verification with Bitwuzla and Mallob" (TACAS'26).
* MaxSAT: [MaxSAT Evaluation 2024](https://maxsat-evaluations.github.io/2024/benchmarks.html), anytime weighted and unweighted problems

For practical reasons (such as the size of the artifact), note that we removed the largest instances (roughly the ones with file sizes ≥ 128 MiB) from these test sets.

You can extract all benchmarks to your host machine (e.g., to run bare-metal experiments) by entering the Docker image and then copying the benchmark directory to the `share/` directory:
```bash
cp -r benchmarks share/
```


## Smoke Test

In the Docker image, start the smoke test with
```
scripts/run-test-smoke.sh
```

which should, at the end, print a line as follows:
```
************************************************************
All runs done. Find output at /app/share/mallob-123456789abc-123456789
************************************************************
```

Evaluate the test with:
```
scripts/eval-test-smoke.sh /app/share/mallob-123456789abc-123456789
```
(replace the directory according to the output of the test run).
This creates raw data files that form the basis for plots and tables.

You can then accordingly run
```
scripts/plot-test-smoke.sh /app/share/mallob-123456789abc-123456789
```
to produce plots.

# TODO EXPLAIN PLOTS (& TABLES ?)


## Full Review

The full demonstration is run just like the above smoke test:
```
# Small demo (60s time limit per input, reduced benchmark sets) - 12-24 hours
scripts/run-test-demo-small.sh
scripts/eval-test-demo-small.sh /app/share/mallob-123456789abc-123456789
scripts/plot-test-demo-small.sh /app/share/mallob-123456789abc-123456789

# Large demo (300s time limit per input, full benchmark sets) - about a week
scripts/run-test-demo.sh
scripts/eval-test-demo.sh /app/share/mallob-123456789abc-123456789
scripts/plot-test-demo.sh /app/share/mallob-123456789abc-123456789
```


## Custom Experiments

The setup we provide can be easily extended to run custom experiments. Consult, e.g., the file `scripts/run-test-demo.sh` in the Docker image. Using Mallob program options (consulting Mallob's specific documentation, especially in its `docs/` directory) and the featured environment variables, you can assemble your own suite of experiments with deviating scales, timeouts, benchmarks, or Mallob configurations. Please let us know if you run into any trouble doing so. 


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

If you are working with a SLURM-managed HPC cluster, please consult the SLURM-specific documentation for Mallob at the sub-directory `mallob-cav26/docs/clusters.md`. Otherwise, any subsequent steps heavily depend on your hardware and system environment, which unfortunately means that we cannot provide any specific instructions for launching the distributed program.


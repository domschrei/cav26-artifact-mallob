
# CAV 2026 Artifact for Paper #39


Paper title: **Mallob: Scalable Automated Reasoning On Demand**  
Claimed badges: **Available + Functional + Reusable**  

Justification for the badges:

* **Functional:** The artifact supports the claims on the capabilities of the tool presented in the paper. It provides a readily usable installation of Mallob in a Docker container, which supports all major features outlined in the paper at a shared-memory level.

  - Since our tool paper does not come with its own original experiments but instead discusses and re-examines experimental results from a wide range of prior publications, we refer to the supplements of the according papers for reproducing the respective experiments. In the scope of this artifact, we decided to instead provide a **broad experimental demonstration** of all major capabilities of the Mallob system at a shared-memory level, showing some selected performance measures for each application at a small scale.

  - We also provide the sources and scripts required to run distributed experiments; however, since these are heavily dependent on the concrete computational environment at hand, we cannot offer a self-contained, end-to-end, one-size-fits-all pipeline in this setting.

* **Reusable:** Mallob is MIT-licensed (+ LGPL dual license) and comes with extensive documentation and tests.

Requirements:

* Smoke test:
  - 32 GB RAM
  - 8 physical cores
  - 30 min
* Small shared-memory demonstration:
  - 64 GB RAM
  - 32 physical cores
  - 24 hours
* Full shared-memory demonstration:
  - 64 GB RAM
  - 32 physical cores
  - roughly one week
* External connectivity: NOT required.


## Content

This artifact contains the following files:

* README.md : The documentation you are currently reading
* LICENSE.txt : MIT license
* mallob-cav26.zip : The Mallob project, including its source code, scripts, and documentation. A snapshot of [Mallob's GitHub repository](https://github.com/domschrei/mallob)
* mallob-cav26-img.tar : A Docker image you can readily import and enter, coming with a pre-installed and set up Mallob, diverse benchmarks, and convenience scripts for running experiments
* data/ : Sample experimental data and plots produced with the artifact on our end.


## Setup

We assume that [Docker is properly installed on your system](https://get.docker.com/).

- Import the docker image from `mallob-cav26-img.tar.gz`:

  ```bash
  docker load -i mallob-cav26-img.tar.gz
  ```
  This will import the docker image named `mallob-cav26`, which can take a few moments.

- Start a docker container:
  ```bash
  mkdir -p ./share
  docker run -v ./share:/app/share -it --rm mallob-cav26
  ```
  This will spin up a new docker container in which all subsequent steps should be executed. You can now reproduce the tests and experiments as explained below.
  
  Result files will be exported to your host machine's directory `./share` (relative to from where you executed the `docker run` command).

- Execute the command `exit` to leave the shell and exit the image at any point.


## Benchmarks

This artifact comes with a number of diverse benchmark sets from the following sources:

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
####################################################################################
All runs done. Find output at /app/share/mallob-123456789abc-123456789
####################################################################################
```

Evaluate the test with:
```
scripts/eval-test-smoke.sh /app/share/mallob-123456789abc-123456789
```
(replace the directory according to the output of the test run).
This first creates raw data files, which form the basis for plots and tables, and then produces said plots and tables.

The output should end like this:
```
####################################################################################
All output written to /app/share/mallob-123456789abc-123456789/output-987654321/
####################################################################################
```

As a basic sanity check, you can read the basic performance table gathered for SAT solving and should get output like this:

```
$ cat /app/share/mallob-123456789abc-123456789/output-987654321/table-sat.txt
_                   overall  _        satisf.  _         unsatisf.  _
Run                 #solved  PAR2     #solved  avgtime   #solved    avgtime
c1-sat-mixed        11       4.51659  4        0.040775  7          0.0241091
c1-sat-monolproof   11       4.54403  4        0.107934  7          0.0641143
c1-sat-rtcheck      8        6.03196  3        0.14766   5          0.039245
c1-sat-streamlined  12       4.05699  4        0.244611  8          0.020179
c8-sat-mixed        13       3.60742  5        0.391268  8          0.0240116
c8-sat-monolproof   11       4.55621  4        0.117328  7          0.093557
c8-sat-rtcheck      13       3.87363  6        1.19653   7          0.0419234
c8-sat-streamlined  12       4.02875  4        0.103426  8          0.0201673
```

Similarly, if you visit the indicated output directory on your host system (i.e., outside of Docker) and open the file `sat-cdf-logscale.pdf`, you should be able to see performance lines for the same eight runs.

**Note:** The experiments of the smoke test are **not** indicative of the different approaches' performance, since the timeouts, scales, and benchmark sets are far too small/low to arrive at any meaningful data.


## Full Review

The full demonstration is run just like the above smoke test:
```
# Small demo (60s time limit per input, reduced benchmark sets) - 12-24 hours
scripts/run-test-demo-small.sh
scripts/eval-test-demo-small.sh /app/share/mallob-123456789abc-123456789

# Full demo (300s time limit per input, full benchmark sets) - about a week
scripts/run-test-demo.sh
scripts/eval-test-demo.sh /app/share/mallob-123456789abc-123456789
```

The produced output contains the following files:

* table-{sat,incsat,maxsat,smt,scheduling}.txt : Basic performance measures for the different setups.
* {sat,incsat,maxsat,smt,scheduling}-cdf.pdf : Performance curves for the different setups (linear scale).
* {sat,incsat,maxsat,smt}-cdf-logscale.pdf : Performance curves for the different setups (logarithmic scale).

  - Note that for IncSAT, MaxSAT, and SMT, only completely solved inputs are counted as solved in these plots. Inputs where some number of queries / increments / solution costs have been solved are not visualized.

* maxsat-quality-{lb,ub}.pdf : Whenever MallobMax finds an updated (lower|upper) bound for the objective function, the bound is rated with a number between 0 and 1 (based on the best known solution for the instance). The plot shows, similar to the CDF plots above, how the sum of these scores progresses over time.
* 1v1-overhead-over-mixed-*.pdf : Per-instance performance comparison of monolithic proof production with unchecked, mixed-portfolio solving.
* 1v1-overhead-*-rtcheck.pdf : Per-instance performance comparison of solving including real-time proof checking with unchecked, mixed-portfolio solving.
* 1v1-overhead-solve-vs-check-*.pdf : Per-instance performance comparison of solving time vs. checking time with monolithic proof production.

In each output, "c1" represents single-core runs, "c8" eight-core runs, etc.

### Expected results

Precisely quantifying the expected performance of the experiments is difficult since deviations in the used hardware can result in significantly different performance measures. That said, we now provide a number of qualitative indicators you should be able to confirm based on the produced plots and tables if everything went smoothly:

* `table-sat.txt`, `sat-cdf(-logscale).pdf` : The parallel configurations generally outperform the sequential variants in terms of more solved instances and lower PAR-2 scores. The "mixed" and "streamlined" configurations are expected to perform the best whereas the proof-backed "rtcheck" and "monol" variants incur some additional overhead.

  - Note that the proof-backed variants are based on a different portfolio (CaDiCaL only) than the unchecked variants (Kissat and others). Due to orthogonal performance of the solver backends, it is normal that the proof-backed variants perform better than the unchecked variants on some instances.

* `table-incsat.txt`, `incsat-cdf(-logscale).pdf` : The parallel variants **do not necessarily** outperform the sequential variants, reason being that the overhead of parallel execution is often not worthwhile for many of the considered inputs. The variants with proof checking ("rtcheck") are expected to perform worse than the unchecked variants.
* `table-maxsat.txt`, `maxsat-cdf(-logscale).pdf` : The number of optimal instances may be rather low especially in the "small" demo. This can also lead to very low "LB" scores and few (or none) data points in the CDF plot. The UB score (i.e., overall found solution quality over time), however, should clearly show the benefits of the parallel execution as running times increase.
* `table-smt.txt`, `smt-cdf(-logscale).pdf` : Solved instances should be larger and PAR-2 score should be lower for the parallel variant. The CDF plot should show that the parallel variant consistently performs better (beginning at some minimum running time).
* `table-scheduling.txt`, `scheduling-cdf.pdf` : The larger-scale variant should solve more instances overall and dominate the performance of the lower-scale variant in the CDF plot (i.e., solved instances over time).
* `maxsat-quality-{lb,ub}.pdf` : The progression of lower bounds ("LB") may be rather uninteresting (or completely empty) if few instances (or none) were solved to completion. The progression of upper bounds ("UB") should however show better scores for the parallel variant, especially at longer running times.
* `1v1-overhead-over-mixed-*.pdf` : The checked variant should generally incur some overhead (i.e., points mostly above the diagonal), which can be especially large for very low running times. The overhead is expected to be higher for the parallel variant than for the sequential variant.
* `1v1-overhead-*-rtcheck.pdf` : The measured overhead should generally be lower than for monolithic proof production (`1v1-overhead-over-mixed-*-monolproof.pdf`) and be mostly independent of the scale of solving (i.e., the points are distributed similarly for the sequential vs. parallel variant).
* `1v1-overhead-solve-vs-check-*.pdf` : The time needed for checking should be significantly lower than for solving in the sequential case. In the parallel case, checking times may be closer to the solving time.

You can also compare the data and plots obtained from your runs with the sample data we provide in the artifact (`data/` directory).


## Custom Experiments

The setup we provide can be easily extended to run custom experiments. Consult, e.g., the file `scripts/run-test-demo.sh` in the Docker image. Using Mallob program options (consulting Mallob's specific documentation, especially in its `docs/` directory) and the featured environment variables, you can assemble your own suite of experiments with deviating scales, timeouts, benchmarks, or Mallob configurations. Please let us know if you run into any trouble doing so. 


## Bare Metal Setup

For experiments beyond the scope of this artifact's reproducibility, we also provide a bare metal setup of Mallob, i.e., for usage **outside** of the provided Docker container.

**Note:** Experiments conducted on bare-metal hardware must be evaluated (`eval-*.sh`) **outside** of the Docker container, and experiments conducted in the Docker environment must be evaluated **within** the Docker environment.

The following packages must be installed on your host system (assuming an Ubuntu-like OS):

```bash
git cmake build-essential zlib1g-dev libopenmpi-dev wget unzip build-essential zlib1g-dev cmake python3 build-essential gfortran curl libjemalloc-dev libjemalloc2 gdb psmisc meson python3-mesonpy ninja-build libgmp-dev pkgconf libmpfr-dev cargo bc
```

You should then be able to unpack and build Mallob as follows:

```bash
unzip mallob-cav26.zip
mv mallob-cav26 mallob
cd mallob
bash scripts/setup/cmake-make.sh build -DMALLOB_MAX_N_APPTHREADS_PER_PROCESS=64 -DMALLOB_APP_SMT=1 -DMALLOB_APP_MAXSAT=1 -DMALLOB_BUILD_IMPCHECK=1
```

To use our experimental scripting setup outside of Docker at a shared-memory level, you need to extract the directories `benchmarks/` and `scripts/` from the Docker container (as described at "Benchmarks" above).
Make sure that your directory structure looks like this:

```
<base directory>
├── benchmarks
├── mallob
|   ├── build
|   └── ...
└── scripts
```

You should then be able to run experiments from the base directory, e.g., via `scripts/run-test-smoke.sh`.

If you are working with a SLURM-managed HPC cluster, please consult the SLURM-specific documentation for Mallob at the sub-directory `mallob/docs/clusters.md`. Otherwise, any subsequent steps heavily depend on your hardware and system environment, which unfortunately means that we cannot provide any specific instructions for launching the distributed program. Let us know if you experience any troubles and we may be able to assist!


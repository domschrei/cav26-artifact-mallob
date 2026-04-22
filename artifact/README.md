
# CAV 2026 Artifact

Paper title: **Mallob: Scalable Automated Reasoning On Demand**  
Claimed badges: **Available + Functional + Reusable**  

Justification for the badges:

  * **Functional:** [give reasons why you believe that the Functional badge should
    be awarded (if applied for Functional or Reusable); example:  The artifact
    replicates most of the results in the paper (see below for details).  It
    compiles Tool and executes the benchmarks on it and the other tools.  We
    validate the correctness of the outputs of Tool by cross-comparison with
    the results of the other tools.  The source code of Tool is included in the
    artifact.]

    - replicated: [which claims/results of the paper are replicated by the
      artifact and how (you can, e.g., refer to a concrete point in FULL REVIEW
      below), e.g.,
       * Table 1: point (1)
       * Figure 1: point (2)
       * Figures 2 and 3: point (3)
       * Figure 4: point (4) [requires external connectivity]
       * Proof of Thm. 5: point (5)
      ]

    - not-replicated: [which claims/results cannot be replicated and why, e.g.,
       * Table 2: to reproduce the results, one needs to have access to the
                  computer Holly 6000, which is not available outside our
                  research lab
       * Table 3: this table is a result of a survey among undergraduate students
                  at the Institute of Happiness; the survey cannot be
                  reproduced as a part of the artifact, but the raw filled in
                  questionnaires are available in the directory survey/
       * Fig. 6: to obtain the results, one needs to have a working installation
                 of AcmeVerifier of Acme Inc.; if the reviewers have it,
                 they can reproduce the results by point (6) below.
      ]

  * **Reusable:** [give reasons why you believe that the Reusable badge should be
    awarded (if applied for); e.g., The license of Tool is GNU GPLv3.  Tool is
    provided with an extensive test suite (in /tool/tests/) and documentation
    (in /tool/doc after the tool is compiled).

Requirements:

  * RAM: [FILL IN]
  * CPU cores: [FILL IN]
  * Time (smoke test): [expected time to execute the smoke test on a standard
    laptop (including compilation, installation, etc.)]
  * Time (full review): [expected time to execute the full review (do not
    include the time of reviewers reading the paper, playing with the tool on
    their own, etc.)]

external connectivity: NO


## Setup

- Import the docker image from `mallob-cav26-img.tar.gz`:

  ```bash
  docker load -i mallob-cav26-img.tar.gz
  ```
  This will import the docker image named `mallob-cav26`. This
  can take a few moments.

- Start a docker container:
  ```bash
  docker run -v $(pwd)/share:/app/share -it --rm mallob-cav26
  ```

  **Note:** This will spin up a new docker container in which all subsequent
    steps should be executed. You can now reproduce the tests and experiments
    as explained below.

 - Result files will be exported to your host machine's directory `./share`
   (relative to from where you executed the `docker run` command).

 - Execute the command `exit` to leave the shell and exit the image at any
   point.


## Smoke Test

Start the smoke test with

  scripts/run-test-smoke.sh

which should, at the end, print a line as follows:

  ************************************************************
  All runs done. Find output at /app/share/mallob-fadd131f2af1-1776866726
  ************************************************************

Evaluate the test with:

  scripts/eval-test-smoke.sh /app/share/mallob-fadd131f2af1-1776866726

(replace the directory according to the output of the test run).





## Full Review

[below is an example of how to write this section; delete it and substitute
with your instructions]

Assuming the smoke test passed, run the following command to reproduce the
results.  Running the full benchmark suite can take around 1 week on a standard
laptop, so we also provide a short version containing a selection of benchmarks
that should show the same trends as the whole suite and finishes in ~4 hours.

  cd results/

  ./run_full.sh results/output.csv     [to run the full version ~ runtime: 1 week]

or 

  ./run_short.sh results/output.csv    [to run the short version ~ runtime: 4 hours]

The commands will print out progress as their execute the benchmarks.
The output will be a file "output.csv".

For completeness, we included the output files obtained by our experiments in
folder ref_output_full/.

In the following outputs, concrete values may differt but the overall trends
(e.g., ratios between the mean times of the tools) should stay the same.

(1) To obtain the results in Table 1, run the following command:

    cd results/
    ./generate_table1.sh output.csv

    and the table will be printed on the standard output

(2) To obtain the results in Figure 1, run the following command:

    cd results/
    ./generate_fig1.sh output.csv

    the figure will then be in results/fig1.svg

(3) To generate Figures 2 and 3, run the following command:

    cd results/
    ./generate_figs2_3.sh output.csv

    the figure will then be in results/fig2.png and results/fig3.pdf

(4) [this point requires external connectivity]
    To generate Figure 4, run

    cd results/
    ./generate_fig4.sh survey/data.xml

    this will access the servers of Acme Inc. to generate the figure, which will be in results/fig4.svg

(5) To certify the proof of Thm. 5., run

    rocqc thm5_proof.v
    echo "exit code = $?"

    if exit code is 0, the proof is verified

(6) [optional, this step needs a working copy of AcmeVerifier; expected runtime: 1 hour]
    To generate Figure 6, run the following command
    
    # set up a working copy of AcmeVerifier on the virtual machine
    export ACME_VER_PATH=<path to the AcmeVerifier binary>
    export ACME_VER_LICENSE_KEY=<AcmeVerifier license key>
    ./run_acme.sh output_acme.csv
    ./generate_fig5.sh output_acme.csv

    the resulting figure will be in results/fig5.gif


## Bare Metal Setup

```bash
cd mallob
bash scripts/setup/cmake-make.sh build -DMALLOB_MAX_N_APPTHREADS_PER_PROCESS=64 -DMALLOB_APP_SMT=1 -DMALLOB_APP_MAXSAT=1 -DMALLOB_BUILD_IMPCHECK=1
```

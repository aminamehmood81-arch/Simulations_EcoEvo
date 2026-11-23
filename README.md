# Simulations_EcoEvo

**Amina Mehmood** – MSc Computational Methods in Ecology and Evolution (CMEE),
Imperial College London, 2026–27

Coursework for *Scientific Computing and Simulation for Ecology and Evolution*
(James Rosindell).

## Repository structure

### `code/`
R scripts for the coursework.

### `hpc/`
Job script used on the Imperial HPC cluster, plus a sample of the job
output (`.o`) and error (`.e`) files as proof of the runs.

### `results/`
Figures and simulation outputs.

## Requirements

R (tested with R 4.5.2 locally and R 4.5.1 on the HPC). Base R only, no extra packages.

## Part 1 – Stochastic demographic population model

### Files

- `code/Demographic.R` – the model: parameters, parameter checks and all model
  functions (deterministic and stochastic). Every other script loads it.
- `code/Panel_B_HPC.R` – one HPC job: 40 stochastic runs for each starting size
  (3, 10, 30, 100 adults), 120 time steps each. Saves one `.rda` file per job.
- `hpc/run_script.sh` – the job script submitted to the cluster.
- `hpc/*.e3048681.*`, `hpc/*.o3048681.*` – sample error and output files from
  3 of the 20 jobs.
- `results/panel_b_rda/` – the 20 result files from the HPC (one per job).
- `code/Figure_1.R` – makes the final two-panel figure: simulates Panel a
  locally and reads the 20 HPC files for Panel b. Saves `results/figure_1.pdf`.

### Workflow

1. **Model** – `Demographic.R` holds the model. Every other script loads it,
   so it is written only once.
2. **Local test** – I ran `Panel_B_HPC.R` on my laptop first (one job,
   40 runs per size) to check it worked before using the cluster.
3. **HPC runs** – I copied `Demographic.R` and `Panel_B_HPC.R` to the Imperial
   cluster and submitted `run_script.sh` as an array job: `qsub -J 1-20 run_script.sh`
   - 20 jobs × 40 runs = 800 runs per starting size, 120 time steps each.
   - Each job uses its job number (`PBS_ARRAY_INDEX`) as its seed, so every job
     gives different results, and each one can be repeated exactly.
   - All 20 `.e` files were empty (no errors). I downloaded the 20 result files
     to `results/panel_b_rda/`.
   - The jobs ran in my home folder. Next time I will run them in `$TMPDIR`
     (fast local storage on the compute node) and copy the results back.
4. **Figure** – `Figure_1.R` runs Panel a locally (seed 2026), reads the 20 HPC
   files, counts how many runs were extinct (population 0) at time step 120, and
   draws both panels.

### How to run

Run from the project root:

    Rscript code/Figure_1.R

or, inside R started in the project root: `source("code/Figure_1.R")`.

To rerun the HPC part, copy `code/Demographic.R` and `code/Panel_B_HPC.R` to
`$HOME/run_files/` on the cluster, then submit `qsub -J 1-20 run_script.sh`.

### Changes made to the provided code

The model code is based on `Demographic.R` provided on Canvas. Changes:

- Added the missing `sum_vect()` function, needed by `survival_maturation()`.
- `rmultinom(n = 11, ...)` → `rmultinom(n = 1, ...)`: the call generated 11
  independent random draws, but the function only returned one, so the other
  10 draws were wasted every time.
- `print()` → `stop()` when transition probabilities add up to more than 1, so the
  code halts instead of continuing with impossible values.
- Removed an `if` block in `stochastic_simulation()` that had no effect (the time
  series is already filled with zeros when it is created).
- Removed `rm(list = ls())`, because it deleted the variables of any script
  that loaded the model.
- Added `stopifnot()` checks on the parameters.

### Sources

- Coursework brief: `2026_sci_comp_in_E_and_E_coursework_11-15-26.pdf`
- Provided model code: `Demographic.R` (Canvas)
- Model parameters: `matrix_info_for_part_1.pdf`
- HPC instructions: `HPC_use_notes.pdf` and `Practical_1_-_cluster_use_1.pdf`

---

# Development Diary

## 2026-11-21 20:15

**Recap of 18–20 Nov (written today because I did not push entries on those days):**
- 18 Nov: first successful HPC login.
- 19–20 Nov: learned how matrix population models work and read the provided code.

**Key idea I understood:** both models use the same fixed probabilities. The
deterministic model applies them as exact fractions to the whole population,
like a script. The stochastic model gives each individual its own random chance,
so the outcome changes from year to year even though the probabilities stay the
same.

**Today:**
- Added the parameters and `stopifnot()` checks, so a typing mistake would stop
  the code instead of silently giving wrong results.
- Fixed the code: added `sum_vect`, changed `rmultinom` n=11 to n=1, changed
  `print` to `stop`, and removed an `if` block that did nothing.
- Built Panel A step by step: deterministic lines first, then stochastic.
- My first figure was cluttered (legend on top of the data, too many lines).
  I improved it: legend below the plot, lighter dashed lines, deterministic lines
  drawn on top, 5 runs per colour.

**Seed hacking:** changing the seed changed the stochastic lines a lot, and some
seeds gave much neater figures. I tried several. I asked Claude why and learned
that choosing a seed after seeing the results is called seed hacking. I went
back to 2026, the seed I chose before seeing any results.

**Also noticed:** changing n=11 to n=1 changed my example lines, because n=11
used up more random numbers. Both are statistically the same. I chose n=1
because it is correct (only one draw is needed). I also timed both: the
difference was only a few milliseconds, so speed was not the main reason.

**AI use:** used Claude as a tutor to explain each function line by line and the
idea of seed hacking. I tested things myself in R to check I understood. Claude
also helped me tidy the wording of this README.

**Prediction for Panel b:** I predict that populations starting with fewer
adults have a higher chance of extinction than populations starting with more
adults. Each individual has the same survival chance in both, but in a small
population a few unlucky deaths or failed breeding attempts can remove
everyone. In a large population, good and bad luck almost cancel each other out.

## 2026-11-22 20:15
I ran local test, job 1 and observed 40% of runs starting with 3 adults went extinct.
Claude made me predict before analysing the HPC results and I predicted if My local test (40 runs) gave 40% extinction from 3 adults. With 800 runs per size I expect roughly: 3 adults: 60%, 10 adults: 30%, 30 adults: 10%, 100 adults: 5%. And, the reason might be that big population balances out the luck, lucky and unlucky individuals cancel each other out. A small population doesn’t have enough individuals to do that, so a few unlucky deaths can wipe it out.
After HPC runs these are the results I got. Results (800 runs per size):3 adults: 40.6%, 10: 6.2%, 30: 0.1%,
100: 0%. 
Compared with my prediction: right direction, but extinction fell much faster than I expected. This might be because the larger number of runs produced more possibilities even that the probability fell down to zero in 100 adults population. 
I am still working on my code for right figure generation, that's why I am not comitting any of these today.

## 2026-11-23

**Correction to yesterday:** I wrote that extinction fell fast because more runs
gave more possibilities. That was wrong. More runs only make the estimate more
precise; they do not change the true probability. The real reason: each adult
starts its own family line, and the population only dies out if every line
dies out. If one line dies with chance about 0.74, then N lines all die with
chance about 0.74^N, which gets very small very fast as N grows.

**Figure:** combined Panel a and Panel b into one two-panel figure
(`Figure_1.R`), as the brief asks. Panel b went through several versions:
I added the probability values next to each dot, moved the legends below both
panels so they line up, drew a proper error-bar symbol in the legend, made the
axis titles bold, and labelled both log axes.

**Error bars:** at 100 adults, 0 of 800 runs went extinct, so the standard error
is 0. This does not mean extinction is impossible, only that it is rarer than
about 3 in 800 (rule of three).

**Tidying the repo:** the same code was in `Panel_A.R`, `Panel_B.R` and
`Figure_1.R`. I kept the model in `Demographic.R` and the figure in
`Figure_1.R` only, so each job lives in one place. I moved the old scripts to my
local sandbox, which is not pushed. I removed `rm(list = ls())` from
`Figure_1.R` and tested it in a clean R session (`R --vanilla`,
`source("code/Figure_1.R")`): it rebuilt the figure with no errors.

**HPC working directory:** my jobs ran in `$HOME`, not `$TMPDIR`. James said
this is fine for now, but next time I should `cd $TMPDIR`, `cp` the scripts in,
run there, and `cp` the results back to `$HOME`, because `$TMPDIR` is fast local
storage on the compute node and doesn't overload the shared drive.


**AI use:** Claude explained the q^N idea, the plotting functions (`text`,
`arrows`, `legend`, `par`), `$TMPDIR` and the `.e`/`.o` files, and helped me
check word counts for the caption. I made the design decisions for the figure
myself.
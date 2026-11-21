# Simulations_EcoEvo

**Amina Mehmood** – MSc Computational Methods in Ecology and Evolution (CMEE),
Imperial College London, 2026–27

Coursework for *Scientific Computing and Simulation for Ecology and Evolution*
(James Rosindell).

## Repository structure

### `code/`
R scripts for the coursework.

### `data/`
Input data. Empty for Part 1: all model parameters are set in the code.

### `results/`
Figures and simulation outputs.

### `sandbox/`
Practice and test scripts. Not part of the assessed work.

## Requirements

R (tested with R 4.5.2). Base R only, no extra packages.

## Part 1 – Stochastic demographic population model

### Files

- `code/Panel_A.R` – model parameters, parameter checks, all model
  functions (deterministic and stochastic) and the code for Panel a: the
  deterministic model and 5 example stochastic runs, starting from 100 and
  10 adults, for 24 time steps. Saves `results/panel_a.pdf`.
- Panel b *(in progress)*: extinction probability against starting size, using
  the Imperial HPC.

### How to run

Run from the project root:

    Rscript code/Panel_A.R

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
- Added `stopifnot()` checks on the parameters.

### Sources

- Coursework brief: `2026_sci_comp_in_E_and_E_coursework_11-15-26.pdf`
- Provided model code: `Demographic.R` (Canvas)
- Model parameters: `matrix_info_for_part_1.pdf`
- HPC instructions: `HPC_use_notes.pdf` and `Practical_1_-_cluster_use_1.pdf`

## Part 1 – Results Discription
In the deterministic model, both curves have the same shape even though they start with different numbers of adults. This is because both start with only adults, and the stage they start in, rather than their number, defines the shape. The population first booms because the adults produce offspring. Then it drops, because many adults die and the offspring take time to grow through three stages before they can reproduce. After that, the population grows steadily, because it now has individuals in every stage. In the stochastic model, runs starting with 100 adults stay close to the deterministic line, but runs starting with 10 adults are much more haphazard, and one of five fell to a single individual. In a small population, chance deaths and failed breeding can push numbers down further and further.

---

# Development Diary
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


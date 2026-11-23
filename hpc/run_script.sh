#!/bin/bash
#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=1:mem=1gb
module load R/4.5.1-gfbf-2025a
cd $HOME/run_files/results
echo "R is about to run"
R --vanilla < $HOME/run_files/Panel_B_HPC.R
echo "R has finished running"


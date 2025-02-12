#!/bin/bash
#SBATCH --job-name=tescho_mod
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --ntasks=8
#SBATCH --time=36:00:00

module load python
conda activate /project2/cbrook/software/modeltest_env

modeltest-ng -i tescho_full_align.fasta -d nt -t ml -p 8

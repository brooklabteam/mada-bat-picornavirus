#!/bin/bash
#SBATCH --job-name=kun
#SBATCH --partition=broadwl
#SBATCH --output=kun.out
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --ntasks-per-node=5
#SBATCH --time=36:00:00

module load vim/7.4
module load emacs/25.1
module load python/3.6
module load java/1.8.0_121
module load cmake/3.15.1

raxml-ng-mpi --all --msa kunsagi_all_align.fasta --model TIM2+G4 --prefix T1  --seed 1 --threads auto{5} --bs-metric fbp,tbe

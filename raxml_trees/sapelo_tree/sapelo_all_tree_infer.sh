#!/bin/bash
#SBATCH --job-name=sapelo_tree
#SBATCH --partition=broadwl
#SBATCH --output=sapelo_tree.out
#SBATCH --nodes=1
#SBATCH --ntasks=9
#SBATCH --ntasks-per-node=9
#SBATCH --time=36:00:00

module load vim/7.4
module load emacs/25.1
module load python/3.6
module load java/1.8.0_121
module load cmake/3.15.1

raxml-ng-mpi --msa sapelo_all_align.fasta --model GTR+G4 --prefix T2 --seed 1 --threads auto{9}
#!/bin/bash
#SBATCH --job-name=kobu_boot2
#SBATCH --partition=broadwl
#SBATCH --output=kobu_boot2.out
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=8
#SBATCH --time=36:00:00

module load vim/7.4
module load emacs/25.1
module load python/3.6
module load java/1.8.0_121
module load cmake/3.15.1

raxml-ng-mpi --bootstrap --msa kobu_all_align.fasta --model GTR+I+G4 --prefix T4  --seed 2 --threads auto{8}

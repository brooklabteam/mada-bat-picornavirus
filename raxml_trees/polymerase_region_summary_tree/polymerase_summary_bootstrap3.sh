#!/bin/bash
#SBATCH --job-name=poly_boot3
#SBATCH --partition=broadwl
#SBATCH --output=poly_boot3.out
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --ntasks-per-node=6
#SBATCH --time=36:00:00

module load vim/7.4
module load emacs/25.1
module load python/3.6
module load java/1.8.0_121
module load cmake/3.15.1

raxml-ng-mpi --bootstrap --msa polymerase_summary_align_trim.fasta --model GTR+I+G4 --prefix T5  --seed 2 --threads auto{6}

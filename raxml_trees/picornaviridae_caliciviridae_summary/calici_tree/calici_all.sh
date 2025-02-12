#!/bin/bash
#SBATCH --job-name=cal
#SBATCH --partition=broadwl
#SBATCH --output=cal.out
#SBATCH --nodes=1
#SBATCH --ntasks=7
#SBATCH --ntasks-per-node=7
#SBATCH --time=36:00:00

module load vim/7.4
module load emacs/25.1
module load python/3.6
module load java/1.8.0_121
module load cmake/3.15.1

raxml-ng-mpi --all --msa calici_refseq_all_align.fasta --model TVM+I+G4 --prefix T1  --seed 1 --threads auto{7} --bs-metric fbp,tbe

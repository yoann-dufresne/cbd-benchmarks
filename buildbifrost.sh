#!/bin/bash
#SBATCH --array=1-2
#SBATCH --output=Bifrosttest1hu.%A_%a.out
#SBATCH -p seqbio
#SBATCH --mem "40G" 
#SBATCH --mail-user=oguinard
#SBATCH --mail-type=begin,end,fail
#SBATCH --qos fast
/usr/bin/time -v Bifrost build -r /pasteur/appa/scratch/oguinard/data/HG002.hap1.Google.fa -o bi1hu

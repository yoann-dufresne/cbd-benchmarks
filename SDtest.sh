#!/bin/bash
#SBATCH --output=metamem
#SBATCH -p seqbio
#SBATCH --mem "1024G" 
#SBATCH --mail-user=oguinard
#SBATCH --mail-type=begin,end,fail
#SBATCH --qos fast
/usr/bin/time -v ./bin/serializer /pasteur/appa/scratch/oguinard/sortedmeta/sorted_list-meta /pasteur/appa/scratch/oguinard/serialmeta/serialsorted_list-meta
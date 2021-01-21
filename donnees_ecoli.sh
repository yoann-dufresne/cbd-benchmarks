#!/bin/sh

#passage sous forme txt
./dsk -file ecoli_150bp_100x.fa -kmer-size 31
./dsk2ascii -file ecoli_150bp_100x.h5 -out ecoli_150bp_100x.txt

#utilisation de bcalm pour Jellyfish et blight
./bcalm -in ecoli_150bp_100x.fa -kmer-size 31 -abundance-min 2

#!!! ici on a besoin des 2 executables txtSorter et testGeneration dans ConwayBromageLib

#Modifier FileSorter.cpp dans ConwayBromageLib pour trier un autre txt puis recompiler
#tri du format .txt
#param 1 : le txt qu'on veut trier
#param 2 : le nom du txt une fois qu'il sera trié
./FileSorter ecoli_150bp_100x.txt ecoli_150bp_100x_SORTED.txt

#Modifier KmerListGenerator.cpp dans ConwayBromageLib pour générer d'autres fichiers de tests puis recompiler
#Generation des fichiers de tests
#param 1 : le fichier fasta
#param 2 : le fichier txt
#on obtient à la fin 3 fichiers genomic_query.fastq, full_random_query.fastq et random_present_query.fastq
.LmerListGenerator ecoli_150bp_100x.fa ecoli_150bp_100x.tx

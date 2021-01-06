#!/bin/sh

#passage sous forme txt
./dsk -file ecoli_150bp_100x.fa -kmer-size 31
./dsk2ascii -file ecoli_150bp_100x.h5 -out ecoli_150bp_100x.txt

#utilisation de bcalm pour Jellyfish et blight
./bcalm -in ecoli_150bp_100x.fa -kmer-size 31 -abundance-min 2

#!!! ici on a besoin des 2 executables txtSorter et testGeneration dans ConwayBromageLib

#Modifier FileSorter.cpp dans ConwayBromageLib pour trier un autre txt puis recompiler
#tri du format .txt
./ConwayBromageLib/txtSorter

#Modifier KmerListGenerator.cpp dans ConwayBromageLib pour générer d'autres fichiers de tests puis recompiler
#Generation des fichiers de tests
./ConwayBromageLib/testGeneration

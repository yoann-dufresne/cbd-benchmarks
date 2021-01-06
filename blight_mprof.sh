#!/bin/sh

rm -r wdir/ 

for i in `seq 1 50`;
do
    echo "========== tour $i ===========";
    echo "GENOMIC";
    mkdir wdir/
    mprof run bench/tools/blight/bench_blight -g ecoli_150bp_100x_unitigs.fa -q ecoli_genomic.fastq  -k 30 -t 10;
    rm -r wdir/
    python3 parser.py -d mprofile_* -w blight_genomic_space.txt
    rm mprof_*;
    
    echo "FULL RANDOM";
    mkdir wdir/
    mprof run bench/tools/blight/bench_blight -g ecoli_150bp_100x_unitigs.fa -q ecoli_full_random_.fastq  -k 30 -t 10;
    rm -r wdir/
    python3 parser.py -d mprofile_* -w blight_full_random_space.txt
    rm mprof*;

    echo "RANDOM PRESENT";
    mkdir wdir/
    mprof run bench/tools/blight/bench_blight -g ecoli_150bp_100x_unitigs.fa -q ecoli_random_present.fastq  -k 30 -t 10;
    rm -r wdir/
    python3 parser.py -d mprofile_* -w blight_random_present_space.txt
    rm mprof_*;
done

echo "=== MOYENNAGE ==="
#duree totale (construction + requete) et espace memoire occupe
python3 analysis.py -q blight_genomic_space.txt -w mean_blight_genomic_space.txt
python3 analysis.py -q blight_full_random_space.txt -w mean_blight_full_random_space.txt
python3 analysis.py -q blight_random_present_space.txt -w mean_blight_random_present_space.tx

rm blight_genomic_space.txt
rm blight_full_random_space.txt
rm blight_random_present_space.txt

echo "Travail termine"

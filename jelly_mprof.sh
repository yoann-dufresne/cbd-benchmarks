#!/bin/sh

rm mprofile*

for i in `seq 1 50`;
do
    echo "========== tour $i ===========";
    echo "GENOMIC";
    mprof run jellyfish count -m 30 -s 100M -t 10 -C ecoli_150bp_100x_unitigs.fa;
    python3 parser.py -d mprofile_* -w jelly_build.txt
    rm -r mprofile_*;

    mprof run jellyfish query mer_counts.jf -s ecoli_genomic.fastq;
    python3 parser.py -d mprofile_* -w jelly_genomic.txt
    rm -r mprofile_*;

    rm mer_counts.jf;
    
    echo "FULL RANDOM";
    mprof run jellyfish count -m 30 -s 100M -t 10 -C ecoli_150bp_100x_unitigs.fa;
    python3 parser.py -d mprofile_* -w jelly_build.txt
    rm -r mprofile_*;

    mprof run jellyfish query mer_counts.jf -s ecoli_full_random_.fastq;
    python3 parser.py -d mprofile_* -w jelly_full_random.txt
    rm -r mprofile_*;

    rm mer_counts.jf;
    
    echo "RANDOM PRESENT";
    mprof run jellyfish count -m 30 -s 100M -t 10 -C ecoli_150bp_100x_unitigs.fa;
    python3 parser.py -d mprofile_* -w jelly_build.txt
    rm -r mprofile_*;

    mprof run jellyfish query mer_counts.jf -s ecoli_random_present.fastq;
    python3 parser.py -d mprofile_* -w jelly_random_present.txt
    rm -r mprofile_*;

    rm mer_counts.jf;
    
done

echo "=== MOYENNAGE ==="
python3 analysis.py -q jelly_build.txt -w mean_jelly_build.txt
python3 analysis.py -q jelly_genomic.txt -w mean_jelly_genomic.txt
python3 analysis.py -q jelly_full_random.txt -w mean_jelly_full_random.txt
python3 analysis.py -q jelly_random_present.txt -w mean_jelly_random_present.txt

rm jelly_genomic.txt
rm jelly_full_random.txt
rm jelly_random_present.txt

echo "Travail termine"

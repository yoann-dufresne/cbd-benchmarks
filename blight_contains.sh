#!/bin/sh

rm -r wdir/ 

for i in `seq 1 50`;
do
    echo "========== tour $i ===========";
    echo "GENOMIC";
    mkdir wdir/
    bench/tools/blight/bench_blight -g ecoli_150bp_100x_unitigs.fa -q ecoli_genomic.fastq  -k 30 -t 10 > test.txt
    rm -r wdir/
    python3 parser_blight.py -q test.txt -t build.txt -w query_genomic.txt -s space_genomic.txt
    rm test.txt
    
    echo "FULL RANDOM";
    mkdir wdir/
    bench/tools/blight/bench_blight -g ecoli_150bp_100x_unitigs.fa -q ecoli_full_random_.fastq  -k 30 -t 10 > test.txt;
    rm -r wdir/
    python3 parser_blight.py -q test.txt -t build.txt -w query_full_random.txt -s space_full_random.txt
    rm test.txt

    echo "RANDOM PRESENT";
    mkdir wdir/
    bench/tools/blight/bench_blight -g ecoli_150bp_100x_unitigs.fa -q ecoli_random_present.fastq  -k 30 -t 10 > test.txt;
    rm -r wdir/
    python3 parser_blight.py -q test.txt -t build.txt -w query_random_present.txt -s space_random_present.txt
    rm test.txt

done

echo "=== MOYENNAGE ==="
python3 analyse_temporelle.py -q build.txt -w mean_blight_build.txt

python3 analyse_temporelle.py -q query_genomic.txt -w mean_query_genomic.txt
python3 analyse_temporelle.py -q query_full_random.txt -w mean_query_full_random.txt
python3 analyse_temporelle.py -q query_random_present.txt -w mean_query_random_present.txt

python3 analyse_temporelle.py -q space_genomic.txt -w mean_space_genomic.txt
python3 analyse_temporelle.py -q space_full_random.txt -w mean_space_full_random.txt
python3 analyse_temporelle.py -q space_random_present.txt -w mean_space_random_present.txt

echo "=== CLEANING ==="
rm build.txt

rm query_genomic.txt
rm query_full_random.txt
rm query_random_present.txt

rm space_genomic.txt
rm space_full_random.txt
rm space_random_present.txt 

echo "Travail termine"

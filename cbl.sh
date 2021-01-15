#!/bin/sh
echo "50 tours pour l'analyse de successors sur 1000000"
echo "fichier testé : /home/alexa/Bureau/Pasteur/ecoli_test/ecoli_150bp_100x.SORTED.txt"

#appeler QueryAnalysis pour l'analyse sur contains
#appeler SuccessorsAnalysis pour l'analyse sur successors

for i in `seq 1 50`;
do
    echo "========== tour $i ===========";
    echo "++ CONTAINS  ++";

#modification : ./contains fichier_où_on_cherche fichier_de_test fichier_stockage_temps_de_test fichier_stockage_temps_de_construction
    ./contains ecoli_150bp_100x.SORTED.txt ecoli_random_present.fastq cbl_random_present_contains.txt buildTime.txt
    
    ./contains ecoli_150bp_100x.SORTED.txt ecoli_full_random_.fastq cbl_full_random_contains.txt buildTime.txt
    
    ./contains ecoli_150bp_100x.SORTED.txt ecoli_genomic.fastq cbl_genomic_contains.txt buildTime.txt
    
    echo "++ SUCCESSORS  ++"
#pareil pour successors
    ./successors ecoli_150bp_100x.SORTED.txt ecoli_random_present.fastq cbl_random_present_successors.txt buildTime.txt
    
    ./successors ecoli_150bp_100x.SORTED.txt ecoli_full_random_.fastq cbl_full_random_successors.txt buildTime.txt
    
    ./successors ecoli_150bp_100x.SORTED.txt ecoli_genomic.fastq cbl_genomic_successors.txt buildTime.txt

    echo "++ CONTAINS MPROF  ++";
    
#modification : ./contains_for_space fichier_où_on_cherche fichier_de_test
    mprof run ./contains_for_space ecoli_150bp_100x.SORTED.txt ecoli_random_present.fastq
    python3 parser.py -d mprofile_* -w cbl_random_present_contains_mprof.txt
    ls
    rm -r mprofile_*;

    mprof run ./contains_for_space ecoli_150bp_100x.SORTED.txt ecoli_full_random_.fastq
    python3 parser.py -d mprofile_* -w cbl_full_random_contains_mprof.txt
    ls
    rm -r mprofile_*;
    
    mprof run ./contains_for_space ecoli_150bp_100x.SORTED.txt ecoli_genomic.fastq
    python3 parser.py -d mprofile_* -w cbl_genomic_contains_mprof.txt
    ls
    rm -r mprofile_*;
    
    echo "++ SUCCESSORS MPROF  ++"

#pareil pour successors_for_space
    mprof run ./successors_for_space ecoli_150bp_100x.SORTED.txt ecoli_random_present.fastq
    python3 parser.py -d mprofile_* -w cbl_random_present_successors_mprof.txt
    ls
    rm -r mprofile_*;
    
    mprof run ./successors_for_space ecoli_150bp_100x.SORTED.txt ecoli_full_random_.fastq
    python3 parser.py -d mprofile_* -w cbl_full_random_successors_mprof.txt
    ls
    rm -r mprofile_*;
    
    mprof run ./successors_for_space ecoli_150bp_100x.SORTED.txt ecoli_genomic.fastq
    python3 parser.py -d mprofile_* -w cbl_genomic_successorscontains_mprof.txt
    ls
    rm -r mprofile_*;
done
echo "=== MOYENNAGE ==="

echo "+++ MPROF +++" #pour l'espace occupé

python3 analysis.py -q cbl_random_present_contains_mprof.txt -w mean_cbl_random_present_contains_mprof.txt
python3 analysis.py -q cbl_full_random_contains_mprof.txt -w mean_cbl_full_random_contains_mprof.txt
python3 analysis.py -q cbl_genomic_contains_mprof.txt -w mean_cbl_genomic_contains_mprof.txt

python3 analysis.py -q cbl_random_present_successors_mprof.txt -w mean_cbl_random_present_successors_mprof.txt
python3 analysis.py -q cbl_full_random_successors_mprof.txt -w mean_cbl_full_random_successors_mprof.txt
python3 analysis.py -q cbl_genomic_successorscontains_mprof.txt -w mean_cbl_genomic_successorscontains_mprof.txt

echo "+++ SANS MPROF +++" #pour le calcul du temps

python3 analyse_temporelle.py -q buildTime.txt -w mean_buildTime.txt

python3 analyse_temporelle.py -q cbl_random_present_contains.txt -w mean_cbl_random_present_contains.txt
python3 analyse_temporelle.py -q cbl_full_random_contains.txt -w mean_cbl_full_random_contains.txt
python3 analyse_temporelle.py -q cbl_genomic_contains.txt -w mean_cbl_genomic_contains.txt

python3 analyse_temporelle.py -q cbl_random_present_successors.txt -w mean_cbl_random_present_successors.txt
python3 analyse_temporelle.py -q cbl_full_random_successors.txt -w mean_cbl_full_random_successors.txt
python3 analyse_temporelle.py -q cbl_genomic_successors.txt -w mean_cbl_genomic_successors.txt

echo "+++ CLEANING +++"
rm cbl_random_present_contains_mprof.txt
rm cbl_full_random_contains_mprof.txt
rm cbl_genomic_contains_mprof.txt
rm cbl_random_present_successors_mprof.txt
rm cbl_full_random_successors_mprof.txt
rm cbl_genomic_successorscontains_mprof.txt

rm buildTime.txt
rm cbl_random_present_contains.txt 
rm cbl_full_random_contains.txt
rm cbl_genomic_contains.txt
rm cbl_random_present_successors.txt
rm cbl_full_random_successors.txt
rm cbl_genomic_successors.txt

echo "Travail termine"

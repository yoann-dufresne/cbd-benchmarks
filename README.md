
## Dependancies
- nextflow
- Python
- cmake
- gcc
## using it
```
git clone --recurse-submodules https://github.com/yoann-dufresne/cbd-benchmarks
```
if you clone it without recurse use that :
```
git submodule update --init --recursive 
```

you need to have installed the different software for using the different pipeline used for testing or puting the executable in a bin repertory on the same level as the pipeline 
## Software tested against it 
- Bifrost(https://github.com/pmelsted/bifrost)
- sshash(https://github.com/jermp/sshash)
- Themisto(https://github.com/algbio/themisto)
- Metagraph(https://github.com/ratschlab/metagraph)


## drawing time graph
```bash
  python3 graph.py dirname
```

## instruction
all path passed in argument must be absolute, nextflow don't take relative path with arguments 

## what each pipeline do
requestthemisto.nf give the time needed to querry if some kmer exit for a themisto index
sortKmer take a file of sequence and convert it into a sorted list of kmer
sshashquerry give the time needed to querry if some kmer exit for a sshash index
sshashtest.nf build a index with sshash by using cuttlefish to preprocess the sequence
themistotest.nf build a index with sshash by using cuttlefish to preprocess the sequence
timetest.nf do request test on CBD on different percentage of kmer existing
metagraphtest.nf build a metagraph and annotate it from sequence 
bifrosttest.sh build a bifrost graph 
bifrosttimetest.nf give the time needed to querry a number of kmer on a bifrost graph
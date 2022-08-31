
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
sortKmer take a file of sequence and convert it into a sorted list of kmer for building of cbd


build: to build the index/graph
buildsshash.nf for sshash index
buildthemisto.nf for themisto index
buildmetagraph.nf for metagraph graph
buildbifrost.sh for bifrost graph 

querry: to test the time need to querry on each type of graph
querrythemisto.nf fo themisto
querrysshash.nf for Sshash
querrybifrost.nf for Bifrost
querrymetagraph
querrycbd.nf  for CBD(build it too)



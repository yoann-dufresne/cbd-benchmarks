
# Benchmark CBD de Bruijn graph
This repository contains Nextflow pipelines to benchmark the [CBD de bruijn graph representation](https://github.com/yoann-dufresne/cbd). 

## dependencies
- [Nextflow](https://www.nextflow.io/), with support for [DSL2](https://www.nextflow.io/docs/latest/dsl2.html) 
- [Python](https://www.python.org/) >= 3.6

The included external binaries *(`kmc`, `bcalm2`, `themisto`, `metagraph`, `sshash` and `bifrost`)* are compiled for linux_x86_64 distributions.  
Our custom tools can be compiled from source from [yoann-dufresne/cbd](https://github.com/yoann-dufresne/cbd) *( for `buildIndex`, `loadIndex` and `queryIndex`)* and [lucblassel/kmer-generator](https://github.com/lucblassel/kmer-generator). 

---

## Prepare sequence data
The tools takes as input a list of sorted $k$-mers. A pipeline is given to create all necessary input files. To execute it call:

```
nextflow run prepare-data.nf --reference <path_to_reference_fasta>
```

This will output the following files, *(`<organism>` is the short name of the supplied reference fasta by default, but can be specified by passing a value to the pipeline with the `--organism` flag.)*:
```
data/
├── <organism>/
│   ├── kmers.30.<organism>.txt
│   ├── kmers.31.<organism>.txt
│   └── sorted.kmers.31.<organism>.txt
└── <organism>.fa
```

The benchmarking pipeline expects to find the reference fasta file in the `data/` directory. 

---

## Generate query data

A pipeline and a CLI tool are included to generate static benchmarking datasets. You can run the pipelines with the following command:

```
nextflow run generate-benchmarks.nf --organism <organism> 
```

It expects the previous directory structure and will use the `data/<organism>/kmers.30.<organism>.txt` file as the source of "real" k-mers.  
This pipeline generates benchmarking datasets that are made up of real and synthetic k-mers, with a specific percentage of "real" k-mers. This will create files named `data/<organism>/bench/<organism>-<real_kmer_fraction>-<repeat_number>.kmers`. 
You can specify the percentage of "real" k-mers you want in each dataset by passing values between 0 and 1, separated by spaces; *e.g.*: `--percent "0.1 0.2 0.3"`, will generate 3 datasets with 10%, 20% and 30% of real k-mers respectively. 


---

## Benchmarking tools
The benchmarking pipeline is implemented as a DSL2 nextflow pipeline. 
Processes are defined in the `modules/` directory, with one module per tool.  

Launch the pipeline by specifying the `<organism>` and `tool` parameter values *(This pipeline assumes that you have files organized like above)*:

```
nextflow run bench-tool.nf --tool <tool> --organism <organism>
```

Each process outputs a report generated with `/usr/bin/time -v`, these are collected, parsed and unified to produce a single `<resultDIr>/<organism>/<tool>.json` file with releveant info. 

### Implemented tools:

 - [x] CBD:
    - [x] Build index
    - [x] Load index
    - [x] Query index (contains)
    - [x] Query index (neighbours)
 - [ ] Themisto:
    - [x] Build index
    - [ ] Load index
    - [ ] query index
 - [ ] Bifrost:
    - [ ] Build index
    - [ ] Load index
    - [ ] query index
 - [ ] Metagraph:
    - [ ] Build index
    - [ ] Load index
    - [ ] query index
 - [ ] SSHash:
    - [ ] Build index
    - [ ] Load index
    - [ ] query index
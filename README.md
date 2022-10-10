
# Benchmark CBD de Bruijn graph
This repository contains Nextflow pipelines to benchmark the [CBD de bruijn graph representation](https://github.com/yoann-dufresne/cbd). 

## dependencies
- [Nextflow](https://www.nextflow.io/), with support for [DSL2](https://www.nextflow.io/docs/latest/dsl2.html) 
- [Python](https://www.python.org/) >= 3.6

## Prepare sequence data
The tools takes as input a list of sorted $k$-mers. A pipeline is given to create all necessary input files. To execute it call:

```
nextflow run prepare-data.nf --reference <path_to_reference_fasta>
```

This will output the following files, *(`<organism>` is the short name of the supplied reference fasta by default, but can be specified by passing a value to the pipeline with the `--organism` flag.)*:
```
data/
└── <organism>/
    ├── kmers.30.<organism>.txt
    ├── kmers.31.<organism>.txt
    └── sorted.kmers.31.<organism>.txt
```

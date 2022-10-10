
# Benchmark CBD de Bruijn graph
This repository contains Nextflow pipelines to benchmark the [CBD de bruijn graph representation](https://github.com/yoann-dufresne/cbd). 

## dependencies
- [Nextflow](https://www.nextflow.io/), with support for [DSL2](https://www.nextflow.io/docs/latest/dsl2.html) 
- [Python](https://www.python.org/) >= 3.6

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
**TODO**

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
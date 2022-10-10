
nextflow.enable.dsl=2

resDir = "./results"

// ENUM{ cbd, themisto }
tool = "cbd"

include { build_themisto; query_themisto; load_themisto } from "./modules/themisto"
include { build_cbd; query_contains_cbd; query_neighbours_cbd; load_cbd } from "./modules/cbd"

workflow {
    fasta = channel.fromPath("./data/sarscov2.fa")
    sorted_kmers_31 = channel.fromPath("./data/sarscov2/sorted.kmers.31.sarscov2.txt")
    kmers_30 = channel.fromPath("./data/sarscov2/kmers.30.sarscov2.txt")
    repeats = channel.from(1..5)
    org = "sarscov2"

    if (tool == "themisto") {
        build_themisto(fasta, org, resDir)
        query_themisto(build_themisto.out.index, kmers_30, org, repeats, resDir)
        load_themisto(build_themisto.out.index, org, repeats, resDir)
    } else {
        build_cbd(sorted_kmers_31, org, resDir)
        query_contains_cbd(build_cbd.out.index, kmers_30, org, repeats, resDir)
        query_neighbours_cbd(build_cbd.out.index, kmers_30, org, repeats, resDir)
        load_cbd(build_cbd.out.index, org, repeats, resDir)
    }

}



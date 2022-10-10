include {count_kmers; export_kmers; sort_kmers} from "./modules/kmer_utils.nf"

nextflow.enable.dsl=2
dataDir = "./data"

workflow sorted {
    take: 
        fasta
        org
        val
        output_dir
    main:
        count_kmers(fasta, val, org)
        export_kmers(count_kmers.out[0], count_kmers.out[1], count_kmers.out[2], count_kmers.out[3], output_dir)
        sort_kmers(export_kmers.out[0], export_kmers.out[1], export_kmers.out[2], output_dir)
    emit:
        sorted = sort_kmers.out[0]
}

workflow unsorted {
    take: 
        fasta
        org
        val
        output_dir
    main:
        count_kmers(fasta, val, org)
        export_kmers(count_kmers.out[0], count_kmers.out[1], count_kmers.out[2], count_kmers.out[3], output_dir)
    emit:
        sorted = export_kmers.out[0]
}

workflow {
    // Input files
    reference = Channel.fromPath("./data/sarscov2.fa")
    org = "sarscov2"

    sorted(reference, org, 31, dataDir)
    unsorted(reference, org, 30, dataDir)

}
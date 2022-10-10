include {count_kmers; export_kmers; sort_kmers} from "./modules/kmer_utils.nf"


nextflow.enable.dsl=2
dataDir = "./data"

params.reference = "$dataDir/sarscov2.fa"
params.organism = file(params.reference).getSimpleName()

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
    reference = Channel.fromPath(params.reference)

    sorted(reference, params.organism, 31, dataDir)
    unsorted(reference, params.organism, 30, dataDir)

}
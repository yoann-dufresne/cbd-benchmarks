nextflow.enable.dsl=2

include {single; single as single_s} from "./modules/kmer_utils.nf"
include {multiple; multiple as multiple_s} from "./modules/kmer_utils.nf"
include {guess_format} from "./modules/kmer_utils.nf"

params.dataDir = "./data"
params.reference = "${params.dataDir}/sarscov2.fa"

// Check if single or multiple reference file(s)
if (file(params.reference) in List) {
    params.num = file(params.reference).size
} else {
    params.num = 1
}

// Enforce <organism> specification if multiple reference files
if (params.num > 1) {
    if (!params.organism) {
        exit 1, "[Pipeline error] `--organism` must be specified when using multiple input files"
    }
} else {
    params.organism = file(params.reference).getSimpleName()
}

workflow {

    reference = Channel.fromPath(params.reference)
    format = reference.map{ guess_format(it) }
    meta_c = Channel.from([[31, true], [30, false]])

   if (params.num == 1) {
        single(reference, format, params.organism, 30, params.dataDir, false)
        single_s(reference, format, params.organism, 31, params.dataDir, true)
    } else {
        multiple(reference, format, params.organism, 30, params.dataDir, false)
        multiple_s(reference, format, params.organism, 31, params.dataDir, true)
    }

}
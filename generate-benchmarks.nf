nextflow.enable.dsl=2

params.organism = "sarscov2"
params.resDir = "./data"
params.percents = "0 0.25 0.5 0.75 1"
params.repeats = 3
params.maxsize = 2000000

// Check that user specified values are correct and parse percentages values
def validate_percentages( percent_values) {
    ps = percent_values.split()
    nums = []

    for (p in ps) {
        try {
            p_f = Float.parseFloat(p)
            nums.add(p_f)
        } catch (Exception e) {
            return [false, nums]
        }
    }

    [true, nums]
}

(valid, percent_values) = validate_percentages(params.percents)
if (!valid) {
    exit 1, "[Pipeline error] $params.percents does not contain percentage values. Please specify values between 0 and 1 only."
}

// 1 k-mer per line, with 1 byte per nucleotide and 1 for '\n' means that
// we can get the number of k-mers with:
// size_in_bytes(file) / (k+1).
def count_kmers(file) {
    try {
        //filename: "kmers.<k>.<org>.txt"
        k = file.getBaseName().tokenize(".")[1].toInteger()
        size = file.size()
        return [true, size / (k + 1)]
    } catch (Exception e) {
        println e
        return [false, 0]
    }
}

process generate_dataset {
    input:
    path kmers
    val org
    each percent
    val dir
    val size
    each repeat

    publishDir "${dir}/${org}/bench/", mode: "link"
    output:
    path "${org}-${percent}-${repeat}.kmers"

    script:
    """
    kmer-generator mix \
        --file ${kmers} \
        --kmer-size 30 \
        --query-number ${size} \
        --percent ${percent} \
        --out ${org}-${percent}-${repeat}.kmers
    """
}

workflow {

    kmers = file("./data/${params.organism}/kmers.30.${params.organism}.txt")
    percents = channel.from(percent_values)
    repeats = channel.from(1..params.repeats)

    (success, num) = count_kmers(kmers)
    if (!success) {
        exit 1, "[Pipeline error] cannot read kmers file ($kmers)"
    }

    if (num > params.maxsize) {
        generate_dataset(kmers, params.organism, percents, params.resDir, params.maxsize, repeats)
    } else {
        generate_dataset(kmers, params.organism, percents, params.resDir, num, repeats)
    }

}
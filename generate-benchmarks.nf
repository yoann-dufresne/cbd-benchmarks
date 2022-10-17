nextflow.enable.dsl=2

params.organism = "sarscov2"
params.dataDir = "./data"
params.percents = "0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1"
params.maxsize = 4000000

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

    publishDir "${dir}/${org}/bench/", mode: "move"
    output:
    path "${org}-${percent}.kmers"

    script:
    if (percent == 0)
        """
        kmer-generator generate \
            --kmer-size 30 \
            --query-number ${size} \
            --out ${org}-${percent}.kmers
        """
    else if (percent != 1)
        """
        kmer-generator mix \
            --file ${kmers} \
            --kmer-size 30 \
            --query-number ${size} \
            --percent ${percent} \
            --out ${org}-${percent}.kmers
        """
    else
        """
        shuf -n ${size} ${kmers} > ${org}-${percent}.kmers
        """
}

process generate_report {
    input:
    val dir
    val org
    val size

    publishDir "${dir}/${org}/", mode: "copy"
    output:
    path "${org}.benchmark_size.json"

    script:
    """
    echo '{"organism": "${org}", "size": ${size}}' > ${org}.benchmark_size.json
    """

}

workflow {

    kmers = file("${params.dataDir}/${params.organism}/kmers.30.${params.organism}.txt")
    percents = channel.from(percent_values)

    (success, num) = count_kmers(kmers)
    if (!success) {
        exit 1, "[Pipeline error] cannot read kmers file ($kmers)"
    }

    if (num > params.maxsize) {
        generate_dataset(kmers, params.organism, percents, params.dataDir, params.maxsize)
        generate_report(params.dataDir, params.organism, params.maxsize)
    } else {
        generate_dataset(kmers, params.organism, percents, params.dataDir, num)
        generate_report(params.dataDir, params.organism, num)
    }

    
}
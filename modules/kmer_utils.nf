process count_kmers {
    input:
    path fasta
    val k
    val org

    output:
    path "kmers.kmc_pre"
    path "kmers.kmc_suf"
    val k
    val org

    memory { (fasta.size() * 2) * 1.B }

    script:
    """
    kmc -k${k} \
        -ci1 \
        -fm \
        ${fasta} \
        kmers \
        .
    """
}

process export_kmers {
    input:
    path kmc_pre
    path kmc_shuf
    val k
    val org
    val outputDir

    publishDir "${outputDir}/${org}", mode: "link"
    output:
    path "kmers.${k}.${org}.txt"
    val k
    val org

    memory { (kmc_pre.size() * 4) * 1.B }

    script:
    """
    kmc_tools transform ${kmc_pre.baseName} dump kmers

    # Removing counts
    cat kmers | cut -f1 > kmers.${k}.${org}.txt
    """
}

process sort_kmers {
    input:
    path kmers
    val k
    val org
    val outputDir

    publishDir "${outputDir}/${org}", mode: "link"
    output:
    path "sorted.kmers.${k}.${org}.txt"

    memory { (kmers.size() * 5) * 1.B }
    cpus 16

    script:
    """
    LC_ALL=C sort --parallel=16 ${kmers} > sorted.kmers.${k}.${org}.txt
    """
}
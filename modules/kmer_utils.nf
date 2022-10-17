process count_kmers {
    input:
    path seqs
    val k
    val org
    val format

    output:
    path "kmers.kmc_pre"
    path "kmers.kmc_suf"
    val k
    val org

    memory { 
        (seqs.size() * 12) * 1.B < 4.GB ? 
            4.GB : (seqs.size() * 12) * 1.B 
    }

    script:
    mem = task.memory.toGiga() - 2
    """
    kmc -k${k} \
        -ci1 \
        -m${mem} \
        -sm \
        -f${format} \
        ${seqs} \
        kmers \
        .
    """
}

process merge_kmc_dbs {
    input:
    path "*.kmc_pre"
    path "*.kmc_suf"
    val k
    val org

    output:
    path "joined.kmc_pre"
    path "joined.kmc_suf"
    val k
    val org

    memory 20.GB

    script:
    """
    prepare-kmc-def.py --db joined *.kmc_pre > def
    kmc_tools complex def
    """
}


process export_kmers {
    input:
    path kmc_pre
    path kmc_shuf
    val k
    val org
    val outputDir

    publishDir "${outputDir}/${org}", mode: "copy"
    output:
    path "kmers.${k}.${org}.txt"
    val k
    val org

    memory { 
        (kmc_pre.size() + kmc_shuf.size()) * 10 * 1.B < 3.GB ? 
            3.GB : (kmc_pre.size() + kmc_shuf.size()) * 10 * 1.B
        }

    script:
    """
    kmc_tools transform ${kmc_pre.baseName} dump kmers

    # Removing counts
    cut -f1 kmers > kmers.${k}.${org}.txt

    rm kmers
    """
}

process export_sorted_kmers {
    input:
    path kmc_pre
    path kmc_shuf
    val k
    val org
    val outputDir

    publishDir "${outputDir}/${org}", mode: "copy"
    output:
    path "sorted.kmers.${k}.${org}.txt"
    val k
    val org

    memory { 
        (kmc_pre.size() + kmc_shuf.size()) * 10 * 1.B < 3.GB ? 
            3.GB : (kmc_pre.size() + kmc_shuf.size()) * 10 * 1.B
        }
    cpus 16

    script:
    """
    kmc_tools transform ${kmc_pre.baseName} dump kmers

    cut -f1 kmers > kmers_cut
    # Removing counts
    LC_ALL=C sort --parallel=${task.cpus} kmers_cut > sorted.kmers.${k}.${org}.txt

    rm kmers kmers_cut
    """
}

workflow single {
    take:
        reference
        format
        org
        k
        output_dir
        sort
    main:
        count_kmers(reference, k, org, format)
        if (sort) {
            export_sorted_kmers(
                count_kmers.out[0], // kmc_pre
                count_kmers.out[1], // kmc_suf
                k, org, output_dir
            )
        } else {
            export_kmers(
                count_kmers.out[0], // kmc_pre
                count_kmers.out[1], // kmc_suf
                k, org, output_dir
            )
        }
}

workflow multiple {
    take:
        reference
        format
        org
        k
        output_dir
        sort
    main:
        count_kmers(reference, k, org, format)

        merge_kmc_dbs(
            count_kmers.out[0].collect(), // kmc_pre +
            count_kmers.out[1].collect(), // kmc_shuf +
            k, org
        )
        if (sort) {
            export_sorted_kmers(
                merge_kmc_dbs.out[0], // merged kmc_pre
                merge_kmc_dbs.out[1], // merged kmc_shuf
                k, org, output_dir
            )
        } else {
            export_kmers(
                merge_kmc_dbs.out[0], // merged kmc_pre
                merge_kmc_dbs.out[1], // merged kmc_shuf
                k, org, output_dir
            )
        }
}

// Get file format for KMC from file extension
def guess_format(file) {
    ext = file.getExtension()

    if (ext == "gz") {
        shorter = file.parent + file.baseName
        ext = shorter.getExtension()
    }

    format = ""
    if (ext == "fa" || ext == "fasta" || ext == "fna") {
        format = "m"
    } else if (ext == "fq" || ext == "fastq") {
        format = "q"
    } else {
        exit 1, "[Pipeline error] $ext is not a recognized sequence format file extension"
    }

    format
}
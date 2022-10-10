

process build_themisto {
    input:
    path fasta
    val org
    val dir

    publishDir "${dir}/${org}/themisto", pattern: "*.txt"
    output:
    path "themisto.dbg", emit: index
    path "build_themisto.txt"

    script:
    """
    /usr/bin/time -v -o build_themisto.txt touch themisto.dbg

    echo "\tDisk size: \$INDEXSIZE" >> build_themisto.txt
    echo "\tTask: themisto build" >> build_themisto.txt
    echo "\tOrganism: ${org}" >> build_themisto.txt
    """
}


process query_themisto {
    input:
    path index
    path kmers
    val org
    each repeat
    val dir

    publishDir "${dir}/${org}/themisto"
    output:
    path "query_themisto_${repeat}.txt"

    script:
    """
    /usr/bin/time -v -o query_themisto_${repeat}.txt sleep 2

    echo "\tTask: themisto query" >> query_themisto_${repeat}.txt
    echo "\tOrganism: ${org}" >> query_themisto_${repeat}.txt
    """
}


process load_themisto {
    input:
    path index
    val org
    each repeat
    val dir

    publishDir "${dir}/${org}/themisto"
    output:
    path "load_themisto_${repeat}.txt"

    script:
    """
    /usr/bin/time -v -o load_themisto_${repeat}.txt sleep 1

    echo "\tTask: themisto load" >> load_themisto_${repeat}.txt
    echo "\tOrganism: ${org}" >> load_themisto_${repeat}.txt
    """
}

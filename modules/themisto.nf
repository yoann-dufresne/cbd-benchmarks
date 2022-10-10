

process build_themisto {
    input:
    path fasta
    val org
    val dir

    publishDir "${dir}/${org}", pattern: "*.txt"
    output:
    path "themisto.dbg", emit: index
    path "build_themisto.txt"

    script:
    """
    /usr/bin/time -v -o build_themisto.txt touch themisto.dbg
    """
}


process query_themisto {
    input:
    path index
    path kmers
    val org
    each repeat
    val dir

    publishDir "${dir}/${org}"
    output:
    path "query_themisto_${repeat}.txt"

    script:
    """
    /usr/bin/time -v -o query_themisto_${repeat}.txt sleep 2
    """
}


process load_themisto {
    input:
    path index
    val org
    each repeat
    val dir

    publishDir "${dir}/${org}"
    output:
    path "load_themisto_${repeat}.txt"

    script:
    """
    /usr/bin/time -v -o load_themisto_${repeat}.txt sleep 1
    """
}

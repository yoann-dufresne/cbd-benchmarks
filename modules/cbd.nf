

process build_cbd {
    input:
    path sorted_kmers
    val org
    val dir

    publishDir "${dir}/${org}", pattern: "*.txt"
    output:
    path "cbd.dbg", emit: index
    path "build_cbd.txt"

    script:
    """
    /usr/bin/time -v -o build_cbd.txt buildIndex \
        ${sorted_kmers} \
        cbd.dbg
    """
}


process query_contains_cbd {
    input:
    path index
    path kmers
    val org
    each repeat
    val dir

    publishDir "${dir}/${org}"
    output:
    path "query_contains_cbd_${repeat}.txt"

    script:
    """
    /usr/bin/time -v -o query_contains_cbd_${repeat}.txt queryIndex \
        ${index} \
        ${kmers}
    """
}

process query_neighbours_cbd {
    input:
    path index
    path kmers
    val org
    each repeat
    val dir

    publishDir "${dir}/${org}"
    output:
    path "query_neighbours_cbd_${repeat}.txt"

    script:
    """
    /usr/bin/time -v -o query_neighbours_cbd_${repeat}.txt queryIndex \
        -s \
        ${index} \
        ${kmers}
    """
}

process load_cbd {
    input:
    path index
    val org
    each repeat
    val dir

    publishDir "${dir}/${org}"
    output:
    path "load_cbd_${repeat}.txt"

    script:
    """
    /usr/bin/time -v -o load_cbd_${repeat}.txt loadIndex ${index}
    """
}

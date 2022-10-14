

process build_cbd {
    label "same_node"

    input:
    path sorted_kmers
    val org
    val dir

    output:
    path "cbd.dbg", emit: index
    path "build_cbd.txt", emit: report

    script:
    """
    /usr/bin/time -v -o build_cbd.txt buildIndex \
        ${sorted_kmers} \
        cbd.dbg
    INDEXSIZE=\$(stat -c%s "cbd.dbg")

    echo "\tDisk size: \$INDEXSIZE" >> build_cbd.txt
    echo "\tTask: CBD build" >> build_cbd.txt
    echo "\tOrganism: ${org}" >> build_cbd.txt
    """
}


process query_contains_cbd {
    label "same_node"

    input:
    path index
    path kmers
    val org
    each repeat
    val dir

    output:
    path "query_contains_cbd_${repeat}.txt", emit: report

    script:
    """
    /usr/bin/time -v -o query_contains_cbd_${repeat}.txt queryIndex \
        ${index} \
        ${kmers}

    echo "\tTask: CBD contains" >> query_contains_cbd_${repeat}.txt
    echo "\tOrganism: ${org}" >> query_contains_cbd_${repeat}.txt
    echo "\tBenchmark: ${kmers.baseName}" >> query_contains_cbd_${repeat}.txt
    """
}

process query_neighbours_cbd {
    label "same_node"

    input:
    path index
    path kmers
    val org
    each repeat
    val dir

    output:
    path "query_neighbours_cbd_${repeat}.txt", emit: report

    script:
    """
    /usr/bin/time -v -o query_neighbours_cbd_${repeat}.txt queryIndex \
        -s \
        ${index} \
        ${kmers}

    echo "\tTask: CBD neighbours" >> query_neighbours_cbd_${repeat}.txt
    echo "\tOrganism: ${org}" >> query_neighbours_cbd_${repeat}.txt
    echo "\tBenchmark: ${kmers.baseName}" >> query_neighbours_cbd_${repeat}.txt
    """
}

process load_cbd {
    label "same_node"

    input:
    path index
    val org
    each repeat
    val dir

    output:
    path "load_cbd_${repeat}.txt", emit: report

    script:
    """
    /usr/bin/time -v -o load_cbd_${repeat}.txt loadIndex ${index}

    echo "\tTask: CBD load" >> load_cbd_${repeat}.txt
    echo "\tOrganism: ${org}" >> load_cbd_${repeat}.txt
    """
}

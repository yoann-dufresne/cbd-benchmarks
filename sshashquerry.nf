process query{
    publishDir "./timesshash", mode: 'link'    
    input:
    tuple file(index),file(graph),val(number) from data
    output:
    file("result")
    script:
    """
    for i in {1. .${number}}
    do
        echo ">" >>kmers.fa
        shuf ${kmer} -n 1 >> kmers.fa
    done
    time query ${index} kmers.fa > result
    """

}
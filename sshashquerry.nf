data=Channel.fromPath("./threshold1HG002.hap1.Google.fa.unitigs.fa.ust.fa.index")// put the input index here 
//graph=Channel.fromPath("./")//put the graph here
number=["100"]//put the number of kmer to test here
kmer=Channel.fromPath("./kmertest")//put here the list of all kmer that are gonna be randomly tried 
process query{
    publishDir "./timesshash", mode: 'link'    
    input:
    tuple file(index),file(graph),val(number),file(kmer) from data
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
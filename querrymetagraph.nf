graph=Channel.fromPath('.')//here goes the graph
annotation=Channel.fromPath(".")//here goes the annotation
kmer=Channel.fromPath(".")//here goes a list of kmer to randomly test
number=["100"]
graph
    .combine(annotation)
    .combine(kmer)
    .combine(number)
    .set{data}

process query{
    publishDir "./metagraphtest", mode: 'link'
    input:
    tuple file(graph),file(annotation),file(kmer),val(number) from data
    output:
    file "result"
    memory 1.GB
    cpus 1
    script:
    """
    for (( c=0; c<${number}; c++ ))
    do
        echo ">" >>kmers.fa
        shuf ${kmer} -n 1 >> kmers.fa
    done
    ./metagraph query -v -i ${graph} -a ${annotation} --discovery-fraction 0.8 --labels-delimiter ", " query.fa >result
    """
}
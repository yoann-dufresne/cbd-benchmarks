inputdata=Channel.fromPath("./themisto/metacuttle.fa.index.tdbg")
kmer=Channel.fromPath("./sortedmeta/sorted_list-meta")
number=["1000"]
inputdata
    .combine(kmer)
    .combine(number)
    .set{inputdata}
process querry{
    publishDir "./themistotimetest", mode: 'link'
    input:
    tuple file(index),file(kmer),val(number) from inputdata
    output:

    script:
    """
    for i in {1. .${number}}
    do
        echo ">" >>kmers.fa
        shuf ${kmer} -n 1 >> kmers.fa
    done
    themisto pseudoalign --query-file kmers.fa --index-prefix ${index}  --out-file themistotimetest${number}.txt
    """
}
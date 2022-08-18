#!/usr/bin/env nextflow
/*data=Channel.fromPath("")
threshold=["1","2"]
data
    .combine(threshold)
    .set{data}
process bcalm{
    input:
    tuple file(in), val(a) from data
    output:
    tuple file("threshold${a}${in}"),val(a) into boutput
    script:
    """ 
    bcalm -in ${in} -kmer-size 31 -abundance-min ${a} -out threshold${a}${in}
    """
}
process UST{
    input:
    tuple file(boutput),val(a) from boutput
    output:
    tuple file(${boutput}.ust.fa),val(a) into uoutput
    script:
    """
    ust -k 31 -i ${boutput}
    """
}*/
uoutput=Channel.fromPath("./threshold2list-meta.unitigs.fa.ust.fa")
process sshhash{
    input:
    file(in) from uoutput
    output:

    memory 500.GB
    cpus 10
    script:
    """
    ./build ${in} 31 13 --check --bench -o ${in}.index
    """
}
data=Channel.fromPath('./graph/*')
fasta=Channel.fromPath("./data/*")
shufsequence=Channel.fromPath('./sequencegen.py')
data
    .combine(fasta)
    .combine(shufsequence)
    .combine(iteration)
    .set{data}

process timesequence{
    publishDir "./bifrosttime", mode: 'link'
    input:
    tuple file(graph),file(fasta),file(shufsequence),val(iteration) from data
    output:
    file "result${iteration}"

    memory 1.GB
    cpus 1
    script:
    """
    python3 ${shufsequence} ${fasta} >shuf.fa
    time Bifrost -t 1  -e 0.8 -query -g ${graph} -q shuf -o timebifrost${iteration} > result${iteration}
    """
}
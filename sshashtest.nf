data=Channel.fromPath("./list-meta")// the data you want to process
process cuttlefish{
    publishDir "./cuttlemeta", mode: 'link'
    input:
    file(list) from data
    output:
    file("${list}.fa") into coutput
    memory 1024.GB
    cpus 32
    script:
    """
    cuttlefish build -l ${list} -o ${list}  -k 31 --read -c 1 -m 1024 -t 32
    """
    //change the -l to -s if using only one file in entry and not a list of file 
}
process sshhash{
    input:
    file(in) from coutput
    output:

    memory 500.GB
    cpus 10
    script:
    """
    ./build ${in} 31 13 --check --bench -o ${in}.index
    """
}
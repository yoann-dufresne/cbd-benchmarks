data=Channel.fromPath("./list-meta")
//used to build a graph with cuttlefish, was 
process cuttlefish{
    publishDir "./cuttlemeta", mode: 'link'
    input:
    file(list) from data
    output:

    memory 1024.GB
    cpus 32
    script:
    """
    cuttlefish build -l ${list} -o metacuttle  -k 31 --read -c 1 -m 1024 -t 32
    """
}
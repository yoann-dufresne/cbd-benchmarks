data=Channel.fromPath("./metacuttle.fa")
//build a themisto index from the input
process themisto{
    publishDir "themisto", mode: 'link'
    input:
    file(entry) from data
    output:
    file ("${entry}.index.tdbg")
    memory 100.GB
    cpus 32
    script:
    """
    themisto build  -k 31 -m 100000 --input-file ${entry} --index-prefix ${entry}.index --temp-dir tmp --no-colors --n-threads 32


    """
}
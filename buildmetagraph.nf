data=Channel.fromPath('./data/HG002.hap1.Google.fa')
count=["1"]
data
    .combine(count)
    .into{data}

/*
process the fasta file for metagraph
*/
process countKmer {         
    input :
    tuple path(dataentry),val(count) from data
    
    output :
    tuple file("${dataentry.baseName}.kmc_pre"), file("${dataentry.baseName}.kmc_suf"),val(count) into bin
    
    memory 50.GB
    cpus 32

    script:
    """
    kmc -fm -ci${count} -t32 -k31 ${dataentry} ${dataentry.baseName} .
    """
}
/*
build the dbg for metagraph
*/
process metagraph{
    publishDir "metagraphtest", mode: 'link'
    input:
    tuple file(pre), file(suf),val(count) from bin
    output:
    file("meta${entry}.dbg")
    memory 100.GB
    cpus 32
    script:
        """
        metagraph build --min-count ${count} -k 31 -p 32 -o graph${pre.baseName} ${pre}
        """
}

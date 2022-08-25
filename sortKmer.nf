#!/usr/bin/env nextflow

params.data=Channel.fromPath('/home/oceane/dev/data/*.fasta')

/*
this process take the fasta file and process trough KMC(-fm for fasta file and -fq for Fastq)
*/
process countKmer {         
    input :
    path dataentry from data
    
    output :
    tuple file("${dataentry.baseName}.kmc_pre"), file("${dataentry.baseName}.kmc_suf") into bin
    
    memory 5.GB

    script:
    """
    mkdir bloup
    kmc -k31 -fm -ci1 ${dataentry} ${dataentry.baseName} .
    """
}
/*
this process transfom the kmc output in a list of kmer in Asci
*/
process convert {
    input :                                                                      
    tuple file(pre), file(suf) from bin
    output :
    file("dataout/${pre.baseName}") into txt

    memory 5.GB

    script :
    """
    mkdir dataout
    kmc_tools transform  ${pre.baseName} dump dataout/${pre.baseName}
    """
}

/*
this process sort the kmer file 
*/
process sortKmer { 
    publishDir "/home/oceane/dev/sorted/", mode: 'link' 
                                                                                                                   
    input:
    file convert from txt
    output:
    file "sorted_${convert.baseName}"

    memory 5.GB
    cpus 4
    
    """
    sort --parallel=4 ${convert} > sorted_${convert.baseName}
    """


}

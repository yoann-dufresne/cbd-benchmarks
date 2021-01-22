import os



WORKDIR="bench"
INPUT_DATA="small_ecoli.fasta"
nb_exec=3



bcalm=f"{WORKDIR}/tools/bcalm/build/bcalm"
blight=f"{WORKDIR}/tools/blight/bench_blight"
jellyfish=f"{WORKDIR}/tools/jellyfish-2.3.0/bin/jellyfish"
dsk=f"{WORKDIR}/tools/dsk/build/bin/dsk"
dsk_dump=f"{WORKDIR}/tools/dsk/build/bin/dsk2ascii"
sorter=f"{WORKDIR}/tools/CBl/txtSorter"
kmer_generator=f"{WORKDIR}/tools/CBl/testGeneration"

successors=f"{WORKDIR}/tools/CBl/successors"
successors_mem=f"{WORKDIR}/tools/CBl/successors_for_space"
contains=f"{WORKDIR}/tools/CBl/contains"
contains_mem=f"{WORKDIR}/tools/CBl/contains_for_space"



input_name = INPUT_DATA.split("/")[-1]
input_name = input_name[:input_name.rfind('.')]
methods = ["blight", "jellybuild", "jellyquery"]
k_vals = [31]
queries = ["genomic_query", "random_present_query", "full_random_query"]

rule all:
  input:
    expand(f"{WORKDIR}/results/{input_name}.k{{k}}/{input_name}.k{{k}}.{{query}}_{{method}}_average_{nb_exec}.txt", method=methods, k=k_vals, query=queries),
    f"{WORKDIR}/results/small_ecoli.k31/small_ecoli.k32.counts.txt",
    # f"{WORKDIR}/results/small_ecoli.k31/small_ecoli.k31.genomic_query.fasta"


# ----- Multiple executions -----

rule multi_profile:
  input:
    "{path}/{file}.k{k}/{query_file}.fasta",
    expand("{{path}}/{{file}}.k{{k}}/{{query_file}}_{val}.{{soft}}.mprof", val=range(nb_exec))
  output:
    mprof=f"{{path}}/{{file}}.k{{k}}/{{query_file}}_{{soft}}_parsed_{nb_exec}.txt",
    avg=f"{{path}}/{{file}}.k{{k}}/{{query_file}}_{{soft}}_average_{nb_exec}.txt"
  threads: 1
  run:
    for i in range(nb_exec):
      shell(f"python3 scripts/mprof_parser.py -d {{wildcards.path}}/{{wildcards.file}}.k{{wildcards.k}}/{{wildcards.query_file}}_{i}.{{wildcards.soft}}.mprof -w {{output.mprof}}")
    shell("python3 scripts/averaging.py -q {output.mprof} -w {output.avg}")


# ----- Software processing -----

rule profile_blight:
  input:
    soft=blight,
    unitigs="{path}/{file}.k{k}/{file}.k{k}.unitigs.fa",
    query="{path}/{file}.k{k}/{query}.fasta"
  output:
    stdout="{path}/{file}.k{k}/{query}_{val}.blight.stdout.txt",
    mprof="{path}/{file}.k{k}/{query}_{val}.blight.mprof"
  threads:
    workflow.cores
  run:
    shell("mkdir -p wdir")
    shell("mprof run -o {output.mprof} {input.soft} -g {input.unitigs} -q {input.query} -k {wildcards.k} -t {threads} > {output.stdout}")
    shell("rm -rf wdir {input.unitigs}*.glue.*")


rule profile_jellyfish:
  input:
    soft=jellyfish,
    unitigs="{path}/{file}.k{k}/{file}.k{k}.unitigs.fa",
    query="{path}/{file}.k{k}/{query}.fasta"
  output:
    stdout_build="{path}/{file}.k{k}/{query}_{val}.jellybuild.stdout.txt",
    mprof_build="{path}/{file}.k{k}/{query}_{val}.jellybuild.mprof",
    stdout_query="{path}/{file}.k{k}/{query}_{val}.jellyquery.stdout.txt",
    mprof_query="{path}/{file}.k{k}/{query}_{val}.jellyquery.mprof"
  threads:
    workflow.cores
  run:
    shell("mprof run -o {output.mprof_build} {input.soft} count -s 100M -C {input.unitigs} -m {wildcards.k} -t {threads} -o {input.unitigs}.jf > {output.stdout_build}")
    shell("mprof run -o {output.mprof_query} {input.soft} query {input.unitigs}.jf -s {input.query} > {output.stdout_query}")
    shell("rm -f {input.unitigs}.jf")


# rule profile_CBl_successors:
#   input:
#     time=successors,
#     mem=successors_mem,
#     kmers=(lambda wild: f"{{path}}/{{file}}.k{{k}}/{{file}}.k{wild.k+1}.counts.txt"),
#     query="{path}/{query}.fasta"
#   output:
#     stdout_query="{path}/{file}.k{k}/{query}_{val}.successors_CBlquery.stdout.txt",
#     stdout_build="{path}/{file}.k{k}/{query}_{val}.successors_CBlbuild.stdout.txt"
#   run:
#     shell("./{input.time} {input.kmers} {input.query} {output.stdout_query} {output.stdout_build}")



# ----- Query constructions -----

# def input_name_func(wildcards):
#   path = '/'.join(wildcards.path.split('/')[:-2])
#   last_slash = wildcards.path.rfind('/')
#   filename = wildcards.path[last_slash+1:]

#   print(path, filename, f"{path}/{filename}.fasta")
  
#   return f"{path}/{filename}.fasta"



rule generate_query:
  input:
    soft=kmer_generator,
    fa="{path}/{file}.fasta",
    kmers="{path}/{file}.k{k}/{file}.k{k}.counts.txt"
  output:
    "{path}/{file}.k{k}/{file}.k{k}.genomic_query.fasta",
    "{path}/{file}.k{k}/{file}.k{k}.full_random_query.fasta",
    "{path}/{file}.k{k}/{file}.k{k}.random_present_query.fasta"
  run:
    shell("./{input.soft} {input.fa} {input.kmers} {wildcards.path}/{wildcards.file}.k{wildcards.k}/{wildcards.file}.k{wildcards.k} {wildcards.k}")




# ----- Data preprocess -----

rule count_kmers:
  input:
    counter=dsk,
    dump=dsk_dump,
    sort=sorter,
    fa="{path}/{file}.fasta"
  output:
    "{path}/{file}.k{fk}/{file}.k{qk}.counts.txt"
  run:
    shell("./{input.counter} -file {input.fa} -kmer-size {wildcards.qk} -abundance-min 1 -out {output}.h5")
    shell("./{input.dump} -file {output}.h5 -out {output}.tmp && rm -f {output}.h5")
    shell("./{input.sort} {output}.tmp {output} && rm {output}.tmp")


rule bcalm_preprocess:
  input:
    soft=bcalm,
    fa="{path}/{query}.fasta"
  output:
    "{path}/{file}.k{fk}/{query}.k{qk}.unitigs.fa"
  shell:
    "{input.soft} -in {input.fa} -kmer-size {wildcards.qk} -abundance-min 1 -out {wildcards.path}/{wildcards.file}.k{wildcards.fk}/{wildcards.query}.k{wildcards.qk}"


# ----- Tools downloads and compile -----

rule prepare_tools:
  input:
    f"{WORKDIR}/tools/blight/bench_blight",
    f"{WORKDIR}/tools/jellyfish-2.3.0/bin/jellyfish",
    f"{WORKDIR}/tools/CBl/contains",
    f"{WORKDIR}/tools/CBl/successors",
    f"{WORKDIR}/tools/CBl/contains_for_space",
    f"{WORKDIR}/tools/CBl/successors_for_space",
    f"{WORKDIR}/tools/CBl/txtSorter",
    f"{WORKDIR}/tools/CBl/testGeneration",
    f"{WORKDIR}/tools/dsk/build/bin/dsk"
  

# Download Blight and compile
rule setup_blight:
  input:
    "{path}/tools/.ready.lock",
    f"{bcalm}"
  output:
    "{path}/tools/blight/bench_blight"
  threads:
    workflow.cores
  shell:
    "git clone --depth 1  https://github.com/Malfoy/Blight {wildcards.path}/tools/blight && "
    "cd {wildcards.path}/tools/blight && "
    "make -j {threads} "


# Download Jellyfish
rule setup_jellyfish:
  input:
    "{path}/tools/.ready.lock",
  output:
    "{path}/tools/jellyfish-2.3.0/bin/jellyfish"
  threads:
    workflow.cores
  shell:
    "cd {wildcards.path}/tools/ && "
    "wget https://github.com/gmarcais/Jellyfish/releases/download/v2.3.0/jellyfish-2.3.0.tar.gz && "
    "tar -xvf jellyfish-2.3.0.tar.gz && cd jellyfish-2.3.0 && "
    "./configure --prefix=$PWD && make -j {threads} "


rule setup_bcalm:
  input:
    "{path}/tools/.ready.lock"
  output:
    "{path}/tools/bcalm/build/bcalm"
  threads:
    workflow.cores
  shell:
    "cd {wildcards.path}/tools/ && "
    "rm -rf bcalm && "
    "git clone --recursive https://github.com/GATB/bcalm && "
    "cd bcalm && "
    "mkdir build && cd build && cmake .. && make -j {threads}"


rule setup_CBl:
  input:
    "{path}/tools/.ready.lock"
  output:
    "{path}/tools/CBl/contains",
    "{path}/tools/CBl/successors",
    "{path}/tools/CBl/contains_for_space",
    "{path}/tools/CBl/successors_for_space",
    "{path}/tools/CBl/txtSorter",
    "{path}/tools/CBl/testGeneration"
  threads:
    workflow.cores
  shell:
    "rm -rf {wildcards.path}/tools/CBl && mkdir {wildcards.path}/tools/CBl && "
    "cd {wildcards.path}/tools/CBl && "
    "git clone --recursive https://github.com/yoann-dufresne/ConwayBromageLib.git && "
    "cd - && "
    "cp CBl_scripts/* {wildcards.path}/tools/CBl/ && "
    "cd {wildcards.path}/tools/CBl && "
    "cmake . && make -j {threads}"


rule setup_DSK:
  input:
    "{path}/tools/.ready.lock"
  output:
    "{path}/tools/dsk/build/bin/dsk",
    "{path}/tools/dsk/build/bin/dsk2ascii"
  threads:
    workflow.cores
  shell:
    "rm -rf {wildcards.path}/tools/dsk && "
    "cd {wildcards.path}/tools && "
    "git clone --recursive https://github.com/GATB/dsk.git && "
    "cd dsk && mkdir -p build && cd build &&"
    "cmake .. && make -j {threads}"


rule set_inputs:
  input:
    data=INPUT_DATA,
    lock="{path}/results/.ready.lock"
  output:
    "{path}/results/" + INPUT_DATA.split("/")[-1]
  run:
    if INPUT_DATA[0] != '/':
      shell("ln -s $PWD/{input.data} {wildcards.path}/results/" + INPUT_DATA.split("/")[-1])
    else:
      shell("ln -s {input} {wildcards.path}/results/" + INPUT_DATA.split("/")[-1])

# Create directory tree
rule set_workdir:
  input:
    INPUT_DATA
  output:
    "{path}/tools/.ready.lock",
    "{path}/results/.ready.lock",
  run:
    shell(f"rm -rf {wildcards.path}")
    shell("mkdir -p {wildcards.path}/tools && touch {wildcards.path}/tools/.ready.lock")
    shell("mkdir -p {wildcards.path}/results && touch {wildcards.path}/results/.ready.lock")

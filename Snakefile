import os



WORKDIR="bench"
INPUT_DATA="small_ecoli.fasta"
nb_exec=3



bcalm=f"{WORKDIR}/tools/bcalm/build/bcalm"
blight=f"{WORKDIR}/tools/blight/bench_blight"
jellyfish=f"{WORKDIR}/tools/jellyfish-2.3.0/bin/jellyfish"




rule all:
  input:
    f"{WORKDIR}/results/small_ecoli.k31/small_ecoli_blight_average_{nb_exec}.txt",
    f"{WORKDIR}/results/small_ecoli.k31/small_ecoli_jellybuild_average_{nb_exec}.txt",
    f"{WORKDIR}/results/small_ecoli.k31/small_ecoli_jellyquery_average_{nb_exec}.txt"


# ----- Multiple executions -----

rule multi_profile:
  input:
    "{path}/{query_file}.fasta",
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
    unitigs="{path}/{file}.k{k}.unitigs.fa",
    query="{path}/{query}.fasta"
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
    unitigs="{path}/{file}.k{k}.unitigs.fa",
    query="{path}/{query}.fasta"
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



# ----- Data preprocess -----

rule bcalm_preprocess:
  input:
    soft=bcalm,
    fa="{filename}.fasta"
  output:
    "{filename}.k{k}.unitigs.fa"
  shell:
    "{input.soft} -in {input.fa} -kmer-size {wildcards.k} -abundance-min 1 -out {wildcards.filename}.k{wildcards.k}"


# ----- Tools downloads and compile -----

rule prepare_tools:
  input:
    f"{WORKDIR}/tools/blight/bench_blight",
    f"{WORKDIR}/tools/jellyfish-2.3.0/bin/jellyfish"
  

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


# Create directory tree
rule set_workdir:
  input:
    INPUT_DATA
  output:
    "{path}/tools/.ready.lock",
    "{path}/results/.ready.lock",
    "{path}/results/" + INPUT_DATA.split("/")[-1]
  run:
    shell(f"rm -rf {wildcards.path}")
    shell("mkdir -p {wildcards.path}/tools && touch {wildcards.path}/tools/.ready.lock")
    shell("mkdir -p {wildcards.path}/results && touch {wildcards.path}/results/.ready.lock")
    if INPUT_DATA[0] != '/':
      shell("ln -s $PWD/{input} {wildcards.path}/results/" + INPUT_DATA.split("/")[-1])
    else:
      shell("ln -s {input} {wildcards.path}/results/" + INPUT_DATA.split("/")[-1])

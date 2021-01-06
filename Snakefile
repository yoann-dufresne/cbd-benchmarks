import os



WORKDIR="bench"


rule prepare_tools:
  input:
    f"{WORKDIR}/tools/blight/bench_blight",
    f"{WORKDIR}/tools/jellyfish-2.3.0/bin/jellyfish"


# Download Blight and compile
rule setup_blight:
  input:
    "{path}/tools/.ready.lock"
  output:
    "{path}/tools/blight/bench_blight"
  threads:
    workflow.cores
  shell:
    "git clone --depth 1  https://github.com/Malfoy/Blight {wildcards.path}/tools/blight && "
    "cd {wildcards.path}/tools/blight && "
    "make -j {threads}"


# Download Jellyfish
rule setup_jellyfish:
  input:
    "{path}/tools/.ready.lock"
  output:
    "{path}/tools/jellyfish-2.3.0/bin/jellyfish"
  threads:
    workflow.cores
  shell:
    "cd {wildcards.path}/tools/ && "
    "wget https://github.com/gmarcais/Jellyfish/releases/download/v2.3.0/jellyfish-2.3.0.tar.gz && "
    "tar -xvf jellyfish-2.3.0.tar.gz && cd jellyfish-2.3.0 && "
    "./configure --prefix=$PWD && make -j {threads}"


# Create directory tree
rule set_workdir:
  output:
    "{path}/tools/.ready.lock",
    "{path}/results/.ready.lock"
  run:
    if os.path.exists(f"{wildcards.path}"):
      shell(f"rm -rf {wildcards.path}")

    shell("mkdir {wildcards.path}")
    shell("mkdir {wildcards.path}/tools && touch {wildcards.path}/tools/.ready.lock")
    shell("mkdir {wildcards.path}/results && touch {wildcards.path}/results/.ready.lock")

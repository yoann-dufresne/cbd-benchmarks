import os



WORKDIR="bench"

rule all:
  input:
    f"{WORKDIR}/tools/blight/bench_blight"


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

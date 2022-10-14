nextflow.enable.dsl=2

include { build_themisto; query_themisto; load_themisto } from "./modules/themisto"
include { build_cbd; query_contains_cbd; query_neighbours_cbd; load_cbd } from "./modules/cbd"

def expected_tools = [
    "themisto",
    "cbd",
] as Set

params.tool = "cbd"
params.organism = "sarscov2"
params.repeats = 30
params.resDir = "./results"

if (!expected_tools.contains(params.tool)) {
    exit 1, "[Pipeline error] $params.tool is not an available tool to benchmark. Available tools are: $expected_tools"
}

process collect_reports {
    input:
    path "file*"
    val org
    val dir
    val tool

    publishDir "${dir}/${org}", mode: "copy"
    output:
    path "${tool}.json"

    script:
    """
    join_reports.py --out ${tool}.json file*
    """
}


workflow {

    fasta = channel.fromPath("./data/${params.organism}.fa")
    sorted_kmers_31 = channel.fromPath("./data/${params.organism}/sorted.kmers.31.${params.organism}.txt")
    benchmarks = channel.fromPath("./data/${params.organism}/bench/*.kmers")
    repeats = channel.from(1..params.repeats)

    if (params.tool == "themisto") {

        build_themisto(fasta, params.organism, params.resDir)
        query_themisto(build_themisto.out.index, benchmarks, params.organism, repeats, params.resDir)
        load_themisto(build_themisto.out.index, params.organism, repeats, params.resDir)

    } else { // Default CBD

        build_cbd(sorted_kmers_31, params.organism, params.resDir)

        queries = build_cbd.out.index.combine(benchmarks)

        query_contains_cbd(queries.map({it[0]}), queries.map({it[1]}), params.organism, repeats, params.resDir)
        query_neighbours_cbd(queries.map({it[0]}), queries.map({it[1]}), params.organism, repeats, params.resDir)
        load_cbd(build_cbd.out.index, params.organism, repeats, params.resDir)

        benches = build_cbd.out.report
            .concat(query_contains_cbd.out.report,
                    query_neighbours_cbd.out.report,
                    load_cbd.out.report)
            .collect()

        collect_reports(benches, params.organism, params.resDir, "CBD")
    }

}



#!/usr/bin/env python3

import argparse
import json

KEYS_TO_KEEP = {
    "User time (seconds)": "usr_time",
    "System time (seconds)": "sys_time",
    "Maximum resident set size (kbytes)": "max_rss",
    "Average resident set size (kbytes)": "avg_rss",
    "Disk size": "disk",
    "Task": "task",
    "Organism": "organism",
    "Benchmark": "benchmark",
}


def parse_report(filename):

    stats = dict()
    with open(filename, "r") as file:
        for line in file:
            k, v = line.strip().split(": ")
            if k in KEYS_TO_KEEP:
                stats[KEYS_TO_KEEP[k]] = v

    return stats


def get_args():
    parser = argparse.ArgumentParser(
        description="Extract relevant info from /usr/bin/time reports"
    )

    parser.add_argument(
        "-o", "--out", help="Output file (default stdout)", required=False
    )
    parser.add_argument(
        "files", metavar="FILE", help="Reports from /usr/bin/time", nargs="+"
    )

    return parser.parse_args()


def main():

    args = get_args()

    stats = []
    for filename in args.files:
        stats.append(parse_report(filename))

    if args.out is not None:
        with open(args.out, "w") as file:
            json.dump(stats, file)
    else:
        print(json.dumps(stats))


if __name__ == "__main__":
    main()

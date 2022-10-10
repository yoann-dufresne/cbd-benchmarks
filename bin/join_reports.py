#!/usr/bin/env python3

import argparse
import json


def parse_report(filename):
    stats = dict()
    with open(filename, "r") as file:
        for i, line in enumerate(file):
            if i == 0:
                stats["command"] = line.split('"')[1].split()[0]
            elif i == 1:
                stats["usr_time"] = float(line.split(":")[1])
            elif i == 2:
                stats["sys_time"] = float(line.split(":")[1])
            elif i == 9:
                stats["max_RSS"] = 1000 * int(line.split(":")[1])
            elif i == 10:
                stats["avg_RSS"] = 1000 * int(line.split(":")[1])
            elif i == 23:
                stats["disk_size"] = int(line.split(":")[1])

    return stats

def get_args():
    parser = argparse.ArgumentParser(description="Extract relevant info from /usr/bin/time reports")

    parser.add_argument("-o", "--out", help="Output file (default stdout)", required=False)
    parser.add_argument("files", metavar="FILE", help="Reports from /usr/bin/time", nargs="+")

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

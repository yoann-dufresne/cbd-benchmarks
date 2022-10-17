#!/usr/bin/env python3
import argparse
from os import path

def main():
    parser = argparse.ArgumentParser(description="Prepare the definition file to merge several KMC dbs with `kmc_tools complex`.")
    parser.add_argument("--db", help="output db prefix", default="joined")
    parser.add_argument("files", nargs="+", help="all your kmc db files")
    args = parser.parse_args()

    prefixes = set(
        path.splitext(filename)[0]
        for filename in args.files
    )

    sets = []
    res = ""
    for i, name in enumerate(prefixes):
        sets.append(f"set{i}")
        res += f"set{i} = {name}\n"
    print(
        "INPUT:\n"
        f"{res}"
        "OUTPUT:\n"
        f"{args.db} = {' + '.join(sets)}"
    )



if __name__ == "__main__":
    main()

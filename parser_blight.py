
import argparse
from random import sample
import matplotlib.pyplot as plt

def parse_args():
    parser = argparse.ArgumentParser(description='This script generate a tsv file containing fake kmer counts.')
    parser.add_argument('--time-query', '-q', type=str, help='File')
    parser.add_argument('--writing-time', '-t', type=str, help='File')
    parser.add_argument('--writing-query', '-w', type=str, help='File')
    parser.add_argument('--writing-space', '-s', type=str, help='File')
    args = parser.parse_args()
    
    return args

def getDataFromFile(my_file, writing_time, writing_query, writing_space):
    file0 = open(my_file, "r")
    file1 = open(writing_time, "a")
    file2 = open(writing_query, "a")
    file3 = open(writing_space, "a")
    datafile = file0.readlines()
    for line in datafile:
        if 'The whole indexing took me' in line:
            file1.write("\n{}".format(line[27:-9]))
            print("{}".format(line[27:]))
            print("{}".format(line))
        elif 'The whole QUERY took me' in line:
            file2.write("\n{}".format(line[24:-9]))
            print("{}".format(line[24:]))
            print("{}".format(line))
        elif 'TOTAL Size estimated' in line:
            file3.write("\n{}".format(line[30:-1]))
            print("{}".format(line[30:]))
        

def main():
    args = parse_args()
    getDataFromFile(args.time_query, args.writing_time, args.writing_query, args.writing_space)

if __name__ == "__main__":
    main()

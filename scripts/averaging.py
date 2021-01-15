
import argparse
from random import sample
import matplotlib.pyplot as plt

def parse_args():
    parser = argparse.ArgumentParser(description='This script calculate mean of time and space')
    parser.add_argument('--time-query', '-q', type=str, help='File')
    parser.add_argument('--writing-file', '-w', type=str, help='File')
    args = parser.parse_args()
    
    return args

def getDataFromFile(my_file):
    file0 = open(my_file, "r")

    duree = []
    mem = []
    i = 0
    for line in file0 :
        sp = line.split('|')
        if(i>0):
            duree.append(float(sp[2]))
            mem.append(float(sp[3]))
        i = i+1
    return duree, mem

def mean_max_min(my_file, writing_file):
    duree, mem = getDataFromFile(my_file)
    writing = open(writing_file, "a")
    mean_duree = 0
    mean_mem = 0
    for d in duree:
        mean_duree = mean_duree + d
    for e in mem:
        mean_mem = mean_mem + e
        
    mean_duree = mean_duree / len(duree)
    mean_mem = mean_mem / len(mem)
    
    writing.write("\n{}\t{}".format(mean_duree, mean_mem))
        
def main():
    args = parse_args()
    mean_max_min(args.time_query, args.writing_file)
    
if __name__ == "__main__":
    main()

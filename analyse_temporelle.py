
import argparse
from random import sample
import matplotlib.pyplot as plt

def parse_args():
    parser = argparse.ArgumentParser(description='This script generate a tsv file containing fake kmer counts.')
    parser.add_argument('--time-query', '-q', type=str, help='File')
    parser.add_argument('--writing-file', '-w', type=str, help='File')
    args = parser.parse_args()
    
    return args

def getDataFromFile(my_file):
    file0 = open(my_file, "r")

    data = [] # les résultats des flux pondérés
    tour = []
    i = 0;
    for line in file0 :
        sp = line.split('\n') # séparation '\n'
        if(i>0):
            data.append(float(sp[0]))
            tour.append(i)
        i = i+1        
    return [data, tour]

def getDataMprof(my_file):
    file1 = open(my_file, "r")
    memory_space = []
    tour = []
    i = 0;
    for line in file1 :
        sp = line.split(' ')
        if(i > 0):
            memory_space.append(float((sp[1])[0:len(sp[1])-1]))
            tour.append(i)
        i = i+1
    return [memory_space,tour]

def mean_max_min(my_file, writing_file):
    (data,tour) = getDataFromFile(my_file)
    #(data,tour) = getDataMprof(my_file)
    writing = open(writing_file, "a")
    my_min = 10000000000
    my_max = 0
    mean = 0
    for d in data:
        mean = mean + d
        if (d < my_min):
            my_min = d
        if (d > my_max):
            my_max = d
    mean = mean / len(data)
    print("moyenne des relevés : {}".format(mean))
    writing.write("\n{}".format(mean))
    print("minimum : {}".format(my_min))
    print("maximum : {}".format(my_max))
    #writing.write("\n{}".format(my_max))
    #print("espace occupe : {}".format(data[-5]))
    #writing.write("\n{}\t{}".format(data[-5], my_max))
        
def main():
    args = parse_args()
    mean_max_min(args.time_query, args.writing_file)
    #graph(args.time_query)

    
if __name__ == "__main__":
    main()

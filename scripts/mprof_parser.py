#!/usr/bin/env python3
import matplotlib.pyplot as plt
import numpy as np
import argparse
import os
import time
import datetime

def parse_args():
    parser = argparse.ArgumentParser(description='This script counts average execution time and create and average mprof plot.')
    parser.add_argument('--dat-file', '-d', type=str, help='The file which contains infos')
    parser.add_argument('--writing-file', '-w', type=str, help='file where we write results')
    args = parser.parse_args()
    return args

def getLen(dat_file):
    file = open(dat_file, "r")
    time = []
    memory = []
    file.readline() #skip the first line
    for line in file:
        sp = line.split(' ')
        memory.append(float(sp[1]))
        time.append(float(sp[2]))
    file.close()
    return memory, time

def main():
    args = parse_args()
    print("Write in : {}".format(args.writing_file))
    dataMem,dataTime = getLen(args.dat_file)
    spliterS = time.ctime(dataTime[0])
    spliterE = time.ctime(dataTime[-1])
    duration = dataTime[-1] - dataTime[0]
    print("dataTime : {}\t{}".format(dataTime[0], dataTime[-1]))
    print("{}\n".format(duration))
    
    writing = open(args.writing_file, "a")#debut | fin | duree | espece memoire occupe fin | plus gros pic memoire
    writing.write("\n{}|{}|{}|{}|{}".format(spliterS, spliterE, duration, max(dataMem), dataMem[-1]))
    print("{} | {} | {} | {} | {}\n".format(spliterS, spliterE, duration, max(dataMem), dataMem[-1]))
    writing.close()

if __name__ == "__main__":
    main()

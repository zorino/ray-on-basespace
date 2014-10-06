#!/usr/bin/env python

import sys
import os
import subprocess
import json


def readOutputNumbers(file):
        
    with open(file) as f:
        content = f.readlines()

    i = 0
    result = []
    row = []

    while i < 4:
        i = i + 1
        j = 0
        if row:
            result.append(row)
        row = []
        while j < 7:
            j = j+1
            x = content.pop(0)
            row.append(x.rstrip())

    result.append(row)
    return result

if __name__ == "__main__":

    results = readOutputNumbers(sys.argv[1])
    stats = ["Number of sequences", 
             "Total length of seq.",
             "Average length",
             "N50",
             "Median",
             "Largest"]

    i = 0
    j = 0

    while j < 7:
        if j == 0:
            header = []
            header.append(" ")
            i = 0
            while i < 4:
                header.append(results[i][j])
                i = i+1
            print "\t".join(header)
        else:
            line = []
            line.append(stats[j-1])
            i = 0
            while i < 4:
                line.append(results[i][j].split(": ")[1])
                i = i+1
            i = 0
            print "\t".join(line)
        j = j+1

#!/usr/bin/env python

import sys
import json


def readAppSession(file):
    
    jsonSession = ""
    
    with open (file, "r") as myfile:
        data=myfile.read()
        jsonSession = json.loads(data)
        
    return jsonSession


def getKmerSize(json):

    for key in json['Properties']['Items']:
        if key['Name'] == "Input.KmerSize":
            return key['Content']



if __name__ == "__main__":

    json = readAppSession(sys.argv[1])
    kmerSize = getKmerSize(json)

    


#!/usr/bin/env python

import sys
import os
import subprocess
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

def getProjectID(json):

    for key in json['Properties']['Items']:
        if key['Name'] == "Input.project-id":
            return key['Content']['Id']
 


if __name__ == "__main__":

    json = readAppSession(sys.argv[1])

    if sys.argv[2] == "kmersize":
        kmerSize = getKmerSize(json)
        print kmerSize
    elif sys.argv[2] == "projectID":
        projectID = getProjectID(json)
        print projectID


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


if __name__ == "__main__":

    json = readAppSession(sys.argv[1])
    kmerSize = getKmerSize(json)
    
    
    os.chdir("/opt/")
    subprocess.call(["bash", "/opt/ray-on-basespace/Generate-RayConf.sh", "-r /data/input/samples/","-d .", "-k "+kmerSize, "-o Assembly"])
    subprocess.call(["mpiexec", "-n 32", "/opt/ray/BUILD/Ray", "Ray.conf"])
    subprocess.call(["mv", "Assembly", "/data/output/appresults/"])

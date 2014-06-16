#!/bin/bash

source /etc/profile
module load openmpi-x86_64

echo "Generating Ray Config File.."
cd /opt/
kmersize=$(python2 ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json kmersize)
projectID=$(python2 ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json projectID)
sampleID=$(python2 ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json sampleID)
mkdir Search-Datasets
reads=$(find /data/input/samples/$sampleID -name "*fastq*")
readDir=$(dirname $reads)
bash /opt/ray-on-basespace/Generate-RayConf.sh -r $readDir -d ./Search-Datasets -k $kmersize -o Assembly

echo "Running Ray Assembly.."
mpiexec -n 32 ./ray/BUILD/Ray Ray.conf
mkdir -p /data/output/appresults/$projectID/$sampleID
mv Assembly /data/output/appresults/$projectID/$sampleID/

echo "Assembly Finished"

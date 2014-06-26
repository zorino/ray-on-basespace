#!/bin/bash

source /etc/profile
module load openmpi-x86_64

echo "Generating Ray Config File.."
cd /opt/
kmersize=$(python2 ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json kmersize)
projectID=$(python2 ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json projectID)
sampleID=$(python2 ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json sampleID)
reads=$(find /data/input/samples/$sampleID -name "*fastq*" | head -n 1)
readDir=$(dirname $reads)
mkdir reads
for i in $(ls $readDir | grep "fastq" | grep "_R")
do
    cp $readDir/$i ./reads/$i.fastq.gz
done

mkdir Search-Datasets
mkdir -p /data/output/appresults/$projectID
bash /opt/ray-on-basespace/Generate-RayConf.sh -r ./reads -d ./Search-Datasets -k $kmersize -o /data/output/appresults/$projectID/$sampleID

echo "Running Ray Assembly.."
cat Ray.conf
mpiexec -n 10 --mca btl ^sm /opt/ray/BUILD/Ray Ray.conf

echo "Assembly Finished"

wait

#!/bin/bash

source /etc/profile
module load openmpi-x86_64

echo "Generating Ray Config File.."
cd /opt/
kmersize=$(python2 ./ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json kmersize)
projectID=$(python2 ./ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json projectID)
mkdir Search-Datasets
bash /opt/ray-on-basespace/Generate-RayConf.sh -r /data/input/samples/ -d ./Search-Datasets -k $kmerSize -o Assembly
cat Ray.conf

echo "Running Ray Assembly.."
mpiexec -n 32 ./ray/BUILD/Ray Ray.conf
mv Assembly /data/output/appresults/$projectID

echo "Assembly Finished"

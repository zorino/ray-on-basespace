#!/bin/bash

source /etc/profile
module load openmpi-x86_64

echo "Generating Ray Config File.."
python2 /opt/ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json

echo "Running Ray Assembly.."
mpiexec -n 32 /opt/ray/BUILD/Ray Ray.conf
mv Assembly /data/output/appresults/

echo "Assembly Finished"

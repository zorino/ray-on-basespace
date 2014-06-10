#!/bin/bash

source /etc/profile
module load openmpi-x86_64
python2 /opt/ray-on-basespace/Ray-Launcher.py /data/input/AppSession.json

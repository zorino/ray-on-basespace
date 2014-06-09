# Linux OS
FROM centos

# Install Dependency
RUN yum install -y gcc-c++ openmpi openmpi-devel zlib zlib-devel bzip2-libs bzip2-devel git

# Install RayPlatform and Ray from github
RUN source /etc/profile; module load openmpi-x86_64;\
 cd /opt/; git clone https://github.com/sebhtml/RayPlatform.git; cd RayPlatform/;\
 make clean; make;\
 cd /opt/; git clone https://github.com/sebhtml/ray.git;\
 cd /opt/ray/; make clean;\
 make PREFIX=BUILD MAXKMERLENGTH=64 HAVE_LIBZ=y HAVE_LIBBZ2=y ASSERT=n;\
 make install;\
 cd /opt/; mkdir bin; cd bin/; ln -s ../ray/BUILD/Ray .;

# Install utilitaries to run assemblies
RUN cd /opt/; git clone https://github.com/Zorino/ray-on-basespace.git;\
 cd ray-on-basespace/; git pull;\
 bash Launch-Ray.sh

# Maintener
MAINTAINER Maxime Deraspe maxime@deraspe.net

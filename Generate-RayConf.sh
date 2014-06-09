#!/bin/bash
# author: Maxime Déraspe
# reviewed by : 
#
# Script that wil generate a Ray.conf config
# file to be used with Ray Assembler.
#
# It will search for any datasets with fasta
# sequences in it.
# Then,
# it will search for NCBI-taxonomy and GO
# to construct the profiling.
# Based on Ray commands :
#	-with-taxonomy
#	-gene-ontology
#
# The PATH are hard coded to NCBI-taxonomy/ and
# Gene-Ontology/ to be searched in (profiling).
#
# This Script aims to be used with UpdateDatabases.sh
# .. if not respect the directories name above if you
# want the power of Ray profiling.
#
# Generate-RayConf.sh -r ReadsDir -d DatasetsDir -k kmerSize -o OutputDir
#

if [ "$1" == "" ]
then
    echo "Specify at least -r ReadDirectory and -d DatasetsDirectory (default:k=31,o=RayOutput)"
    echo -e "\n   Generate-RayConf.sh -r ReadsDir -d DatasetsDir -k kmerSize -o OutputDir\n"
    exit 0
fi


# Input user arguments
while getopts "r:d:k:o:help" opt
do
    case $opt in
        r)
            r=$OPTARG
            ;;
        d)
            d=$OPTARG
            ;;
        k)
            k=$OPTARG
            ;;
        o)
            outdir=$OPTARG
            ;;
        h)
            echo "Default are -k 31 and -o RayOutput"
            echo -e "\n   Generate-RayConf.sh -r ReadsDir -d DatasetsDir -k kmerSize -o OutputDir\n"
            exit 0
            ;;
        \?)
            echo "Invalid Options !"
            exit 0
            ;;
    esac
done

## Setting default parameters
if [[ -z $k ]]
then
    k="31"
fi
if [[ -z $outdir ]]
then
    outdir="RayOutput"
fi

curDir=$(pwd)

# Ray.conf kmer size
echo -e "# Ray Configuration File #" > Ray.conf
echo -e "\n# Kmer Size" >> Ray.conf
echo -e "-k $k\n" >> Ray.conf


# Searching Paired Reads
echo -e "\nSearching for reads librairies\n"

# If files are R1_ R2_ it will be matched
# in the libraries. If not it will be 1 file
# by -p (still considering it's paired end).
echo -e "# Reads Librairies" >> Ray.conf

cd $r
rdir=$(pwd)
seqDone=""

for i in $(ls | grep fastq)
do
    if [[ $(echo $i | grep R1_) != "" ]] && [[ $(echo $seqDone | grep $i) == "" ]]
    then
        snd=$(echo $i | sed 's/R1_/R2_/g')
        if [ $(ls | grep $snd) != "" ]
        then
            echo -e "-p" >> $curDir/Ray.conf
            echo -e "\t$rdir/$i" >> $curDir/Ray.conf
            echo -e "\t$rdir/$snd" >> $curDir/Ray.conf
        else
            echo -e "-s" >> $curDir/Ray.conf
            echo -e "\t$rdir/$i" >> $curDir/Ray.conf
        fi
        seqDone="$seqDone $i $snd"
    elif [[ $(echo $i | grep R2_) != "" ]] && [[ $(echo $seqDone | grep $i) == "" ]]
    then
        snd=$(echo $i | sed 's/R2_/R1_/g')
        if [ "$(ls | grep $snd)" != "" ]
        then
            echo -e "-p" >> $curDir/Ray.conf
            echo -e "\t$rdir/$i" >> $curDir/Ray.conf
            echo -e "\t$rdir/$snd" >> $curDir/Ray.conf
        else
            echo -e "-s" >> $curDir/Ray.conf
            echo -e "\t$rdir/$i" >> $curDir/Ray.conf
        fi
        seqDone="$seqDone $i"
    elif [[ $(echo $seqDone | grep $i) == "" ]]
    then
        echo -e "-s" >> $curDir/Ray.conf
        echo -e "\t$rdir/$i" >> $curDir/Ray.conf
    fi
done

cd $curDir

# Searching Datasets
echo -e "Searching for datasets .... please wait\n"

echo -e "\n# Search Datasets" >> Ray.conf

cd $d
dataDir=$(pwd)

# Finding fasta files and write it
if [[ -f $curDir/Search-sequences.txt ]] && [[ -f $curDir/Search-directories.txt ]]
then
    echo "Taking Search-* files content as input search dataset"
else
    echo "Looking for datasets (fasta sequences) for the profiling.."
    find -L . -name *.fasta > $curDir/Search-sequences.txt
    for i in $(cat $curDir/Search-sequences.txt)
    do
        echo $(dirname $i)
    done | uniq > $curDir/Search-directories.txt
fi


for i in $(cat $curDir/Search-directories.txt)
do
    if [[ $i != *Gene-Ontology ]]
    then
        tmpDir=$(pwd)
        cd $i
        echo "-search" >> $curDir/Ray.conf
        echo -e "\t$(pwd)" >> $curDir/Ray.conf
        cd $tmpDir
    fi
done

cd $dataDir

# Searching Profiling Files
echo -e "Searching for profiling files .... please wait\n"

echo -e "\n# Profiling Ontology + Taxonomy" >> $curDir/Ray.conf

## Gene-Ontology (hard-coded path)
# ontology=$(find -L . -type d | grep Gene-Ontology$)
ontologyDir=$(cat $curDir/Search-directories.txt | grep Gene-Ontology/)
ontology="${ontologyDir%%Gene-Ontology*}Gene-Ontology/"

echo $ontology

if [[ $ontology != "" && -f "$ontology/OntologyTerms.txt" \
    && -f "$ontology/Annotations.txt" ]]
then
    cd $ontology
    echo -e "-gene-ontology" >> $curDir/Ray.conf
    echo -e "\t$(pwd)/OntologyTerms.txt" >> $curDir/Ray.conf
    echo -e "\t$(pwd)/Annotations.txt" >> $curDir/Ray.conf
    echo "Ontology Added"
    cd $dataDir
fi


## NCBI-taxonomy (hard-coded path)
# taxonomy=$(find -L . -type d | grep NCBI-taxonomy$)
taxonomyDir=$(cat $curDir/Search-directories.txt | grep NCBI-Taxonomy/)
taxonomy="${taxonomyDir%%NCBI-Taxonomy*}NCBI-Taxonomy/"

echo $taxonomyDir
echo $taxonomy

if [[ $taxonomy != "" && -f "$taxonomy/Genome-to-Taxon.tsv" \
    && -f "$taxonomy/TreeOfLife-Edges.tsv" && -f "$taxonomy/Taxon-Names.tsv" ]]
then
    cd $taxonomy
    echo -e "-with-taxonomy" >> $curDir/Ray.conf
    echo -e "\t$(pwd)/Genome-to-Taxon.tsv" >> $curDir/Ray.conf
    echo -e "\t$(pwd)/TreeOfLife-Edges.tsv" >> $curDir/Ray.conf
    echo -e "\t$(pwd)/Taxon-Names.tsv" >> $curDir/Ray.conf
    echo "Taxonomy Added"
    cd $dataDir
fi

cd $curDir

# Ray.conf Output directory
echo -e "\n# Output Directory" >> Ray.conf
echo -e "-o $outdir\n" >> Ray.conf

# Finished
echo "Finished with Success !"
echo ""


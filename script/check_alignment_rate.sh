#!/bin/bash
#SBATCH --partition=rimlsfnwi
#SBATCH --job-name=check_alignment_rate
#SBATCH --output=./log/%x-%A-%a.out
#SBATCH --error=./log/%x-%A-%a.err
#SBATCH --time=00:05:00
#SBATCH --mem 1G
#SBATCH -c 1

wd=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh
sub=scifi
outputDir=$wd/$sub/
inputDir=$wd/$sub/demultiplexed
inputfile_list=($inputDir/scifi#4053*.bam)

outputFile=alignment_rate.txt

if [ -f "$outputDir/$outputFile" ]; then
        echo "$outputFile exists"
        rm $outputDir/$outputFile
fi

for f in $inputDir/scifi#4053*.bam;
do
	basename_temp=${f%.bam};
	basename=${basename_temp##*/};
	readFile=$wd/$sub/mapped/$basename/$basename.STAR.Log.final.out;
	echo $basename >> $outputFile;
	grep -H -E "Uniquely mapped reads number" $readFile >> $outputFile;
 	grep -H -E "Uniquely mapped reads %" $readFile >> $outputFile;
	grep -H -E "Average mapped length" $readFile >> $outputFile;
	i+=1;
done

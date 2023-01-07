#!/bin/bash
#SBATCH --partition=rimlsfnwi
#SBATCH --job-name=check_alignment
#SBATCH --output=./log/%x-%A-%a.out
#SBATCH --error=./log/%x-%A-%a.err
#SBATCH --time=00:05:00
#SBATCH --mem 1G
#SBATCH -c 1

wd=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh
sub=scifi/mapped
job=arr_STAR_TRANSCRIPT_BASIC-2550622
outputDir=$wd/$sub/$job
inputDir=$wd/$sub/$job

outputFile=$outputDir/$job.txt

if [ -f "$outputFile" ] ; then
    rm "$outputFile"
fi

for f in $inputDir/*.out;
do
	echo $f >> $outputFile;
	grep -H -E "finished successfully" $f >> $outputFile;
done

var="$(grep -H -E "finished successfully" $outputFile | wc -l)"
echo "Total $var samples are aligned successfully!" >> $outputFile

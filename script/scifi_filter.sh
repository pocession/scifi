#!/bin/env bash
#SBATCH --partition=rimlsfnwi
#SBATCH --job-name=scifi_filter
#SBATCH --output=./log/arr_%x-%A-%a.out
#SBATCH --error=./log/arr_%x-%A-%a.err
#SBATCH --time=08:00:00
#SBATCH --mem 8G
#SBATCH -c 1
#SBATCH --array=1-72 

export DISPLAY=:0.0

wd=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh
sub=scifi
outputDir=$wd/$sub/filtered
inputDir=$wd/$sub/demultiplexed
mappedDir=$wd/$sub/mapped
r2=$wd/$sub/round2_sample_annotation.csv

inputfile_list=($inputDir/scifi#4053*.bam)
inputfile=${inputfile_list[$SLURM_ARRAY_TASK_ID-1]}

basename_temp=${inputfile%.bam}
basename=${basename_temp##*/}

if [ -d "$outputDir/$basename" ]; then
        echo "$basename exists"
        rm  -r $outputDir/$basename
fi

mkdir $outputDir/$basename

python3 -u -m scifi.scripts.summarizer \
    --r1-annot $wd/$sub/round1_plate_well_annotation.csv \
    --r1-attributes sample_name \
    --cell-barcodes r2 \
    --only-summary \
    --no-save-intermediate \
    --min-umi-output 20 \
    --expected-cell-number 200000 \
    --save-gene-expression \
    --no-output-header \
    --correct-r1-barcodes \
    --correct-r2-barcodes \
    --correct-r2-barcode-file $r2 \
    --sample-name $basename \
    $mappedDir/$basename/$basename.ALL.STAR.Aligned.out.bam.featureCounts.bam \
    $outputDir/$basename/$basename.ALL.STAR.Aligned.out.bam.featureCounts.bam

#!/bin/env bash
#SBATCH --partition=rimlsfnwi
#SBATCH --job-name=scifi_map
#SBATCH --output=./log/arr_%x-%A-%a.out
#SBATCH --error=./log/arr_%x-%A-%a.err
#SBATCH --time=08:00:00
#SBATCH --mem 128G
#SBATCH -c 4
#SBATCH --array=1-72 

wd=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh
sub=scifi
genomeIndexDir=$wd/GRCh38/STARINDEX/
genomeDir=$wd/GRCh38/
outputDir=$wd/$sub/mapped
inputDir=$wd/$sub/demultiplexed

inputfile_list=($inputDir/scifi#4053*.bam)
inputfile=${inputfile_list[$SLURM_ARRAY_TASK_ID-1]}

basename_temp=${inputfile%.bam}
basename=${basename_temp##*/}

if [ -d "$outputDir/$basename" ]; then
        echo "$basename exists"
        rm  -r $outputDir/$basename
fi

mkdir $outputDir/$basename

STAR \
--runThreadN 4 \
--genomeDir $genomeIndexDir \
--clip3pAdapterSeq AAAAAA \
--outSAMprimaryFlag AllBestScore \
--outSAMattributes All \
--outFilterScoreMinOverLread 0 \
--outFilterMatchNminOverLread 0 --outFilterMatchNmin 0 \
--outSAMunmapped Within \
--outSAMtype BAM Unsorted \
--readFilesType SAM SE \
--readFilesCommand samtools view -h \
--outFileNamePrefix $outputDir/$basename/$basename.ALL.STAR. \
--readFilesIn $inputDir/$basename.bam

featureCounts \
-T 4 \
-F GTF \
-t gene \
-g gene_id \
--extraAttributes gene_name \
-Q 30 \
-s 0 \
-R BAM \
-a $genomeDir/gencode.v42.primary_assembly.annotation.gtf \
-o $outputDir/$basename/$basename.ALL.STAR.featureCounts.quant_gene.tsv \
$outputDir/$basename/$basename.ALL.STAR.Aligned.out.bam

ln -s $outputDir/$basename/$basename.ALL.STAR.Aligned.out.bam    $outputDir/$basename/$basename.ALL.STAR.Aligned.out.exon.bam

featureCounts \
-T 4 \
-F GTF \
-t exon \
-g gene_id \
--extraAttributes gene_name \
-Q 30 \
-s 0 \
-R BAM \
-a $genomeDir/gencode.v42.primary_assembly.annotation.gtf \
-o $outputDir/$basename/$basename.ALL.STAR.featureCounts.quant_gene.exon.tsv \
$outputDir/$basename/$basename.ALL.STAR.Aligned.out.bam

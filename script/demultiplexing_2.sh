#!/bin/bash
#SBATCH --partition=rimlsfnwi
#SBATCH -t 24:00:00
#SBATCH --mem=120G
#SBATCH -c 8
#SBATCH --job-name="demultiplexing2"
#SBATCH --output=./log/slurm-%x.%j.out
#SBATCH --error=./log/slurm-%x.%j.err

samplesheet=samplesheet.tsv

wd=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh
sub=scifi
picard_jar=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh/App/picard-2.19.2-CeMM-all.jar
input_bam=scifi/demultiplexed/unmultiplexed.bam
output_dir=scifi/demultiplexed
output_prefix=scifi
output_metrics_file=$output_dir/scifi_matrix.csv

java \
-Xmx20G \
-Djava.io.tmpdir=./tmp \
-jar $picard_jar \
IlluminaSamDemux \
INPUT= $wd/$input_bam \
OUTPUT_DIR= $wd/$output_dir \
OUTPUT_PREFIX= $output_prefix \
LIBRARY_PARAMS= $wd/$sub/$samplesheet \
METRICS_FILE= $output_metrics_file \
TMP_DIR=./tmp \
COMPRESSION_LEVEL=9 \
CREATE_MD5_FILE=true \
OUTPUT_FORMAT=bam \
BARCODE_TAG_NAME=BC \
BARCODE_QUALITY_TAG_NAME=QT \
MAX_MISMATCHES=1 \
MIN_MISMATCH_DELTA=1 \
MAX_NO_CALLS=2 \
MINIMUM_BASE_QUALITY=0 \
VERBOSITY=INFO \
QUIET=false \
VALIDATION_STRINGENCY=STRICT \
MAX_RECORDS_IN_RAM=500000 \
CREATE_INDEX=false \
GA4GH_CLIENT_SECRETS=client_secrets.json \
USE_JDK_DEFLATER=false \
USE_JDK_INFLATER=false \
DEFLATER_THREADS=8 \
MATCHING_THREADS=8 \
READ_STRUCTURE= 8M13B8B16M47T \
TAG_PER_MOLECULAR_INDEX=RX \
TAG_PER_MOLECULAR_INDEX=r2

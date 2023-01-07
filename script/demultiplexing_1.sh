#!/bin/bash
#SBATCH --partition=rimlsfnwi
#SBATCH -t 24:00:00
#SBATCH --mem=120G
#SBATCH -c 8
#SBATCH --job-name="demultiplexing1"
#SBATCH --output=./log/slurm-%x.%j.out
#SBATCH --error=./log/slurm-%x.%j.err

input=/ceph/rimlsfnwi/raw_data/bcl/2022/220829_NS500173_0891_AH3GNTBGXM
csv=SampleSheet.csv

wd=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh
picard_jar=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh/App/picard-2.19.2-CeMM-all.jar
output_bam=scifi/unmultiplexed/unmultiplexed.bam

java \
-Xmx20G \
-Djava.util.concurrent.ForkJoinPool.common.parallelism=2 \
-Djava.io.tmpdir=./tmp \
-jar $picard_jar \
IlluminaBasecallsToMultiplexSam \
RUN_DIR= $input \
LANE=1 \
OUTPUT= $wd/$output_bam \
SEQUENCING_CENTER=BSF \
NUM_PROCESSORS=2 \
APPLY_EAMSS_FILTER=false \
INCLUDE_NON_PF_READS=false \
TMP_DIR=tmp \
CREATE_MD5_FILE=false \
FORCE_GC=false \
MAX_READS_IN_RAM_PER_TILE=9000000 \
MINIMUM_QUALITY=2 \
VERBOSITY=INFO \
QUIET=false \
VALIDATION_STRINGENCY=STRICT \
CREATE_INDEX=false \
GA4GH_CLIENT_SECRETS=client_secrets.json

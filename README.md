# scifi
A data process pipeline for ultra multiplexing single cell RNA-seq data (scifi-RNA-seq).

## Description
scifi-RNA-seq is a single cell RNA-seq technique, which allows user to pre-index >150K cells in 96-well plates and load more than one cell in single droplet. After in-silico demultiplexing, the transcriptomics in each cell could be retrieved. The workflow utilizes a standard microfluidic droplet generator (10x Genomics Chromium) and 10X ATAC-seq kit v3. Please check the [original publication](https://www.nature.com/articles/s41592-021-01153-z) for more details.

## Usage
Due to some configuration problems, the [original data analysis pipeline](https://github.com/epigen/scifiRNA-seq) could not be automatically run in my server. Therefore, I dissemble the pipeline into these five steps and run them manually.

1. [Demultiplexing 1](./script/demultiplexing_1.sh): This step reads the bcl2 file (Illuminar raw data) and demultiplex the data into an unaligned, unmultiplexed bam file.
2. [Demultiplexing 1](./script/demultiplexing_2.sh): This step performs a real demultiplexing step to create a bam file with all tag information. Different flags are specified to indicate the index in the bam file. For more information about demultiplexing step, please check the [original demultiplexing pipeline](https://github.com/epigen/scifiRNA-seq/blob/main/demultiplexing_guide.rst).
3. [Map](./script/scifi_map.sh): This step performs mapping and counting process and generates a count matrix (cell-gene) for each well.
4. [Filtering](./script/scifi_filter.sh): This step performs a filtering process to remove cells with low UMI counts.
5. [Join](./script/scifi_join.sh): This step aggregates data from each well and generates a complete count matrix (cell-gene) for the experiment / sample.

## Credits
- [Original data analysis pipeline](https://github.com/epigen/scifiRNA-seq).
- [Original publication](https://www.nature.com/articles/s41592-021-01153-z).

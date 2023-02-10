# scifi

A data process pipeline for ultra high throughput single cell RNA-seq data (scifi-RNA-seq).

## Background

Droplet-based single cell sequencing method is a powerful tool in omics study. Within a standard droplet generator, cells are first mixed with oil-encapsulated droplet and undergo a series of biochemical reactions. This process generates a collection of droplets and each droplet contains oligo-indexed heredity materials from a single cell. However, to prevent more than two cells are loaded into one droplet, most of droplets have to be remained empty. Those droplets are still sequenced and it creates a huge waste of sequencing throughput.

To reduce the waste, a method called [scifi-RNA-seq](https://www.nature.com/articles/s41592-021-01153-z) was invented by Paul Datlinger et. al. This method utilizes a specific barcoding strategy to preindex >150K cells in 96-well plates and more than one cells are overloaded into one droplet. The throughput is significantly increased by 15X.

The workflow utilizes a standard microfluidic droplet generator (10x Genomics Chromium) and 10X ATAC-seq kit v3. Please check the [original publication](https://www.nature.com/articles/s41592-021-01153-z) for more details.

## Usage

- `Rscript --vanilla script.R input.csv output`.
- `input.csv` is the file from preprocessed data pipeline (see below) and output is the name for this experiment.
- The App will create a folder named `rds` and store the cleaned count matrix in `rds` object.
- The App will also create another folder named `output` and store the final result in 10X format. These three files `matrix.mtx, genes.tsv, barcodes.tsv` could be used for downstream analysis in other softwares such as [Seurat](https://satijalab.org/seurat/articles/get_started.html).

## Data preprocessing

Due to some configuration problems, the [original data preprocessing pipeline](https://github.com/epigen/scifiRNA-seq) could not be automatically run in our server. Therefore, I dissemble the pipeline into these five steps and run them manually.

1. [Demultiplexing 1](./script/demultiplexing_1.sh): This step reads the bcl2 file (Illuminar raw data) and demultiplex the data into an unaligned, unmultiplexed bam file.
2. [Demultiplexing 2](./script/demultiplexing_2.sh): This step performs a real demultiplexing step to create a bam file with all tag information. Different flags are specified to indicate the index in the bam file. For more information about demultiplexing step, please check the [original demultiplexing pipeline](https://github.com/epigen/scifiRNA-seq/blob/main/demultiplexing_guide.rst).
3. [Map](./script/scifi_map.sh): This step performs mapping and counting process and generates a count matrix (cell-gene) for each well.
4. [Filtering](./script/scifi_filter.sh): This step performs a filtering process to remove cells with low UMI counts.
5. [Join](./script/scifi_join.sh): This step aggregates data from each well and generates a complete count matrix (cell-gene) for the experiment / sample.

## Credits

- [Original data preprocessing pipeline](https://github.com/epigen/scifiRNA-seq).
- [Original publication](https://www.nature.com/articles/s41592-021-01153-z).

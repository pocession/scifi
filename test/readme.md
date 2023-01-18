# A sandbox for app testing

## Usage

- `Rscript input.csv output`.
- `input.csv` is the joined result from scifi pipeline and output is the name for this experiment. The App will create a folder with the name `output` and store three files in that folder. These three files `matrix.mtx, genes.tsv, barcodes.tsv` could be used for downstream analysis in other softwares such as [Seurat](https://satijalab.org/seurat/articles/get_started.html).

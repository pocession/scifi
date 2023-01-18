#!/usr/bin/env Rscript

## Handling I/O ====
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  print("There is only one argument. This argument is automatically taken as the input file")
  args[2] = "output"
}

## Loading packages ====
print("Loading packages")
library(EnsDb.Hsapiens.v86)
library(Seurat)
library(patchwork)
library(Matrix)
library(dplyr)
library(tidyr)
library(data.table)
print("Loading packages done!")

## Variables ====
exp <- args[2]
print(exp)

## path ====
wd <- getwd()
input <- file.path(wd)
output <- file.path(wd,args[2])
rds_output <- file.path(wd,"rds")
dir.create(output,recursive = TRUE)
dir.create(rds_output,recursive = TRUE)
print(paste0("The working path is ", wd))

# Functions ====
## Assign new barcodes
get_cellBarcodes <- function(df,colName) {
  x <- df %>%
    tidyr::separate(colName, c("exp_code1","Day","Musa","scifi3","exp_code2","well"),sep="_")
  x$cellbarcode <- paste(x$r2,x$exp_code1,x$expcode2,x$well,sep="_")
  return(x)
}

## Assign gene symbols
### Use keytypes(db) to check keytypes
get_GeneSymbol <- function(df) {
  x <- df
  x <- x %>%
    tidyr::separate(gene, c("gene","version"))
  x$symbol = mapIds(hs_db,
                    keys=x$gene, 
                    column="SYMBOL",
                    keytype="GENEID",
                    multiVals="first")
  x <- x[!is.na(x$symbol),]
  return(x)
}

## Assign numbers to NA in a data frame
### Very slow
# get_ridNA <- function(df,num) {
#   x <- df
#   x[is.na(x)] <- num
#   return(x)
# }

## Fast method
### Credit: https://stackoverflow.com/questions/7235657/fastest-way-to-replace-nas-in-a-large-data-table
get_ridNA_dowle3 = function(DT, num) {
  x <- DT[,-1]
  
  # either of the following for loops
  
  # by name :
  ## for (j in names(DT)) {
  ##    set(DT,which(is.na(DT[[j]])),j,num)
  ## }
  
  # or by number (slightly faster than by name) :
  for (j in seq_len(ncol(x))) {
    set(x,which(is.na(x[[j]])),j,num)
  }
  x <- cbind(DT[,1],x)
}

## Get matrix
get_matrix <- function(df,firstCol) {
  x <- as.matrix(df[,-1])
  rownames(x) <- df$symbol
  return(x)
}

## Save to 10X object
get_10X <- function(mtx, out.path, out.name) {
  x <- mtx
  path <- out.path
  name <- out.name
  
  # save sparse matrix
  x <- Matrix(x , sparse = T )
  writeMM(obj = x, file=file.path(path,"matrix.mtx"))
  
  # save genes and cells names
  write(x = rownames(x), file=file.path(path,"genes.tsv"))
  write(x = colnames(x), file=file.path(path,"barcodes.tsv"))
}

# Read and clean input ====
## Read
input_file <- read.csv(file.path(input,args[1]))
colnames(input_file) <- c("r2","gene","umi","sample_name")

## Clean data
input_file <- get_cellBarcodes(input_file,"sample_name")

# converse ensembl to gene symbol ====
## this step removes those unmapped gene too
## Set gene symbol db
hs_db <- EnsDb.Hsapiens.v86
input_file <- get_GeneSymbol(input_file)

# collapse cell barcode and gene symbol if needed ====
input_file <- aggregate(umi~cellbarcode+symbol, input_file, sum)

# create count matrix ====
## transpose long to wide table
input_file_df <- input_file %>%
  tidyr::pivot_wider(names_from = cellbarcode, values_from = umi)

## Assign 0 to NA
input_file_df <- get_ridNA_dowle3(input_file_df,0)

# save count matrix to rds object ====
saveRDS(input_file_df,file.path(rds_output,paste0(exp,".rds")))
print(paste0("The cleaned count matrix is saved in rds object to: ", rds_output))

# Get matrix ====
input_file_mtx <- get_matrix(input_file_df,symbol)

# Save results in 10X format ====
get_10X(input_file_mtx, file.path(output), exp)

print(paste0("The results are save in 10X format to: ", output))
print("Done!")

# Generate test.csv for input
# tmp_dir <- "/Users/hsieh/scifi/test/"
# input_file <- read.csv(file.path(tmp_dir,"scifi#40532_Day1_Musa_scifi3_N703.expression.csv"))
# tmp <- input_file[sample(nrow(input_file), 2000), ]
# write.csv(tmp,file.path(tmp_dir, "test.csv"), row.names = FALSE)

# Issues
## In get_cellBarcodes
## To get the barcode, the last column is split into several new columns.
## But the method is too spcific, should be improved.
# Libraries
library(EnsDb.Hsapiens.v86)
library(Seurat)
library(patchwork)
library(Matrix)
library(dplyr)
library(tidyr)
library(data.table)

# variable
exp1_name <- "scifi#40532_Day1_Musa_scifi3_N703"
exp2_name <- "scifi#40533_Day1_Musa_scifi2_N702"

# path
wd <- dirname(rstudioapi::getSourceEditorContext()$path)
input <- file.path(wd,"joined")
output <- file.path(wd,"preprocessed")
exp1_output <- file.path(output,"scifi#40532_Day1_Musa_scifi3_N703")
exp2_output <- file.path(output,"scifi#40533_Day1_Musa_scifi2_N702")
dir.create(exp1_output,recursive = TRUE)
dir.create(exp2_output,recursive = TRUE)

# Set gene symbol db
hs_db <- EnsDb.Hsapiens.v86

# Functions

# Assign new barcodes
get_cellBarcodes <- function(df,colName) {
  x <- df %>%
    tidyr::separate(colName, c("exp_code1","Day","Musa","scifi3","exp_code2","well"),sep="_")
  x$cellbarcode <- paste(x$r2,x$exp_code1,x$expcode2,x$well,sep="_")
  return(x)
}

# Assign gene symbols
# Use keytypes(db) to check keytypes
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

# Assign numbers to NA in a data frame
## Very slow
get_ridNA <- function(df,num) {
  x <- df
  x[is.na(x)] <- num
  return(x)
}

## Fast method
## Credit: https://stackoverflow.com/questions/7235657/fastest-way-to-replace-nas-in-a-large-data-table
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

# Get matrix
get_matrix <- function(df,firstCol) {
  x <- as.matrix(df[,-1])
  rownames(x) <- df$symbol
  return(x)
}

# Save to 10X object
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


# input files
list.files(input)

# read input
exp1 <- read.csv(file.path(input,"scifi#40532_Day1_Musa_scifi3_N703.expression.csv"))
exp2 <- read.csv(file.path(input,"scifi#40533_Day1_Musa_scifi2_N702.expression.csv"))

colnames(exp1) <- c("r2","gene","umi","sample_name")
colnames(exp2) <- c("r2","gene","umi","sample_name")

exp1 <- get_cellBarcodes(exp1,"sample_name")
exp2 <- get_cellBarcodes(exp2,"sample_name")

# converse ensembl to gene symbol
## this step removes those unmapped gene too
exp1.genesym <- get_GeneSymbol(exp1)
exp2.genesym <- get_GeneSymbol(exp2)

# collapse cell barcode and gene symbol if needed
exp1.summarized <- aggregate(umi~cellbarcode+symbol, exp1.genesym, sum)
exp2.summarized <- aggregate(umi~cellbarcode+symbol, exp2.genesym, sum)

# create count matrix
exp1.df <- exp1.summarized %>%
  tidyr::pivot_wider(names_from = cellbarcode, values_from = umi)

exp2.df <- exp2.summarized %>%
  tidyr::pivot_wider(names_from = cellbarcode, values_from = umi)

# Assign 0 to NA
exp1.df0 <- get_ridNA_dowle3(exp1.df,0)
exp2.df0 <- get_ridNA_dowle3(exp2.df,0)

# save count matrix
saveRDS(exp1.df0,file.path(wd,"preprocessed",paste0("scifi#40532_Day1_Musa_scifi3_N703",".rds")))
saveRDS(exp2.df0,file.path(wd,"preprocessed",paste0("scifi#40533_Day1_Musa_scifi2_N702",".rds")))

# Get matrix
exp1.mtx <- get_matrix(exp1.df,symbol)
exp2.mtx <- get_matrix(exp2.df,symbol)

# Save to 10X objects
get_10X(exp1.mtx, file.path(exp1_output), "scifi#40532_Day1_Musa_scifi3_N703.expression")
get_10X(exp2.mtx, file.path(exp2_output), "scifi#40533_Day1_Musa_scifi2_N702.expression")
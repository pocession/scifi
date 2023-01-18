#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  print("There is only one argument. App automatically takes this argument as the input file.")
  args[2] = "out.txt"
}
print(args)
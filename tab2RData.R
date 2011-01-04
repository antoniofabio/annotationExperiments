#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
cargs <- length(args)

if(cargs < 2 || cargs > 3) {
  message("converts a tab-delimited file into an R dataframe.

usage:
 ./tab2RData.R fileName.tab fileName.RData objName[default: D]
")
  quit("no", status=1)
}

tabFileName <- args[1]
rdataFileName <- args[2]
if(cargs < 3) {
  objName <- "D"
} else {
  objName <- args[3]
}

d <- read.delim(tabFileName, header=TRUE, as.is=TRUE, quote="'")
assign(objName, d)
save(list=objName, file=rdataFileName)

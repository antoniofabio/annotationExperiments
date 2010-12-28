#! /usr/bin/env Rscript

fileNames <- commandArgs(trailingOnly=TRUE)
rfaFile <- fileNames[1]
faFile <- fileNames[2]
pslFile <- gsub("^(.*)\\.fa$", "\\1.psl", faFile)

cmd <- sprintf("blat -noHead -minIdentity=100 -stepSize=7 %s %s %s",
               shQuote(rfaFile), shQuote(faFile), shQuote(pslFile))
message('executing shell command:')
message(shQuote(cmd))
system(cmd)

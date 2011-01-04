#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

usage <- function() {
  message("Reads a '.psl' blat output file (with no header section) into an R dataframe
with readable variable names, and saves it into an RData file

usage:
./psl2RData.R fileName.psl fileName.RData

 fileName.psl: name of the input file, in '.psl' blat format
 fileName.RData: name of the RData output file (default: 'fileName.psl.RData')

= Details =
Query sequence names are assumed to be in the 'probesetName|probeName' format,
while target sequence names are assumed to be in the 'SequenceID|GeneID' format.
Starting from this assumption, an attempt is made to extract 'probesetName' and
'GeneID' directly.

A new variable 'score' is computed, equal to the number of matches divided by the
query sequence size.
")
}

cargs <- length(args)
if(cargs < 1 || cargs > 2) {
  message("wrong number of arguments (", cargs, ")\n")
  usage()
  quit(save="no", status=1)
}

pslFile <- args[1]
if(cargs < 2) {
  pslFile.RData <- paste(pslFile, ".RData", sep="")
} else {
  pslFile.RData <- args[2]
}

## matches int unsigned ,       # Number of bases that match that aren't repeats
## misMatches int unsigned ,    # Number of bases that don't match
## repMatches int unsigned ,     # Number of bases that match but are part of repeats
## nCount int unsigned ,           # Number of 'N' bases
## qNumInsert int unsigned ,     # Number of inserts in query
## qBaseInsert int unsigned ,     # Number of bases inserted in query
## tNumInsert int unsigned ,      # Number of inserts in target
## tBaseInsert int unsigned ,      # Number of bases inserted in target
## strand char(2) ,                # + or - for query strand, optionally followed by + or – for target strand
## qName varchar(255) ,           # Query sequence name
## qSize int unsigned ,            # Query sequence size
## qStart int unsigned ,         # Alignment start position in query
## qEnd int unsigned ,             # Alignment end position in query
## tName varchar(255) ,           # Target sequence name
## tSize int unsigned ,            # Target sequence size
## tStart int unsigned ,           # Alignment start position in target
## tEnd int unsigned ,             # Alignment end position in target
## blockCount int unsigned ,    # Number of blocks in alignment
## blockSizes longblob ,        # Size of each block in a comma separated list
## qStarts longblob ,      # Start of each block in query in a comma separated list
## tStarts longblob ,      # Start of each block in target in a comma separated list

colNames <- c("matches", "misMatches", "repMatches", "nCount",
              "qNumInsert", "qBaseInsert",
              "tNumInsert", "tBaseInsert",
              "strand",
              "qName", "qSize", "qStart", "qEnd",
              "tName", "tSize", "tStart", "tEnd",
              "blockCount", "blockSizes",
              "qStarts", "tStarts")
colClasses <- structure(rep("NULL", length(colNames)), names=colNames)
colClasses[c('qName', 'tName')] <- "character"
colClasses['strand'] <- "factor"
colClasses[c('matches', 'qSize', 'tSize')] <- "integer"

psl <- read.delim(pslFile, header=FALSE, colClasses=colClasses,
                  col.names=colNames)

psl <- within(psl, {
  probeset <- gsub("^(.*)\\|.*$", "\\1", qName)
  probe <- gsub("^.*\\|(.*)$", "\\1", qName)
  geneID <- gsub("^.*\\|(.*)$", "\\1", tName)
  refSeq <- gsub("^(.*)\\|.*$", "\\1", tName)
  score <- matches / qSize
})

save(psl, file=pslFile.RData)

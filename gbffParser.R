#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
cargs <- length(args)

if(cargs != 1) {
  message("parses relevant infos from a (eventually compressed) refseq '.gbff' file,
and stores it into a tab-delimited file

usage:
 ./gbff2RData.R fileName.gbff > fileName.tab
")
  quit("no", status=1)
}

dbFileName <- args[1]

con <- gzfile(dbFileName, "r")
line <- NA_character_
lineNum <- 0
lastAccession <- NA_character_
getLine <- function() {
  line <<- readLines(con, n=1, warn=FALSE)
  lineNum <<- lineNum + 1
}

head <- function() gsub("^(.*?) +.*$", "\\1", line)
tail <- function() {
  if(head() == "") {
    gsub("^ +(.*)$", "\\1", line)
  } else {
    gsub("^\\w+? +(.*)$", "\\1", line)
  }
}
indentation <- function() nchar(gsub("^( *?).*?$", "\\1", line))
getHead <- function(name, indentation) {
  while(head() != name && length(line) > 0 && line != "//") { ## eventually skip interveening fields
    block(indentation)
  }
}

block <- function(currentIndentation) {
  ans <- tail()
  repeat {
    getLine()
    if(indentation() <= currentIndentation) {
      break
    }
    ans <- c(ans, tail())
  }
  return(ans)
}
sanitize <- function(x) gsub("\t", " ", x)
field <- function(name) {
  currentIndentation <- indentation()
  getHead(name, currentIndentation)
  ans <- sanitize(paste(block(currentIndentation), collapse=" "))
  return(ans)
}

origin <- function() {
  getHead("ORIGIN", 0)
  getLine()
  ans <- character(0)
  while(line != "//") {
    ans <- c(ans, line)
    getLine()
  }
  ans <- gsub("^ *[0-9]+(.*)$", "\\1", ans)
  ans <- toupper(paste(gsub(" ", "", ans), collapse=""))
  getLine()
  return(ans)
}

dump <- function(x) cat(x, "\t", sep="")

feat.parse <- function() {
  ll <- tail()
  if(!grepl("^/", ll)) {
    getLine()
    return(character(0))
  }
  name <- gsub("^/(.*?)=\".*$", "\\1", ll)
  value <- gsub("^/.*?=\"(.*?)\"?$", "\\1", ll)
  if(name == "db_xref") {
    name <- gsub("^(.+?):.*$", "\\1", value)
    value <- gsub("^.+?:(.*)$", "\\1", value)
  }
  ans <- structure(value, names=name)
  getLine()
  return(ans)
}

features <- function() {
  getHead("FEATURES", 0)
  getLine() ## source
  getLine()
  record <- character(0)
  while(indentation() > 0) {
    record <- c(record, feat.parse())
  }
  record <- record[c('organism', 'mol_type', 'chromosome', 'map', 'gene',
                     'gene_synonym', 'note', 'GeneID')]
  cat(record, sep="\t")
  while(indentation() > 0) {
    getLine()
  }
}

entry <- function() {
  dump(field("LOCUS"))
  dump(field("DEFINITION"))
  accession <- field("ACCESSION")
  lastAccession <<- accession
  dump(accession)
  dump(field("VERSION"))
  dump(field("KEYWORDS"))
  dump(field("SOURCE"))
  ## while(head() == "REFERENCE") {
  ##   field("REFERENCE")
  ## }
  dump(field("COMMENT"))
  features()
  origin()
  cat("\n")
}

cat("LOCUS\tDEFINITION\tACCESSION\tVERSION\tKEYWORDS\tSOURCE\tCOMMENT\torganism\tmol_type\tchromosome\tmap\tsymbol\tsynonym\tnote\tGeneID\n")
getLine()
while(length(line) > 0) {
  entry()
}

close(con)

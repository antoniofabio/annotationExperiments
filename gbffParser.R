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

feat.slash <- function() {
  ll <- tail()
  ans <- gsub("/.+=\"(.*)\"$", "\\1", ll)
  getLine()
  return(ans)
}

features <- function() {
  getHead("FEATURES", 0)
  getLine() ## source
  getLine()
  dump(feat.slash()) ## organism
  dump(feat.slash()) ## mol_type
  feat.slash()       ## db_xref
  dump(feat.slash()) ## chromosome
  dump(feat.slash()) ## map
  getLine()          ## gene
  dump(feat.slash()) ## symbol
  dump(feat.slash()) ## synonym
  dump(feat.slash()) ## note
  cat(gsub("^GeneID:(.*)$", "\\1", feat.slash())) ## GeneID
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

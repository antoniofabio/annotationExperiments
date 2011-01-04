#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
cargs <- length(args)

if(cargs != 1) {
  message("parses relevant infos from a refseq '.gbff' file,
and stores it into a tab-delimited file

usage:
 ./gbff2RData.R fileName.gbff > fileName.tab
")
  quit("no", status=1)
}

dbFileName <- args[1]

con <- file(dbFileName, "r")
line <- NA_character_
getLine <- function() {
  line <<- readLines(con, n=1, warn=FALSE)
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
expectHead <- function(what) stopifnot(head() == what)

fieldOneLine <- function(name) {
  expectHead(name)
  ans <- shQuote(tail())
  getLine()
  return(ans)
}
fieldMultipleLines <- function(name) {
  expectHead(name)
  currentIndentation <- indentation()
  ans <- tail()
  repeat {
    getLine()
    if(indentation() <= currentIndentation) {
      break
    }
    ans <- c(ans, tail())
  }
  ans <- shQuote(paste(ans, collapse=" "))
  return(ans)
}
origin <- function() {
  expectHead("ORIGIN")
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
entry <- function() {
  dump(fieldOneLine("LOCUS"))
  dump(fieldOneLine("DEFINITION"))
  dump(fieldOneLine("ACCESSION"))
  dump(fieldOneLine("VERSION"))
  dump(fieldOneLine("KEYWORDS"))
  dump(fieldMultipleLines("SOURCE"))
  while(head() == "REFERENCE") {
    fieldMultipleLines("REFERENCE")
  }
  dump(fieldMultipleLines("COMMENT"))
  fieldMultipleLines("FEATURES") ## just discard the 'features' for now
  cat(origin(), "\n", sep="")
}

cat("LOCUS\tDEFINITION\tACCESSION\tVERSION\tKEYWORDS\tSOURCE\tCOMMENT\tORIGIN\n")
getLine()
while(length(line) > 0) {
  entry()
}

close(con)

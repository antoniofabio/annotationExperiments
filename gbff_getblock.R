#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
dbFileName <- args[1]
refSeqID <- args[2]

con <- file(dbFileName, "r")

eatBlock <- function(con) {
  ans <- character(0)
  while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
    if(line == "//") {
      break
    }
    ans <- c(ans, line)
  }
  return(ans)
}

EOF <- function(con) {
  if(length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
    pushBack(line, con)
    return(FALSE)
  } else {
    return(TRUE)
  }
}

while(!EOF(con)) {
  block <- eatBlock(con)
  block.id <- grep("^VERSION", block, value=TRUE)
  block.id <- strsplit(block.id, " +")[[1]][2]
  if(block.id == refSeqID) {
    writeLines(block)
    close(con)
    quit("no", status=0)
  }
}
message("entry not found")

close(con)

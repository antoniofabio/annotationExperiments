#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
con <- file(args[1], "r")

status <- 0
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  if (status == 0) { ## looking for RefSeq identifier
    if(grepl("^VERSION", line)) {
      status <- 1
      cat(">", strsplit(line, " +")[[1]][2], "|", sep="")
      next
    }
  } else if (status == 1) { ## looking for GeneID
    expr <- ".*/db_xref=\"GeneID:([0-9]+)\""
    if(grepl(expr, line)) {
      cat(gsub(expr, "\\1", line), "\n", sep="")
      status <- 2
      next
    }
  } else if (status == 2) { ## looking for sequence
    if(grepl("^ORIGIN", line)) {
      status <- 3
      next
    }
  } else if (status == 3) {
    if(line == "//") {
      cat("\n")
      status <- 0
      next
    }
    line <- gsub(" ", "", line)
    cat(toupper(gsub("^[0-9]+(.*)", "\\1", line)))
  }
}

close(con)

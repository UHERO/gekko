#!/usr/bin/env Rscript --vanilla
# put the script in the directory with the .tsd files
# run in R: system(paste("Rscript replace_strings.R", "_m.tsd", "@"))
# or on the command line: Rscript replace_strings.R "_m.tsd" "@"

# two arguments: file pattern to search for and string pattern to replace
args = commandArgs(trailingOnly=TRUE)
file_pattern <- args[1]
string_pattern <- args[2]

# # alternatively set the argument values directly in the script
# # and run with set arguments in R: source("replace_strings.R") 
# file_pattern <- "_m.tsd"
# string_pattern <- "@" # @ or _

# directory in which the .tsd files (and this script) reside
file.dir <- "." # imperfect solutions: getSrcDirectory(function(x) {x}) or dirname(sys.frame(1)$ofile)
# local directory with files you want to work with
setwd(file.dir)
cat("relative path:", file.dir, "\n")

#' Replace multiple strings across multiple files with original values and replacement values.
#' https://gist.github.com/mattjbayly/9c56ec80ae291ff00589ffa3440806a1
#' 
#' files - A character string of file names to work through.
#' f - A character string of original values that you want to replace.
#' r - A character string of replacement values (f->r).
multi_replace <- function(files="", f="", r=""){
  file_line = data.frame() # (optional) tracking table
  #loop through each file separately
  for(j in 1:length(files)){
    nl <- suppressWarnings(readLines(files[j])) # read file line by line
    # loop through each of the find and replace values within each file
    for(i in 1:length(f)){
      cnt_replaced <- data.frame(filename = files[j], find = f[i], replace = r[i], times = length(grep(f[i], nl))) # fill tracking table with values
      file_line <- rbind(file_line, cnt_replaced) # populate tracking table count of find & replace within each file
      nl <- gsub(f[i], r[i], nl) # find and replace value line by line
    }
    write(nl, file = files[j]) # save files with same name & overwrite old
    rm(nl) # don't overwrite with previous file if error.
  }
  return(file_line) # print the tracking table
}

### EXAMPLE ###
# get a list of files based on a pattern of interest e.g. .tsd, .txt 
filer = list.files(pattern=file_pattern)
# direction of replacement (@ -> _ or _ -> @)
if (string_pattern == "@") { # from @ to _
  # f - list of original string values you want to change
  f <- c("@")
  # r - list of values to replace the above values with
  # make sure the indexing of f & r
  r <- c("_")
} else { # from @ to _
  # f - list of original string values you want to change
  f <- c("GDPPC_R_US_SOLA", "GDPPC_R_JP_SOLA", "GDPPC_R_US_SOLQ", "GDPPC_R_JP_SOLQ", paste0("_", c("US_SOLA", "JP_SOLA", "US_SOLQ", "JP_SOLQ", "US", "JP")))
  # r - list of values to replace the above values with
  # make sure the indexing of f & r
  r <- c("GDPPC_R_US      REAL PER CAPITA GDP, U.S.", "GDPPC_R_JP      REAL PER CAPITA GDP, JAPAN", "GDPPC_R_US      REAL PER CAPITA GDP, U.S.", "GDPPC_R_JP      REAL PER CAPITA GDP, JAPAN", paste0("@", c("US     ", "JP     ", "US     ", "JP     ", "US", "JP")))
}

# Run the function and watch all your changes take place ;)
tracking_sheet <- multi_replace(filer, f, r)
print(tracking_sheet)

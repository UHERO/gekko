#!/usr/bin/env Rscript --vanilla
# put the script in the directory with the AREMOS equation file
# run in R: system(paste("Rscript model_parsing.R", "AREQ.txt", "GEKEQ.txt"))
# or on the command line: Rscript model_parsing.R "AREQ.txt", "GEKEQ.txt"

# two arguments: AREMOS equations (input) and GEKKO equations (output)
args = commandArgs(trailingOnly=TRUE)
argsLen <- length(args)
if (argsLen > 2) stop("error: too many arguments.")
if (argsLen < 1) stop("error: missing infile.")
infile <- args[1]
outfile <- if (argsLen < 2) paste0("GEKKO_", infile) else args[2]

# # alternatively set the argument values directly in the script
# # and run with set arguments in R: source("model_parsing.R") 
infile <- "in.txt"
outfile <- "out.txt"
estfile <- "est.txt"
esteqfile <- "esteq.txt"
stochfile <- "stoch.txt"
idfile <- "id.txt"
modfile <- "mod.txt"

# directory in which the .tsd files (and this script) reside
file.dir <- "." # imperfect solutions: getSrcDirectory(function(x) {x}) or dirname(sys.frame(1)$ofile)
# local directory with files you want to work with
setwd(file.dir)
cat("relative path:", file.dir, "\n")

# read file line by line
lines_in <- suppressWarnings(readLines(infile))

# eliminate lines containig the following strings
lines_in <- lines_in[!grepl("(QUARTERLY)", lines_in)]
lines_in <- lines_in[!grepl("(Date)", lines_in)]
lines_in <- lines_in[!grepl("(Sum Sq)", lines_in)]
lines_in <- lines_in[!grepl("(R Sq)", lines_in)]
lines_in <- lines_in[!grepl("(D.W.)", lines_in)]
lines_in <- lines_in[!grepl("(H[[:blank:]]+[[:digit:].-]+)", lines_in)]
lines_in <- lines_in[!grepl("(\\?\\?)", lines_in)]
lines_in <- lines_in[!grepl("(\\([[:digit:].]+\\))", lines_in)]
lines_in <- lines_in[!grepl("(\\([[:blank:]NC]+\\))", lines_in)]

# pull all lines belonging to a single equation to a single line
row_i <- 1
eq_i <- 0
eq_all <- vector(mode = "character")
while (row_i <= length(lines_in)) {
  eq_i <- eq_i + 1
  eq_all[eq_i] <- lines_in[row_i]
  row_i <- row_i + 1
  while (!grepl("(QEQ).+", lines_in[row_i])) {
    eq_all[eq_i] <- paste(eq_all[eq_i], lines_in[row_i])
    row_i <- row_i + 1
    if (row_i > length(lines_in)) break
  }
}

# add formula code for identities and estimated equations fix some miscategorization
eq_all_stochastic <- grep("(Identity)", eq_all, invert = TRUE)
# eq_all[eq_all_stochastic]
write(eq_all[eq_all_stochastic], file = stochfile)
eq_all_identity <- grep("(Identity)", eq_all)
# eq_all[eq_all_identity]
write(eq_all[eq_all_identity], file = idfile)
eq_all <- gsub("[[:blank:]]*(QEQ).+(Squares)", "FRML _SJ_D ", eq_all)
eq_all <- gsub("[[:blank:]]*(QEQ).+(\\(imposed\\))", "FRML _IJ_D ", eq_all)
eq_all <- gsub("[[:blank:]]*(QEQ).+(\\(Identity\\))", "FRML _IJ_D ", eq_all)
eq_all <- gsub("(FRML _SJ_D)([[:blank:]]+ys_r@hi)", "FRML _IJ_D\\2", eq_all)
eq_all <- gsub("(FRML _SJ_D)([[:blank:]]+eag@hi)", "FRML _IJ_D\\2", eq_all)
eq_all <- gsub("(FRML _SJ_D)([[:blank:]]+eag@hon)", "FRML _IJ_D\\2", eq_all)

# fix syntax
eq_all <- gsub("$", ";", eq_all) # add semicolon to end of line
eq_all <- gsub("@", "_", eq_all) # replace @ with _
eq_all <- gsub("[[:blank:]]+", " ", eq_all) # eliminate extra blank space
eq_all <- gsub("/[[:blank:]]+", "/", eq_all) # eliminate blank space in fractions
eq_all <- gsub("ocup%", "ocupp", eq_all) # replace % in ocup%
eq_all <- gsub("=[[:blank:]]*\\+", "=", eq_all) # remove + after the = sign
eq_all <- gsub("dlog\\(4,", "dlogy(", eq_all) # replace dlog(4) with dlogy
eq_all <- gsub("diff\\(4,", "diffy(", eq_all) # replace diff(4) with diffy
eq_all <- gsub("(_[[:alpha:]]+)(\\.)([[:digit:]]{1})", "\\1\\[-\\3\\]", eq_all) # replace dot notation for lags with lags in square brackets
eq_all <- gsub("\\(([_[:alpha:]]+)(\\+|\\*|/)([_[:alpha:]]+)\\)(\\[-[[:digit:]]\\])", "\\(\\1\\4\\2\\3\\4\\)", eq_all) # distribute lags to two function arguments
eq_all <- gsub("\\(([_[:alpha:]]+)(\\+|\\*|/)([_[:alpha:]]+)(\\*|/)([_[:alpha:]]+)\\)(\\[-[[:digit:]]\\])", "\\(\\1\\6\\2\\3\\6\\4\\5\\6\\)", eq_all) # distribute lags to three function arguments
eq_all <- gsub("(\\){2})(\\[-[[:digit:]]\\])", "\\2\\1", eq_all) # move lags to arguments inside nested functions
eq_all <- gsub("\\(([_[:alpha:]]+)\\)(\\[-[[:digit:]]\\])", "\\(\\1\\2\\)", eq_all) # move lags to function arguments

# fix some specific issues
eq_all <- gsub("FRML _IJ_D viscrair_hi/vis_hi = 0.0550000 AR_0 = 0.9000000 * AR_1 ;", "FRML _SJ_D viscrair_hi/vis_hi = viscrair_hi[-1]/vis_hi[-1] -0.0003808023 + 0.0096218377 * dum_021 + 0.0093058315 * dum_051 + 0.0080655935 * dum_061 + 0.0065136970 * dum_071 - 0.0260728516 * dum_081 ;", eq_all, fixed = TRUE)
eq_all <- gsub("QEQ:VLOSCRAIR_HI.EQ Cochrane-Orcutt vloscrair_hi = 5.8008883 AR_0 = 0.8859439 * AR_1 ;", "FRML _SJ_D vloscrair_hi = 0.9828369 * vloscrair_hi[-1] + 1.1068284 + 0.6750869 * dum_041 + 0.5182475 * dum_081 - 0.9773999 * dum_082 - 0.5169660 * dum_121 ;", eq_all, fixed = TRUE)
eq_all <- gsub("diff(rilgfcy10_us)[-3]", "diff(rilgfcy10_us[-3])", eq_all, fixed = TRUE)
eq_all <- gsub("dlog(vis_hi[-1])[-2]", "dlog(vis_hi[-3])", eq_all, fixed = TRUE)
eq_all <- gsub("(ocupp_hon-82)[-1]", "(ocupp_hon[-1]-82)", eq_all, fixed = TRUE)
eq_all <- gsub("ocupp_hi-70", "(ocupp_hi-70)", eq_all, fixed = TRUE)
eq_all <- gsub("ocupp_hon-75", "(ocupp_hon-75)", eq_all, fixed = TRUE)
# eq_all <- gsub("(dum_[[:digit:]]+)(+|-)(dum_[[:digit:]]+)", "\\1 \\+ \\3", eq_all) # separate these dummies
eq_all <- gsub("(dum_[[:digit:]]+)(\\+|-)(dum_[[:digit:]]+)", "\\(\\1\\2\\3\\)", eq_all) # parenthesize these dummies

# # restate complex "dependent" variables as implicit functions
# eq_all <- gsub("(log|dlog)?\\(?([[:alpha:]_]+)/([[:alpha:]_]+)\\)?[[:blank:]]*=([^;]+)", "\\2 = \\2 - \\(\\1\\(\\2/\\3\\) - \\(\\4\\)\\)", eq_all)

# save file
write(eq_all, file = outfile)

# save identities separately (to be recombined with estimated equations below)
eq_id <- eq_all[grepl("(FRML _IJ_D)", eq_all)]

# save file
write(eq_id, file = idfile)

# # prepare equations for OLS estimation in GEKKO
# eq_est <- eq_all[grepl("(FRML _SJ_D)", eq_all)] # focus on stochastic equations
# eq_est <- gsub("=[-|+[:digit:][:blank:].]+\\*", "=", eq_est) # remove coefficient after =
# eq_est <- gsub(" [-|+[:digit:][:blank:].]+\\*", ",", eq_est) # remove coefficient and separate terms with +
# eq_est <- gsub(" [-|+[:digit:][:blank:].]+;", " ;", eq_est) # finish line with ;
# eq_est <- gsub("FRML _SJ_D", "OLS <DUMP=%EQ_DUMP DUMPOPTIONS='APPEND'>", eq_est,) # check NA in sample for estimation

# prepare equations for OLS estimation in R
eq_est_R <- eq_est <- eq_all[grepl("(FRML _SJ_D)", eq_all)] # festimated equations
eq_est_R <- gsub("=", "~", eq_est_R) # replace = with ~
eq_est_R <- gsub("~[-|+[:digit:][:blank:].]+\\*", "~", eq_est_R) # remove coefficient after ~
eq_est_R <- gsub(" [-|+[:digit:][:blank:].]+\\*", " +", eq_est_R) # remove coefficient and separate terms with +
eq_est_R <- gsub(" [-|+[:digit:][:blank:].]+;", " ;", eq_est_R) # finish line with ;
eq_est_R <- gsub("(ocupp_hon[-1]-82)", "(ocupp_hon[-1])", eq_est_R, fixed = TRUE) # the constant captures the level shift
eq_est_R <- gsub("(ocupp_hi-70)", "(ocupp_hi)", eq_est_R, fixed = TRUE) # the constant captures the level shift
eq_est_R <- gsub("(ocupp_hon-75)", "(ocupp_hon)", eq_est_R, fixed = TRUE) # the constant captures the level shift
eq_est_R <- gsub("SEASON", "season", eq_est_R, fixed = TRUE) # equations in lower case
eq_est_R <- gsub("([_[:alnum:]]+)\\[-([[:digit:]])\\]", "L\\(\\1,\\2\\)", eq_est_R) # use L() for lags in R
eq_est_R <- gsub("dlog\\(([()*/_,[:alnum:]]+)\\)", "d\\(log\\(\\1\\)\\)", eq_est_R) # break up dlog into d and log
eq_est_R <- gsub("dlogy\\(([()*/_,[:alnum:]]+)\\)", "d\\(log\\(\\1\\),4\\)", eq_est_R) # break up dlogy into d(,4) and log
eq_est_R <- gsub("diffy\\(([()*/_,[:alnum:]]+)\\)", "d\\(\\1,4\\)", eq_est_R) # use d(,4) for diffy
eq_est_R <- gsub("diff\\(", "d\\(", eq_est_R) # use d() for diff
eq_est_R <- gsub(" (L?\\(?[,_[:alnum:]]+\\)?/L?\\(?[,_[:alnum:]]+\\)?) ", " I\\(\\1\\) ", eq_est_R) # avoid the breakup of ratios into individual terms
eq_est_R <- gsub("\\((dum_[[:digit:]]+)(\\+|-)(dum_[[:digit:]]+)\\)", "I\\(\\1\\2\\3\\)", eq_est_R) # avoid the breakup of these dummies
eq_est_R <- gsub("FRML _SJ_D", "", eq_est_R) # extract the formula
eq_est_R <- gsub(" ;", "", eq_est_R) # extract the formula
# eq_est_R <- gsub("FRML _SJ_D", "dynlm(", eq_est_R) # use dynlm to estimate model
# eq_est_R <- gsub(" ;", ", data = data_ts);", eq_est_R) # use the data for estimation

# save file
write(eq_est_R, file = estfile)

# load some packages before estimating the model
library(tidyverse)
library(broom)
library(readxl)
library(tsbox)
library(dynlm)

# load data for estimation
data_ts <- read_excel("QMOD_DAT.XLSX") %>% rename(time = ...1) %>% rename_all(tolower) %>% ts_long() %>% ts_ts()
data_ts %>% ts_summary()

# estimate each equation and collect the results
eq_est_R_res <- character()
for (eq_i in seq_along(eq_est_R)){ # eq_i <- 5
  est_res <- dynlm(as.formula(eq_est_R[eq_i]), data = data_ts)
  coef_res <- tidy(est_res)
  eq_est_R_res[eq_i] <- paste(as.formula(eq_est_R[eq_i])[2], " = ")
  for (term_i in seq_along(coef_res$term)){
    eq_est_R_res[eq_i] <- paste(eq_est_R_res[eq_i], " + ", coef_res$estimate[term_i], " * ", coef_res$term[term_i])
  }
}

# save file
write(eq_est_R_res, file = esteqfile)

# avoid breaking up the right hand side in some equations
no_brk <- grep(":", eq_est_R_res)
eq_est_R[no_brk] <- gsub("~ ", "~ I(", eq_est_R[no_brk])
eq_est_R[no_brk] <- gsub("$", ")", eq_est_R[no_brk])
# REPEAT ESTIMATION AFTER THIS STEP

# clean up the estimated equations for modeling in gekko
G_mod <- eq_est_R_res 
G_mod <- gsub("[[:blank:]]+", " ", G_mod) # eliminate extra blank space
G_mod <- gsub("=[[:blank:]]*\\+", "=", G_mod) # eliminate + after =
G_mod <- gsub("\\+[[:blank:]]*-", "- ", G_mod) # combine + and -
G_mod <- gsub(" \\* \\(Intercept\\)", "", G_mod) # intercept = 1
G_mod <- gsub("L\\(([_[:alnum:]]+), ([[:digit:]]+)\\)", "\\1[-\\2]", G_mod) # lag notation
G_mod <- gsub("d\\(log\\(([[:alnum:][:punct:]]+)\\), 4\\)", "dlogy\\(\\1\\)", G_mod) # dlogy
G_mod <- gsub("d\\(log\\(([[:alnum:][:punct:]]+)\\)\\)", "dlog\\(\\1\\)", G_mod) # dlog
G_mod <- gsub("d\\(log\\(([[:alnum:][:punct:]]+) \\* ([[:alnum:][:punct:]]+)\\)\\)", "dlog\\(\\1\\*\\2\\)", G_mod) # dlog with *
G_mod <- gsub("d\\(([[:alnum:][:punct:]]+), 4\\)", "diffy\\(\\1\\)", G_mod) # diffy
G_mod <- gsub("d\\(([[:alnum:][:punct:]]+)\\)", "diff\\(\\1\\)", G_mod) # diff
G_mod <- gsub("I\\(", "\\(", G_mod) # no need for I in Gekko

# restate complex "dependent" variables as implicit functions
G_mod <- gsub("(log|dlog)?\\(?([[:alpha:]_]+)/([[:alpha:]_]+)\\)?[[:blank:]]*=([^;]+)", "\\2 = \\2 - \\(\\1\\(\\2/\\3\\) - \\(\\4\\)\\)", G_mod)

# add syntax
G_mod <- gsub("^", "FRML _SJ_D ", G_mod) # add formula designation
G_mod <- gsub("$", " ;", G_mod) # add ; to end of line

# combine with identities
G_mod <- c(G_mod, eq_id)
  
# save file
write(G_mod, file = modfile)

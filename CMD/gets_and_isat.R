# gets: General-to-Specific Modeling and Indicator Saturation
# https://cran.r-project.org/web/packages/gets/gets.pdf
# https://cran.r-project.org/web/packages/gets/index.html
# https://www.jstatsoft.org/article/view/v086i03
# https://user2015.math.aau.dk/presentations/124.pdf

library(tidyverse)
library(readxl)
library(gets)

QMOD_DAT <- read_excel("QMOD_DAT.XLSX") %>% rename(time = "...1") %>% mutate(time = as.Date(time))
# add lags to the dataset
# QMOD_DAT_1 <- QMOD_DAT %>% select(!starts_with("dum")) %>% ts_long() %>% ts_lag(1) %>% ts_wide() %>% rename_at(vars(-time), str_c, "_1")
# QMOD_DAT_2 <- QMOD_DAT %>% select(!starts_with("dum")) %>% ts_long() %>% ts_lag(2) %>% ts_wide() %>% rename_at(vars(-time), str_c, "_2")
# QMOD_DAT_3 <- QMOD_DAT %>% select(!starts_with("dum")) %>% ts_long() %>% ts_lag(3) %>% ts_wide() %>% rename_at(vars(-time), str_c, "_3")
# QMOD_DAT_4 <- QMOD_DAT %>% select(!starts_with("dum")) %>% ts_long() %>% ts_lag(4) %>% ts_wide() %>% rename_at(vars(-time), str_c, "_4")
# QMOD_DAT_5 <- QMOD_DAT %>% select(!starts_with("dum")) %>% ts_long() %>% ts_lag(5) %>% ts_wide() %>% rename_at(vars(-time), str_c, "_5")
# QMOD_DAT_6 <- QMOD_DAT %>% select(!starts_with("dum")) %>% ts_long() %>% ts_lag(6) %>% ts_wide() %>% rename_at(vars(-time), str_c, "_6")
# QMOD_DAT_7 <- QMOD_DAT %>% select(!starts_with("dum")) %>% ts_long() %>% ts_lag(7) %>% ts_wide() %>% rename_at(vars(-time), str_c, "_7")
# QMOD_DAT_8 <- QMOD_DAT %>% select(!starts_with("dum")) %>% ts_long() %>% ts_lag(8) %>% ts_wide() %>% rename_at(vars(-time), str_c, "_8")
# QMOD_DAT_WLAGS <- QMOD_DAT %>% left_join(QMOD_DAT_1) %>% left_join(QMOD_DAT_2) %>% left_join(QMOD_DAT_3) %>% left_join(QMOD_DAT_4) %>% left_join(QMOD_DAT_5) %>% left_join(QMOD_DAT_6) %>% left_join(QMOD_DAT_7) %>% left_join(QMOD_DAT_8)

to_analyze <- QMOD_DAT %>% mutate(VISCRAIR_VIS_HI = VISCRAIR_HI/VIS_HI) %>% select(time, VISCRAIR_VIS_HI) %>% drop_na() %>% head(-1)
to_analyze <- QMOD_DAT %>% select(time, VLOSCRAIR_HI) %>% drop_na()
to_analyze %>% pull(time) %>% head(1)
to_analyze_zoo <- zooreg(to_analyze %>% select(-time), frequency = 4, start = c(2001, 1))
model1 <- arx(to_analyze_zoo[, "VISCRAIR_VIS_HI"], mc = TRUE, ar = 1:4, vcov.type = "white")
model2 <- getsm(model1)
test <- isat(to_analyze_zoo[,"VISCRAIR_VIS_HI"], ar=1, sis=TRUE, t.pval =0.01)
test <- isat(to_analyze_zoo[,"VISCRAIR_VIS_HI"], ar=1, sis = FALSE, iis = TRUE, t.pval =0.01)



##SIS using the Nile data in an autoregressive model
#isat(Nile, ar=1:2, sis=TRUE, iis=FALSE, plot=TRUE, t.pval=0.005)
##transform data to log-differences:
#dlogy <- diff(log(y))

##run isat with step impulse saturation on four
##lags and a constant 1 percent significance level:
#isat(dlogy, ar=1:4, sis=TRUE, t.pval =0.01)


data("infldata", package = "gets")

inflData <- zooreg(infldata[, -1], frequency = 4, start = c(1989, 1))

inflMod01 <- arx(inflData[, "infl"], mc = TRUE, ar = 1:4, mxreg = inflData[, 2:4], vcov.type = "white")

inflMod02 <- arx(inflData[, "infl"], mc = TRUE, ar = 1:4, mxreg = inflData[, 2:4], arch = 1:4, vxreg = inflData[, 2:4], vcov.type = "white")

inflMod03 <- getsm(inflMod02)

inflMod04 <- arx(residuals(inflMod03), arch = 1:4, vxreg = inflData[, 2:4])

inflMod05 <- getsv(inflMod04, ar.LjungB = list(lag = 5, pval = 0.025))

inflMod06 <- arx(inflData[, "infl"], mc = TRUE, ar = c(1, 4), arch = 1:2, vxreg = inflData[, 2:4], vcov.type = "white")

newvxreg <- matrix(0, 4, 3)
colnames(newvxreg) <- c("q2dum", "q3dum", "q4dum") 
newvxreg[2, "q2dum"] <- 1
newvxreg[3, "q3dum"] <- 1
newvxreg[4, "q4dum"] <- 1

set.seed(123)
predict(inflMod06, n.ahead = 4, spec = "variance", newvxreg = newvxreg)

eviews(inflMod06)


# Indicator saturation

options(plot = TRUE)
so2 <- data("so2data", package = "gets")
yso2 <- zoo(so2data[, "DLuk_tot_so2"], order.by = so2data[, "year"]) 
(sis <- isat(yso2, t.pval = 0.01))
x1972 <- zoo(sim(so2data[, "year"])[, 26], order.by = so2data[, "year"]) 
isat(yso2, t.pval = 0.01, mxreg = x1972)
sisvar <- isatvar(sis)
iis <- isat(yso2, ar = 1, sis = FALSE, iis = TRUE, t.pval = 0.05) 
isatvar(iis, conscorr = TRUE, effcorr = TRUE)
isatvar(iis,  conscorr = FALSE, effcorr = FALSE)
bcorr <- biascorr(b = sisvar[, "const.path"], b.se = sisvar[, "const.se"], p.alpha = 0.01, T = length(sisvar[, "const.path"]))
isattest(sis, hnull = 0, lr = FALSE, ci.pval = 0.99, plot.turn = TRUE, biascorr = TRUE)


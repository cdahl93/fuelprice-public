###############################################################################

#                      SCRIPT: bbsr_raumtypen_to_db.R                         #

###############################################################################

# DESCRIPTION -------------------------
# This script writes excel data from the BBSR regarding Kreis- and Gemeinde-
# information to the db.

# Script ------------------------------
# Packages
library(tidyverse)
library(DBI)
library(odbc)

# load excel data
bbsr_kreise <- readxl::read_xlsx(path = "data/download-ref-kreistypen-xls.xlsx",
                                 skip = 2, sheet = "Kreise", trim_ws = T,
                                 col_names = T)

bbsr_gemeinden <- readxl::read_xlsx(path = "data/download-ref-kreistypen-xls.xlsx",
                                    skip = 2, sheet = "Gemeinden", trim_ws = T,
                                    col_names = T,
                                    na = c("#NULL!"))

# add leading 0's , format as.character()
bbsr_kreise$krs17 <- str_pad(string = bbsr_kreise$krs17,
                             width = max(nchar(bbsr_kreise$krs17)),
                             pad = "0")
bbsr_kreise$kreg17 <- str_pad(string = bbsr_kreise$kreg17,
                              width = max(nchar(bbsr_kreise$kreg17)),
                              pad = "0")
bbsr_kreise$ROR11 <- str_pad(string = bbsr_kreise$ROR11,
                             width = max(nchar(bbsr_kreise$ROR11)),
                             pad = "0")
bbsr_kreise$amr16 <- str_pad(string = bbsr_kreise$amr16,
                             width = max(nchar(bbsr_kreise$amr16)),
                             pad = "0")
bbsr_kreise$RBZ <- str_pad(string = bbsr_kreise$RBZ,
                           width = max(nchar(bbsr_kreise$RBZ)),
                           pad = "0")
bbsr_kreise$land <- str_pad(string = bbsr_kreise$land,
                            width = max(nchar(bbsr_kreise$land)),
                            pad = "0")

bbsr_gemeinden$gem17 <- str_pad(string = bbsr_gemeinden$gem17,
                                width = max(nchar(bbsr_gemeinden$gem17)),
                                pad = "0")
bbsr_gemeinden$vbgem17 <- str_pad(string = bbsr_gemeinden$vbgem17,
                                  width = max(nchar(bbsr_gemeinden$vbgem17)),
                                  pad = "0")
bbsr_gemeinden$PLZ <- str_pad(string = bbsr_gemeinden$PLZ,
                              width = max(nchar(bbsr_gemeinden$PLZ), na.rm = T),
                              pad = "0")
bbsr_gemeinden$krs17 <- str_pad(string = bbsr_gemeinden$krs17,
                                width = max(nchar(bbsr_gemeinden$krs17)),
                                pad = "0")
bbsr_gemeinden$ROR11 <- str_pad(string = bbsr_gemeinden$ROR11,
                                width = max(nchar(bbsr_gemeinden$ROR11)),
                                pad = "0")
bbsr_gemeinden$grenzreg_v1 <- as.character(bbsr_gemeinden$grenzreg_v1)
bbsr_gemeinden$grenzreg_v2 <- as.character(bbsr_gemeinden$grenzreg_v2)
bbsr_gemeinden$land <- str_pad(string = bbsr_gemeinden$land,
                               width = max(nchar(bbsr_gemeinden$land)),
                               pad = "0")

# Connect to db
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")

# Write to db
colnames(bbsr_kreise) <- tolower(colnames(bbsr_kreise))
dbGetQuery(dbcon, "DELETE FROM bbsr_kreise_2017;")
dbWriteTable(dbcon, c("bbsr_kreise_2017"), value = bbsr_kreise, append = T,
             row.names = F)

colnames(bbsr_gemeinden) <- tolower(colnames(bbsr_gemeinden))
dbGetQuery(dbcon, "DELETE FROM bbsr_gemeinden_2017;")
dbWriteTable(dbcon, c("bbsr_gemeinden_2017"), value = bbsr_gemeinden, append = T,
             row.names = F)

# Disconnect db
dbDisconnect(dbcon)

# Clear Working Space
rm(list=ls())

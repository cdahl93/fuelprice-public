# Load zaehlstellen data in db

# Packages
library(DBI)
library(odbc)
library(readr)

# data
zaehlstellen <- read_delim("//192.168.1.10/dbdata/bast/zaehlstellen/zaehlstellen_2018.csv",
                           delim = ";",
                           escape_double = FALSE, 
                           col_types = cols(Jahr = col_integer(),
                                            TK_Nr = col_integer(),
                                            DZ_Nr = col_integer(),
                                            DZ_Name = col_character(),
                                            Land_Nr = col_integer(),
                                            Land_Code = col_character(),
                                            Str_Kl = col_character(),
                                            Str_Nr = col_integer(),
                                            Str_Zus = col_character(),
                                            Erf_Art = col_character(),
                                            Fernziel_Ri1 = col_character(),
                                            Nahziel_Ri1 = col_character(),
                                            Hi_Ri1 = col_character(),
                                            Fernziel_Ri2 = col_character(),
                                            Nahziel_Ri2 = col_character(),
                                            Hi_Ri2 = col_character(),
                                            Anz_Fs_Q = col_integer(),
                                            vT_MobisSo = col_integer(),
                                            DTV_Kfz_MobisSo_Q = col_number(),
                                            DTV_Kfz_MobisSo_Ri1 = col_number(),
                                            DTV_Kfz_MobisSo_Ri2 = col_number(),
                                            DTV_SV_MobisSo_Q = col_number(),
                                            DTV_SV_MobisSo_Ri1 = col_number(),
                                            DTV_SV_MobisSo_Ri2 = col_number(),
                                            pSV_MobisSo_Q = col_number(),
                                            fer = col_number(),
                                            bSo = col_number(),
                                            bFr = col_number(),
                                            Mt = col_number(),
                                            pMt = col_number(),
                                            Mn = col_number(),
                                            pMn = col_number(),
                                            Md = col_number(),
                                            pMd = col_number(),
                                            Me = col_number(),
                                            pMe = col_number(),
                                            DL_Ri1 = col_character(),
                                            DL_Ri2 = col_character(),
                                            pPLZ_MobisSo_Q = col_number(),
                                            pLfw_MobisSo_Q = col_number(),
                                            pMot_MobisSo_Q = col_number(),
                                            pPmA_MobisSo_Q = col_number(),
                                            pLoA_MobisSo_Q = col_number(),
                                            pLzg_MobisSo_Q = col_number(),
                                            pSat_MobisSo_Q = col_number(),
                                            pBus_MobisSo_Q = col_number(),
                                            pSon_MobisSo_Q = col_number(),
                                            Koor_UTM32_E = col_number(),
                                            Koor_UTM32_N = col_number(),
                                            MSV30_Kfz_MobisSo_Ri1 = col_number(),
                                            MSV30_Kfz_MobisSo_Ri2 = col_number(),
                                            bSV30_MobisSo_Ri1 = col_number(),
                                            bSV30_MobisSo_Ri2 = col_number(),
                                            DTV_Kfz_W_MobisFr_Q = col_number(),
                                            DTV_Kfz_W_MobisFr_Ri1 = col_number(),
                                            DTV_Kfz_W_MobisFr_Ri2 = col_number(),
                                            pSV_W_MobisFr_Q = col_number(),
                                            pSV_W_MobisFr_Ri1 = col_number(),
                                            pSV_W_MobisFr_Ri2 = col_number(),
                                            Koor_WGS84_N = col_number(),
                                            Koor_WGS84_E = col_number(),
                                            MSV50_Kfz_MobisSo_Ri1 = col_number(),
                                            MSV50_Kfz_MobisSo_Ri2 = col_number(),
                                            pMSV50_Kfz_MobisSo_Ri1 = col_number(),
                                            pMSV50_Kfz_MobisSo_Ri2 = col_number(),
                                            bSV50_MobisSo_Ri1 = col_number(),
                                            bSV50_MobisSo_Ri2 = col_number(),
                                            bLkwK50_MobisSo_Ri1 = col_number(),
                                            bLkwK50_MobisSo_Ri2 = col_number(),
                                            pMSV50_Kfz_W_MobisFr_Ri1 = col_number(),
                                            pMSV50_Kfz_W_MobisFr_Ri2 = col_number(),
                                            DTV_Kfz_NZB_DiMiDo_Ri1 = col_number(),
                                            DTV_Kfz_NZB_DiMiDo_Ri2 = col_number(),
                                            bSo_Ri1 = col_number(),
                                            bSo_Ri2 = col_number(),
                                            bMo_Ri1 = col_number(),
                                            bMo_Ri2 = col_number(),
                                            bFr_Ri1 = col_number(),
                                            bFr_Ri2 = col_number(),
                                            bSa_Ri1 = col_number(),
                                            bSa_Ri2 = col_number(),
                                            Q_P_t = col_number(),
                                            Q_L1_t = col_number(),
                                            Q_L2_t = col_number(),
                                            Q_K_t = col_number(),
                                            Q_P_n = col_number(),
                                            Q_L1_n = col_number(),
                                            Q_L2_n = col_number(),
                                            Q_K_n = col_number(),
                                            Q_P_a = col_number(),
                                            Q_L1_a = col_number(),
                                            Q_L2_a = col_number(),
                                            Q_K_a = col_number(),
                                            Anmerkungen = col_character(),
                                            X95 = col_skip()), # remove last column which stems from trailing ';'
                           locale = locale(decimal_mark = ",",
                                           grouping_mark = ".",
                                           encoding = "ISO-8859-1"),
                           trim_ws = TRUE)

# Adjust colnames
colnames(zaehlstellen) <- lapply(colnames(zaehlstellen), tolower)

# Connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10)

# Write data to db
dbWriteTable(dbcon, c("zaehlstellen"), value = zaehlstellen, append = T, row.names = F)

# Update geoposition column
dbSendQuery(dbcon, "UPDATE zaehlstellen SET geopos = ST_SetSRID(ST_MakePoint(koor_wgs84_e,koor_wgs84_n),4326);")

# Disconnect db
dbDisconnect(dbcon)

# Clear Working Space
rm(list=ls())

# FIND METHOD FOR CATEGORIZING STATIONS (AUTOBAHN, CITY, COUNTRYSIDE)

# packages
library(DBI)
library(odbc)

# DB connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")

# get stations
stations <- dbGetQuery(dbcon, "SELECT * FROM stations;")


stations <- cbind.data.frame(stations, street_cat = vector("character", length = dim(stations)[1]), stringsAsFactors = F)

# index autohöfe
autohof_ind <- c(grep(pattern = "autohof", x = stations$name, ignore.case = T),
                 grep(pattern = "autohof", x = stations$brand, ignore.case = T),
                 grep(pattern = "autohof", x = stations$street, ignore.case = T),
                 grep(pattern = "autohof", x = stations$house_number, ignore.case = T))
autohof_ind <- sort(unique(autohof_ind)) # remove double entries and sort asc.

# index of autobahn
autobahn_ind <- c(which(stations$street == "A"),
                  grep(pattern = "A[0-9]{1,3}", x = stations$name, ignore.case = T),
                  grep(pattern = "A[0-9]{1,3}", x = stations$street, ignore.case = T),
                  grep(pattern = "A[0-9]{1,3}", x = stations$house_number, ignore.case = T),
                  grep(pattern = "autobahn", x = stations$name, ignore.case = T),
                  grep(pattern = "autobahn", x = stations$brand, ignore.case = T),
                  grep(pattern = "autobahn", x = stations$street, ignore.case = T),
                  grep(pattern = "autobahn", x = stations$house_number, ignore.case = T),
                  grep(pattern = "BAB [0-9]{1,3}", x = stations$name, ignore.case = T),
                  grep(pattern = "BAB [0-9]{1,3}", x = stations$street, ignore.case = T),
                  grep(pattern = "BAB [0-9]{1,3}", x = stations$house_number, ignore.case = T),
                  grep(pattern = "BAB[0-9]{1,3}", x = stations$name, ignore.case = T),
                  grep(pattern = "BAB[0-9]{1,3}", x = stations$street, ignore.case = T),
                  grep(pattern = "BAB[0-9]{1,3}", x = stations$house_number, ignore.case = T),
                  grep(pattern = "BAB[0-9]{1,3}", x = stations$street, ignore.case = T),
                  grep(pattern = "BAT", x = stations$name, ignore.case = F),
                  grep(pattern = "BAT", x = stations$street, ignore.case = F),
                  grep(pattern = "BAT", x = stations$house_number, ignore.case = F))

autobahn_ind <- sort(unique(autobahn_ind)) # remove double entries and sort asc.
autobahn_ind <- setdiff(autobahn_ind, autohof_ind) # remove autohof cases from autobahn index


uuids_autobahn <- stations$uuid[autobahn_ind]
uuids_autohof <- stations$uuid[autohof_ind]

#write.table(uuids_autobahn, file = "data/uuids_autobahn.csv", row.names = F, eol = " OR\n", sep = ",")
#write.table(uuids_autohof, file = "data/uuids_autohof.csv", row.names = F, eol = " OR\n", sep = ",")

# selection works (compared to Jahresbericht MTS-K)




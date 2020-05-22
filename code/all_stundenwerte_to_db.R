# Load stundenwerte data in db

# Packages
library(DBI)
library(odbc)
library(data.table)

# DB Connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10)

# Data
# vector of file paths
pathtofolder <- file.path("//192.168.1.10", "dbdata", "bast", "stundenwerte")
years <- seq(2003,2018)
streettype <- c("A","B")

filepaths <- c()
index <- 1
for(i in 1:length(years)){
  for(j in 1:length(streettype)){
    filepaths[index] <- paste(pathtofolder, "/", years[i], "_", streettype[j], "_s.txt", sep = "")
    index <- index+1
  }
}

# Read data, transform, push to db
for(i in 2:length(filepaths)){
  print(paste("Starting:", filepaths[i]))
  datatodb <- fread(file = filepaths[i], sep = ";", header = T, stringsAsFactors = F,
                    colClasses = c(Strnum = "character",
                                   Datum = "character",
                                   Stunde = "character"))
  print(paste("Loaded:", filepaths[i]))
  
  datatodb <- cbind.data.frame(datatodb[,1:9],
                               time = paste(as.Date(datatodb$Datum, format = "%y%m%d"), " ", datatodb$Stunde, ":00:00", sep = ""),
                               datatodb[,10:dim(datatodb)[2]])
  datatodb$Datum <- as.Date(datatodb$Datum, format = "%y%m%d")
  colnames(datatodb) <- sapply(colnames(datatodb), tolower)
  print(paste("Transformed:", filepaths[i]))
  
  # Write data to db
  dbWriteTable(dbcon, c("stundenwerte"), value = datatodb, append = T, row.names = F)
  print(paste("To DB:", filepaths[i]))
  
  # Clear data
  rm(list="datatodb")
  print(paste("Finished:", filepaths[i]))
}


# Disconnect db
dbDisconnect(dbcon)

# Clear Working Space
rm(list=ls())

# Construct ISOdatetime
#ISOdatetime(year = as.numeric(substr(as.Date(std2003$Datum, format = "%y%m%d"), 1, 4)),
#        month = as.numeric(substr(as.Date(std2003$Datum, format = "%y%m%d"), 6, 7)),
#        day = as.numeric(substr(as.Date(std2003$Datum, format = "%y%m%d"), 9, 10)),
#        hour = as.numeric(std2003$Stunde),
#        min = 0,
#        sec = 0,
#        tz = "")
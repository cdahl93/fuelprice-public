# Reading data from last point in database to yesterday
# Packages
library(DBI)
library(odbc)
library(readr)

# DB Connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10)

# Latest entry in DB
out <- dbGetQuery(dbcon, "SELECT last(time,time) FROM price;")

latest <- as.Date(out[1,1])

# Latest available data point
today <- Sys.Date()
yesterday <- Sys.Date()-1

# Difference in days
diff <- as.numeric(yesterday-latest)

if(diff > 0){
  for(i in diff:1){
    year <- format(today-i,"%Y")
    month <- format(today-i,"%m")
    day <- format(today-i,"%d")
    
    pathtoserver = file.path("//192.168.1.10", "dbdata", "tankerkoenig", "prices", year, month)
    filename = paste(pathtoserver, "/", paste(year, month, day, sep = "-"), "-prices.csv", sep = "")
    
    df <- read_csv(filename,
                   col_types = cols(time = col_character(),
                                    stid = col_character(),
                                    pdi = col_double(),
                                    pe5 = col_double(),
                                    pe10 = col_double(),
                                    cdi = col_integer(),
                                    ce10 = col_integer(),
                                    ce5 = col_integer()),
                   col_names = c("time", "stid", "pdi", "pe5", "pe10", "cdi", "ce5", "ce10"),
                   skip = 1,
                   na = c("-0.001","0.000"))
    
    dbWriteTable(dbcon, c("price"), value = df, append = T, row.names = F)
    print(paste("Added", filename, sep=""))
  }
}

# Disconnect
dbDisconnect(dbcon)

# Clear Working Space
rm(list=ls())
# Packages
library(DBI)
library(odbc)
library(readr)
library(sp)
library(rgdal)

# Geo data
#path <- file.path("C:", "Users", "luftg", "Documents", "Data Projects", "fuelprice")
kreise = readOGR(dsn=paste(path,"/data/map_zensus2011", sep = ""), layer="VG250_Kreise", encoding = "UTF-8")
laender = readOGR(dsn=paste(path,"/data/map_zensus2011", sep = ""), layer="VG250_Bundeslaender", encoding = "UTF-8")
gemeinde = readOGR(dsn=paste(path,"/data/map_zensus2011", sep = ""), layer="VG250_Gemeinden", encoding = "UTF-8")

getinfo = function(in.spat){
  out = vector(mode="character", length=6)
  out[1] = as.character(over(in.spat, laender)$RS)
  out[2] = as.character(over(in.spat, laender)$GEN)
  out[3] = as.character(over(in.spat, kreise)$RS)
  out[4] = as.character(over(in.spat, kreise)$GEN)
  out[5] = as.character(over(in.spat, gemeinde)$RS)
  out[6] = as.character(over(in.spat, gemeinde)$GEN)
  return(out)
}

# Latest stations data
yesterday <- Sys.Date()-1
year <- format(yesterday,"%Y")
month <- format(yesterday,"%m")
day <- format(yesterday,"%d")
pathtoserver = file.path("//192.168.1.10", "dbdata", "tankerkoenig", "stations", year, month)
filename <- paste(pathtoserver, "/", paste(year, month, day, sep = "-"), "-stations.csv", sep = "")

stations_new <- read_csv(filename, 
                         col_types = cols(brand = col_character(), 
                                          city = col_character(), 
                                          first_active = col_character(),
                                          house_number = col_character(), 
                                          latitude = col_number(), 
                                          longitude = col_number(), 
                                          name = col_character(), 
                                          openingtimes_json = col_skip(), 
                                          post_code = col_character(), 
                                          street = col_character(),
                                          uuid = col_character()),
                         skip = 0,
                         na = c("nicht","Nicht"))

# DB Connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")

# Get station list (uuid's) from db
db_stations <- dbGetQuery(dbcon, "SELECT uuid FROM stations")

# Check for new stations and add their geo-information

# Query one row of stations table to get right coloumn names
db_stations_names <- dbGetQuery(dbcon, "SELECT * FROM stations LIMIT 1")

for(i in 1:dim(stations_new)[1]){
  new_data = data.frame()  
  if(any(db_stations$uuid == toupper(stations_new$uuid[i])) == 0){ # station is not already in database
    lat = stations_new$latitude[i]
    lon = stations_new$longitude[i]
    coords = as.data.frame(cbind(lon,lat))
    coords.spat = SpatialPoints(coords)
    proj4string(coords.spat) = proj4string(kreise)
    geoinfo = getinfo(coords.spat)
    new_data = rbind(new_data, c(stations_new[i,], geoinfo), stringsAsFactors = F)
    brands_cat = rep("Sonstige", dim(new_data)[1])
    target_brands = c("ARAL","Shell","ESSO","TOTAL","AVIA","JET","STAR","Agip","Raiffeisen","HEM","OMV","OIL!","BFT")
    for(j in 1:length(target_brands)){
      brands_cat[grep(target_brands[j], new_data$brand, ignore.case = T)] = target_brands[j]
    }
    new_data = cbind(new_data, brands_cat, NA)
    colnames(new_data) = colnames(db_stations_names)
    dbWriteTable(dbcon, c("stations"), value = new_data, append = T, row.names = F)
    dbSendQuery(dbcon, paste("UPDATE stations SET geopos = ST_SetSRID(ST_MakePoint(longitude,latitude),4326) WHERE uuid = '", stations_new$uuid[i], "';", sep = "")) # Update geoposition column
    print(paste("Added station: ", sep = ""))
    print(new_data[1,])
  }
}


# Disconnect
dbDisconnect(dbcon)

# Clear Working Space
rm(list=ls())

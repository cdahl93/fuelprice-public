###############################################################################

#                         NEW SCRIPT: T_stations_to_db.R                      #

###############################################################################

# Packages ----------------------------
library(tidyverse)
library(DBI)
library(odbc)
library(sp)
library(rgdal)

# Functions
source(file = "code/functions/find_brand_FUN.R")
source(file = "code/functions/street_category_FUN.R")
source(file = "code/functions/get_geo_info_FUN.R")

# Load geo data
laender <- readOGR(dsn = "data/map2019/vg250_ebenen",
                   layer="VG250_LAN", encoding = "UTF-8", stringsAsFactors = F,
                   verbose = F, use_iconv = T)
kreise <- readOGR(dsn = "data/map2019/vg250_ebenen",
                  layer="VG250_KRS", encoding = "UTF-8", stringsAsFactors = F,
                  verbose = F, use_iconv = T)
gemeinden <- readOGR(dsn = "data/map2019/vg250_ebenen",
                     layer="VG250_GEM", encoding = "UTF-8", stringsAsFactors = F,
                     verbose = F, use_iconv = T)

# db connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")

# get last update date
stations_last <- dbGetQuery(dbcon, "SELECT max(file_date) AS file_date FROM stations_date;")

# -stations.csv files in repository
pathtoserver = file.path("//192.168.1.10", "dbdata", "tankerkoenig", "stations")

# filter new files
stations_files <- tibble(path = list.files(pathtoserver, full.names = T, recursive = T)) %>%
  filter(path != "//192.168.1.10/dbdata/tankerkoenig/stations/stations.csv") %>%  # filter initial csv
  mutate(date = str_extract(path, "[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])")) %>%
  filter(date > stations_last$file_date) %>%
  arrange(date)

# new stations to db
if (dim(stations_files)[1] > 0) {
  print(paste(Sys.time(), " - Start adding stations to db"))
  progress = txtProgressBar(min=1, max=dim(stations_files)[1], style = 3, width = 100)
  for(i in 1:dim(stations_files)[1]){
    # read data
    stations_new <- read_csv(file = stations_files$path[i], 
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
    
    # get stations in db
    db_stations <- dbGetQuery(dbcon, "SELECT uuid FROM stations_test;")
    db_stations <- as_tibble(db_stations)
    
    # filter for stations not already in db
    stations_new <- filter(stations_new, !(uuid %in% tolower(db_stations$uuid)))
    
    # remaining stations: add information and write to db
    if(dim(stations_new)[1] > 0){
      # get geoinformation
      coords <- select(stations_new, longitude, latitude) %>%
        SpatialPoints()
      proj4string(coords) <- proj4string(kreise)
      
      geoinfo <- tibble(bl_kz = NA, bl_name = NA,
                        kreis_kz = NA, kreis_name = NA,
                        gemeinde_kz = NA, gemeinde_name = NA,
                        .rows = dim(stations_new)[1])
      
      for(j in 1:dim(stations_new)[1]){ 
        geoinfo[j,] <- get_geo_info(coords[j,])
      }
      
      # add additional information
      stations_new <- stations_new %>%
        bind_cols(geoinfo) %>% # add geo information
        add_column(brand_cat = find_brand(stations_new)) %>% # brand category
        add_column(street_cat = street_category(stations_new)) # street category
      
      # Write new stations to db
      colnames(stations_new) <- tolower(colnames(stations_new))
      dbWriteTable(dbcon, c("stations_test"), value = stations_new, append = T, row.names = F)
      dbGetQuery(dbcon, paste("UPDATE stations_test SET geopos = ST_SetSRID(ST_MakePoint(longitude,latitude),4326)")) # Update geoposition column
      stations_date <- tibble(file_date = stations_files$date[i],
                              number = dim(stations_new)[1])
      dbWriteTable(dbcon, c("stations_date"), value = stations_date, append = T, row.names = F, overwrite = F)  
      print(paste(Sys.time(), " - Added: ", dim(stations_new)[1], " station(s) to DB", sep = ""))
      print(paste(Sys.time(), " - with UUID:", stations_new$uuid), sep = "")
      
    }else{
      
      # update stations_date
      stations_date <- tibble(file_date = stations_files$date[i],
                              number = 0)
      dbWriteTable(dbcon, c("stations_date"), value = stations_date, append = T, row.names = F, overwrite = F)  
      
    }
    setTxtProgressBar(progress, i)
  }
  print(paste(Sys.time(), " - End adding stations to db"))
}

# db disconnect
dbDisconnect(dbcon)

# Clear Working Space
rm(list=ls())
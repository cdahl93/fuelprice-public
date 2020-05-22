###############################################################################

#                   NEW SCRIPT: initial_stations_to_db.R                      #

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

# file path
pathtoserver = file.path("//192.168.1.10", "dbdata", "tankerkoenig", "stations", "2019", "01")
filename <- paste(pathtoserver, "/", "2019-01-24-stations.csv", sep = "")  

# load data
stations_new <- read_csv(file = filename, 
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

# get geoinformation
coords <- select(stations_new, longitude, latitude) %>%
  SpatialPoints()
proj4string(coords) <- proj4string(kreise)

geoinfo <- tibble(bl_kz = NA, bl_name = NA,
                  kreis_kz = NA, kreis_name = NA,
                  gemeinde_kz = NA, gemeinde_name = NA,
                  .rows = dim(stations_new)[1])

print(paste(Sys.time(), " - Start getting geo information"))
progress = txtProgressBar(min=1, max=dim(stations_new)[1], style = 3, width = 100)
for(i in 1:dim(stations_new)[1]){ 
  geoinfo[i,] <- get_geo_info(coords[i,])
  setTxtProgressBar(progress, i)
}
print(paste(Sys.time(), " - End getting geo information"))

# add additional information
stations_new <- stations_new %>%
  bind_cols(geoinfo) %>% # add geo information
  add_column(brand_cat = find_brand(stations_new)) %>% # brand category
  add_column(street_cat = street_category(stations_new)) # street category

# Write stations to db
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")
dbGetQuery(dbcon, "DELETE FROM stations_test;")
colnames(stations_new) <- tolower(colnames(stations_new))
dbWriteTable(dbcon, c("stations_test"), value = stations_new, append = T, row.names = F)

dbGetQuery(dbcon, paste("UPDATE stations_test SET geopos = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);")) # Update geoposition column

stations_date <- tibble(file_date = as.Date("2019-01-24"),
                        number = dim(stations_new)[1])
dbWriteTable(dbcon, c("stations_date"), value = stations_date, append = F, row.names = F, overwrite = T)


# db disconnect
dbDisconnect(dbcon)

# Clear Working Space
rm(list=ls())
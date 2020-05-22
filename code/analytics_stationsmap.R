# Stations Map --------------------------------------------------------------------------------------------

# Status
print(paste('Start: analytics_stationsmap.R at', Sys.time()))

# Database connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")

# Stations data
stations <- dbGetQuery(dbcon, "SELECT * FROM stations;")

# Average prices last 30 Days
time_start = paste(as.character(Sys.Date()-31), " 00:00:00", sep = "")
time_end   = paste(as.character(Sys.Date()-1), " 23:59:59", sep = "")
avgprice_stations <- dbGetQuery(dbcon, paste("SELECT stid, round(AVG(pe5),3) AS E5, round(AVG(pe10),3) AS E10, round(AVG(pdi),3) AS Diesel
                                              FROM price
                                              WHERE time BETWEEN '", time_start, "' AND '", time_end, "' GROUP BY stid;", sep =""))

stations <- merge(stations, avgprice_stations, by.x = "uuid", by.y = "stid")
stations$e5[which(stations$e5 == 0.000)] <- NA
stations$e10[which(stations$e10 == 0.000)] <- NA 
stations$diesel[which(stations$diesel == 0.000)] <- NA 

avgprice <- dbGetQuery(dbcon, paste("SELECT round(AVG(pe5),3) AS E5, round(AVG(pe10),3) AS E10, round(AVG(pdi),3) AS Diesel
                                     FROM price
                                     WHERE time BETWEEN '", time_start, "' AND '", time_end, "';", sep = ""))

stations <- cbind(stations, 
                  diffe5 = round(stations$e5-avgprice$e5[1], 3),
                  diffe10 = round(stations$e10-avgprice$e10[1], 3),
                  diffdiesel = round(stations$diesel-avgprice$diesel[1], 3))

# Disconnect db
dbDisconnect(dbcon)

# Append information for map
stations <- cbind(stations, 
                  strhsnr = paste(stations$street, stations$house_number),
                  plzcity = paste(stations$post_code, stations$city),
                  pe5 = paste(stations$e5, "€ (", stations$diffe5, "€)", sep = ""),
                  pe10 = paste(stations$e10, "€ (", stations$diffe10, "€)", sep = ""),
                  pdiesel = paste(stations$diesel, "€ (", stations$diffdiesel, "€)", sep = ""))

# Map
brands <- unique(stations$brand_cat)
brands <- sort(brands)
col_brand <- c("yellow","blue","blueviolet","orange","lightblue","green","gold","deepskyblue","darkblue","lightgreen","red","grey","hotpink","white")

shapes <- list()
for(i in 1:length(brands)){
  shapes[[i]] <- st_as_sf(stations[which(stations$brand_cat == brands[i]),], coords = c("longitude","latitude"), crs = 4979)
}

map_stations <- tm_shape(shapes[[1]], name = brands[1]) +
  tm_dots(col = col_brand[1], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[2]], name = brands[2]) +
  tm_dots(col = col_brand[2], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[3]], name = brands[3]) +
  tm_dots(col = col_brand[3], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[4]], name = brands[4]) +
  tm_dots(col = col_brand[4], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[5]], name = brands[5]) +
  tm_dots(col = col_brand[5], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[6]], name = brands[6]) +
  tm_dots(col = col_brand[6], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[7]], name = brands[7]) +
  tm_dots(col = col_brand[7], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[8]], name = brands[8]) +
  tm_dots(col = col_brand[8], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[9]], name = brands[9]) +
  tm_dots(col = col_brand[9], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                          "E10 (Diff. DEU): " = "pe10",
                                                          "Diesel (Diff. DEU): " = "pdiesel",
                                                          "Straße : " = "strhsnr",
                                                          "Stadt: " = "plzcity",
                                                          "Bundesland: " = "bl_name",
                                                          "Kreis: " = "kreis_name",
                                                          "Gemeinde: " = "gemeinde_name",
                                                          "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[10]], name = brands[10]) +
  tm_dots(col = col_brand[10], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                           "E10 (Diff. DEU): " = "pe10",
                                                           "Diesel (Diff. DEU): " = "pdiesel",
                                                           "Straße : " = "strhsnr",
                                                           "Stadt: " = "plzcity",
                                                           "Bundesland: " = "bl_name",
                                                           "Kreis: " = "kreis_name",
                                                           "Gemeinde: " = "gemeinde_name",
                                                           "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[11]], name = brands[11]) +
  tm_dots(col = col_brand[11], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                           "E10 (Diff. DEU): " = "pe10",
                                                           "Diesel (Diff. DEU): " = "pdiesel",
                                                           "Straße : " = "strhsnr",
                                                           "Stadt: " = "plzcity",
                                                           "Bundesland: " = "bl_name",
                                                           "Kreis: " = "kreis_name",
                                                           "Gemeinde: " = "gemeinde_name",
                                                           "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[12]], name = brands[12]) +
  tm_dots(col = col_brand[12], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                           "E10 (Diff. DEU): " = "pe10",
                                                           "Diesel (Diff. DEU): " = "pdiesel",
                                                           "Straße : " = "strhsnr",
                                                           "Stadt: " = "plzcity",
                                                           "Bundesland: " = "bl_name",
                                                           "Kreis: " = "kreis_name",
                                                           "Gemeinde: " = "gemeinde_name",
                                                           "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[13]], name = brands[13]) +
  tm_dots(col = col_brand[13], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                           "E10 (Diff. DEU): " = "pe10",
                                                           "Diesel (Diff. DEU): " = "pdiesel",
                                                           "Straße : " = "strhsnr",
                                                           "Stadt: " = "plzcity",
                                                           "Bundesland: " = "bl_name",
                                                           "Kreis: " = "kreis_name",
                                                           "Gemeinde: " = "gemeinde_name",
                                                           "Aktiv seit: " = "first_active")) + 
  tm_shape(shapes[[14]], name = brands[14]) +
  tm_dots(col = col_brand[14], id = "name", popup.vars = c("E5 (Diff. DEU): " = "pe5",
                                                           "E10 (Diff. DEU): " = "pe10",
                                                           "Diesel (Diff. DEU): " = "pdiesel",
                                                           "Straße : " = "strhsnr",
                                                           "Stadt: " = "plzcity",
                                                           "Bundesland: " = "bl_name",
                                                           "Kreis: " = "kreis_name",
                                                           "Gemeinde: " = "gemeinde_name",
                                                           "Aktiv seit: " = "first_active"))

map_stations_int <- tmap_leaflet(map_stations) 

map_stations_int <- map_stations_int %>% 
  addLegend("topright", colors = col_brand, labels = brands, opacity = 1) %>%
  addLayersControl(overlayGroups = brands,
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addSearchOSM(options = searchOptions(zoom = 12, minLength = 3, autoCollapse = T, 
                                       hideMarkerOnCollapse = T))

# Save map
saveWidget(map_stations_int, file = paste(getwd(),"/figures/stations.html", sep = ""),
           title = "Tankstellen Karte",
           selfcontained = F)

# Save static previews
#mapshot(map_stations_int, file = paste(getwd(),"/figures/stations.png", sep = ""))

# Clean working space
rm(list = ls())

# Status
print(paste('End: analytics_stationsmap.R at', Sys.time()))
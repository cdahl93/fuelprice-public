# Map of average price last 30 days -------------------------------

# Status
print(paste('Start: analytics_map30days_auto.R at', Sys.time()))

# Geo data
kreise = readOGR(dsn=paste(getwd(),"/data/map_zensus2011", sep =""), layer="VG250_Kreise", encoding = "UTF-8")
laender = readOGR(dsn=paste(getwd(),"/data/map_zensus2011", sep = ""), layer="VG250_Bundeslaender", encoding = "UTF-8")
#gemeinde = readOGR(dsn=paste(getwd(),"/data/map_zensus2011", sep = ""), layer="VG250_Gemeinden", encoding = "UTF-8")

# Database connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")

# Query data
time_start = paste(as.character(Sys.Date()-31), " 00:00:00", sep = "")
time_end   = paste(as.character(Sys.Date()-1), " 23:59:59", sep = "")

price_bl <- dbGetQuery(dbcon, paste("SELECT bl_kz, bl_name, round(AVG(pe5),3) AS pe5, round(AVG(pe10),3) AS pe10, round(AVG(pdi),3) AS pdi, count(*) AS anzahl FROM (
                                          (SELECT price.stid, avg(price.pe5) AS pe5, avg(price.pe10) AS pe10, avg(price.pdi) AS pdi FROM price
                                  WHERE price.time BETWEEN '", time_start, "' AND '", time_end, "'
                                  GROUP BY price.stid) AS pricecc
                                  INNER JOIN stations ON stations.uuid = pricecc.stid) GROUP BY bl_kz, bl_name;", sep = ""))


price_kreis <- dbGetQuery(dbcon, paste("SELECT kreis_kz, kreis_name, round(AVG(pe5),3) AS pe5, round(AVG(pe10),3) AS pe10, round(AVG(pdi),3) AS pdi, count(*) AS anzahl FROM (
                                          (SELECT price.stid, avg(price.pe5) AS pe5, avg(price.pe10) AS pe10, avg(price.pdi) AS pdi FROM price
                                  WHERE price.time BETWEEN '", time_start, "' AND '", time_end, "'
                                  GROUP BY price.stid) AS pricecc
                                  INNER JOIN stations ON stations.uuid = pricecc.stid) GROUP BY kreis_kz, kreis_name;", sep = ""))

mean_all <- dbGetQuery(dbcon, paste("SELECT round(avg(pe5),3) as pe5, round(avg(pe10),3) as pe10, round(avg(pdi),3) as pdi FROM price
                                    WHERE time BETWEEN '", time_start, "' AND '", time_end, "';"))


# Disconnect db
dbDisconnect(dbcon)

price_bl <- cbind(price_bl,
                  diffe5 = round(price_bl$pe5-mean_all$pe5[1],3),
                  diffe10 = round(price_bl$pe10-mean_all$pe10[1],3),
                  diffpdi = round(price_bl$pdi-mean_all$pdi[1],3),
                  pe5text = paste(price_bl$pe5, "€", sep = ""),
                  pe10text = paste(price_bl$pe10, "€", sep = ""),
                  pditext = paste(price_bl$pdi, "€", sep = ""),
                  diffe5text = paste(round(price_bl$pe5-mean_all$pe5[1],3), "€", sep = ""),
                  diffe10text = paste(round(price_bl$pe10-mean_all$pe10[1],3), "€", sep = ""),
                  diffpditext = paste(round(price_bl$pdi-mean_all$pdi[1],3), "€", sep = ""))


price_kreis <- cbind(price_kreis,
                     diffe5 = round(price_kreis$pe5-mean_all$pe5[1],3),
                     diffe10 = round(price_kreis$pe10-mean_all$pe10[1],3),
                     diffpdi = round(price_kreis$pdi-mean_all$pdi[1],3),
                     pe5text = paste(price_kreis$pe5, "€", sep = ""),
                     pe10text = paste(price_kreis$pe10, "€", sep = ""),
                     pditext = paste(price_kreis$pdi, "€", sep = ""),
                     diffe5text = paste(round(price_kreis$pe5-mean_all$pe5[1],3), "€", sep = ""),
                     diffe10text = paste(round(price_kreis$pe10-mean_all$pe10[1],3), "€", sep = ""),
                     diffpditext = paste(round(price_kreis$pdi-mean_all$pdi[1],3), "€", sep = ""))


#Join price and geo data
kreise@data = left_join(kreise@data, price_kreis, by = c("RS" = "kreis_kz"))
laender@data = left_join(laender@data, price_bl, by = c("RS" = "bl_kz"))


# map
map_kreise <- tm_shape(shp = kreise, name = "Super E5") + 
  tm_polygons("pe5",
              style = "pretty",
              palette = "PuBuGn",
              border.col = "white",
              border.alpha = 0.5,
              title = "Preis Super-E5 in €",
              id = "GEN",
              popup.vars = c("Durchschnittlicher Super-E5 Preis:" = "pe5text",
                             "Diff. zum Bundesdurchschnitt: " = "diffe5text",
                             "Anzahl Tankstellen: " = "anzahl")) +
  tm_layout(title = paste("Kraftstoffpreise - Vom ", format(as.Date(time_start), "%d.%m.%Y"), " bis ", format(as.Date(time_end), "%d.%m.%Y"), sep = ""),
            title.size = 1.1,
            title.position = c("center","top"),
            inner.margins = c(0.05,0.10,0.10,0.10)) +
  tm_scale_bar(color.dark = "gray70",
               position = c("right","bottom"))


map_bl <- tm_shape(shp = laender) + 
  tm_polygons("pe5",
              style = "pretty",
              palette = "PuBuGn",
              border.col = "white",
              border.alpha = 0.5,
              title = "Preis Super-E5 in €",
              id = "GEN",
              popup.vars = c("Durchschnittlicher Super-E5 Preis:" = "pe5text",
                             "Diff. zum Bundesdurchschnitt: " = "diffe5text",
                             "Anzahl Tankstellen: " = "anzahl")) +
  tm_layout(title = paste("Benzinpreise - Vom ", format(as.Date(time_start), "%d.%m.%Y"), " bis ", format(as.Date(time_end), "%d.%m.%Y"), sep = ""),
            title.size = 1.1,
            title.position = c("center","top"),
            inner.margins = c(0.05,0.10,0.10,0.10)) +
  tm_scale_bar(color.dark = "gray70",
               position = c("right","bottom"))


# Interactive map
map_kreise_int = tmap_leaflet(map_kreise)
map_bl_int = tmap_leaflet(map_bl)    


# Save as html widget
saveWidget(map_kreise_int, file = paste(getwd(),"/figures/price.kreise.last30days.html", sep = ""),
           title = paste("Benzinpreise - Vom ", format(as.Date(time_start), "%d.%m.%Y"), " bis ", format(as.Date(time_end), "%d.%m.%Y"), sep = ""),
           selfcontained = F)

saveWidget(map_bl_int, file = paste(getwd(),"/figures/price.bl.last30days.html", sep = ""),
           title = paste("Benzinpreise - Vom ", format(as.Date(time_start), "%d.%m.%Y"), " bis ", format(as.Date(time_end), "%d.%m.%Y"), sep = ""),
           selfcontained = F)

# Save static previews
#mapshot(map_kreise_int, file = paste(getwd(),"/figures/price.kreise.last30days.png", sep = ""))
#mapshot(map_bl_int, file = paste(getwd(),"/figures/price.bl.last30days.png", sep = ""))

# Clean working space
rm(list = ls())

# Status
print(paste('End: analytics_map30days_auto.R at', Sys.time()))
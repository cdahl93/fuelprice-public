# Packages -----------------------------------
print(paste("Start: Loading Packages at", Sys.time()))
pkgs <- c("DBI","odbc","sp","sf","rgdal","dplyr","tmap","htmlwidgets",
          "plotly","mapview","leaflet","leaflet.extras")
lapply(pkgs, library, character.only = T)
print(paste("End: Loading Packages at", Sys.time()))
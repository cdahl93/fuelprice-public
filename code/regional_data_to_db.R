###############################################################################

#                         SCRIPT: regional_data_to_db.R                       #

###############################################################################

# DESCRIPTION
# This script reads and cleans region data fer states and counties (e.g. pop-
# ulation, car statistics, area)

# Packages
library(tidyverse)
library(DBI)
library(odbc)

# CAR NUMBERS -----------------------------------------------------------------

  # load data
  #guess_encoding("data/46251-0006.csv")
  cars_in <- read_delim(file = "data/46251-0006.csv",
                        skip = 5,
                        delim = ";",
                        na = c("-"),
                        locale = locale(encoding = "ISO-8859-1",
                                        decimal_mark = ","))
  
  # Transform data
  cars <- cars_in %>%
    rename(date = X1, kreis_kz = X2, kreis_name_typ = X3) %>%
    mutate(date = as.Date(date, format = "%d.%m.%Y")) %>%
    filter(!(is.na(date)))
  
  names <- tibble(long_names = colnames(cars),
                  short_names = c("date",
                                  "kreis_kz",
                                  "kreis_name",
                                  "kfz",
                                  "rad",
                                  "rad_lei",
                                  "rad_mot",
                                  "pkw",
                                  "pkw_ott",
                                  "pkw_die",
                                  "bus",
                                  "lkw",
                                  "lkw_spe",
                                  "zug",
                                  "zug_gew",
                                  "zug_sat",
                                  "schlepp",
                                  "kfz_son",
                                  "wohnmob",
                                  "anhang",
                                  "anhang_las",
                                  "sattel"))
  
  colnames(cars) <- names$short_names
  
  # new obeservations to db
  dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "ISO-8859-1")
  
  cars_db <- dbGetQuery(dbcon, "SELECT distinct(date) FROM car_numbers
                        ORDER BY date ASC;")
  if (length(cars_db$date) > 0){
    cars_to_db <- cars %>%
      filter(!(date %in% cars_db$date))  
  }else{
    cars_to_db <- cars
  }
  
  if (dim(cars_to_db)[1] > 0){
    dbWriteTable(conn = dbcon, name = "car_numbers", value = cars_to_db, 
                 append = T)    
  }
  
  #dbWriteTable(conn = dbcon, name = "car_numbers_names", value = names, 
  #append = T)
  
  dbDisconnect(dbcon)

  # Clear Working Space
  rm(list=ls())


# AREA STATES -----------------------------------------------------------------
  
  # load data
  #guess_encoding(file = "data/11111-0001.csv")
  area_bl_in <- read_delim(file = "data/11111-0001.csv",
                           delim = ";",
                           skip = 5,
                           locale = locale(encoding = "ISO-8859-1",
                                           decimal_mark = ","))
  
  # transform data
  area_bl_tidy <- area_bl_in %>%
    drop_na('31.12.1995') %>%
    rename(bl_name = X1) %>%
    pivot_longer(-bl_name, names_to = "date", values_to = "area_bl") %>%
    mutate(date = as.Date(date, format = "%d.%m.%Y")) %>%
    mutate(bl_name = if_else(bl_name == "Insgesamt", "Deutschland", bl_name))
    
  # add bl_kz
  dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "ISO-8859-1")
  
  bl_kz <- dbGetQuery(dbcon, "SELECT distinct(bl_kz), bl_name FROM stations
                      WHERE bl_kz IS NOT NULL
                      ORDER BY bl_kz ASC;")
  
  area_bl_wkz <- area_bl_tidy %>%
    left_join(bl_kz, by = "bl_name") %>%
    mutate(bl_kz = if_else(bl_name == "Deutschland", "00", bl_kz)) %>%
    select(bl_kz, bl_name, date, area_bl)

  # new obeservations to db
  area_bl_db <- dbGetQuery(dbcon, "SELECT distinct(date) FROM area_bl
                           ORDER BY date ASC;")

  if (length(area_bl_db$date) > 0){
    area_bl_to_db <- area_bl_wkz %>%
      filter(!(date %in% area_bl_db$date))  
  }else{
    area_bl_to_db <- area_bl_wkz
  }

  if (dim(area_bl_to_db)[1] > 0 ){
    dbWriteTable(conn = dbcon, name = "area_bl", value = area_bl_to_db, 
                 append = T)  
  }  
  
  dbDisconnect(dbcon)
  
  # Clear Working Space
  rm(list=ls())

  
# AREA COUNTIES ---------------------------------------------------------------
  
  # load data
  #guess_encoding(file = "data/11111-0001.csv")
  area_kreis_in <- read_delim(file = "data/11111-0002.csv",
                              delim = ";",
                              skip = 5,
                              na = c("-","..."),
                              locale = locale(encoding = "ISO-8859-1",
                                              decimal_mark = ","))
  
  # transform data
  area_kreis_tidy <- area_kreis_in %>%
    rename(kreis_kz = X1, kreis_name = X2) %>%
    drop_na(kreis_name) %>%
    pivot_longer(-c("kreis_name", "kreis_kz"), names_to = "date", 
                 values_to = "area_kreis")%>%
    mutate(date = as.Date(date, format = "%d.%m.%Y")) %>%
    select(kreis_kz, kreis_name, date, area_kreis)
    
  # new obeservations to db
  dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "ISO-8859-1")
  
  area_kreis_db <- dbGetQuery(dbcon, "SELECT distinct(date) FROM area_kreis
                              ORDER BY date ASC;")
  
  if (length(area_kreis_db$date) > 0){
    area_kreis_to_db <- area_kreis_tidy %>%
      filter(!(date %in% area_kreis_db$date))  
  }else{
    area_kreis_to_db <- area_kreis_tidy
  }
  
  if (dim(area_kreis_to_db)[1] > 0 ){
    dbWriteTable(conn = dbcon, name = "area_kreis", value = area_kreis_to_db, 
                 append = T)  
  }  
  
  dbDisconnect(dbcon)
  
  # Clear Working Space
  rm(list=ls())

  
# POPULATION STATES -----------------------------------------------------------
  
  # load data
  #guess_encoding(file = "data/12411-0010.csv")
  pop_bl_in <- read_delim(file = "data/12411-0010.csv",
                          delim = ";",
                          skip = 5,
                          na = c("-"),
                          locale = locale(encoding = "ISO-8859-1",
                                          decimal_mark = ","))
  
  # transform data
  pop_bl_tidy <- pop_bl_in %>%
    drop_na('31.12.1995') %>%
    rename(bl_name = X1) %>%
    pivot_longer(-bl_name, names_to = "date", values_to = "pop_bl") %>%
    mutate(date = as.Date(date, format = "%d.%m.%Y"))
    
  
  # add bl_kz
  dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "ISO-8859-1")
  
  bl_kz <- dbGetQuery(dbcon, "SELECT distinct(bl_kz), bl_name FROM stations
                      WHERE bl_kz IS NOT NULL
                      ORDER BY bl_kz ASC;")
  
  pop_bl_wkz <- pop_bl_tidy %>%
    left_join(bl_kz, by = "bl_name") %>%
    select(bl_kz, bl_name, date, pop_bl)
  
  # new obeservations to db
  pop_bl_db <- dbGetQuery(dbcon, "SELECT distinct(date) FROM pop_bl
                          ORDER BY date ASC;")
  
  if (length(pop_bl_db$date) > 0){
    pop_bl_to_db <- pop_bl_wkz %>%
      filter(!(date %in% pop_bl_db$date))  
  }else{
    pop_bl_to_db <- pop_bl_wkz
  }
  
  if (dim(pop_bl_to_db)[1] > 0 ){
    dbWriteTable(conn = dbcon, name = "pop_bl", value = pop_bl_to_db, 
                 append = T)  
  }  
  
  dbDisconnect(dbcon)
  
  # Clear Working Space
  rm(list=ls())
  
  
# POPULATION COUNTIES ---------------------------------------------------------------
  
  # load data
  #guess_encoding(file = "data/12411-0015.csv")
  pop_kreis_in <- read_delim(file = "data/12411-0015.csv",
                             delim = ";",
                             skip = 5,
                             na = c("-","..."),
                             locale = locale(encoding = "ISO-8859-1",
                                             decimal_mark = ","))
  
  # transform data
  pop_kreis_tidy <- pop_kreis_in %>%
    rename(kreis_kz = X1, kreis_name = X2) %>%
    drop_na(kreis_name) %>%
    pivot_longer(-c("kreis_name", "kreis_kz"), names_to = "date", 
                 values_to = "pop_kreis")%>%
    mutate(date = as.Date(date, format = "%d.%m.%Y")) %>%
    select(kreis_kz, kreis_name, date, pop_kreis)
  
  # new obeservations to db
  dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "ISO-8859-1")
  
  pop_kreis_db <- dbGetQuery(dbcon, "SELECT distinct(date) FROM pop_kreis
                             ORDER BY date ASC;")
  
  if (length(pop_kreis_db$date) > 0){
    pop_kreis_to_db <- pop_kreis_tidy %>%
      filter(!(date %in% pop_kreis_db$date))  
  }else{
    pop_kreis_to_db <- pop_kreis_tidy
  }
  
  if (dim(pop_kreis_to_db)[1] > 0 ){
    dbWriteTable(conn = dbcon, name = "pop_kreis", value = pop_kreis_to_db, 
                 append = T)  
  }  
  
  dbDisconnect(dbcon)
  
  # Clear Working Space
  rm(list=ls())
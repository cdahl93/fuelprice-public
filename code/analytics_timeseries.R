# Time Series of fuel prices in germany for different sorts (e5 e10 diesel) -------------------------------

# Status
print(paste('Start: analytics_timeseries_auto.R at', Sys.time()))

# Database connection
dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")

# query data
prices_day <- dbGetQuery(dbcon, "SELECT time_bucket('1 day', time::TIMESTAMP) as day, 
                                                    round(avg(pe5),3) as e5,
                                                    round(avg(pe10),3) as e10,
                                                    round(avg(pdi),3) as diesel
             FROM price
             GROUP BY day
             ORDER BY day ASC;")

if(format(Sys.Date(), "%d") == "02"){ # Compute the monthly plot on the second day of each month
  sqlquery <- "SELECT date_trunc('month', time) as month, round(avg(pe5),3) as e5,
                                                        round(avg(pe10),3) as e10,
                                                        round(avg(pdi),3) as diesel
             FROM price
             GROUP BY month
             ORDER BY month ASC;"
  
  prices_month <- dbGetQuery(dbcon, sqlquery)
  
  print(paste('Intermediate: analytics_timeseries_auto.R - Second day of Month - Monthly data calculated', Sys.time()))
}

time_start = paste(as.character(Sys.Date()-91), " 00:00:00", sep = "")
time_end   = paste(as.character(Sys.Date()-1), " 23:59:59", sep = "")

prices_hour <- dbGetQuery(dbcon, paste("SELECT time_bucket('1 hour', time::TIMESTAMP) as hour, 
                                                    round(avg(pe5),3) as e5,
                                                    round(avg(pe10),3) as e10,
                                                    round(avg(pdi),3) as diesel
             FROM price
             WHERE time BETWEEN '", time_start, "' AND '", time_end,
                                       "' GROUP BY hour
             ORDER BY hour ASC;", sep = ""))

# Disconnect db
dbDisconnect(dbcon)

# Status
print(paste('Intermediate: analytics_timeseries_auto.R - Data loaded from DB at', Sys.time()))


# Plot data
plot_names <- c("E5", "E10", "Diesel")
plot_colors <- c("blue", "orange", "green")

# Plot daily prices
plot_day <- plot_ly(prices_day)
for(i in 1:(dim(prices_day)[2]-1)){
  plot_day <- add_trace(plot_day, x = prices_day$day, y = prices_day[,i+1],
                        name = plot_names[i],
                        type = "scatter", mode = "lines",
                        line = list(color = plot_colors[i]))  
}
plot_day <- layout(plot_day,
                   xaxis = list(showgrid = T,
                                nticks = 20,
                                zeroline = F,
                                title = "",
                                mirror = "all",
                                autorange = F,
                                range = c(sub(pattern = format(as.Date(time_end), "%Y"), x = time_end, replacement = as.numeric(substr(time_end, 1, 4))-3),
                                          time_end),
                                rangeslider = list(type = "date"),
                                rangeselector = list(
                                  buttons = list(
                                    list(
                                      count = 3,
                                      label = "3 mo",
                                      step = "month",
                                      stepmode = "backward"),
                                    list(
                                      count = 6,
                                      label = "6 mo",
                                      step = "month",
                                      stepmode = "backward"),
                                    list(
                                      count = 1,
                                      label = "1 yr",
                                      step = "year",
                                      stepmode = "backward"),
                                    list(
                                      count = 3,
                                      label = "3 yr",
                                      step = "year",
                                      stepmode = "backward"),
                                    list(
                                      count = 1,
                                      label = "YTD",
                                      step = "year",
                                      stepmode = "todate"),
                                    list(
                                      step = "all")
                                  )
                                )
                   ),
                   yaxis = list(showgrid = T,
                                zeroline = F,
                                nticks = 20,
                                showline = F,
                                title = "Euro",
                                mirror = "all"),
                   title = "Daily fuel prices") %>%
  partial_bundle()

# Plot monthly prices
if(format(Sys.Date(), "%d") == "02"){ # Compute the monthly plot on the second day of each month
  plot_month <- plot_ly(prices_month)
  for(i in 1:(dim(prices_month)[2]-1)){
    plot_month <- add_trace(plot_month, x = prices_month$month, y = prices_month[,i+1],
                            name = plot_names[i],
                            type = "scatter", mode = "lines",
                            line = list(color = plot_colors[i]))  
  }
  plot_month <- layout(plot_month,
                       xaxis = list(showgrid = T,
                                    nticks = 20,
                                    zeroline = F,
                                    title = "",
                                    mirror = "all",
                                    rangeslider = list(type = "date"),
                                    rangeselector = list(
                                      buttons = list(
                                        list(
                                          count = 1,
                                          label = "1 yr",
                                          step = "year",
                                          stepmode = "backward"),
                                        list(
                                          count = 3,
                                          label = "3 yr",
                                          step = "year",
                                          stepmode = "backward"),
                                        list(
                                          count = 5,
                                          label = "5 yr",
                                          step = "year",
                                          stepmode = "backward"),
                                        list(
                                          count = 1,
                                          label = "YTD",
                                          step = "year",
                                          stepmode = "todate"),
                                        list(
                                          step = "all")
                                      )
                                    )
                       ),
                       yaxis = list(showgrid = T,
                                    zeroline = F,
                                    nticks = 20,
                                    showline = F,
                                    title = "Euro",
                                    mirror = "all"),
                       title = "Monthly fuel prices") %>%
    partial_bundle()
  
  print(paste('Intermediate: analytics_timeseries_auto.R - Second day of Month - Monthly data plotted', Sys.time()))
}

# Plot hourly prices
plot_hour <- plot_ly(prices_hour)
for(i in 1:(dim(prices_hour)[2]-1)){
  plot_hour <- add_trace(plot_hour, x = prices_hour$hour, y = prices_hour[,i+1],
                         name = plot_names[i],
                         type = "scatter", mode = "lines",
                         line = list(color = plot_colors[i]))  
}
plot_hour <- layout(plot_hour,
                    xaxis = list(showgrid = T,
                                 nticks = 20,
                                 zeroline = F,
                                 title = "",
                                 autorange = F,
                                 range = list(
                                   as.character(as.Date(time_end)-3), time_end
                                 ),
                                 mirror = "all",
                                 rangeslider = list(type = "date"),
                                 rangeselector = list(
                                   buttons = list(
                                     list(
                                       count = 72,
                                       label = "72 h",
                                       step = "hour",
                                       stepmode = "backward"),
                                     list(
                                       count = 7,
                                       label = "7 d",
                                       step = "day",
                                       stepmode = "backward"),
                                     list(
                                       count = 14,
                                       label = "14 d",
                                       step = "day",
                                       stepmode = "backward"),
                                     list(
                                       count = 1,
                                       label = "1 mo",
                                       step = "month",
                                       stepmode = "backward"),
                                     list(
                                       step = "all",
                                       label = "90 d")
                                   )
                                 )
                    ),
                    yaxis = list(showgrid = T,
                                 zeroline = F,
                                 nticks = 20,
                                 showline = F,
                                 title = "Euro",
                                 mirror = "all"),
                    title = "Hourly fuel prices") %>%
  partial_bundle()

# Status
print(paste('Intermediate: analytics_timeseries_auto.R - Plots created at', Sys.time()))

# save plots
saveWidget(plot_day, file = paste(getwd(),"/figures/price.tsdaily.html", sep = ""),
           title = "Daily fuel prices",
           selfcontained = F)

if(format(Sys.Date(), "%d") == "02"){ # Compute the monthly plot on the second day of each month
  saveWidget(plot_month, file = paste(getwd(),"/figures/price.tsmonthly.html", sep = ""),
             title = "Monthly fuel prices",
             selfcontained = F)
  orca(plot_month, file = "/figures/price.tsmonthly.png", width = 992, height = 744)
}

saveWidget(plot_hour, file = paste(getwd(),"/figures/price.tshourly.html", sep = ""),
           title = "Hourly fuel prices - Last 90 days",
           selfcontained = F)

# Save static previews
orca(plot_day, file = "/figures/price.tsdaily.png", width = 992, height = 744)
orca(plot_hour, file = "/figures/price.tshourly.png", width = 992, height = 744)

# Clean working space
rm(list = ls())

# Status
print(paste('End: analytics_timeseries_auto.R at', Sys.time()))
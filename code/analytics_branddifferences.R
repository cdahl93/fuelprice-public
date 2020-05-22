# Price differences between brands (last year) ------------------------------------------------------------

# Status
print(paste('Start: analytics_branddifferences_auto.R at', Sys.time()))

dbcon <- dbConnect(odbc(), "fuelprice", timeout = 10, encoding = "windows-1252")

# Time period
time_start <- paste(as.character(Sys.Date()-366), " 00:00:00", sep = "")
time_end <- paste(as.character(Sys.Date()-1), " 23:59:59", sep = "")

# Average fuel prices for time period by brands
sqlquery <- paste("SELECT round(AVG(price.pe5), 3) AS E5,
                         round(AVG(price.pe10), 3) AS E10,
                         round(AVG(price.pdi), 3) AS Diesel,
                         stations.brand_cat AS Marke
                  FROM price
                  LEFT JOIN stations ON stations.uuid = price.stid
                  AND price.time BETWEEN '", time_start, "' AND '", time_end, "'
                  GROUP BY brand_cat;", sep = "")

mean_brand <- dbGetQuery(dbcon, sqlquery)
mean_brand <- mean_brand[-c(which(is.na(mean_brand$marke))),]

# Average fuel price for time period for all
sqlquery <- paste("SELECT round(AVG(price.pe5), 3) AS E5,
                          round(AVG(price.pe10), 3) AS E10,
                          round(AVG(price.pdi), 3) AS Diesel
                   FROM price
                   WHERE price.time BETWEEN '", time_start, "' AND '", time_end, "'", sep = "")

mean_all <- dbGetQuery(dbcon, sqlquery)

# Disconnect db
dbDisconnect(dbcon)

# Difference from brands to overall mean
diff_brand <- mean_brand
for(i in 1:dim(mean_brand)[1]){
  diff_brand[i,1:3] <- mean_brand[i,1:3] - mean_all
}
diff_brand[,1:3] <- diff_brand[,1:3]*100

# Plot
updatemenus <- list(
  list(
    active = 3,
    type = "buttons",
    buttons = list(
      list(
        label = "Super E5",
        method = "update",
        args = list(list(visible = c(F, T, F)),
                    list(title = "Preisunterschiede nach Marken - Super E5"))),
      list(
        label = "Super E10",
        method = "update",
        args = list(list(visible = c(F, F, T)),
                    list(title = "Preisunterschiede nach Marken - Super E10"))),
      list(
        label = "Diesel",
        method = "update",
        args = list(list(visible = c(T, F, F)),
                    list(title = "Preisunterschiede nach Marken - Diesel"))),
      list(
        label = "Alle",
        method = "update",
        args = list(list(visible = c(T,T,T)),
                    list(title = "Preisunterschiede nach Marken")))
    )
  )
)

# calculate range of yaxis, vertical position of xaxis
ymin <- min(diff_brand[,1:3])
ymax <- max(diff_brand[,1:3])
ymin_adj <- ymin - 1 # adjusting for better visibility
ymax_adj <- ymax + 1
xaxis_vertpos <- (abs(ymin_adj)+abs(ymax))/(abs(ymin_adj)+abs(ymax_adj)) # vertical position as fraction of total y range; xaxis will stay right above the bars

diff_plot <- plot_ly(type = "bar",
                     textposition = "auto",
                     hoverinfo = "x+y",) %>%
  add_trace(x = diff_brand$marke, y = diff_brand$e5, name = "Super E5", text = round(diff_brand$e5, 2), marker = list(color = "blue"), opacity = 0.9) %>%
  add_trace(x = diff_brand$marke, y = diff_brand$e10, name = "Super E10", text = round(diff_brand$e10, 2), marker = list(color = "green"), opacity = 0.9) %>%
  add_trace(x = diff_brand$marke, y = diff_brand$diesel, name = "Diesel", text = round(diff_brand$diesel, 2), marker = list(color = "orange"), opacity = 0.9) %>%
  layout(title = list(text = "Preisunterschied nach Marken - Letzte 365 Tage",
                      y = 0.995),
         yaxis = list(title = "€-Cent",
                      range = c(ymin_adj, ymax_adj)),
         xaxis = list(title = "",
                      tickfont = list(size = 15),
                      side = "top",
                      anchor = "free",
                      position = xaxis_vertpos),
         shapes = list(
           list(type = "rect",
                fillcolor = "lightgrey", line = list(color = "lightgrey"), opacity = 0.5, layer = "below",
                x0 = 0.5, x1 = 1.5, xref = "x",
                y0 = min(diff_brand[,1:3]), y1 = max(diff_brand[,1:3]), yref = "y"),
           list(type = "rect",
                fillcolor = "lightgrey", line = list(color = "lightgrey"), opacity = 0.5, layer = "below",
                x0 = 2.5, x1 = 3.5, xref = "x",
                y0 = min(diff_brand[,1:3]), y1 = max(diff_brand[,1:3]), yref = "y"),
           list(type = "rect",
                fillcolor = "lightgrey", line = list(color = "lightgrey"), opacity = 0.5, layer = "below",
                x0 = 4.5, x1 = 5.5, xref = "x",
                y0 = min(diff_brand[,1:3]), y1 = max(diff_brand[,1:3]), yref = "y"),
           list(type = "rect",
                fillcolor = "lightgrey", line = list(color = "lightgrey"), opacity = 0.5, layer = "below",
                x0 = 6.5, x1 = 7.5, xref = "x",
                y0 = min(diff_brand[,1:3]), y1 = max(diff_brand[,1:3]), yref = "y"),
           list(type = "rect",
                fillcolor = "lightgrey", line = list(color = "lightgrey"), opacity = 0.5, layer = "below",
                x0 = 8.5, x1 = 9.5, xref = "x",
                y0 = min(diff_brand[,1:3]), y1 = max(diff_brand[,1:3]), yref = "y"),
           list(type = "rect",
                fillcolor = "lightgrey", line = list(color = "lightgrey"), opacity = 0.5, layer = "below",
                x0 = 10.5, x1 = 11.5, xref = "x",
                y0 = min(diff_brand[,1:3]), y1 = max(diff_brand[,1:3]), yref = "y"),
           list(type = "rect",
                fillcolor = "lightgrey", line = list(color = "lightgrey"), opacity = 0.5, layer = "below",
                x0 = 12.5, x1 = 13.5, xref = "x",
                y0 = min(diff_brand[,1:3]), y1 = max(diff_brand[,1:3]), yref = "y")
         ),
         updatemenus = updatemenus) %>%
  partial_bundle()


# Save plot
saveWidget(diff_plot, file = paste(getwd(),"/figures/diffprice_brand.html", sep = ""),
           title = "Preisunterschiede nach Marken",
           selfcontained = F)

# Save static image
orca(diff_plot, file = "/figures/diffprice_brand.png", width = 992, height = 744)

# Clean working space
rm(list = ls())

# Status
print(paste('End: analytics_branddifferences_auto.R at', Sys.time()))

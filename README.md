# German fuel prices
This project aims at analyzing german fuel prices

## Background
Since june 2014 gas stations in germany are obliged to submit every price change to the Bundeskartellamt. Tankerkönig as so called Markttransparenzstelle für Kraftstoffe (MTS-K) makes this data public. They share the daily price changes as csv-files in their repo: https://creativecommons.tankerkoenig.de/ 

The dataset grows daily by about 600,000 price changes, hence over the years over 840 million datapoints from over 15,000 gas stations accumulated. This calls for a database (here: PostgreSQL with timescaledb and postgis extension) to analyze the data efficiently.

## Current state: Analysis
* Map of all gas stations with additional information (e.g. prices (diff. to mean) in the last 30 days, active since, ...)
* Price differences by gas station brands and fuel sorts
* Map of the prices in the last 30 days for Super E5 by counties and states
* Time development of fuel prices in hourly, daily and monthly interval

## To-Do
* Structural analysis of regional price differences
* Combine fuel price data with traffic data

# Clone
To clone this repository use: https://chris:TOKEN@gitea.dahldata.com/chris/fuelprice.git


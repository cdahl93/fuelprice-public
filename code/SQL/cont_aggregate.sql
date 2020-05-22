CREATE VIEW daily_prices
WITH (timescaledb.continuous, 
	  timescaledb.max_interval_per_job = '1d',
	  timescaledb.refresh_interval = '1d',
	  timescaledb.refresh_lag = '10m')
AS
SELECT time_bucket('1 day', time) as day, 
	   round(avg(pe5),3) as e5,
       round(avg(pe10),3) as e10,
       round(avg(pdi),3) as diesel
FROM price
GROUP BY day;

CREATE VIEW hourly_prices
WITH (timescaledb.continuous, 
	  timescaledb.max_interval_per_job = '1d',
	  timescaledb.refresh_interval = '1d',
	  timescaledb.refresh_lag = '10m')
AS
SELECT time_bucket('1 hour', time) as hour, 
	   round(avg(pe5),3) as e5,
       round(avg(pe10),3) as e10,
       round(avg(pdi),3) as diesel
FROM price
GROUP BY hour;

REFRESH MATERIALIZED VIEW daily_prices;

DROP MATERIALIZED VIEW daily_prices;
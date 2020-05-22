-- Request for average price by state / county
	-- Create temporary table with average prices over defined time period for each station_id
	SELECT price.stid, AVG(pe5) INTO TEMPORARY station_price FROM price
	WHERE price.time BETWEEN '2018-01-01' AND '2018-01-31'
	GROUP BY price.stid;

	-- Create temporary table with station_id and community_code based on ZIP codes
	SELECT stations.stid, community_code INTO TEMPORARY station_zip FROM stations
	INNER JOIN kkzplz
	ON stations.zip = kkzplz.zipcode;

	-- Create output of average fuel price for each community_code
	SELECT station_zip.community_code, AVG(station_price.avg) FROM station_price
	INNER JOIN station_zip
	ON station_price.stid = station_zip.stid
	GROUP BY station_zip.community_code;

	-- NEW
	SELECT price.stid, AVG(price.pe5) INTO TEMPORARY station_price FROM price
	WHERE price.time BETWEEN '2019-07-01' AND '2019-07-31'
	GROUP BY price.stid;

	-- COMBINED QUERY
	SELECT bl_name, AVG(pe5) FROM (
	(SELECT price.stid, avg(price.pe5) AS pe5 FROM price
	WHERE price.time BETWEEN '2019-10-03 00:00:00' AND '2019-11-02 23:59:59'
	GROUP BY price.stid) AS pricecc
	INNER JOIN stations ON stations.uuid = pricecc.stid) GROUP BY bl_name;


-- Request number of stations, area and population by state or county
	-- State Request
	SELECT stations.bl_kz, stations.bl_name, stat_num, area.area_bl, pop.pop_bl, round(stat_num/area.area_bl,4) AS a_dens, round(stat_num*1000/(pop.pop_bl),4) AS p_dens
	FROM (SELECT bl_kz, bl_name, count(*) AS stat_num FROM stations
		  WHERE bl_kz IS NOT NULL
		  GROUP BY bl_kz, bl_name) stations
	LEFT JOIN (SELECT bl_kz, area_bl FROM area_bl
			   WHERE date = '2016-12-31') area
	ON stations.bl_kz = area.bl_kz
	LEFT JOIN (SELECT bl_kz, pop_bl FROM pop_bl
			   WHERE date = '2018-12-31') pop
	ON stations.bl_kz = pop.bl_kz
	ORDER BY bl_kz ASC;

	-- County Request with cars
	SELECT stations.kreis_kz, stations.kreis_name, stat_num, 
	area.area_kreis, pop.pop_kreis, 
	round(stat_num/area.area_kreis,4) AS a_dens, 
	round(stat_num*1000/(pop.pop_kreis),4) AS p_dens,
	cars.kfz, cars.lkw
	FROM (SELECT kreis_kz, kreis_name, count(*) AS stat_num FROM stations
		  WHERE kreis_kz IS NOT NULL
		  GROUP BY kreis_kz, kreis_name) stations
	LEFT JOIN (SELECT kreis_kz, area_kreis FROM area_kreis
			   WHERE date = '2016-12-31') area
	ON stations.kreis_kz = area.kreis_kz
	LEFT JOIN (SELECT kreis_kz, pop_kreis FROM pop_kreis
			   WHERE date = '2018-12-31') pop
	ON stations.kreis_kz = pop.kreis_kz
	LEFT JOIN (SELECT kreis_kz, kfz, lkw FROM car_numbers
			  WHERE date = '2019-01-01') cars
	ON stations.kreis_kz = cars.kreis_kz
	ORDER BY kreis_kz ASC;
	
	-- 7 largest cities
	SELECT pop.kreis_kz, stations.kreis_name, count, pop.pop_kreis, area.area_kreis,
	   round(count/area.area_kreis, 4) AS a_dens, round(count*1000/pop.pop_kreis, 4) as p_dens
FROM (SELECT kreis_kz, pop_kreis FROM pop_kreis
	  WHERE date = '2018-12-31' AND pop_kreis IS NOT NULL
	  ORDER by pop_kreis DESC
	  LIMIT 7) pop
LEFT JOIN (SELECT kreis_kz, kreis_name, count(*) AS count FROM stations
		   GROUP BY kreis_kz, kreis_name) stations
ON pop.kreis_kz = stations.kreis_kz
LEFT JOIN (SELECT kreis_kz, area_kreis FROM area_kreis
		   WHERE date = '2016-12-31') area
ON pop.kreis_kz = area.kreis_kz
ORDER BY pop.kreis_kz ASC;
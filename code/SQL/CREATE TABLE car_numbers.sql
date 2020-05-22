CREATE TABLE car_numbers (
	date				date						NOT NULL,
	kreis_kz			character(5)				NOT NULL,
	kreis_name			character varying(250)		NOT NULL,
	kfz					integer,
	rad					integer,
	rad_lei				integer,
	rad_mot				integer,
	pkw					integer,
	pkw_ott				integer,
	pkw_die				integer,
	bus					integer,
	lkw					integer,
	lkw_spe				integer,
	zug					integer,
	zug_gew				integer,
	zug_sat				integer,
	schlepp				integer,
	kfz_son				integer,
	wohnmob				integer,
	anhang				integer,
	anhang_las			integer,
	sattel				integer
);

CREATE INDEX ON car_numbers (kreis_kz, date ASC);
CREATE TABlE area_kreis (
	kreis_kz			character(5)					NOT NULL,
	kreis_name			character varying(250)			NOT NULL,
	date				date							NOT NULL,
	area_kreis			numeric(22,2)							
);

CREATE INDEX ON area_kreis (kreis_kz, date ASC);
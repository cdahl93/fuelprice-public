CREATE TABlE pop_kreis (
	kreis_kz			character(5)					NOT NULL,
	kreis_name			character varying(250)			NOT NULL,
	date				date							NOT NULL,
	pop_kreis			numeric(9)							
);

CREATE INDEX ON pop_kreis (kreis_kz, date ASC);
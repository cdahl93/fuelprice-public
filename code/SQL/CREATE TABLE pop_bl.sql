CREATE TABlE pop_bl (
	bl_kz			character(2)					NOT NULL,
	bl_name			character varying(250)			NOT NULL,
	date			date							NOT NULL,
	pop_bl			numeric(9)							
);

CREATE INDEX ON pop_bl (bl_kz, date ASC);
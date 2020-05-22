CREATE TABlE area_bl (
	bl_kz			character(2)					NOT NULL,
	bl_name			character varying(250)			NOT NULL,
	date			date							NOT NULL,
	area_bl			numeric(22,2)							
);

CREATE INDEX ON area_bl (bl_kz, date ASC);
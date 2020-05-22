CREATE TABLE bbsr_gemeinden_2017 (
	gem17				character(8)				NOT NULL,
	name17				character varying(250)		NOT NULL,
	fl17				integer,
	vbgem17				character(8),
	vbgnam17			character varying(250),
	plz					character(5),
	plzmulti			integer,
	krs17				character(8),
	krs17_name			character varying(250),
	ktyp4				integer,
	ktyp4_name			character varying(250),
	slraum				integer,
	slraum_name			character varying(250),
	ror11				character(4),
	ror11_name			character varying(250),
	rtyp3				integer,
	rtyp3_name			character varying(250),
	nuts2				character(4),
	nuts2_name			character varying(250),
	grenzreg_v1			character varying(10),
	grenzreg_v2			character varying(10),
	metropolen_IKM_2015_a	character varying(250),
	metropolen_IKM_2015_b	character varying(250),
	land				character(2),
	ow					integer
);

CREATE INDEX ON bbsr_gemeinden_2017 (krs17);
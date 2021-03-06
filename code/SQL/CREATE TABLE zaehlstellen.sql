CREATE TABLE zaehlstellen (
	jahr						integer						NOT NULL,
	tk_nr						integer						NOT NULL,
	dz_nr						integer						NOT NULL,
	dz_name						character varying(150)		NOT NULL,
	land_nr						integer						NOT NULL,
	land_code					character(2)				NOT NULL,
	str_kl						character(1),
	str_nr						integer,
	str_zus						character varying(10),
	erf_art						character varying(10),
	fernziel_ri1				character varying(150),
	nahziel_ri1					character varying(150),
	hi_ri1						character(1),
	fernziel_ri2				character varying(150),
	nahziel_ri2					character varying(150),
	hi_ri2						character(1),
	anz_fs_q					integer,
	vt_mobisso					integer,
	dtv_kfz_mobisso_q			numeric(20),
	dtv_kfz_mobisso_ri1			numeric(20),
	dtv_kfz_mobisso_ri2			numeric(20),
	dtv_sv_mobisso_q			numeric(20),
	dtv_sv_mobisso_ri1			numeric(20),
	dtv_sv_mobisso_ri2			numeric(20),
	psv_mobisso_q				numeric(4,1),
	fer							numeric(5,2),
	bso							numeric(5,2),
	bfr							numeric(5,2),
	mt							numeric(20),
	pmt							numeric(4,1),
	mn							numeric(20),
	pmn							numeric(4,1),
	md							numeric(20),
	pmd							numeric(4,1),
	me							numeric(20),
	pme							numeric(4,1),
	dl_ri1						character(1),
	dl_ri2						character(1),
	pplz_mobisso_q				numeric(4,1),
	pLfw_MobisSo_Q				numeric(4,1),
	pMot_MobisSo_Q				numeric(4,1),
	pPmA_MobisSo_Q				numeric(4,1),
	pLoA_MobisSo_Q				numeric(4,1),
	pLzg_MobisSo_Q				numeric(4,1),
	pSat_MobisSo_Q				numeric(4,1),
	pBus_MobisSo_Q				numeric(4,1),
	pSon_MobisSo_Q				numeric(4,1),
	Koor_UTM32_E				numeric(10),
	Koor_UTM32_N				numeric(10),
	MSV30_Kfz_MobisSo_Ri1		numeric(20),
	MSV30_Kfz_MobisSo_Ri2		numeric(20),
	bSV30_MobisSo_Ri1			numeric(5,1),
	bSV30_MobisSo_Ri2			numeric(5,1),
	DTV_Kfz_W_MobisFr_Q			numeric(20),
	DTV_Kfz_W_MobisFr_Ri1		numeric(20),
	DTV_Kfz_W_MobisFr_Ri2		numeric(20),
	pSV_W_MobisFr_Q				numeric(4,1),
	pSV_W_MobisFr_Ri1			numeric(4,1),
	pSV_W_MobisFr_Ri2			numeric(4,1),
	Koor_WGS84_N				numeric(15,12)				NOT NULL,
	Koor_WGS84_E				numeric(15,12)				NOT NULL,
	MSV50_Kfz_MobisSo_Ri1		numeric(20),
	MSV50_Kfz_MobisSo_Ri2		numeric(20),
	pMSV50_Kfz_MobisSo_Ri1		numeric(4,1),
	pMSV50_Kfz_MobisSo_Ri2		numeric(4,1),
	bSV50_MobisSo_Ri1			numeric(5,1),
	bSV50_MobisSo_Ri2			numeric(5,1),
	bLkwK50_MobisSo_Ri1			numeric(5,1),
	bLkwK50_MobisSo_Ri2			numeric(5,1),
	pMSV50_Kfz_W_MobisFr_Ri1	numeric(4,1),
	pMSV50_Kfz_W_MobisFr_Ri2	numeric(4,1),
	DTV_Kfz_NZB_DiMiDo_Ri1		numeric(20),
	DTV_Kfz_NZB_DiMiDo_Ri2		numeric(20),
	bSo_Ri1						numeric(5,2),
	bSo_Ri2						numeric(5,2),
	bMo_Ri1						numeric(5,2),
	bMo_Ri2						numeric(5,2),
	bFr_Ri1						numeric(5,2),
	bFr_Ri2						numeric(5,2),
	bSa_Ri1						numeric(5,2),
	bSa_Ri2						numeric(5,2),
	Q_P_t						numeric(20),
	Q_L1_t						numeric(20),
	Q_L2_t						numeric(20),
	Q_K_t						numeric(20),
	Q_P_n						numeric(20),
	Q_L1_n						numeric(20),
	Q_L2_n						numeric(20),
	Q_K_n						numeric(20),
	Q_P_a						numeric(20),
	Q_L1_a						numeric(20),
	Q_L2_a						numeric(20),
	Q_K_a						numeric(20),
	Anmerkungen					character varying(350),
	geopos						geometry(POINT,4326)
);

SELECT create_hypertable('zaehlstellen','jahr', chunk_time_interval => 1);

CREATE INDEX ON zaehlstellen (dz_nr, jahr DESC);
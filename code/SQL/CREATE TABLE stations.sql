CREATE TABLE stations (
  uuid			uuid					NOT NULL,	
  name			character varying(250)	NOT NULL,
  brand			character varying(150),				
  street		character varying(250),			
  house_number	character varying(150),			
  post_code		char(5),								
  city			character varying(150),	
  latitude		numeric(15,12)			NOT NULL,	
  longitude		numeric(15,12)			NOT NULL,	
  first_active	timestamptz,
  bl_kz			char(2),
  bl_name		character varying(150),
  kreis_kz      char(5),
  kreis_name    character varying(250),
  gemeinde_kz   char(12),
  gemeinde_name character varying(250)
);


# With brand category

CREATE TABLE stations (
  uuid			uuid					NOT NULL,	
  name			character varying(250)	NOT NULL,
  brand			character varying(150),				
  street		character varying(250),			
  house_number	character varying(150),			
  post_code		char(5),								
  city			character varying(150),	
  latitude		numeric(15,12)			NOT NULL,	
  longitude		numeric(15,12)			NOT NULL,	
  first_active	timestamptz,
  bl_kz			char(2),
  bl_name		character varying(150),
  kreis_kz      char(5),
  kreis_name    character varying(250),
  gemeinde_kz   char(12),
  gemeinde_name character varying(250),
  brand_cat		character varying(15)
);

CREATE INDEX ON stations (uuid);

# With brand category AND geoposition in postgis

CREATE TABLE stations (
  uuid			uuid					NOT NULL,	
  name			character varying(250)	NOT NULL,
  brand			character varying(150),				
  street		character varying(250),			
  house_number	character varying(150),			
  post_code		char(5),								
  city			character varying(150),	
  latitude		numeric(15,12)			NOT NULL,	
  longitude		numeric(15,12)			NOT NULL,	
  first_active	timestamptz,
  bl_kz			char(2),
  bl_name		character varying(150),
  kreis_kz      char(5),
  kreis_name    character varying(250),
  gemeinde_kz   char(12),
  gemeinde_name character varying(250),
  brand_cat		character varying(15),
  geopos		geometry(POINT,4326)
);

CREATE INDEX ON stations (uuid);

# With brand category AND geoposition in postgis AND location category

CREATE TABLE stations (
  uuid			uuid					NOT NULL,	
  name			character varying(250),
  brand			character varying(150),				
  street		character varying(250),			
  house_number	character varying(150),			
  post_code		char(5),								
  city			character varying(150),	
  latitude		numeric(15,12)			NOT NULL,	
  longitude		numeric(15,12)			NOT NULL,	
  first_active	timestamptz,
  bl_kz			char(2),
  bl_name		character varying(150),
  kreis_kz      char(5),
  kreis_name    character varying(250),
  gemeinde_kz   char(12),
  gemeinde_name character varying(250),
  brand_cat		character varying(15),
  street_cat	character varying(15),
  geopos		geometry(POINT,4326)
);

CREATE INDEX ON stations (uuid);
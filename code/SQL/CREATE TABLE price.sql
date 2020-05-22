CREATE TABLE price (
  time 		timestamptz 		NOT NULL,
  stid 		uuid 				NOT NULL,
  pdi 		numeric(8,3),
  pe5 		numeric(8,3),
  pe10 		numeric(8,3),
  cdi 		integer,
  ce5 		integer,
  ce10 		integer
);

SELECT create_hypertable('price','time');

CREATE INDEX ON price (stid, time DESC);


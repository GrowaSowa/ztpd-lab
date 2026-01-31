-- Oracle Spatial: Układy LRS (28.11)
-- 1A.
CREATE TABLE S6_LRS (
	geom SDO_GEOMETRY
);


-- 1B.
INSERT INTO S6_LRS (geom)
SELECT geom FROM streets_and_railroads s
WHERE SDO_WITHIN_DISTANCE(s.geom,
	(SELECT geom FROM major_cities WHERE city_name = 'Koszalin'),
	'distance=10 unit=km') = 'TRUE';


-- 1C.
SELECT SDO_GEOM.SDO_LENGTH(s.geom, 1, 'unit=km') AS distance,
ST_LINESTRING(s.geom).ST_NUMPOINTS() AS st_numpoints
FROM S6_LRS s;


-- 1D.
UPDATE S6_LRS SET geom = (
	SELECT SDO_LRS.CONVERT_TO_LRS_GEOM(s.geom, 0,
		SDO_GEOM.SDO_LENGTH(s.geom, 1, 'unit=km'))
	FROM S6_LRS s);

-- 1E.
INSERT INTO USER_SDO_GEOM_METADATA VALUES (
	'S6_LRS', 'GEOM',
	SDO_DIM_ARRAY(
		MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
		MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),
		MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1)
	), 8307
);


-- 1F.
CREATE INDEX s6_lrs_idx ON S6_LRS(geom)
indextype IS MDSYS.SPATIAL_INDEX;


-- 2A.
SELECT SDO_LRS.VALID_MEASURE(geom, 500) AS valid_500 FROM S6_LRS;


-- 2B.
SELECT SDO_LRS.GEOM_SEGMENT_END_PT(geom) AS end_pt FROM S6_LRS;


-- 2C.
SELECT SDO_LRS.LOCATE_PT(geom, 150, 0) AS km150 FROM S6_LRS;


-- 2D.
SELECT SDO_LRS.CLIP_GEOM_SEGMENT(geom, 120, 160) AS clipped FROM S6_LRS;


-- 2E.
SELECT SDO_LRS.PROJECT_PT(s.geom, C.GEOM) AS wjazd_na_s6
FROM S6_LRS s, major_cities c WHERE c.city_name = 'Slupsk';


-- 2F.
SELECT SDO_GEOM.SDO_LENGTH(
	SDO_LRS.OFFSET_GEOM_SEGMENT(s.geom, M.DIMINFO, 50, 200, 50,
'unit=m arc_tolerance=1'), 1, 'unit=km') * 1000000 AS koszt
FROM S6_LRS s, USER_SDO_GEOM_METADATA m
where m.table_name = 'S6_LRS' AND m.column_name = 'GEOM';
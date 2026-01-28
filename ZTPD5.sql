-- Oracle SPatial: Przetwarzanie danych (14.11)
-- 1A.
INSERT INTO USER_SDO_GEOM_METADATA VALUES (
	'figury', 'ksztalt',
	MDSYS.SDO_DIM_ARRAY(
		MDSYS.SDO_DIM_ELEMENT('X', 0, 10, 0.01),
		MDSYS.SDO_DIM_ELEMENT('Y', 0, 8, 0.01)
	), NULL
);


-- 1B.
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0) FROM dual;


-- 1C.
CREATE INDEX figury_idx ON figury(ksztalt) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;


-- 1D.
SELECT id FROM figury WHERE MDSYS.SDO_FILTER(ksztalt,
	MDSYS.SDO_GEOMETRY(2001, NULL,
		MDSYS.SDO_POINT_TYPE(3, 3, NULL), NULL, NULL)
) = 'TRUE';


-- 1E.
SELECT id FROM figury WHERE MDSYS.SDO_RELATE(ksztalt,
	MDSYS.SDO_GEOMETRY(2001, NULL,
		MDSYS.SDO_POINT_TYPE(3, 3, NULL), NULL, NULL),
	'mask=ANYINTERACT'
) = 'TRUE';


-- 2A.
SELECT c.city_name AS miasto, SDO_NN_DISTANCE(1) as odl
FROM major_cities c WHERE MDSYS.SDO_NN(geom,
	(SELECT geom FROM major_cities WHERE city_name = 'Warsaw'),
	'sdo_num_res=10 unit=km', 1) = 'TRUE' AND city_name != 'Warsaw';


-- 2B.
SELECT c.city_name AS miasto FROM major_cities c
WHERE MDSYS.SDO_WITHIN_DISTANCE(c.geom,
	(SELECT geom FROM major_cities WHERE city_name = 'Warsaw'),
	'distance=100 unit=km') = 'TRUE' AND city_name != 'Warsaw';


-- 2C.
SELECT b.cntry_name AS kraj, c.city_name AS miasto FROM country_boundaries b, major_cities c
WHERE MDSYS.SDO_RELATE(c.geom, b.geom, 'mask=INSIDE') = 'TRUE' AND b.cntry_name = 'Slovakia';


-- 2D.
SELECT b.cntry_name AS panstwo, SDO_GEOM.SDO_DISTANCE(b.geom,
	(SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland'),
	1, 'unit=km') AS odl
FROM country_boundaries b WHERE MDSYS.SDO_RELATE(b.geom,
	(SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland'),
	'mask=ANYINTERACT') != 'TRUE';


-- 3A.
SELECT b.cntry_name AS cntry_name, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(b.geom,
	(SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland'),
	1), 1, 'unit=km') AS odleglosc
FROM country_boundaries b WHERE MDSYS.SDO_RELATE(b.geom,
	(SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland'),
	'mask=TOUCH') = 'TRUE';


-- 3B.
SELECT b.cntry_name AS cntry_name FROM country_boundaries b
ORDER BY SDO_GEOM.SDO_AREA(b.geom, 1, 'unit=SQ_KM') DESC
FETCH FIRST 1 ROW ONLY;


-- 3C.
SELECT SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_MBR(
	SDO_GEOM.SDO_UNION(
		(SELECT geom FROM major_cities WHERE city_name = 'Warsaw'),
		(SELECT geom FROM major_cities WHERE city_name = 'Lodz'), 1)),
	1, 'unit=SQ_KM') AS sq_km FROM dual;


-- 3D.
SELECT SDO_GEOM.SDO_UNION(
	(SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland'),
	(SELECT geom FROM major_cities WHERE city_name = 'Prague'),
	1).GET_GTYPE() as gtype
FROM dual;


-- 3E.
SELECT c.city_name, b.cntry_name FROM country_boundaries b, major_cities c
WHERE MDSYS.SDO_RELATE(b.geom, c.geom, 'mask=CONTAINS') = 'TRUE'
ORDER BY SDO_GEOM.SDO_DISTANCE(c.geom,
	SDO_GEOM.SDO_CENTROID(b.geom, 1), 1, 'unit=km')
FETCH FIRST 1 ROW ONLY;


-- 3F.
SELECT r.name AS name, SUM(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(r.geom,
		(SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland'), 1),
	1, 'unit=km')) AS dlugosc FROM rivers r
WHERE MDSYS.SDO_RELATE(r.geom,
	(SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland'),
	'mask=ANYINTERACT') = 'TRUE' GROUP BY r.name;
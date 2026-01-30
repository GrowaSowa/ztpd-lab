-- Oracle Spatial: Standard SQL/MM (21.11)
-- 1A.
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
and prior t.owner = t.owner;


-- 1B.
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;


-- 1C.
CREATE TABLE myst_major_cities (
	fips_cntry VARCHAR2(2),
	city_name VARCHAR2(40),
	stgeom ST_POINT
);


-- 1D.
INSERT INTO myst_major_cities (fips_cntry, city_name, stgeom)
SELECT fips_cntry, city_name, ST_POINT(geom) FROM major_cities;


-- 2A.
INSERT INTO myst_major_cities VALUES ('PL', 'Szczyrk', ST_POINT(19.036107, 49.718655, 8307));


-- 3A.
CREATE TABLE myst_country_boundaries (
	fips_cntry VARCHAR2(2),
	cntry_name VARCHAR2(40),
	stgeom ST_MULTIPOLYGON
);


-- 3B.
INSERT INTO myst_country_boundaries (fips_cntry, cntry_name, stgeom)
SELECT fips_cntry, cntry_name, ST_MULTIPOLYGON(geom) FROM country_boundaries;


-- 3C.
SELECT b.stgeom.ST_GEOMETRYTYPE() AS typ_obiektu, COUNT(*) AS ile FROM myst_country_boundaries b
GROUP BY b.stgeom.ST_GEOMETRYTYPE();


-- 3D.
SELECT b.stgeom.ST_ISSIMPLE() FROM myst_country_boundaries b;


-- 4A.
SELECT b.cntry_name AS cntry_name, COUNT(*) FROM myst_country_boundaries b, myst_major_cities c
WHERE c.stgeom.ST_WITHIN(b.stgeom) = 1
GROUP BY b.cntry_name;


-- 4B.
SELECT a.cntry_name, b.cntry_name FROM myst_country_boundaries a, myst_country_boundaries b
WHERE a.stgeom.ST_TOUCHES(b.stgeom) = 1 AND b.cntry_name = 'Czech Republic';


-- 4C.
SELECT UNIQUE b.cntry_name AS cntry_name, r.name AS name FROM myst_country_boundaries b, rivers r
WHERE ST_LINESTRING(r.geom).ST_INTERSECTS(b.stgeom) = 1 AND b.cntry_name = 'Czech Republic';


-- 4D.
SELECT TREAT(a.stgeom.ST_UNION(b.stgeom) AS ST_POLYGON).ST_AREA() AS powierzchnia FROM myst_country_boundaries a, myst_country_boundaries b
WHERE a.cntry_name = 'Czech Republic' AND b.cntry_name = 'Slovakia';


-- 4E.
SELECT b.stgeom.ST_DIFFERENCE(ST_GEOMETRY(w.geom)).ST_GEOMETRYTYPE() AS wegry_bez
FROM myst_country_boundaries b, water_bodies w
WHERE b.cntry_name = 'Hungary' AND w.name = 'Balaton';


-- 5A.
SELECT b.cntry_name AS a_name, count(*)
FROM myst_country_boundaries b, myst_major_cities c
WHERE SDO_WITHIN_DISTANCE(c.stgeom, b.stgeom,
	'distance=100 unit=km') = 'TRUE' AND b.cntry_name = 'Poland'
GROUP BY b.cntry_name;

EXPLAIN PLAN FOR SELECT b.cntry_name AS a_name, count(*)
FROM myst_country_boundaries b, myst_major_cities c
WHERE SDO_WITHIN_DISTANCE(c.stgeom, b.stgeom,
	'distance=100 unit=km') = 'TRUE' AND b.cntry_name = 'Poland'
GROUP BY b.cntry_name;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- 5B.
INSERT INTO USER_SDO_GEOM_METADATA VALUES (
	'MYST_MAJOR_CITIES', 'STGEOM',
	SDO_DIM_ARRAY(
		MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
		MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1)
	), 8307
);


-- 5C.
CREATE INDEX myst_major_cities_idx ON myst_major_cities(stgeom)
indextype IS MDSYS.SPATIAL_INDEX;


-- 5D.
SELECT b.cntry_name AS a_name, count(*)
FROM myst_country_boundaries b, myst_major_cities c
WHERE SDO_WITHIN_DISTANCE(c.stgeom, b.stgeom,
	'distance=100 unit=km') = 'TRUE' AND b.cntry_name = 'Poland'
GROUP BY b.cntry_name;

EXPLAIN PLAN FOR SELECT b.cntry_name AS a_name, count(*)
FROM myst_country_boundaries b, myst_major_cities c
WHERE SDO_WITHIN_DISTANCE(c.stgeom, b.stgeom,
	'distance=100 unit=km') = 'TRUE' AND b.cntry_name = 'Poland'
GROUP BY b.cntry_name;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

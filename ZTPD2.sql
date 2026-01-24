-- Duże obiekty binarne (17.10)
-- 1.
CREATE TABLE movies_ztpd AS SELECT * FROM ZTPD.MOVIES;


-- 2.
DESC movies_ztpd;


-- 3.
SELECT ID, TITLE FROM movies_ztpd WHERE COVER IS NULL;


-- 4.
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS FILESIZE FROM movies_ztpd WHERE COVER IS NOT NULL;


-- 5.
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS FILESIZE FROM movies_ztpd WHERE COVER IS NULL;


-- 6.
SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'TPD_DIR';


-- 7.
UPDATE movies_ztpd SET COVER = EMPTY_BLOB(), MIME_TYPE = 'image/jpeg' WHERE ID = 66;
COMMIT;


-- 8.
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS FILESIZE FROM movies_ztpd WHERE ID = 65 OR ID = 66;


-- 9.
DECLARE
	cover_file BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
	blobvar BLOB;
BEGIN
	SELECT COVER INTO blobvar FROM movies_ztpd WHERE ID = 66 FOR UPDATE;

	DBMS_LOB.fileopen(cover_file, DBMS_LOB.file_readonly);
	DBMS_LOB.LOADFROMFILE(blobvar, cover_file, DBMS_LOB.GETLENGTH(cover_file));
	DBMS_LOB.FILECLOSE(cover_file);
	COMMIT;
END;

-- 10.
CREATE TABLE temp_covers (
	movie_id NUMBER(12),
	image BFILE,
	mime_type VARCHAR2(50)
);


-- 11.
INSERT INTO temp_covers VALUES (
	65, BFILENAME('TPD_DIR', 'eagles.jpg'), 'image/jpeg'
);
COMMIT;


-- 12.
SELECT movie_id, DBMS_LOB.GETLENGTH(image) AS FILESIZE FROM temp_covers WHERE movie_id = 65;


-- 13.
DECLARE
	cover_file BFILE;
	mime VARCHAR2(50);
	blobvar BLOB;
BEGIN
	SELECT image INTO cover_file FROM temp_covers WHERE movie_id = 65;
	SELECT mime_type INTO mime FROM temp_covers WHERE movie_id = 65;
	DBMS_LOB.createtemporary(blobvar, TRUE);
	DBMS_LOB.fileopen(cover_file, DBMS_LOB.file_readonly);
	DBMS_LOB.LOADFROMFILE(blobvar, cover_file, DBMS_LOB.GETLENGTH(cover_file));
	DBMS_LOB.FILECLOSE(cover_file);
	UPDATE movies_ztpd SET COVER = blobvar, MIME_TYPE = mime WHERE ID = 65;
	DBMS_LOB.freetemporary(blobvar);
	COMMIT;
END;


-- 14.
SELECT ID, DBMS_LOB.GETLENGTH(COVER) AS FILESIZE FROM movies_ztpd WHERE ID = 65 or ID = 66;


-- 15.
DROP TABLE movies_ztpd;
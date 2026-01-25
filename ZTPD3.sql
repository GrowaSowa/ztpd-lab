-- Duże obiekty tekstowe (24.10)
-- 1.
CREATE TABLE dokumenty (
	id NUMBER(12) PRIMARY KEY,
	dokument CLOB
);


-- 2.
DECLARE
	clob_obj CLOB;
	i NUMBER;
BEGIN
	DBMS_LOB.createtemporary(clob_obj, TRUE);
	FOR i in 1..10000 LOOP
		DBMS_LOB.append(clob_obj, 'Oto tekst. ');
	END LOOP;
	INSERT INTO dokumenty VALUES (1, clob_obj);
	DBMS_LOB.freetemporary(clob_obj);
	COMMIT;
END;


-- 3.
SELECT * FROM dokumenty;

SELECT id, UPPER(dokument) FROM dokumenty;

SELECT id, LENGTH(dokument) FROM dokumenty;

SELECT id, DBMS_LOB.GETLENGTH(dokument) FROM dokumenty;

SELECT id, SUBSTR(dokument, 5, 1000) FROM dokumenty;

SELECT id, DBMS_LOB.SUBSTR(dokument, 1000, 5) FROM dokumenty;


-- 4.
INSERT INTO dokumenty VALUES (2, EMPTY_CLOB());


-- 5.
INSERT INTO dokumenty VALUES (3, NULL);
COMMIT;


-- 6.
SELECT * FROM dokumenty;

SELECT id, UPPER(dokument) FROM dokumenty;

SELECT id, LENGTH(dokument) FROM dokumenty;

SELECT id, DBMS_LOB.GETLENGTH(dokument) FROM dokumenty;

SELECT id, SUBSTR(dokument, 5, 1000) FROM dokumenty;

SELECT id, DBMS_LOB.SUBSTR(dokument, 1000, 5) FROM dokumenty;


-- 7.
DECLARE
	doc_file BFILE := BFILENAME('TPD_DIR', 'dokument.txt');
	clob_obj CLOB;
	d_offset INTEGER := 1;
	s_offset INTEGER := 1;
	lang_ctx INTEGER := 0;
	w_id INTEGER := 0;
BEGIN
	SELECT dokument INTO clob_obj FROM dokumenty WHERE id = 2 FOR UPDATE;

	DBMS_LOB.FILEOPEN(doc_file, DBMS_LOB.file_readonly);
	DBMS_LOB.LOADCLOBFROMFILE(
		dest_lob => clob_obj,
		src_bfile => doc_file,
		amount => DBMS_LOB.GETLENGTH(doc_file),
		dest_offset => d_offset,
		src_offset => s_offset,
		bfile_csid => 0,
		lang_context => lang_ctx,
		warning => w_id);
	DBMS_LOB.FILECLOSE(doc_file);
	COMMIT;
	IF w_id = DBMS_LOB.WARN_INCONVERTIBLE_CHAR THEN
		DBMS_OUTPUT.PUT_LINE('Napotkano nierozpoznawalny znak.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Tekst skopiowano pomyślnie.');
	END IF;
END;


-- 8.
UPDATE dokumenty SET dokument = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt'), 0) WHERE id = 3;


-- 9.
SELECT * FROM dokumenty;


-- 10.
SELECT id, DBMS_LOB.GETLENGTH(dokument) FROM dokumenty;


-- 11.
DROP TABLE dokumenty;


-- 12.
CREATE OR REPLACE PROCEDURE CLOB_CENSOR (
	obj IN OUT CLOB,
	to_censor IN VARCHAR2
)
IS
	i INTEGER;
	amt INTEGER := 1;
	loc INTEGER;
	replacement VARCHAR2(50);
BEGIN
	FOR i in 1..LENGTH(to_censor) LOOP
		replacement := replacement || '.';
	END LOOP;

	loc := DBMS_LOB.INSTR(obj, to_censor);
	WHILE loc > 0 LOOP
		amt := LENGTH(to_censor);
		DBMS_LOB.WRITE(obj, amt, loc, replacement);
		loc := DBMS_LOB.INSTR(obj, to_censor);
	END LOOP;
END;


-- 13.
CREATE TABLE biographies_ztpd AS SELECT * FROM ZTPD.BIOGRAPHIES;

DECLARE
	bio CLOB;
BEGIN
	SELECT BIO INTO bio FROM biographies_ztpd WHERE ID = 1 FOR UPDATE;
	CLOB_CENSOR(bio, 'Cimrman');
	UPDATE biographies_ztpd SET BIO = bio WHERE ID = 1;
	COMMIT;
END;

SELECT * FROM biographies_ztpd;


-- 14.
DROP TABLE biographies_ztpd;
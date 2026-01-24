-- Obiektowo-relacyjne bazy danych (10.10)
DROP TABLE samochody CASCADE CONSTRAINTS;
DROP TABLE wlasciciele CASCADE CONSTRAINTS;
DROP TYPE samochod;
DROP TYPE wlasciciel;


-- 1.
CREATE OR REPLACE TYPE samochod AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2)
);
/

CREATE TABLE samochody OF samochod;
INSERT INTO samochody VALUES (
    NEW samochod('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999','DD-MM-YYYY'), 25000)
);
INSERT INTO samochody VALUES (
    NEW samochod('FORD', 'MONDEO', 80000, TO_DATE('10-05-1997','DD-MM-YYYY'), 45000)
);
INSERT INTO samochody VALUES (
    NEW samochod('MAZDA', '323', 12000, TO_DATE('22-09-2000','DD-MM-YYYY'), 52000)
);
/

SELECT * FROM samochody;


-- 2.
ALTER TYPE samochod REPLACE AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produkcji) >= 10 THEN
            RETURN 0;
        ELSE
            RETURN cena * (1 - (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produkcji))/10);
        END IF;
    END wartosc;
END;
/


-- 3.
ALTER TYPE samochod ADD MAP MEMBER FUNCTION zuzycie RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produkcji) >= 10 THEN
            RETURN 0;
        ELSE
            RETURN cena * (1 - (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produkcji))/10);
        END IF;
    END wartosc;
    
    MAP MEMBER FUNCTION zuzycie RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produkcji) + kilometry/10000;
    END zuzycie;
END;
/

SELECT * FROM samochody s ORDER BY VALUE(s);


-- 4.
CREATE TABLE wlasciciele (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    AUTO samochod
);
INSERT INTO wlasciciele VALUES (
    'JAN', 'KOWALSKI',
    NEW samochod('FIAT', 'SEICENTO', 30000, TO_DATE('02-12-0010','DD-MM-YYYY'), 19500)
);
INSERT INTO wlasciciele VALUES (
    'ADAM', 'NOWAK',
    NEW samochod('OPEL', 'ASTRA', 34000, TO_DATE('01-06-0009','DD-MM-YYYY'), 33700)
);
/

SELECT * FROM wlasciciele;


-- 5.
DROP TABLE wlasciciele;


-- 6.
CREATE OR REPLACE TYPE wlasciciel AS OBJECT (
    imie VARCHAR2(30),
    nazwisko VARCHAR2(30)
);
/

CREATE TABLE wlasciciele OF wlasciciel;
INSERT INTO wlasciciele VALUES (
	NEW wlasciciel('JAN', 'KOWALSKI')
);
INSERT INTO wlasciciele VALUES (
	NEW wlasciciel('ADAM', 'NOWAK')
);
/

SELECT * FROM wlasciciele;


-- 7.
ALTER TYPE samochod ADD ATTRIBUTE wlasciciel_samochodu REF wlasciciel CASCADE;


-- 8.
DELETE FROM samochody;


-- 9.
ALTER TABLE samochody ADD SCOPE FOR(wlasciciel_samochodu) IS wlasciciele;


-- 10.
INSERT INTO samochody VALUES (
    NEW samochod('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999','DD-MM-YYYY'), 25000, null)
);
INSERT INTO samochody VALUES (
    NEW samochod('FORD', 'MONDEO', 80000, TO_DATE('10-05-1997','DD-MM-YYYY'), 45000, null)
);
/

UPDATE samochody s SET s.wlasciciel_samochodu = (
	SELECT REF(w) FROM wlasciciele w WHERE w.nazwisko = 'KOWALSKI'
);
/

SELECT * FROM samochody;


-- 11.
DECLARE
	TYPE przedmioty IS VARRAY(10) of VARCHAR(20);
	moje_przedmioty przedmioty := przedmioty('');
BEGIN
	moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
	FOR i IN 2..10 LOOP
		moje_przedmioty(i) := 'PRZEDMIOT_' || i;
	END LOOP;

	FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
		DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
	END LOOP;

	moje_przedmioty.TRIM(2);

	FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
		DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
	END LOOP;
END;

-- 12.
DECLARE
	TYPE ksiazki IS VARRAY(10) of VARCHAR(20);
	moje_ksiazki ksiazki := ksiazki('');
BEGIN
	moje_ksiazki(1) := 'HARRY POTTER';
	moje_ksiazki.EXTEND(9);
	FOR i IN 2..10 LOOP
		moje_ksiazki(i) := 'KSIAZKA_' || i;
	END LOOP;

	FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
		DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
	END LOOP;

	moje_ksiazki.TRIM(2);

	FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
		DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
	END LOOP;
END;

-- 13.
DECLARE
	TYPE wykladowcy IS TABLE of VARCHAR2(20);
	moi_wykladowcy wykladowcy := wykladowcy();
BEGIN
	moi_wykladowcy.EXTEND(2);
	moi_wykladowcy(1) := 'MORZY';
	moi_wykladowcy(2) := 'WOJCIECHOWSKI';
	moi_wykladowcy.EXTEND(8);
	FOR i IN 3..10 LOOP
		moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
	END LOOP;

	FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
		DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
	END LOOP;

	moi_wykladowcy.TRIM(2);

	FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
		DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
	END LOOP;

	moi_wykladowcy.DELETE(5,7);

	DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
	DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());

	FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
		IF moi_wykladowcy.EXISTS(i) THEN
			DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
		END IF;
	END LOOP;

	moi_wykladowcy(5) := 'ZAKRZEWICZ';
	moi_wykladowcy(6) := 'KROLIKOWSKI';
	moi_wykladowcy(7) := 'KOSZLAJDA';
	FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
		IF moi_wykladowcy.EXISTS(i) THEN
			DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
		END IF;
	END LOOP;

	DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
	DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

-- 14.
DECLARE
	TYPE miesiac IS TABLE of VARCHAR2(20);
	miesiace miesiac := miesiac();
BEGIN
	miesiace.EXTEND(12);
	miesiace(1) := 'STYCZEN';
	miesiace(2) := 'LUTY';
	miesiace(3) := 'MARZEC';
	miesiace(4) := 'KWIECIEN';
	miesiace(5) := 'MAJ';
	miesiace(6) := 'CZERWIEC';
	miesiace(7) := 'LIPIEC';
	miesiace(8) := 'SIERPIEN';
	miesiace(9) := 'WRZESIEN';
	miesiace(10) := 'PAZDZIERNIK';
	miesiace(11) := 'LISTOPAD';
	miesiace(12) := 'GRUDZIEN';

	miesiace.DELETE(4, 10);

	FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
		IF miesiace.EXISTS(i) THEN
			DBMS_OUTPUT.PUT_LINE(miesiace(i));
		END IF;
	END LOOP;
END;

-- 15.
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/

CREATE TYPE stypendium AS OBJECT (
	nazwa VARCHAR2(50),
	kraj VARCHAR2(30),
	jezyki jezyki_obce
);
/

CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES (
	'SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI')
);
INSERT INTO stypendia VALUES (
	'ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI')
);

SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;

UPDATE stypendia
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/

CREATE TYPE semestr AS OBJECT (
	numer NUMBER,
	egzaminy lista_egzaminow
);
/

CREATE TABLE semestry OF semestr NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES (
	semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA'))
);
INSERT INTO semestry VALUES (
	semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE'))
);

SELECT s.numer, e.* FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.* FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );

INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) VALUES ('METODY NUMERYCZNE');

UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';

DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';


-- 16.
DROP TABLE zakupy;
DROP TYPE zakup;
DROP TYPE koszyk;

CREATE OR REPLACE TYPE koszyk AS TABLE OF VARCHAR2(20);
/

CREATE OR REPLACE TYPE zakup AS OBJECT (
	id NUMBER,
	data_zakupu DATE,
	koszyk_produktow koszyk
);
/

CREATE TABLE zakupy OF zakup NESTED TABLE koszyk_produktow STORE AS tab_koszyk;
INSERT INTO zakupy VALUES (
	zakup(1, CURRENT_DATE, koszyk('CHLEB 500G', 'SER 300G'))
);
INSERT INTO zakupy VALUES (
	zakup(2, CURRENT_DATE, koszyk('CHIPSY LAYS 140G', 'SER 300G', 'MLEKO 1L'))
);
INSERT INTO zakupy VALUES (
	zakup(3, CURRENT_DATE, koszyk('CHLEB 500G', 'BATON 42G'))
);

SELECT z.data_zakupu, k.*  FROM zakupy z, TABLE (z.koszyk_produktow) k; 

DELETE FROM zakupy
WHERE id IN (SELECT z.id FROM zakupy z, TABLE(z.koszyk_produktow) k WHERE k.column_value = 'SER 300G');

SELECT z.data_zakupu, k.*  FROM zakupy z, TABLE (z.koszyk_produktow) k;


-- 17.
CREATE TYPE instrument AS OBJECT (
	nazwa VARCHAR2(20),
	dzwiek VARCHAR2(20),
	MEMBER FUNCTION graj RETURN VARCHAR2
) NOT FINAL;
/

CREATE TYPE BODY instrument AS
	MEMBER FUNCTION graj RETURN VARCHAR2 IS
	BEGIN
		RETURN dzwiek;
	END;
END;
/

CREATE OR REPLACE TYPE instrument_dety UNDER instrument (
	material VARCHAR2(20),
	OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
	MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY instrument_dety AS
	OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
	BEGIN
		RETURN 'dmucham: '||dzwiek;
	END;

	MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
	BEGIN
		RETURN glosnosc||':'||dzwiek;
	END;
END;
/

CREATE OR REPLACE TYPE instrument_klawiszowy UNDER instrument (
	producent VARCHAR2(20),
	OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
	OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
	BEGIN
		RETURN 'stukam w klawisze: '||dzwiek;
	END;
END;
/

DECLARE
	tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
	trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
	fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','ping-ping','steinway');
BEGIN
	dbms_output.put_line(tamburyn.graj);
	dbms_output.put_line(trabka.graj);
	dbms_output.put_line(trabka.graj('glosno'));
	dbms_output.put_line(fortepian.graj);
END;


-- 18.
CREATE TYPE istota AS OBJECT (
	nazwa VARCHAR2(20),
	NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
) NOT INSTANTIABLE NOT FINAL;
/

CREATE TYPE lew UNDER istota (
	liczba_nog NUMBER,
	OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
);
/

CREATE OR REPLACE TYPE BODY lew AS
	OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
	BEGIN
		RETURN 'upolowana ofiara: '||ofiara;
	END;
END;

DECLARE
	KrolLew lew := lew('LEW',4);
	InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
	DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;

-- 19.
DECLARE
	tamburyn instrument;
	cymbalki instrument;
	trabka instrument_dety;
	saksofon instrument_dety;
BEGIN
	tamburyn := instrument('tamburyn','brzdek-brzdek');
	cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
	trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
	-- saksofon := instrument('saksofon','tra-taaaa');
	-- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

-- 20.
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES (
	instrument('tamburyn','brzdek-brzdek')
);
INSERT INTO instrumenty VALUES (
	instrument_dety('trabka','tra-ta-ta','metalowa')
);
INSERT INTO instrumenty VALUES (
	instrument_klawiszowy('fortepian','ping-ping','steinway')
);
/

SELECT i.nazwa, i.graj() FROM instrumenty i;
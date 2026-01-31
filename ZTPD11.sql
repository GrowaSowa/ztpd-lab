-- Oracle Text (09.01)

-- Operator CONTAINS - Podstawy
-- 1.
CREATE TABLE cytaty_ztpd AS SELECT * FROM ZTPD.CYTATY;


-- 2.
SELECT autor, tekst FROM cytaty_ztpd
WHERE LOWER(tekst) LIKE '%pesymista%' AND LOWER(tekst) LIKE '%optymista%';

-- 3.
CREATE INDEX cytaty_ztpd_idx on cytaty_ztpd(tekst)
indextype IS CTXSYS.CONTEXT;


-- 4.
SET DEFINE OFF;
SELECT autor, tekst FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'pesymista & optymista') > 0;


-- 5.
SELECT autor, tekst FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'pesymista ~ optymista') < 1;


-- 6.
SELECT autor, tekst FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'near((pesymista, optymista), 3)') > 0;


-- 7.
SELECT autor, tekst FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'near((pesymista, optymista), 10)') > 0;


-- 8.
SELECT autor, tekst FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'życi%') > 0;


-- 9.
SELECT autor, tekst, SCORE(1) AS dopasowanie FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'życi%', 1) > 0;


-- 10.
SELECT autor, tekst, SCORE(1) AS dopasowanie FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'życi%', 1) > 0
ORDER BY dopasowanie DESC FETCH FIRST 1 ROW ONLY;


-- 11.
SELECT autor, tekst FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'fuzzy(probelm)') > 0;


-- 12.
INSERT INTO cytaty_ztpd VALUES (
	(SELECT COUNT(*) FROM cytaty_ztpd)+1,
	'Bertrand Russell',
	'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.'
);
COMMIT;


-- 13.
SELECT autor, tekst FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'głupcy') > 0;


-- 14.
SELECT table_name FROM all_tables WHERE table_name LIKE '%CYTATY_ZTPD_IDX%';

SELECT * FROM DR$cytaty_ztpd_idx$I WHERE token_text LIKE 'GŁUPCY';


-- 15.
DROP INDEX cytaty_ztpd_idx;

CREATE INDEX cytaty_ztpd_idx on cytaty_ztpd(tekst)
indextype IS CTXSYS.CONTEXT;


-- 16.
SELECT autor, tekst FROM cytaty_ztpd
WHERE CONTAINS(tekst, 'głupcy') > 0;


-- 17.
DROP INDEX cytaty_ztpd_idx;

DROP TABLE cytaty_ztpd;


-- Zaawansowane indeksowanie i wyszukiwanie
-- 1.
CREATE TABLE quotes_ztpd AS SELECT * FROM ZTPD.QUOTES;


-- 2.
CREATE INDEX quotes_ztpd_idx on quotes_ztpd(text)
indextype IS CTXSYS.CONTEXT;


-- 3.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'work') > 0;

SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, '$work') > 0;

SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'working') > 0;

SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, '$working') > 0;


-- 4.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'it') > 0;


-- 5.
SELECT * FROM CTX_STOPLISTS;


-- 6.
SELECT * FROM CTX_STOPWORDS;


-- 7.
DROP INDEX quotes_ztpd_idx;

CREATE INDEX quotes_ztpd_idx on quotes_ztpd(text)
indextype IS CTXSYS.CONTEXT PARAMETERS('stoplist CTXSYS.EMPTY_STOPLIST');


-- 8.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'it') > 0;


-- 9.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'fool & humans') > 0;


-- 10.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'fool & computer') > 0;


-- 11.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, '(fool & humans) WITHIN SENTENCE') > 0;


-- 12.
DROP INDEX quotes_ztpd_idx;


-- 13.
BEGIN
	CTX_DDL.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
	CTX_DDL.add_special_section('nullgroup', 'SENTENCE');
	CTX_DDL.add_special_section('nullgroup', 'PARAGRAPH');
END;


-- 14.
CREATE INDEX quotes_ztpd_idx on quotes_ztpd(text)
indextype IS CTXSYS.CONTEXT PARAMETERS('section group nullgroup');


-- 15.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, '(fool & humans) WITHIN SENTENCE') > 0;

SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, '(fool & computer) WITHIN SENTENCE') > 0;


-- 16.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'humans') > 0;


-- 17.
DROP INDEX quotes_ztpd_idx;

BEGIN
	CTX_DDL.create_preference('lex_z_m', 'BASIC_LEXER');
	CTX_DDL.set_attribute('lex_z_m', 'printjoins', '-');
	CTX_DDL.set_attribute ('lex_z_m', 'index_text', 'YES');
END;

CREATE INDEX quotes_ztpd_idx on quotes_ztpd(text)
indextype IS CTXSYS.CONTEXT PARAMETERS('lexer lex_z_m');


-- 18.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'humans') > 0;

-- 19.
SELECT author, text FROM quotes_ztpd
WHERE CONTAINS(text, 'non\-humans') > 0;

-- 20. TODO
DROP INDEX quotes_ztpd_idx;

DROP TABLE quotes_ztpd;

BEGIN
	CTX_DDL.drop_preference('lex_z_m');
END;

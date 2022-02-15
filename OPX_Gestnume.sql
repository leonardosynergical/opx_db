DROP FUNCTION IF EXISTS OPX_GetTabnum;
DROP FUNCTION IF EXISTS OPX_RecTabnum;
DROP FUNCTION IF EXISTS OPX_GetTabnumData;
DROP FUNCTION IF EXISTS OPX_RecTabnumData;
DROP FUNCTION IF EXISTS OPX_GetTabnumStag;
DROP FUNCTION IF EXISTS OPX_RecTabnumStag;
delimiter |

CREATE FUNCTION OPX_GetTabnum ( Dtb CHAR ( 10 ), Codnum CHAR ( 10 ), LOCKMODE INT )
RETURNS INT
BEGIN
DECLARE	Retval INT DEFAULT 0;
DECLARE	GoDb CHAR ( 20 ) DEFAULT "";
DECLARE Ris INT;
DECLARE	Esiste INT DEFAULT 0;

	IF Dtb > "" THEN
		SET GoDb := Dtb;
	ELSE
		SELECT DATABASE() INTO GoDb;
	END IF;

	SELECT COUNT(*) INTO Esiste
	FROM tabnum
	WHERE cdnume = Codnum;

	IF Esiste > 0 THEN
		IF LOCKMODE = 1 THEN
			UPDATE tabnum
			SET numero = numero + 1
			WHERE cdnume = Codnum;

			SELECT numero INTO Retval
			FROM tabnum
			WHERE cdnume = Codnum
			LIMIT 1;
		ELSE
			SELECT numero INTO Retval
			FROM tabnum
			WHERE cdnume = Codnum;
		END IF;

	END IF;

	RETURN Retval;

END;

CREATE FUNCTION OPX_RecTabnum(Dtb char(10),Codnum char(10),Recnum int)
RETURNS int
BEGIN
DECLARE Retval INT DEFAULT 0;
DECLARE GoDb CHAR(20) DEFAULT "";
DECLARE Ris INT;
DECLARE Esiste INT DEFAULT 0;

  IF Dtb > "" THEN
    SET GoDb := Dtb;
  ELSE
    SELECT DATABASE() INTO GoDb;
  END IF;

  SELECT COUNT(*) INTO Esiste
  FROM tabnum
  WHERE cdnume=Codnum
  AND numero=Recnum
  LIMIT 1;

  IF Esiste > 0 THEN
    UPDATE tabnum SET numero=numero-1 WHERE cdnume=Codnum;
    SET Retval := 1;
  END IF;

  RETURN Retval;

END;

CREATE FUNCTION OPX_GetTabnumData(Dtb CHAR(10),Codnum CHAR(10),Datarf DATE,LOCKMODE INT)
RETURNS INT
BEGIN
DECLARE Retval INT DEFAULT 0;
DECLARE Anno CHAR(4);
DECLARE GoDb CHAR(20) DEFAULT "";
DECLARE Ris INT;
DECLARE Msk CHAR(10) DEFAULT "";

  IF Dtb > "" THEN
    SET GoDb := Dtb;
  ELSE
    SELECT DATABASE() INTO GoDb;
  END IF;

  SELECT YEAR(Datarf) into Anno;

  -- Crea nuova numerazione annuale se non esiste
  SELECT IFNULL(numero,0) INTO Retval
  FROM tabnua
  WHERE cdnume=Codnum
  AND annorf=Anno LIMIT 1;

  IF Retval = 0 THEN
    SELECT msknum INTO Msk
    FROM tabnum
    WHERE cdnume = Codnum;

    SET Retval := CAST(REPLACE(REPLACE(Msk,"AAAA",Anno),"AA",RIGHT(Anno,2)) AS UNSIGNED);

    INSERT IGNORE INTO tabnua (cdnume,annorf,numero)
    VALUES (TRIM(Codnum),Anno,Retval);
  END IF;

  IF LOCKMODE = 1 THEN
    UPDATE tabnua
    SET numero=numero+1
    WHERE cdnume=Codnum
    AND annorf=Anno;
  END IF;

  SELECT numero INTO Retval
  FROM tabnua
  WHERE cdnume=Codnum
  AND annorf=Anno
  LIMIT 1;

  RETURN Retval;

END;

CREATE FUNCTION OPX_RecTabnumData(Dtb char(10),Codnum char(10),Datarf DATE,Recnum int)
RETURNS int
BEGIN
DECLARE Retval INT DEFAULT 0;
DECLARE GoDb CHAR(20) DEFAULT "";
DECLARE Esiste INT DEFAULT 0;
DECLARE Anno CHAR(4);

  IF Dtb > "" THEN
    SET GoDb := Dtb;
  ELSE
    SELECT DATABASE() INTO GoDb;
  END IF;

  SELECT YEAR(Datarf) into Anno;

  SELECT COUNT(*) INTO Esiste
  FROM tabnua
  WHERE cdnume=Codnum
  AND annorf=Anno
  AND numero=Recnum
  LIMIT 1;

  IF Esiste > 0 THEN
    UPDATE tabnua SET numero=numero-1
    WHERE cdnume=Codnum
    AND annorf=Anno;
    SET Retval := 1;
  END IF;

  RETURN Retval;

END;

CREATE FUNCTION OPX_GetTabnumStag(Dtb CHAR(10),Codnum CHAR(10),Codstg CHAR(10),LOCKMODE INT)
RETURNS INT
BEGIN
DECLARE Retval INT DEFAULT 0;
DECLARE Anno CHAR(4);
DECLARE Prog CHAR(4);
DECLARE GoDb CHAR(20) DEFAULT "";
DECLARE Ris INT;
DECLARE Msk CHAR(10) DEFAULT "";

  IF Dtb > "" THEN
    SET GoDb := Dtb;
  ELSE
    SELECT DATABASE() INTO GoDb;
  END IF;

  SELECT LPAD(annous,4,'0'),LPAD(progus,1,'0') into Anno,Prog
  FROM tabstg
  WHERE cdstag = Codstg;

  -- Crea nuova numerazione annuale se non esiste
  SELECT IFNULL(numero,0) INTO Retval
  FROM tabnus
  WHERE cdnume=Codnum
  AND cdstag=Codstg LIMIT 1;

  IF Retval = 0 THEN
    SELECT msknum INTO Msk
    FROM tabnum
    WHERE cdnume = Codnum;

    SET Retval := CAST(REPLACE(REPLACE(REPLACE(Msk,"AAAA",Anno),"AA",RIGHT(Anno,2)),"P",LEFT(Prog,1)) AS UNSIGNED);

    INSERT IGNORE INTO tabnus (cdnume,cdstag,numero)
    VALUES (TRIM(Codnum),Codstg,Retval);
  END IF;

  IF LOCKMODE = 1 THEN
    UPDATE tabnus
    SET numero=numero+1
    WHERE cdnume=Codnum
    AND cdstag=Codstg;
  END IF;

  SELECT numero INTO Retval
  FROM tabnus
  WHERE cdnume=Codnum
  AND cdstag=Codstg
  LIMIT 1;

  RETURN Retval;

END;

CREATE FUNCTION OPX_RecTabnumStag(Dtb char(10),Codnum char(10),Codstg CHAR(10),Recnum int)
RETURNS int
BEGIN
DECLARE Retval INT DEFAULT 0;
DECLARE GoDb CHAR(20) DEFAULT "";
DECLARE Esiste INT DEFAULT 0;

  IF Dtb > "" THEN
    SET GoDb := Dtb;
  ELSE
    SELECT DATABASE() INTO GoDb;
  END IF;

  SELECT COUNT(*) INTO Esiste
  FROM tabnus
  WHERE cdnume=Codnum
  AND cdstag=Codstg
  AND numero=Recnum
  LIMIT 1;

  IF Esiste > 0 THEN
    UPDATE tabnus SET numero=numero-1
    WHERE cdnume=Codnum
    AND cdstag=Codstg;
    SET Retval := 1;
  END IF;

  RETURN Retval;

END;
|

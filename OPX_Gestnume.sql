DROP FUNCTION IF EXISTS OPX_GetTabnum;
DROP FUNCTION IF EXISTS OPX_RecTabnum;
DROP FUNCTION IF EXISTS OPX_GetTabnumData;
DROP FUNCTION IF EXISTS OPX_RecTabnumData;
DROP FUNCTION IF EXISTS OPX_GetTabnumStag;
DROP FUNCTION IF EXISTS OPX_RecTabnumStag;
delimiter |

CREATE FUNCTION OPX_GetTabnum ( Dtb CHAR ( 10 ), Codnum CHAR ( 10 ), Tiplck INT )
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
		IF ISNULL( @OPX_ENGINE_TABNUM ) THEN
			SET @OPX_ENGINE_TABNUM := ( SELECT ENGINE
                                  FROM information_schema.TABLES
                                  WHERE TABLE_SCHEMA = GoDb
                                  AND TABLE_NAME = 'tabnum'
                                  AND ENGINE IS NOT NULL );
		END IF;

		IF Tiplck = 1 THEN
			IF @OPX_ENGINE_TABNUA != "innodb" THEN
				SELECT get_lock(CONCAT(GoDb,TRIM(Codnum),"_TN"),120) INTO Ris;
			END IF;

			UPDATE tabnum
			SET numero = numero + 1
			WHERE cdnume = Codnum;

			SELECT numero INTO Retval
			FROM tabnum
			WHERE cdnume = Codnum
			LIMIT 1;

			IF @OPX_ENGINE_TABNUA != "innodb" THEN
				SELECT release_lock(CONCAT(GoDb,TRIM(Codnum),"_TN")) INTO Ris;
			END IF;
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

  SELECT COUNT(*) INTO Esiste FROM tabnum WHERE cdnume=Codnum;

  IF Esiste > 0 THEN
    IF ISNULL(@OPX_ENGINE_TABNUM) THEN
      SET @OPX_ENGINE_TABNUM := (SELECT ENGINE
                                FROM information_schema.TABLES
                                WHERE TABLE_SCHEMA = GoDb
                                AND TABLE_NAME = 'tabnum'
                                AND ENGINE IS NOT NULL);
    END IF;

    IF Recnum > 0 THEN
      IF  @OPX_ENGINE_TABNUA != "innodb" THEN
        SELECT get_lock(CONCAT(GoDb,TRIM(Codnum),"_TN"),120) INTO Ris;
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

      IF @OPX_ENGINE_TABNUA != "innodb" THEN
        SELECT release_lock(CONCAT(GoDb,TRIM(Codnum),"_TN")) INTO Ris;
      END IF;
    END IF;
  END IF;

  RETURN Retval;

END;

CREATE FUNCTION GO_GetTabnumData(Dtb CHAR(10),Codnum CHAR(10),Datarf DATE,Tiplck INT)
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

  IF ISNULL(@GO_ENGINE_TABNUA) THEN
    SET @GO_ENGINE_TABNUA := (SELECT ENGINE
                              FROM information_schema.TABLES
                              WHERE TABLE_SCHEMA = GoDb
                              AND TABLE_NAME = 'tabnua'
                              AND ENGINE IS NOT NULL);
  END IF;

  IF Tiplck = 1 THEN
          IF  @GO_ENGINE_TABNUA != "innodb" THEN
                  SELECT get_lock(CONCAT(GoDb,TRIM(Codnum),"_TNA_",Anno),120) INTO Ris;
    END IF;

          SELECT IFNULL(numero,0) INTO Retval FROM tabnua WHERE cdnume=Codnum AND annorf=Anno LIMIT 1;
          IF Retval = 0 THEN
                  SELECT msknum INTO Msk FROM tabnum WHERE cdnume = Codnum;
                  SET Retval := CAST(REPLACE(REPLACE(Msk,"AAAA",Anno),"AA",RIGHT(Anno,2)) AS UNSIGNED);
                  INSERT IGNORE INTO tabnua (cdnume,annorf,numero) VALUES (TRIM(Codnum),Anno,Retval);
          END IF;

          UPDATE tabnua SET numero=numero+1 WHERE cdnume=Codnum AND annorf=Anno;
          SELECT numero INTO Retval FROM tabnua WHERE cdnume=Codnum AND annorf=Anno LIMIT 1;

    IF  @GO_ENGINE_TABNUA != "innodb" THEN
                  SELECT release_lock(CONCAT(GoDb,TRIM(Codnum),"_TNA_",Anno)) INTO Ris;
    END IF;
  ELSE
          SELECT numero INTO Retval FROM tabnua WHERE cdnume=Codnum AND annorf=Anno LIMIT 1;
          IF Retval = 0 THEN
                  SELECT msknum INTO Msk FROM tabnum WHERE cdnume = Codnum;
                  SET Retval := CAST(REPLACE(REPLACE(Msk,"AAAA",Anno),"AA",RIGHT(Anno,2)) AS UNSIGNED);
                  INSERT IGNORE INTO tabnua (cdnume,annorf,numero) VALUES (TRIM(Codnum),Anno,Retval);
          END IF;
  END IF;

  RETURN Retval;

END;

CREATE FUNCTION GO_TestCommit(Dtb CHAR(10),Codnum CHAR(10),Datarf DATE,Tiplck INT)
RETURNS INT
BEGIN

  DECLARE Retval INT DEFAULT 0;

  RETURN Retval;
END;

-- Moduli di gestione delle numerazioni
DROP FUNCTION IF EXISTS OPX_GetJsonSizes;
DROP FUNCTION IF EXISTS OPX_GetJsonPackages;
delimiter |

CREATE FUNCTION OPX_GetJsonSizes(Datast CHAR (10), Numrif INT, Tiprif CHAR(10))
RETURNS TEXT
BEGIN

DECLARE Retval TEXT DEFAULT "";

  CASE Datast
    WHEN 'lstagl' THEN
      SELECT CONCAT('{',IFNULL(GROUP_CONCAT(CONCAT('"',taglia,'":',CONCAT('[',quanti,',',prezzo,']'))),''),'}') into Retval
      FROM lstagl
      WHERE lstagl.idrife = Numrif
      and lstagl.tprife = Tiprif;
    WHEN 'ortagl' THEN
      SELECT CONCAT('{',IFNULL(GROUP_CONCAT(CONCAT('"',taglia,'":',CONCAT('[',quanti,',',prezzo,']'))),''),'}') into Retval
      FROM ortagl
      WHERE ortagl.idrife = Numrif
      and ortagl.tprife = Tiprif;
  END CASE;

  RETURN Retval;

END;

CREATE FUNCTION OPX_GetJsonPackages(Datast CHAR (10), Numrif INT)
RETURNS TEXT
BEGIN

DECLARE Retval TEXT DEFAULT "";

  CASE Datast
    WHEN 'orasso' THEN
      SELECT CONCAT('{',IFNULL(GROUP_CONCAT(CONCAT('"',orasso.idasso,'":["',tabass.cdasso,'",',orasso.qtasso,']')),''),'}') INTO Retval
      FROM orasso
      INNER JOIN tabass ON tabass.idasso = orasso.idasso
      where orasso.idrord = Numrif;
  END CASE;

  RETURN Retval;

END;
|

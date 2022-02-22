-- Moduli di gestione delle numerazioni
DROP FUNCTION IF EXISTS OPX_GetJsonItemPrice;
delimiter |

CREATE FUNCTION OPX_GetJsonItemPrice(Nulist INT,Nulisa INT, Cdarti CHAR(30),Cdstag CHAR(4),Cdassl CHAR(10),Cdumco CHAR(10),Datrif DATE,Quanti DOUBLE)
RETURNS TEXT
BEGIN

DECLARE Retval TEXT DEFAULT "";

  SELECT
    CONCAT('{',IFNULL(GROUP_CONCAT(CONCAT('"',l.taglia,'":',CONCAT('[',l.postgl,',',0,',',l.prezzo,',',l.scont1,',',l.scont2,',',l.scont3,',',l.pretgl,']')) ORDER BY l.postgl),''),'}')
  INTO Retval
  FROM (
		SELECT
  		IFNULL(tg.taglia,'') AS taglia,
  		IFNULL(tg.postgl,0) AS postgl,
  		COALESCE(ts.prezzo,td.prezzo,ls.prezzo,ld.prezzo,0) AS prezzo,
  		COALESCE(ls.scont1,ld.scont1,0) AS scont1,
  		COALESCE(ls.scont2,ld.scont2,0) AS scont2,
  		COALESCE(ls.scont3,ld.scont3,0) AS scont3,
  		if(COALESCE(ts.idrife,td.idrife,0)>0,1,0) AS pretgl
		FROM (
			SELECT
		    l1.cdtagl,
		    l1.idrowt,
		    IFNULL(ls.idrowt,0) as idsqta
		  FROM (
				SELECT
          tp.cdtagl,
				  COALESCE(la.idrowt,ln.idrowt,aa.idrowt,an.idrowt,0) AS idrowt
				FROM
          anaart ar
				INNER JOIN tipolo tp
          ON tp.cdartn = ar.cdartn
				LEFT JOIN lsdett la
          ON la.nulist = 501
          AND la.cdstag IN (Cdstag,'')
          AND la.tpinpu = 'AR'
          AND la.codice = ar.cdarti
          AND la.dtvali <= Datrif
				LEFT JOIN lsdett ln
          ON ln.nulist = Nulist
          AND ln.cdstag in (Cdstag,'')
          AND ln.tpinpu = 'AN'
          AND ln.codice = tp.cdartn
          AND la.dtvali <= Datrif
				LEFT JOIN lsdett aa
          ON aa.nulist = 0
          AND aa.cdstag in (Cdstag,'')
          AND aa.tpinpu = 'AR'
          AND aa.codice = ar.cdarti
          AND la.dtvali <= Datrif
				LEFT JOIN lsdett an
          ON an.nulist = 0
          AND an.cdstag in (Cdstag,'')
          AND an.tpinpu = 'AN'
          AND an.codice = tp.cdartn
          AND la.dtvali <= Datrif
				WHERE
          ar.cdarti = Cdarti
				ORDER BY
          COALESCE(la.cdstag,ln.cdstag,aa.cdstag,an.cdstag,'') DESC,
          COALESCE(la.dtvali,ln.dtvali,aa.dtvali,an.dtvali,0) DESC
        LIMIT 1) AS l1
		  LEFT JOIN lssqta ls
        ON ls.idpare = l1.idrowt
        AND Quanti <= ls.qtamax
      ORDER BY
        IFNULL(ls.qtamax,0)
      LIMIT 1) AS l2
		LEFT JOIN postgl tg
      ON tg.cdtagl = l2.cdtagl
		LEFT JOIN lstagl ts
      ON ts.idrife = l2.idsqta
      AND ts.tprife = 'lssqta'
      AND ts.taglia = IFNULL(tg.taglia,'')
		LEFT JOIN lstagl td
      ON td.idrife = l2.idrowt
      AND td.tprife = 'lsdett'
      AND td.taglia = ifnull(tg.taglia,'')
		LEFT JOIN lssqta ls
      ON ls.idrowt = l2.idsqta
		LEFT JOIN lsdett ld
      ON ld.idrowt = l2.idrowt
		ORDER BY
      IFNULL(tg.postgl,0)) as l;

  RETURN Retval;

END;

|

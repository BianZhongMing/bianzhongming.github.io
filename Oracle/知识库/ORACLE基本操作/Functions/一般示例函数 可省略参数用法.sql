create or replace function GET_LB(V_TM IN VARCHAR2 default null)  --default 对应参数可以省略
/*由条码获取类别*/
 RETURN VARCHAR2 as
  V_ZPPL bd_defdoc.docname%TYPE;
BEGIN
  SELECT docname
    INTO V_ZPPL
    FROM (SELECT D.DOCNAME
       FROM TS_BATCHCODE A,BD_INVBASDOC B,BD_DEFDOC D
WHERE A.PK_INVBASDOC=B.PK_INVBASDOC(+)
  AND B.DEF8=D.PK_DEFDOC(+)
  and a.vbatchcode=V_TM );
  RETURN V_ZPPL;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '-1';
END GET_LB;


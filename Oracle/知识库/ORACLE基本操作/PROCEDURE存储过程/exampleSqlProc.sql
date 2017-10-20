CREATE OR REPLACE PROCEDURE "ProcName"
as
SqlOne  varchar2(4000);
SqlTwo  varchar2(4000);
SqlThree varchar2(4000);
begin
SqlOne := q'[truncate table tes_int_memb]';
SqlTwo := q'[]';
SqlThree := q'[]';
execute immediate SqlOne;
execute immediate SqlTwo;
execute immediate SqlThree;
commit;
end ProcName;
/

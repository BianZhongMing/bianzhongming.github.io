ORA-08104: this index object 903237 is being online built or rebuilt
异常终止的在线重建索引导致SMON进程没有将索引的重建标志改回来,ORACLE认为索引还在ONLINE REBUILD中，禁止删除索引。

--sysdba
DECLARE 
  RetVal BOOLEAN;
  OBJECT_ID BINARY_INTEGER;
  WAIT_FOR_LOCK BINARY_INTEGER;
　　BEGIN 
  OBJECT_ID := 903237;
  WAIT_FOR_LOCK := NULL;
　　RetVal := SYS.DBMS_REPAIR.ONLINE_INDEX_CLEAN ();
  COMMIT; 
END; 
/

----OR
declare
  done boolean;
  begin
   done:=dbms_repair.online_index_clean(903237);
  end;
/

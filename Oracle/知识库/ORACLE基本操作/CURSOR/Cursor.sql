--游标
/*open_cursors:每个session可以同时打开的游标数。缺省300 ，可设成1000 
 session_cached_cursors:每个session可以放在内存中的游标数量。
 对于java程序来说，每打开一个ResultSet，就会在数据库中打开一个游标，cached cursors就会增加一个。 
 所以对于一个java程序的数据库来说，如果内存足够的话，这个参数应该设置的大一些，设置成2000比较合适。  
*/
--查询
SQL>show parameter open_cursors;
select count(1) from v$open_cursor;

--调整
SQL>alter system set open_cursors = 10000;  
SQL>commit;   

--定位打开游标过多的SQL。检查代码，是否有游标泄露的代码。
select count(*) ,sql_text from v$open_cursor group by sql_text order by count(*) desc;






升级可能解决游标溢出的问题


问题2：游标值数据库重启后还原
show parameter spfile;

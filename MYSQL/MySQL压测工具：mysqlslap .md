>选择slap的原因：Mysql自带，不用另外安装，简单方便；
>slap劣势：不支持SQL参数化（只能存储过程实现，然后调取存储过程）。

## 1.参数说明：

```
--concurrency代表并发数量，多个可以用逗号隔开，concurrency=10,50,100, 并发连接线程数分别是10、50、100个并发。
--engines代表要测试的引擎，可以有多个，用分隔符隔开。
--iterations代表要运行这些测试多少次。
--auto-generate-sql 代表用系统自己生成的SQL脚本来测试。
--auto-generate-sql-load-type 代表要测试的是读还是写还是两者混合的（read,write,update,mixed）
--number-of-queries 代表总共要运行多少次查询。每个客户运行的查询数量可以用查询总数/并发数来计算。
--debug-info 代表要额外输出CPU以及内存的相关信息。
--number-int-cols ：创建测试表的 int 型字段数量
--auto-generate-sql-add-autoincrement : 代表对生成的表自动添加auto_increment列，从5.1.18版本开始
--number-char-cols 创建测试表的 char 型字段数量。
--create-schema 测试的schema，MySQL中schema也就是database。
--query 使用自定义脚本执行测试，例如可以调用自定义的一个存储过程或者sql语句来执行测试。
--delimiter 说明sql文件中语句间的分隔符是什么
--only-print 如果只想打印看看SQL语句是什么，可以用这个选项
```
## 2.案例：

```
本地压测:
mysqlslap --concurrency=50  --number-of-queries=100 --iterations=1 --create-schema='testdb' --debug-info  --socket=/export/servers/data/my3310/run/mysqld.sock --query="SELECT * FROM TESTTABLE;" 

异地压测：
mysqlslap  -uUser_NAME -P3310 -hHOSTNAME -p123456 --concurrency=50  --number-of-queries=100 --iterations=1 --create-schema='testdb' --debug-info --query="SELECT * FROM TESTTABLE ;" 

指定执行脚本：
mysqlslap –user=root –password=111111 –concurrency=20 –number-of-queries=1000 –create-schema=employees –query="select_query.sql" –delimiter=";"
```
配合操作系统信息可以确定对应的系统瓶颈。

## 附

- 参考：http://blog.chinaunix.net/uid-259788-id-2139303.html
- 存储过程案例：

```sql
DELIMITER $$

DROP PROCEDURE IF EXISTS `t_girl`.`sp_get_article`$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_get_article`(IN f_category_id int,
 IN f_page_size int, IN f_page_no int
)
BEGIN
  set @stmt = 'select a.* from article as a inner join ';
  set @stmt = concat(@stmt,'(select a.aid from article as a ');
  if f_category_id != 0 then
    set @stmt = concat(@stmt,' inner join (select cid from category where cid = ',f_category_id,' or parent_id = ',f_category_id,') as b on a.category_id = b.cid');
  end if;
  if f_page_size >0 && f_page_no > 0 then
    set @stmt = concat(@stmt,' limit ',(f_page_no-1)*f_page_size,',',f_page_size);
  end if; 
 
  set @stmt = concat(@stmt,') as b on (a.aid = b.aid)');
  prepare s1 from @stmt;
  execute s1;
  deallocate prepare s1;
  set @stmt = NULL;
END$$

DELIMITER ;
```
```
[root@localhost ~]# mysqlslap --defaults-file=/usr/local/mysql-maria/my.cnf --concurrency=25,50,100 --iterations=1 --query='call t_girl.sp_get_article(2,10,1);' --number-of-queries=5000 --debug-info -uroot -p -S/tmp/mysql50.sock
```
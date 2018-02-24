# MySQL定位未提交事务执行的SQL语句
>在日常运维过程中，会遇见某个事务执行完未提交，导致后续DDL和DML的session要么处于waiting for metadata lock，要么锁等待超时。这时我们往往只能找到这个未提交的事务的事务id和session id，但一般都处于sleep状态，不好分析事务内容到底是什么，所以通常都是粗鲁地kill这个session后解决问题，但是应用层的研发人员往往找不到到底是哪个事务引起的，后面再出现问题时还要重复kill。那这个情况下，怎么办呢？


## 数据准备：
```sql
drop table  if exists tlock;
create table tlock(id int,name varchar(10));
insert into tlock values(1,'jack'),(2,'Jerry'),(3,'mark');
```

## 一般堵塞核查及解决
- 场景：进程1显式/隐式开启事务未完成/未关闭导致堵塞

- 【session 1】堵塞线程
```sh
select connection_id();
+-----------------+
| connection_id() |
+-----------------+
|              28 |
+-----------------+
1 row in set (0.00 sec)
begin;
update tlock set id=123 where id=1;
insert into tlock values(4,'andy');
```
- 【session 2】被堵塞线程
```sh
select connection_id();
+-----------------+
| connection_id() |
+-----------------+
|              27 |
+-----------------+
1 row in set (0.00 sec)
show variables like '%innodb_lock_w%';-- Value值代表堵塞超时的时间（单位秒）
root@5.7.21-log bzmdb 08:55:15>show variables like '%innodb_lock_w%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_lock_wait_timeout | 50    |
+--------------------------+-------+
1 row in set (0.01 sec)
update tlock set id=1234 where id=1;
```
- 【session 3】核查堵塞情况
```sh
root@5.7.21-log (none) 08:56:29>SELECT p2. HOST blocked_host,
    ->        p2. USER blocked_user,
    ->        r.trx_mysql_thread_id blocked_thread_id,
    ->        TIMESTAMPDIFF(SECOND, r.trx_wait_started, CURRENT_TIMESTAMP) wait_time,
    ->        r.trx_query blocked_query,
    ->        p. HOST block_host,
    ->        p. USER block_user,
    ->        b.trx_mysql_thread_id block_thread_id,
    ->        concat('KILL ', b.trx_mysql_thread_id) kill_blockQuery_sql,
    ->        b.trx_query block_query,
    ->        (select e.SQL_TEXT
    ->           from performance_schema.events_statements_current e
    ->           left join performance_schema.threads t
    ->             on e.THREAD_ID = t.THREAD_ID
    ->          where t.PROCESSLIST_ID = b.trx_mysql_thread_id) events_curr_SQL_TEXT,
    ->        l.lock_table block_table, -- 阻塞方锁住的表,
    ->        IF(p.COMMAND = 'Sleep', CONCAT(p.TIME, ' second'), 0) block_sleep_time
    ->   FROM information_schema.INNODB_LOCK_WAITS w
    ->  INNER JOIN information_schema.INNODB_TRX b
    ->     ON b.trx_id = w.blocking_trx_id
    ->  INNER JOIN information_schema.INNODB_TRX r
    ->     ON r.trx_id = w.requesting_trx_id
    ->  INNER JOIN information_schema.INNODB_LOCKS l
    ->     ON w.blocking_lock_id = l.lock_id
    ->    AND l. lock_trx_id = b. trx_id
    ->  INNER JOIN information_schema.INNODB_LOCKS m
    ->     ON m. lock_id = w. requested_lock_id
    ->    AND m. lock_trx_id = r. trx_id
    ->  INNER JOIN information_schema. PROCESSLIST p
    ->     ON p.ID = b.trx_mysql_thread_id
    ->  INNER JOIN information_schema. PROCESSLIST p2
    ->     ON p2.ID = r.trx_mysql_thread_id
    ->  ORDER BY wait_time DESC \G
*************************** 1. row ***************************
        blocked_host: localhost
        blocked_user: root
   blocked_thread_id: 27
           wait_time: 49
       blocked_query: update tlock set id=1234 where id=1
          block_host: localhost
          block_user: root
     block_thread_id: 28
 kill_blockQuery_sql: KILL 28
         block_query: NULL
events_curr_SQL_TEXT: insert into tlock values(4,'andy')
         block_table: `bzmdb`.`tlock`
    block_sleep_time: 139 second
1 row in set, 3 warnings (0.01 sec)
```
- 【session 2】

  - 超时报错，堵塞解除（也可以kill session解除堵塞）
  - ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction

- 【注意】mysql数据库中最多只能抓取事务中最后执行的一条sql

### 抓取完整SQL方案

1. 利用general_log
  - 需要先打开general_log等着问题复现的方式来定位，经测试，即使事务没有提交，一样会写到general_log。

```sh
root@5.7.21-log (none) 08:56:50>show variables like '%general%';
+------------------+---------------------------------------+
| Variable_name    | Value                                 |
+------------------+---------------------------------------+
| general_log      | OFF                                   |
| general_log_file | /mysqldata/my3306/log/general-log.log |
+------------------+---------------------------------------+
2 rows in set (0.02 sec)

set global general_log=1;
Query OK, 0 rowsaffected (0.00 sec)
```
  - 开启general日志后，只要知道了未提交事务的进程号就可以完美找到对应的SQL语句了。

- 【session 1】rollback；重新执行原SQL
```sh
#按照session id核查
[root@bzm ~]#  cat /mysqldata/my3306/log/general-log.log  | grep 28
2018-02-24T21:04:35.961991+08:00	   28 Query	begin
2018-02-24T21:04:35.984394+08:00	   28 Query	update tlock set id=123 where id=1
2018-02-24T21:04:36.830196+08:00	   28 Query	insert into tlock values(4,'andy')
```
- 限制：长连接核查SQL会很多（筛查耗时），需要提前打开general-log（为避免general-log过大平时默认关闭）。

2. binlog查找
- 假如后面应用层最终commit了，那么会在binlog里记录，可以根据当时的session id去binlog里面查看完整事务。


##DML导致DDL的锁

- 【session 1】堵塞线程
 ```sh
select connection_id();
+-----------------+
| connection_id() |
+-----------------+
|              31 |
+-----------------+
1 row in set (0.00 sec)
begin;
update tlock set id=123 where id=1;
insert into tlock values(4,'andy');
 ```
- 【session 2】被堵塞线程
```sh
select connection_id();
+-----------------+
| connection_id() |
+-----------------+
|              33 |
+-----------------+
1 row in set (0.00 sec)
alter table tlock add column name2 varchar(50);
-- 不受超时影响，session 2一直处在堵塞状态
```
- 【session 3】核查问题
```sh
select * from information_schema. PROCESSLIST;
-- 31	bzm	192.168.171.1:51674	bzmdb	Sleep	736		
-- 33	bzm	192.168.171.1:51683	bzmdb	Query	708	Waiting for table metadata lock	alter table tlock add column name2 varchar(50)
--留意 STATE='Waiting for table metadata lock'对应的SQL 
--此时新开session进行update也会陷入同样的无限期堵塞状态，在此状态下block.sql查询不出任何信息。
select * from information_schema.INNODB_TRX;
--6031	RUNNING	2018-02-24 21:23:26			4	31			0	1	2	1136	1	2	0	READ COMMITTED	1	1		0	0	0	0
最终核查SQL：
-- 开启但未提交事务信息
select a.*,
   (select e.SQL_TEXT
          from performance_schema.events_statements_current e
          left join performance_schema.threads t
            on e.THREAD_ID = t.THREAD_ID
         where t.PROCESSLIST_ID = a.id) events_curr_SQL_TEXT,
         b.trx_started,
         b.trx_query
 from information_schema. PROCESSLIST a join information_schema.INNODB_TRX b on a.ID =b.trx_mysql_thread_id
where a.command='Sleep' and b.trx_state='RUNNING' 
-- 可能被堵塞的ddl(核查正在执行的SQL是否为ddl)
select a.*,
   (select e.SQL_TEXT
          from performance_schema.events_statements_current e
          left join performance_schema.threads t
            on e.THREAD_ID = t.THREAD_ID
         where t.PROCESSLIST_ID = a.id) events_curr_SQL_TEXT -- 提供更多的SQL执行信息
 from information_schema. PROCESSLIST a 
where command='Query' and state='Waiting for table metadata lock'
```
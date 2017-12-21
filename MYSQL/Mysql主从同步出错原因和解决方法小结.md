### 导致主从不一致的原因
1. 网络的延迟
由于mysql主从复制是基于binlog的一种异步复制，通过网络传送binlog文件，理所当然网络延迟是主从不同步的绝大多数的原因，特别是跨机房的数据同步出现这种几率非常的大，所以做读写分离，注意从业务层进行前期设计。
2. 主从两台机器的负载不一致
由于mysql主从复制是主数据库上面启动1个io线程，而从上面启动1个sql线程和1个io线程，当中任何一台机器的负载很高，忙不过来，导致其中的任何一个线程出现资源不足，都将出现主从不一致的情况。
3. max_allowed_packet设置不一致
主数据库上面设置的max_allowed_packet比从数据库大，当一个大的sql语句，能在主数据库上面执行完毕，从数据库上面设置过小，无法执行，导致的主从不一致。
4. key自增键开始的键值跟自增步长设置不一致引起的主从不一致。
5. mysql异常宕机情况下，如果未设置sync_binlog=1或者innodb_flush_log_at_trx_commit=1很有可能出现binlog或者relaylog文件出现损坏，导致主从不一致。
6. mysql本身的bug引起的主从不同步。
7. 版本不一致，特别是高版本是主，低版本为从的情况下，主数据库上面支持的功能，从数据库上面不支持该功能。


### mysql主从同步出错（Slave_IO_Running: NO）常见解决办法 
1. Slave I/O: error connecting to master 'backup@192.168.1.x:3306' - retry-time: 60  retries: 86400, Error_code: 1045
解决方法
从服务器上删除掉所有的二进制日志文件，包括一个数据目录下的master.info文件和hostname-relay-bin开头的文件。
master.info:：记录了Mysql主服务器上的日志文件和记录位置、连接的密码。

2. Error reading packet from server: File '/home/mysql/mysqlLog/log.000001' not found (Errcode: 2) ( server_errno=29) 
解决方法：
由于主服务器运行了一段时间，产生了二进制文件，而slave是从log.000001开始读取的，删除主机二进制文件，包括log.index文件。
 
3. Slave SQL: Error 'Table 'xxxx' doesn't exist' on query. Default database: 't591'. Query: 'INSERT INTO `xxxx`(type,post_id,browsenum)
 SELECT type,post_id,browsenum FROM xxxx WHERE hitdate='20090209'', Error_code: 1146
解决方法：
由于slave没有此table表，添加这个表，使用slave start 就可以继续同步。
 
4. Error 'Duplicate entry '1' for key 1' on query. Default database: 'movivi1'. Query: 'INSERT INTO `v1vid0_user_samename`
 VALUES(null,1,'123','11','4545','123')'
Error 'You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax 
to use near '' at line 1' on query. Default database: 'club'. Query: 'INSERT INTO club.point_process ( GIVEID, GETID, POINT, CREATETIME, DEMO ) 
VALUES ( 0, 4971112, 5, '2010-12-19 16:29:28','
1 row in set (0.00 sec)
解决方法：
Mysql > stop slave;
Mysql > set global sql_slave_skip_counter =1 ;
Mysql > start slave;
 
5. Last_Error: Relay log read failure: Could not parse relay log event entry. The possible reasons are: 
the master's binary log is corrupted (you can check this by running 'mysqlbinlog' on the binary log), 
the slave's relay log is corrupted (you can check this by running 'mysqlbinlog' on the relay log), 
a network problem, or a bug in the master's or slave's MySQL code. If you want to check the master's
 binary log or slave's relay log, you will be able to know their names by issuing 'SHOW SLAVE STATUS' on this slave.
Skip_Counter: 0
Exec_Master_Log_Pos: 1010663436
这个问题原因是，主数据库突然停止或问题终止，更改了mysql-bin.xxx日志，slave服务器找不到这个文件，需要找到同步的点和日志文件，然后chage master即可。
解决方法：
change master to 
master_host='IP',
master_user='同步帐号', 
master_password='同步密码', 
master_port=3306, 
master_log_file='mysql-bin.000025', 
master_log_pos=1010663436;
 
6. Error 'Unknown column 'qdir' in 'field list'' on query. Default database: 'club'. Query: 'insert into club.question_del (id, pid, 
ques_name, givepoint, title, subject, subject_pid, createtime, approve, did, status, intime, order_d, endtime,banzhu_uid,
banzhu_uname,del_cause,qdir) select id, pid, ques_name, givepoint, title, subject, subject_pid, createtime, approve, did, 
status, intime, order_d, endtime,'1521859','admin0523','无意义回复',qdir from club.question where id=7330212'
1 row in set (0.00 sec)
这个错误就说club.question_del 表里面没有qdir这个字段 造成的加上就可以了~！
在主的mysql ： 里面查询 Desc club.question_del； 
在 错误的从服务器上执行 ： alter table question_del add qdir varchar(30) not null;
 
7. Slave_IO_Running: NO 
这个错误就是IO 进程没连接上  ，想办法连接上把 把与主的POS 号和文件一定要对，然后重新加载下数据。具体步骤：
slave stop;
change master to master_host='IP地址',master_user='club',master_password='mima ',master_log_file='mysqld-bin.000048',MASTER_LOG_POS=396549485;
注：master_log_file='mysqld-bin.000048',MASTER_LOG_POS=396549485;是从主的上面查出 来的 ：show master status\G;
LOAD DATA FROM MASTER; 
load data from master；
slave start;

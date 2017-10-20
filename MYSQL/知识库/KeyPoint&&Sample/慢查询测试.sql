-- 慢查询测试
1. 定义：记录超过时间阈值的SQL语句。（不记录事务时间）
2.参数
slow_query_log :是否开启慢查询记录功能
slow_query_log_file :慢查询记录日志存放位置
long_query_time:时间阈值（查询超过多少秒才记录）
3.参数查询及配置修改
-- 查询
show VARIABLES like "%slow%"; 
show variables like "long_query_time";
-- 变更
开启慢查询：
set global slow_query_log='ON';
设置慢查询日志存放的位置：
set global slow_query_log_file='/usr/local/mysql/log/slow.log';
设置时间阈值：--Mysql 5.6+不会生效
set global long_query_time=2; 
另彻底变更配置：修改配置文件my.cnf（重启生效）
[mysqld]
slow_query_log = ON
slow_query_log_file='/usr/local/mysql/log/slow.log'
long_query_time = 2
log_queries_not_using_indexes = ON ###记录下没有使用索引的query，开启这个才能是时间阈值生效

mysql> select sleep(3); #延迟2秒执行 

-- test SQL 1
START TRANSACTION;
select sleep(0.5);
insert into testi values(1,'hehea');
select sleep(0.5);
COMMIT;
--未被记录慢查询


心跳(heartbeat)
1.含义：在master没有写binlog时发出heartbeat，以便slave知道master是否正常。
2.取值范围：单位秒，0 到 4294967秒。精确度可以达到毫秒，最小的非0值是0.001秒。
3.发出条件：master在主机binlog日志文件在设定的间隔时间内没有收到新的事件时发出。
4.参数查看：
--salve env
select heartbeat from mysql.slave_master_info;
--30
SHOW VARIABLES like '%slave_net_timeout%';
--60
值：默认为slave_net_timeout的值除以2，设置为0表示完全的禁用心跳。

复制心跳(master_heartbeat_period)
1.单位：秒。精度：1 毫秒。MySQL5.5开始提供改参数。
2.salve推荐设置：
mysql> stop slave;  
mysql> change master to master_heartbeat_period = 10;  
mysql> set global slave_net_timeout = 25;  
mysql> start slave;  
含义：
 Master 在没有数据的时候，每 个master_heartbeat_period 周期（10 秒）发送一个心跳包。这样 Slave 就能知道 Master 是不是还正常。
 slave_net_timeout 是设置在多久没收到数据后认为网络超时，之后 Slave 的 IO 线程会重新连接 Master 。
 结合这两个设置就可以避免由于网络问题导致的复制延误。master_heartbeat_period 。
 【注】当前master_heartbeat_period =Slave_heartbeat_period。
3.参数查看
show status like  'Slave_heartbeat_period' 
SHOW STATUS LIKE '%heartbeat%';
Slave_heartbeat_period
Slave_last_heartbeat：最后一次收到心跳的时间
Slave_received_heartbeats：总共收到的心跳次数

--其他参数查看
show status like 'slave%'; 
SHOW VARIABLES like '%time%';


参考资料：
https://dev.mysql.com/worklog/task/?id=342
https://www.percona.com/blog/2011/12/29/actively-monitoring-replication-connectivity-with-mysqls-heartbeat/
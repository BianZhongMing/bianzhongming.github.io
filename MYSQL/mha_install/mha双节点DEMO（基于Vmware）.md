# mha双节点DEMO（基于Vmware）

> 安装程序：https://github.com/BianZhongMing/bianzhongming.github.io/tree/master/MYSQL/mha_install/package
> 部署脚本：https://github.com/BianZhongMing/bianzhongming.github.io/tree/master/MYSQL/mha_install/deploy
> 文档：https://github.com/BianZhongMing/bianzhongming.github.io/tree/master/MYSQL/mha_install

## 1.准备工作和基本环境

- 安装Linux，关闭SELINUX和防火墙，操作系统信息如下：

  ```sh
  ####系统信息
  # cat /etc/redhat-release
  CentOS Linux release 7.4.1708 (Core) 

  ###关闭SELINUX
  SELinux：是一种基于 域-类型 模型（domain-type）的强制访问控制（MAC）安全系统。不关闭易导致莫名其妙的问题。
  立刻关闭SELINUX：setenforce 0 或者　　/usr/sbin/setenforce 0
  加到系统默认启动：# vim /etc/selinux/config
  修改 selinux 配置文件
  将SELINUX=enforcing改为SELINUX=disabled，保存后退出
  另：立刻启动： /usr/sbin/setenforce 1 

  ###关闭防火墙
  # centos7默认防火墙
  systemctl stop firewalld.service #停止firewall
  systemctl disable firewalld.service #禁止firewall开机启动
  firewall-cmd --state #查看默认防火墙状态（关闭后显示notrunning，开启后显示running）
  # centos6的iptables防火墙
  servcie iptables stop                    --临时关闭防火墙
  chkconfig iptables off                    --永久关闭防火墙
  ```

- 安装并启动Mysql，mysql信息如下：

  ```sh
  版本：
  root@5.7.21-log (none) 05:46:43>select version();
  +------------+
  | version()  |
  +------------+
  | 5.7.21-log |
  +------------+
  1 row in set (0.00 sec)

  root用户密码：123456
  ```

- 配置my.cnf

  ```sh
  [root@bzm ~]# vi /etc/my.cnf

  # replication read_only属性为0（从库随时可能被提升为master）
  read_only                   =0
  ```

- mysql清理和用户创建，赋权，异地登录测试

  ```sql
  -- clear
  delete from mysql.user where user!='root' or host !='localhost';
  truncate table mysql.db;
  drop database test;

  --create 
  --修改密码规则，避免不符合安全规则报ERROR 1819
  set global validate_password_policy=0;
  set global validate_password_length=6;
  --赋权
  grant all on *.* to 'root'@'192.168.171.%' identified by '123456';
  grant replication slave, replication client on *.* to 'repl'@'192.168.171.%' identified by '123456'; -- 主从复制用户
  flush privileges;
  select user,host from mysql.user;

  --测试会使用的DB
  show databases;
  create database bzmdb;

  --异地登录测试
  mysql -uroot -h192.168.171.135 -P3306 -p
  ```

  ​

- 最后VM创建克隆（链接克隆/完整克隆都可以）

## 2.规划和初始化工作

1. 服务器规划

   ```sh
   192.168.171.135 bzm1	MysqlMaster/Slave,mhaNode（先创建虚拟机）
   192.168.171.136 bzm2	MysqlMaster/Slave,mhaNode,mhaManager
   192.168.171.137 		vip
   ```


2. Mysql配置

   - *改小内存和连接数（避免内存过大）

   - 修改slave的server-id（移除auto.cnf，重启mysql重新生成server-uuid）

     ```sh
     [root@bzm data]# mv auto.cnf  auto.cnf.bk
     [root@bzm data]# systemctl restart mysqld
     [root@bzm data]# ls auto*
     auto.cnf  auto.cnf.bk
     [root@bzm data]# cat auto.cnf
     ```

3. 两台机器配置hosts（mysql主从节点对应IP都需要配入）

   ```sql
   # vi /etc/hosts
   192.168.171.135 bzm1
   192.168.171.136 bzm2

   # ping bzm1
   # ping bzm2
   ```

4. 配置主主互备
   ```sql
   ############ bzm1 配复制
   stop slave; 
   CHANGE MASTER TO   MASTER_HOST='192.168.171.136', MASTER_USER='repl',  MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_AUTO_POSITION = 1;
   start slave;
   # 重置slave：reset slave;
   # 状态查看
   show slave status\G;
   show master status;

   ############ bzm2 配复制
   CHANGE MASTER TO   MASTER_HOST='192.168.171.135', MASTER_USER='repl',  MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_AUTO_POSITION = 1;
   start slave;
   show slave status\G;
   # 为了避免主主互备带来的冲突，设置bzm2只读
   set global read_only=1;
   ```

5. ssh互信配置（mhaNode和mhaManager服务器之间都需要相互建立ssh互信）

   ```sql
   ########## bzm1
   ssh-keygen -t rsa #创建密钥
   ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.171.135 #发送ssh密钥到其他服务器
   ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.171.136 #发送ssh密钥到自己

   ########## bzm2
   ssh-keygen -t rsa #创建密钥
   ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.171.135 #发送ssh密钥到其他服务器
   ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.171.136 #发送ssh密钥到自己

   ########## All 验证免密登陆：
   ssh 192.168.171.135
   ssh 192.168.171.136
   ```
## 3.mha程序安装

1. mhaNode节点安装

   ```sh
   # bzm1/bzm2 数据节点安装：
   yum install perl-DBD-MySQL -y
   cd /opt
   rz 【mha4mysql-node-0.56-0.el6.noarch.rpm】
   rpm -ivh mha4mysql-node-0.56-0.el6.noarch.rpm

   安装完成后会在/usr/bin目录下生成以下脚本文件(这些工具通常由MHAManager的脚本触发，无需人为操作)：
   save_binary_logs              //保存和复制master的二进制日志
   apply_diff_relay_logs          //识别差异的中继日志事件并将其差异的事件应用于其他的slave
   filter_mysqlbinlog             //去除不必要的ROLLBACK事件（MHA已不再使用这个工具）
   purge_relay_logs               //清除中继日志（不会阻塞SQL线程）
   ```

   ```sh
   # 没有yum源安装包安装方式：
   rpm -ivh mysql-libs-5.1.73-8.el6_8.x86_64.rpm
   rpm -ivh perl-DBD-MySQL-4.013-3.el6.x86_64.rpm
   cd /opt
   rz 【mha4mysql-node-0.56-0.el6.noarch.rpm】
   rpm -ivh mha4mysql-node-0.56-0.el6.noarch.rpm
   ```

2. mhaManager节点安装（也可以两台机子都部署管理节点，一主一从架构建议两个节点都安装manager和node包）

   ```sh
   # bzm2
   yum install perl-DBD-MySQL -y  #【和node节点重复】
   yum install perl-Config-Tiny -y
   yum install epel-release -y
   yum install perl-Log-Dispatch -y
   yum install perl-Parallel-ForkManager -y

   cd /opt
   rz 【mha4mysql-manager-0.56-0.el6.noarch.rpm】
   rpm -ivh mha4mysql-manager-0.56-0.el6.noarch.rpm 

   安装完成后会在/usr/bin目录下生成以下脚本文件:
   masterha_check_repl  
   masterha_check_ssh  
   masterha_check_status  
   masterha_conf_host  
   masterha_manager  
   masterha_master_monitor  
   masterha_master_switch  
   masterha_secondary_check  
   masterha_stop  
   filter_mysqlbinlog  
   save_binary_logs  
   purge_relay_logs  
   apply_diff_relay_logs 
   ```

   ```sh
   # 没有yum源安装包安装方式：
   rpm -ivh perl-Config-Tiny-2.12-7.1.el6.noarch.rpm
   rpm -ivh epel-release-6-8.noarch.rpm
   rpm -ivh perl-Parallel-ForkManager-0.7.9-1.el6.noarch.rpm
   # rpm -ivh  compat-db-4.6.21-17.el6.x86_64.rpm
   rpm -ivh perl-Mail-Sender-0.8.16-3.el6.noarch.rpm
   rpm -ivh perl-Mail-Sendmail-0.79-12.el6.noarch.rpm
   rpm -ivh perl-Email-Date-Format-1.002-5.el6.noarch.rpm
   rpm -ivh perl-MIME-Types-1.28-2.el6.noarch.rpm
   rpm -ivh perl-TimeDate-1.16-13.el6.noarch.rpm
   rpm -ivh perl-Params-Validate-0.92-3.el6.x86_64.rpm
   rpm -ivh perl-MailTools-2.04-4.el6.noarch.rpm
   rpm -ivh perl-MIME-Lite-3.027-2.el6.noarch.rpm
   rpm -ivh perl-Log-Dispatch-2.27-1.el6.noarch.rpm
   cd /opt
   rz 【mha4mysql-manager-0.56-0.el6.noarch.rpm】
   rpm -ivh mha4mysql-manager-0.56-0.el6.noarch.rpm 
   ```

## 4.mha配置

1. 配置init.sh，填写相关信息

2. 上传部署包并执行init.sh（主从都需要执行）

   > 注：一台主机部署多套mha时，除了修改配置脚本之外还需修改master_ip_failover和master_ip_online_change中的vip和网络适配器变量名。

3. 另：手工配置

   ```sh
   【修改全局配置文件】
   vi masterha_default.conf 
   [server default]
   #MySQL的用户和密码
   user=root
   password=mysql
   #系统ssh用户
   ssh_user=root
   #复制用户
   repl_user=repl
   repl_password= repl.123
   #监控
   ping_interval=1
   #shutdown_script=""
   #切换调用的脚本
   master_ip_failover_script= /etc/masterha/master_ip_failover
   master_ip_online_change_script= /etc/masterha/master_ip_online_change

   【修改集群配置文件】：
   vi app1.conf
   [server default]
   user=root
   password=mysql
   #mha manager工作目录
   manager_workdir = /var/log/masterha/app1
   manager_log = /var/log/masterha/app1/app1.log
   remote_workdir = /var/log/masterha/app1
   [server1]
   hostname=172.32.3.104 #主库的配置上，把从库写成主节点
   ## cat my.cnf|grep log-bin
   master_binlog_dir =/export/servers/data/my3306/binlog/
   port=3306
   [server2]
   hostname=172.32.3.102 #主库的配置上，把主库写成备节点
   ## cat my.cnf|grep log-bin
   master_binlog_dir=/export/servers/data/my3307/binlog/
   port=3307
   candidate_master=1
   check_repl_delay = 0 #用防止master故障时，切换时slave有延迟，卡在那里切不过来。

   注：如果有一主多从架构，那么只需要在app1/conf文件后面再多添加几个配置即可，类似如下：
   [server3]
   hostname=192.168.0.x
   port=3306
   master_binlog_dir=/data/mysql/data

   【修改master_ip_failover文件中的VIP和绑定网卡】
   vim /etc/masterha/master_ip_failover
   my $vip = "172.32.3.195";
   my $if = "eth0";

   【修改master_ip_online_change文件中的VIP和绑定网卡（修改内容相同）】
   vim /etc/masterha/master_ip_online_change

   【把drop_vip.sh和init_vip.sh中的网卡和VIP都改过来】
   ```

## 5.mha测试

1. Manager节点测试ssh连通性

   ```sh
   [root@bzm cluster1]# masterha_check_ssh --conf=$MHA_HOME/app1.conf
   Wed Feb 28 16:20:24 2018 - [warning] Global configuration file /etc/masterha_default.cnf not found. Skipping.
   Wed Feb 28 16:20:24 2018 - [info] Reading application default configuration from /mha/cluster1/app1.conf..
   Wed Feb 28 16:20:24 2018 - [info] Reading server configuration from /mha/cluster1/app1.conf..
   Wed Feb 28 16:20:24 2018 - [info] Starting SSH connection tests..
   Wed Feb 28 16:20:27 2018 - [debug] 
   Wed Feb 28 16:20:24 2018 - [debug]  Connecting via SSH from root@192.168.171.135(192.168.171.135:22) to root@192.168.171.136(192.168.171.136:22)..
   Wed Feb 28 16:20:27 2018 - [debug]   ok.
   Wed Feb 28 16:20:27 2018 - [debug] 
   Wed Feb 28 16:20:25 2018 - [debug]  Connecting via SSH from root@192.168.171.136(192.168.171.136:22) to root@192.168.171.135(192.168.171.135:22)..
   Wed Feb 28 16:20:26 2018 - [debug]   ok.
   Wed Feb 28 16:20:27 2018 - [info] All SSH connection tests passed successfully.
   ```

   > 测试通过标志：[info] All SSH connection tests passed successfully.

2. 测试集群中的主从复制

   ```sh
   [root@bzm cluster1]# masterha_check_repl --conf=$MHA_HOME/app1.conf --global_conf=$MHA_HOME/masterha_default.conf
   Wed Feb 28 16:34:15 2018 - [info] Reading default configuration from /mha/cluster1/masterha_default.conf..
   Wed Feb 28 16:34:15 2018 - [info] Reading application default configuration from /mha/cluster1/app1.conf..
   Wed Feb 28 16:34:15 2018 - [info] Reading server configuration from /mha/cluster1/app1.conf..
   Wed Feb 28 16:34:15 2018 - [info] MHA::MasterMonitor version 0.56.
   Wed Feb 28 16:34:16 2018 - [info] Multi-master configuration is detected. Current primary(writable) master is 192.168.171.135(192.168.171.135:3306)
   Wed Feb 28 16:34:16 2018 - [info] Master configurations are as below: 
   Master 192.168.171.135(192.168.171.135:3306), replicating from 192.168.171.136(192.168.171.136:3306)
   Master 192.168.171.136(192.168.171.136:3306), replicating from 192.168.171.135(192.168.171.135:3306), read-only

   Wed Feb 28 16:34:16 2018 - [info] GTID failover mode = 1
   Wed Feb 28 16:34:16 2018 - [info] Dead Servers:
   Wed Feb 28 16:34:16 2018 - [info] Alive Servers:
   Wed Feb 28 16:34:16 2018 - [info]   192.168.171.135(192.168.171.135:3306)
   Wed Feb 28 16:34:16 2018 - [info]   192.168.171.136(192.168.171.136:3306)
   Wed Feb 28 16:34:16 2018 - [info] Alive Slaves:
   Wed Feb 28 16:34:16 2018 - [info]   192.168.171.136(192.168.171.136:3306)  Version=5.7.21-log (oldest major version between slaves) log-bin:enabled
   Wed Feb 28 16:34:16 2018 - [info]     GTID ON
   Wed Feb 28 16:34:16 2018 - [info]     Replicating from 192.168.171.135(192.168.171.135:3306)
   Wed Feb 28 16:34:16 2018 - [info]     Primary candidate for the new Master (candidate_master is set)
   Wed Feb 28 16:34:16 2018 - [info] Current Alive Master: 192.168.171.135(192.168.171.135:3306)
   Wed Feb 28 16:34:16 2018 - [info] Checking slave configurations..
   Wed Feb 28 16:34:16 2018 - [info] Checking replication filtering settings..
   Wed Feb 28 16:34:16 2018 - [info]  binlog_do_db= , binlog_ignore_db= 
   Wed Feb 28 16:34:16 2018 - [info]  Replication filtering check ok.
   Wed Feb 28 16:34:16 2018 - [info] GTID (with auto-pos) is supported. Skipping all SSH and Node package checking.
   Wed Feb 28 16:34:16 2018 - [info] Checking SSH publickey authentication settings on the current master..
   Wed Feb 28 16:34:17 2018 - [info] HealthCheck: SSH to 192.168.171.135 is reachable.
   Wed Feb 28 16:34:17 2018 - [info] 
   192.168.171.135(192.168.171.135:3306) (current master)
    +--192.168.171.136(192.168.171.136:3306)

   Wed Feb 28 16:34:17 2018 - [info] Checking replication health on 192.168.171.136..
   Wed Feb 28 16:34:17 2018 - [info]  ok.
   Wed Feb 28 16:34:17 2018 - [info] Checking master_ip_failover_script status:
   Wed Feb 28 16:34:17 2018 - [info]   /mha/cluster1/master_ip_failover --command=status --ssh_user=root --orig_master_host=192.168.171.135 --orig_master_ip=192.168.171.135 --orig_master_port=3306 
   Wed Feb 28 16:34:17 2018 - [info]  OK.
   Wed Feb 28 16:34:17 2018 - [warning] shutdown_script is not defined.
   Wed Feb 28 16:34:17 2018 - [info] Got exit code 0 (Not master dead).

   MySQL Replication Health is OK.
   ```

   > 最后提示：MySQL Replication Health is OK.表示测试通过


## 6.启停mha

1. master节点绑定vip

   ```sh
   [root@bzm ~]# $MHA_HOME/init_vip.sh
   [root@bzm ~]# ip addr|grep ens33
   2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
       inet 192.168.171.135/24 brd 192.168.171.255 scope global dynamic ens33
       inet 192.168.171.137/32 scope global ens33
   ###确认VIP 绑定成功，如果业务按VIP 配置的访问DB，应该已经可以正常访问
   [root@bzm ~]# mysql -uroot -P3306 -h192.168.171.137 -p
   Enter password: 
   Welcome to the MySQL monitor.  Commands end with ; or \g.
   Your MySQL connection id is 89
   Server version: 5.7.21-log MySQL Community Server (GPL)

   Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

   Oracle is a registered trademark of Oracle Corporation and/or its
   affiliates. Other names may be trademarks of their respective
   owners.

   Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

   root@5.7.21-log (none) 05:19:55>exit
   Bye
   ```

2. 启停管理节点，状态日志查询

   ```sh
   ### 创建启动mha脚本
   # echo "nohup masterha_manager --global_conf=$MHA_HOME/masterha_default.conf --conf=$MHA_HOME/app1.conf --remove_dead_master_conf --ignore_last_failover> $MHA_HOME/log/mha_manager.log 2>&1 &">$MHA_HOME/startmha.sh

   ### 创建停止mha脚本
   # echo "masterha_stop   --conf=$MHA_HOME/app1.conf">$MHA_HOME/stopmha.sh

   ### 赋权，启动
   # chmod +x $MHA_HOME/*.sh
   # $MHA_HOME/startmha.sh

   ### 检查是否启动成功：
   masterha_check_status --global_conf=$MHA_HOME/masterha_default.conf --conf=$MHA_HOME/app1.conf
   ### 查看master的健康状况日志：
   cat $MHA_HOME/manager/app1.master_status.health

   ### 启动之后查看控制台输出日志：
   tail -100f $MHA_HOME/log/mha_manager.log
   ### 查看app1日志输出：
   tail -f $MHA_HOME/manager/app1.log
   ```

## 7.Failover测试

> 注：切换的过程中会修改app.conf 配置文件
>
> 注意：Online master switch 开始只有当所有下列条件得到满足。
> 1）. IO threads on all slaves are running // 在所有slave 上IO 线程运行。
> 2）. SQL threads on all slaves are running //SQL 线程在所有的slave 上正常运行。
> 3）. Seconds_Behind_Master on all slaves are less or equal than --running_updates_limit
> seconds // 在所有的slaves 上Seconds_Behind_Master 要小于等于running_updates_limit
> seconds
> 4）. On master, none of update queries take more than --running_updates_limit seconds in the
> show processlist output // 在主上，没有更新查询操作多于running_updates_limit seconds

1. 系统维护在线手工切换

   ```sh
   ### 停止mha(注：手动在线切换mha，切换时需要将在运行的mha 停掉后才能切换。)
   [root@bzm cluster1]# $MHA_HOME/stopmha.sh
   Stopped app1 successfully.

   ### 手工切换
   [root@bzm cluster1]# masterha_master_switch --global_conf=$MHA_HOME/masterha_default.conf --conf=$MHA_HOME/app1.conf --master_state=alive --new_master_host=192.168.171.136 --orig_master_is_new_slave --running_updates_limit=10000
   Wed Feb 28 17:48:40 2018 - [info] MHA::MasterRotate version 0.56.
   Wed Feb 28 17:48:40 2018 - [info] Starting online master switch..
   Wed Feb 28 17:48:40 2018 - [info] 
   Wed Feb 28 17:48:40 2018 - [info] * Phase 1: Configuration Check Phase..
   Wed Feb 28 17:48:40 2018 - [info] 
   Wed Feb 28 17:48:40 2018 - [info] Reading default configuration from /mha/cluster1/masterha_default.conf..
   Wed Feb 28 17:48:40 2018 - [info] Reading application default configuration from /mha/cluster1/app1.conf..
   Wed Feb 28 17:48:40 2018 - [info] Reading server configuration from /mha/cluster1/app1.conf..
   Wed Feb 28 17:48:41 2018 - [info] Multi-master configuration is detected. Current primary(writable) master is 192.168.171.135(192.168.171.135:3306)
   Wed Feb 28 17:48:41 2018 - [info] Master configurations are as below: 
   Master 192.168.171.135(192.168.171.135:3306), replicating from 192.168.171.136(192.168.171.136:3306)
   Master 192.168.171.136(192.168.171.136:3306), replicating from 192.168.171.135(192.168.171.135:3306), read-only

   Wed Feb 28 17:48:41 2018 - [info] GTID failover mode = 1
   Wed Feb 28 17:48:41 2018 - [info] Current Alive Master: 192.168.171.135(192.168.171.135:3306)
   Wed Feb 28 17:48:41 2018 - [info] Alive Slaves:
   Wed Feb 28 17:48:41 2018 - [info]   192.168.171.136(192.168.171.136:3306)  Version=5.7.21-log (oldest major version between slaves) log-bin:enabled
   Wed Feb 28 17:48:41 2018 - [info]     GTID ON
   Wed Feb 28 17:48:41 2018 - [info]     Replicating from 192.168.171.135(192.168.171.135:3306)
   Wed Feb 28 17:48:41 2018 - [info]     Primary candidate for the new Master (candidate_master is set)

   It is better to execute FLUSH NO_WRITE_TO_BINLOG TABLES on the master before switching. Is it ok to execute on 192.168.171.135(192.168.171.135:3306)? (YES/no): yes
   Wed Feb 28 17:48:47 2018 - [info] Executing FLUSH NO_WRITE_TO_BINLOG TABLES. This may take long time..
   Wed Feb 28 17:48:47 2018 - [info]  ok.
   Wed Feb 28 17:48:47 2018 - [info] Checking MHA is not monitoring or doing failover..
   Wed Feb 28 17:48:47 2018 - [info] Checking replication health on 192.168.171.136..
   Wed Feb 28 17:48:47 2018 - [info]  ok.
   Wed Feb 28 17:48:47 2018 - [info] 192.168.171.136 can be new master.
   Wed Feb 28 17:48:47 2018 - [info] 
   From:
   192.168.171.135(192.168.171.135:3306) (current master)
    +--192.168.171.136(192.168.171.136:3306)

   To:
   192.168.171.136(192.168.171.136:3306) (new master)
    +--192.168.171.135(192.168.171.135:3306)

   Starting master switch from 192.168.171.135(192.168.171.135:3306) to 192.168.171.136(192.168.171.136:3306)? (yes/NO): yes
   Wed Feb 28 17:48:51 2018 - [info] Checking whether 192.168.171.136(192.168.171.136:3306) is ok for the new master..
   Wed Feb 28 17:48:51 2018 - [info]  ok.
   Wed Feb 28 17:48:51 2018 - [info] ** Phase 1: Configuration Check Phase completed.
   Wed Feb 28 17:48:51 2018 - [info] 
   Wed Feb 28 17:48:51 2018 - [info] * Phase 2: Rejecting updates Phase..
   Wed Feb 28 17:48:51 2018 - [info] 
   Wed Feb 28 17:48:51 2018 - [info] Executing master ip online change script to disable write on the current master:
   Wed Feb 28 17:48:51 2018 - [info]   /mha/cluster1/master_ip_online_change --command=stop --orig_master_host=192.168.171.135 --orig_master_ip=192.168.171.135 --orig_master_port=3306 --orig_master_user='root' --orig_master_password='123456' --new_master_host=192.168.171.136 --new_master_ip=192.168.171.136 --new_master_port=3306 --new_master_user='root' --new_master_password='123456' --orig_master_ssh_user=root --new_master_ssh_user=root   --orig_master_is_new_slave
   Wed Feb 28 17:48:51 2018 775730 Set read_only on the new master.. ok.
   Wed Feb 28 17:48:51 2018 801626 drop vip 192.168.171.137..
   Wed Feb 28 17:48:52 2018 356390 Set read_only=1 on the orig master.. ok.
   Wed Feb 28 17:48:52 2018 385158 Killing all application threads..
   Wed Feb 28 17:48:52 2018 385218 done.
   Wed Feb 28 17:48:52 2018 - [info]  ok.
   Wed Feb 28 17:48:52 2018 - [info] Locking all tables on the orig master to reject updates from everybody (including root):
   Wed Feb 28 17:48:52 2018 - [info] Executing FLUSH TABLES WITH READ LOCK..
   Wed Feb 28 17:48:52 2018 - [info]  ok.
   Wed Feb 28 17:48:52 2018 - [info] Orig master binlog:pos is mysql-bin.000009:3860.
   Wed Feb 28 17:48:52 2018 - [info]  Waiting to execute all relay logs on 192.168.171.136(192.168.171.136:3306)..
   Wed Feb 28 17:48:52 2018 - [info]  master_pos_wait(mysql-bin.000009:3860) completed on 192.168.171.136(192.168.171.136:3306). Executed 0 events.
   Wed Feb 28 17:48:52 2018 - [info]   done.
   Wed Feb 28 17:48:52 2018 - [info] Getting new master's binlog name and position..
   Wed Feb 28 17:48:52 2018 - [info]  mysql-bin.000070:2644
   Wed Feb 28 17:48:52 2018 - [info]  All other slaves should start replication from here. Statement should be: CHANGE MASTER TO MASTER_HOST='192.168.171.136', MASTER_PORT=3306, MASTER_AUTO_POSITION=1, MASTER_USER='repl', MASTER_PASSWORD='xxx';
   Wed Feb 28 17:48:52 2018 - [info] Executing master ip online change script to allow write on the new master:
   Wed Feb 28 17:48:52 2018 - [info]   /mha/cluster1/master_ip_online_change --command=start --orig_master_host=192.168.171.135 --orig_master_ip=192.168.171.135 --orig_master_port=3306 --orig_master_user='root' --orig_master_password='123456' --new_master_host=192.168.171.136 --new_master_ip=192.168.171.136 --new_master_port=3306 --new_master_user='root' --new_master_password='123456' --orig_master_ssh_user=root --new_master_ssh_user=root   --orig_master_is_new_slave
   Wed Feb 28 17:48:52 2018 646218 Set read_only=0 on the new master.
   Wed Feb 28 17:48:52 2018 648602Add vip 192.168.171.137 on ens33..
   Wed Feb 28 17:48:53 2018 - [info]  ok.
   Wed Feb 28 17:48:53 2018 - [info] 
   Wed Feb 28 17:48:53 2018 - [info] * Switching slaves in parallel..
   Wed Feb 28 17:48:53 2018 - [info] 
   Wed Feb 28 17:48:53 2018 - [info] Unlocking all tables on the orig master:
   Wed Feb 28 17:48:53 2018 - [info] Executing UNLOCK TABLES..
   Wed Feb 28 17:48:53 2018 - [info]  ok.
   Wed Feb 28 17:48:53 2018 - [info] Starting orig master as a new slave..
   Wed Feb 28 17:48:53 2018 - [info]  Resetting slave 192.168.171.135(192.168.171.135:3306) and starting replication from the new master 192.168.171.136(192.168.171.136:3306)..
   Wed Feb 28 17:48:54 2018 - [info]  Executed CHANGE MASTER.
   Wed Feb 28 17:48:54 2018 - [info]  Slave started.
   Wed Feb 28 17:48:54 2018 - [info] All new slave servers switched successfully.
   Wed Feb 28 17:48:54 2018 - [info] 
   Wed Feb 28 17:48:54 2018 - [info] * Phase 5: New master cleanup phase..
   Wed Feb 28 17:48:54 2018 - [info] 
   Wed Feb 28 17:48:55 2018 - [info]  192.168.171.136: Resetting slave info succeeded.
   Wed Feb 28 17:48:55 2018 - [info] Switching master to 192.168.171.136(192.168.171.136:3306) completed successfully.
   ### 说明：
   --orig_master_is_new_slave：把旧的master配置为从库
   --running_updates_limit=10000：如果主从库同步延迟在10000s内都允许切换，但是但是切换的时间长短是由recover时relay 日志的大小决定
   --interactive=0：是否需要手动yes确认交互
   ### 切换成功需要看到类似下面的提示：
   [info] Switching master to 192.168.171.135(192.168.171.135:3306) completed successfully.
   同时要查看VIP是否已经漂移到了新的主库上面
   # ip addr|grep ens33
   2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
       inet 192.168.171.136/24 brd 192.168.171.255 scope global dynamic ens33
       inet 192.168.171.137/32 scope global ens33
   ```

2. master故障手动Failover切换（MHA进程没启动或者挂了的同时主库也挂了）

   ```sh
   # masterha_master_switch --global_conf=$MHA_HOME/masterha_default.conf --conf=$MHA_HOME/app1.conf --dead_master_host=192.168.171.135 --master_state=dead --new_master_host=192.168.171.136 --ignore_last_failover
   切换成功需要看到类似如下提示：
   Started manual(interactive) failover.
   Invalidated master IP address on 192.168.171.135(192.168.171.135:3306)
   Selected 192.168.171.136(192.168.171.136:3306) as a new master.
   192.168.171.136(192.168.171.136:3306): OK: Applying all logs succeeded.
   192.168.171.136(192.168.171.136:3306): OK: Activated master IP address.
   192.168.171.136(192.168.171.136:3306): Resetting slave info succeeded.
   Master failover to 192.168.171.136(192.168.171.136:3306) completed successfully.
   ```

   > 注意：如果是主库服务器还活着，只是mysqld挂了的时候，VIP在切换的时候也会自动漂移，如果是服务器挂了，那么在挂掉的主库重启后，注意不要让VIP随开机启动，因为此时VIP已经漂移到了从库上，从库上可能正在接管业务，故障主库起来后，需要确认数据是否跟新的主库一样，如果一样，那么就把故障主库作为新的从库加入新主库下。

3. master故障自动Failover切换

   ```sh
   ### 手动把主库mysqld停掉，观察$MHA_HOME/manager/masterha/app1.log日志输出，看到如下信息：
   ----- Failover Report -----

   app1: MySQL Master failover 192.168.171.135(192.168.171.135:3306) to 192.168.171.136(192.168.171.136:3306) succeeded

   Master 192.168.171.135(192.168.171.135:3306) is down!

   Check MHA Manager logs at bzm.testing:/var/log/masterha/app1/app1.log for details.

   Started automated(non-interactive) failover.
   Invalidated master IP address on 192.168.171.135(192.168.171.135:3306)
   Selected 192.168.171.136(192.168.171.136:3306) as a new master.
   192.168.171.136(192.168.171.136:3306): OK: Applying all logs succeeded.
   192.168.171.136(192.168.171.136:3306): OK: Activated master IP address.
   192.168.171.136(192.168.171.136:3306): Resetting slave info succeeded.
   Master failover to 192.168.171.136(192.168.171.136:3306) completed successfully.
   ### 表示成功切换，切换成功后，查看VIP是否漂移到了从库上(切换成功后，MHA进程会自动停止)，同时查看/etc/masterha/app1.conf文件中的[server1]的配置是否都被删除掉了。
   ```

   > 注意：故障主库起来后，需要确认数据是否跟新的主库一样，如果一样，那么就把故障主库作为新的从库加入新主库下。然后在故障主库上启动MHA进程。


## 8.问题解决

```sh
#ERROR：--Can't exec "mysqlbinlog": No such file or directory at /usr/local/perl5/MHA/BinlogManager.pm 
在所有节点上执行:
$ ln -s /usr/local/mysql/bin/mysqlbinlog /usr/local/bin/mysqlbinlog
$ ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql 】
[localhost~]$ which mysqlbinlog
   /usr/local/mysql/bin/mysqlbinlog
# ln -s /usr/local/mysql/bin/mysqlbinlog /mysqldata/my3306/binlog/mysqlbinlog
-- ln -s 链接目标 存放软连接路径

#Error
master_pos_wait return null maybe SQL thread was aborted
切换new master ip是否写错

#Error
Tue Apr 21 11:50:41 2015 - [error][/usr/lib/perl5/site_perl/5.8.8/MHA/MasterRotate.pm, ln228] 192.168.1.8 is not alive!
Tue Apr 21 11:50:41 2015 - [error][/usr/lib/perl5/site_perl/5.8.8/MHA/MasterRotate.pm, ln613] Failed to get new master!
Tue Apr 21 11:50:41 2015 - [error][/usr/lib/perl5/site_perl/5.8.8/MHA/MasterRotate.pm, ln652] Got ERROR:  at /usr/bin/masterha_master_switch line 53
#因为/apps/conf/mha/app1.cnf中的no_master=1限制了它成为新master的可能，标识掉no_master=1后，重新在线切换成功。
#app1.cnf 中加上port
```




## 附：MHA 日常维护命令集
```sh
1.查看ssh 登陆是否成功
shell > masterha_check_ssh --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
2.查看复制是否建立好
shell > masterha_check_repl --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
3.检查启动的状态
shell > masterha_check_status--global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
4.停止mha
shell > #masterha_stop --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
5.启动mha
shell > nohup masterha_manager --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf > /tmp/mha_manager.log < /dev/null 2>&1 &
注意：当有slave 节点宕掉的情况是启动不了的，加上--ignore_fail_on_start 即使有节点宕掉也能启动mha，需要在配置文件中设置ignore_fail=1
6.failover 后下次重启
每次failover 切换后会在管理目录生成文件app1.failover.complete ，下次在切换的时候会发现有这个文件导致切换不成功，需要手动清理掉。
shell > rm -rf /masterha/app1/app1.failover.complete
也可以加上参数--ignore_last_failover
7.手工failover
手工failover 场景，master 死掉，但是masterha_manager 没有开启，可以通过手工failover：
shell > masterha_master_switch --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --dead_master_host=old_ip --master_state=dead --new_master_host=new_ip --ignore_last_failover
8.masterha_manager 是一种监视和故障转移的程序。另一方面,masterha_master_switch 程序不监控主库。masterha_master_switch 可以用于主库故障转移,也可用于在线总开关。
9.手动在线切换(master还或者，比如做维护切换时)
shell > masterha_master_switch --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --master_state=alive --new_master_host=192.168.199.78 --orig_master_is_new_slave
或者
shell > masterha_master_switch --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --master_state=alive --new_master_host=192.168.199.78 -orig_master_is_new_slave --running_updates_limit=10000
--orig_master_is_new_slave 切换时加上此参数是将原master 变为slave 节点，如果不加此参数，原来的master 将不启动
--running_updates_limit=10000 切换时候选master 如果有延迟的话，mha 切换不能成功，加上此参数表示延迟在此时间范围内都可切换（单位为s），但是切换的时间长短是由recover时relay 日志的大小决定

```


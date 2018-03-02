##MHA部署指南
### 一、准备工作

1. 硬件准备，操作系统安装完毕（需要root用户权限和密码）；
2. 部署好mysql主从服务（注意复制用户和root用户在master、slave、MHAmanager节点上需要都能访问）；
3. SLAVE的read_only权限通过set global变量配置，不通过my.cnf配置。

### 二、规划和MHA安装

1. 规划
   - mhaManager节点主机及IP
   - mhaNode节点（包含mysql master和slave）主机及IP
   - 规划vip

2. mhaNode/mhaManager服务器之间建立ssh互信（验证免密登陆）

3. mhaNode节点安装

   ```sh
   yum安装：
   yum install perl-DBD-MySQL -y

   rpm安装：
   rpm -ivh mysql-libs-5.1.73-8.el6_8.x86_64.rpm
   rpm -ivh perl-DBD-MySQL-4.013-3.el6.x86_64.rpm 

   安装节点包：
   rpm -ivh mha4mysql-node-0.56-0.el6.noarch.rpm
   ```

   安装完成后会在/usr/bin目录下生成以下脚本文件(这些工具通常由MHAManager的脚本触发，无需人为操作)：

   - save_binary_logs              //保存和复制master的二进制日志
   - apply_diff_relay_logs          //识别差异的中继日志事件并将其差异的事件应用于其他的slave
   - filter_mysqlbinlog             //去除不必要的ROLLBACK事件（MHA已不再使用这个工具）
   - purge_relay_logs               //清除中继日志（不会阻塞SQL线程）

4. mhaManager节点安装

   ```sh
   yum安装：
   yum install perl-DBD-MySQL -y  【和node节点重复】
   yum install perl-Config-Tiny -y
   yum install epel-release -y
   yum install perl-Log-Dispatch -y
   yum install perl-Parallel-ForkManager -y

   rpm安装：
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

   安装管理包：
   rpm -ivh mha4mysql-manager-0.56-0.el6.noarch.rpm 
   ```

   安装完成后会在/usr/bin目录下生成以下脚本文件:

   - masterha_check_repl  
   - masterha_check_ssh  
   - masterha_check_status  
   - masterha_conf_host  
   - masterha_manager  
   - masterha_master_monitor  
   - masterha_master_switch  
   - masterha_secondary_check  
   - masterha_stop  
   - filter_mysqlbinlog  
   - save_binary_logs  
   - purge_relay_logs  
   - apply_diff_relay_logs 

   ?

### 三、配置(管理节点)

1. 修改全局配置文件（masterha_default.conf）

   ```sh
   # vi masterha_default.conf 

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
   ```

2. 修改集群配置文件（app1.conf）

   ```sh
   # vi app1.conf

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

   #注：如果有一主多从架构，那么只需要在app1/conf文件后面再多添加几个配置即可，类似如下：
   [server3]
   hostname=192.168.0.x
   port=3306
   master_binlog_dir=/data/mysql/data
   ```

3. 修改IP切换配置文件

   ```sh
   修改master_ip_failover文件中的VIP和绑定网卡
   vim /etc/masterha/master_ip_failover
   my $vip = "172.32.3.195";
   my $if = "eth0";

   修改master_ip_online_change文件中的VIP和绑定网卡：
   vim /etc/masterha/master_ip_online_change
   【修改内容相同】

   把drop_vip.sh和init_vip.sh中的网卡和VIP都改过来
   ```

   把脚本赋予执行权限：chmod +x drop_vip.sh init_vip.sh master_ip_*



### 四、测试和管理节点的启停

1. Manager测试ssh连通性：

   ```sh
   masterha_check_ssh --conf=/etc/masterha/app1.conf

      注意：如果你是用虚拟机做实验，很可能碰到这步骤报错，碰到两边都无法ssh或者一边可以，一边不可以，此时，可以重新创建密钥试试，如果多次尝试仍然不行，那么就把发起ssh连接而失败的虚拟机换一台再试。或者，看看你的架构是不是把管理节点和数据节点放一起，而管理节点上又没有配置自己到自己免密钥登录。

      看到最后提示：[info] All SSH connection tests passed successfully.表示测试通过
   ```

2. 测试集群中的主从复制

   ```sql
   masterha_check_repl --conf=/etc/masterha/app1.conf --global_conf=/etc/masterha/masterha_default.conf
   注意：执行这个检测命令的时候使用的是user=root帐号去检测，
   注意user=root帐号也要有远程权限,另外，把mysql目录下的命令做个链接：
   # ln -s /usr/local/mysql/bin/* /usr/bin/
   -- ln -s 链接目标 存放软连接路径
   看到最后提示：MySQL Replication Health is OK.表示测试通过
   ```

3. 管理节点的启停和状态

   ```sh
   启动管理节点(只在从库上启动管理节点)：
   启动管理节点最好使用screen启动：
   nohup masterha_manager --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --remove_dead_master_conf --ignore_last_failover> /tmp/mha_manager.log 2>&1 &
   # ps -elf |grep masterha_manager

   确认VIP 绑定成功，如果业务按VIP 配置的访问DB，应该已经可以正常访问
   启动之后查看控制台输出日志：
   tail -100f /tmp/mha_manager.log
   查看app1日志输出：
   tail -f /var/log/masterha/app1/app1.log

   查看master的健康状况日志：
   cat /var/log/masterha/app1/app1.master_status.health

   检查是否启动成功：
   masterha_check_status --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf

   停止mha server
   masterha_stop   --conf=/etc/masterha/app1.conf
   ```
4. 切换测试

   ```sh
   1.在线手工切换（维护切换，需要把MHA监控进程关掉）：
   masterha_master_switch --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --master_state=alive --new_master_host=172.32.3.102 --orig_master_is_new_slave --running_updates_limit=10000
   masterha_master_switch --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --master_state=alive --new_master_host=172.32.3.104 --orig_master_is_new_slave --running_updates_limit=10000
   --orig_master_is_new_slave：把旧的master配置为从库
   --running_updates_limit=10000：如果主从库同步延迟在10000s内都允许切换，但是但是切换的时间长短是由recover时relay 日志的大小决定
   --interactive=0：是否需要手动yes确认交互
   切换成功需要看到类似下面的提示：
   [info] Switching master to 192.168.171.135(192.168.171.135:3306) completed successfully.
   同时要查看VIP是否已经漂移到了新的主库上面
   注：手动在线切换mha，切换时需要将在运行的mha 停掉后才能切换。

   #切换报错
   Fri Feb  9 10:27:24 2018 - [error][/usr/share/perl5/vendor_perl/MHA/MasterRotate.pm, ln142] Getting advisory lock failed on the current master. MHA Monitor runs on the current master. Stop MHA Manager/Monitor and try again.
   Fri Feb  9 10:27:24 2018 - [error][/usr/share/perl5/vendor_perl/MHA/ManagerUtil.pm, ln177] Got ERROR:  at /usr/bin/masterha_master_switch line 53.
   #需要先停止mha server再切换
   masterha_stop   --conf=/etc/masterha/app1.conf
   #再次尝试切换
   Execution of /etc/masterha/master_ip_online_change aborted due to compilation errors.
   Fri Feb  9 10:38:40 2018 - [error][/usr/share/perl5/vendor_perl/MHA/ManagerUtil.pm, ln177] Got ERROR:  at /usr/bin/masterha_master_switch line 53.
   syntax error at /etc/masterha/master_ip_online_change line 171, near ")
         ## Waiting for N * 100 milliseconds so that current connections can exit
         my "
    # 函数后面要加分号结束（&drop_vip();）
    #建议修改my.cnf 里面的report_id 和 report_port（需重启），便于在master上面查询slaveHosts：show slave hosts;

   2.故障手工切换（MHA进程没启动或者挂了的同时主库也挂了）：
   # masterha_master_switch --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --dead_master_host=old_ip --master_state=dead --new_master_host=new_ip --ignore_last_failover
   masterha_master_switch --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --dead_master_host=192.168.171.135 --master_state=dead --new_master_host=192.168.171.136 --ignore_last_failover
   切换成功需要看到类似如下提示：
   Started manual(interactive) failover.
   Invalidated master IP address on 192.168.171.135(192.168.171.135:3306)
   Selected 192.168.171.136(192.168.171.136:3306) as a new master.
   192.168.171.136(192.168.171.136:3306): OK: Applying all logs succeeded.
   192.168.171.136(192.168.171.136:3306): OK: Activated master IP address.
   192.168.171.136(192.168.171.136:3306): Resetting slave info succeeded.
   Master failover to 192.168.171.136(192.168.171.136:3306) completed successfully.
   注意：如果是主库服务器还活着，只是mysqld挂了的时候，VIP在切换的时候也会自动漂移，如果是服务器挂了，那么在挂掉的主库重启后，注意不要让VIP随开机启动，因为此时VIP已经漂移到了从库上，从库上可能正在接管业务，故障主库起来后，需要确认数据是否跟新的主库一样，如果一样，那么就把故障主库作为新的从库加入新主库下

   3.故障自动切换（启动MHA监控进程）手动把主库mysqld停掉，观察/var/log/masterha/app1.log日志输出，看到如下信息：
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
   表示成功切换，切换成功后，查看VIP是否漂移到了从库上(切换成功后，MHA进程会自动停止)，同时查看/etc/masterha/app1.conf文件中的[server1]的配置是否都被删除掉了
   故障主库起来后，需要确认数据是否跟新的主库一样，如果一样，那么就把故障主库作为新的从库加入新主库下。然后在故障主库上启动MHA进程。

   ```


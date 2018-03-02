#!/bin/sh
PATH=$PATH:$HOME/bin

#MHA path
export MHA_HOME=/mha/cluster1;
export MHA_MANAGER_HOME=$MHA_HOME/manager;
export MHA_LOG=$MHA_HOME/log;
export MHA_REMOTE_M_HOME=$MHA_MANAGER_HOME;

# OS Info
export os_ssh_user=root;

# Mysql User Info
export mysql_user=root;
export mysql_user_password=123456;
export mysql_repl_user=repl;
export mysql_repl_user_password=123456;

#Mysql Ip ,port,binlog Path
export mysql_master=192.168.171.135;
export mysql_master_port=3306;
export mysql_master_standby=192.168.171.136;
export mysql_master_standby_port=3306;
#export mysql_slave=192.168.171.100;
#export mysql_slave_port=3306;
    # cat /etc/my.cnf|grep log-bin
    #log-bin                     = /mysqldata/my3306/binlog/mysql-bin
export mysql_master_binlog_dir=/mysqldata/my3306/binlog/;
export mysql_master_standby_binlog_dir=/mysqldata/my3306/binlog/;
#export mysql_slave_binlog_dir=/mysqldata/my3306/binlog/;

#vip info（写入profile）
    # ip addr
    # 2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    # inet 192.168.171.136/24 brd 192.168.171.255 scope global dynamic ens33
echo "# MHA using mysql vip info
export MYSQL_VIP=192.168.171.137;
export MYSQL_VIP_adapterName=ens33;
export MHA_HOME="$MHA_HOME  >>/etc/profile
# 立刻生效
source /etc/profile

mkdir $MHA_HOME -p
mkdir $MHA_LOG -p
mkdir $MHA_MANAGER_HOME -p

################## create masterha_default.conf
echo "[server default]
#MySQL的用户和密码
user="$mysql_user"
password="$mysql_user_password"

#系统ssh用户
ssh_user="$os_ssh_user"

#复制用户
repl_user="$mysql_repl_user"
repl_password= "$mysql_repl_user_password"

#监控
ping_interval=1
#shutdown_script=\"\"

#切换调用的脚本
master_ip_failover_script= "$MHA_HOME"/master_ip_failover
master_ip_online_change_script= "$MHA_HOME"/master_ip_online_change

" > $MHA_HOME/masterha_default.conf
################## create app1.conf
echo "[server default]
#mha manager工作目录
manager_workdir ="$MHA_MANAGER_HOME"
manager_log = "$MHA_MANAGER_HOME"/app1.log
remote_workdir = "$MHA_REMOTE_M_HOME"
[server1]
hostname="$mysql_master"
master_binlog_dir ="$mysql_master_binlog_dir"
port="$mysql_master_port"
candidate_master = 1
check_repl_delay = 0     #用防止master故障时，切换时slave有延迟，卡在那里切不过来。
[server2]
hostname="$mysql_master_standby" 
master_binlog_dir="$mysql_master_standby_binlog_dir"
port="$mysql_master_standby_port"
candidate_master=1
check_repl_delay = 0 

# 注：如果有一主多从架构，那么只需要在conf文件后面再多添加几个配置即可，类似如下：
# [server3]
# hostname=$mysql_slave
# port=$mysql_slave_port
# master_binlog_dir=$mysql_slave_binlog_dir
"> $MHA_HOME/app1.conf

################## create drop_vip.sh
echo "/sbin/ip addr del \""$MYSQL_VIP"/32\" dev "$MYSQL_VIP_adapterName   > $MHA_HOME/drop_vip.sh

################## create init_vip.sh
echo "/sbin/ip addr add \""$MYSQL_VIP"/32\" dev "$MYSQL_VIP_adapterName   > $MHA_HOME/init_vip.sh
################## copy master_ip_failover, master_ip_online_change
cp -ar master_ip_failover $MHA_HOME/master_ip_failover
cp -ar master_ip_online_change $MHA_HOME/master_ip_online_change

cd $MHA_HOME
chmod +x drop_vip.sh init_vip.sh master_ip_*



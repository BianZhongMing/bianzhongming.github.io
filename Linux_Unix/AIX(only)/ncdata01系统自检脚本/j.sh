#
# 定义报表头
#
report_header()
{
HOSTIP=$(ifconfig -a | sed -n '2p' |awk '{print $2}')
HOSTNAME=$(hostname)
cat<<!
Hostname: $HOSTNAME       Server: $HOSTIP
Time: $(date +%Y'-'%m'-'%d' '%H':'%M':'%S)

                                 SYSTEM CHECK REPORT
                                 ===================
 
!
}

#
# 定义日志文件存放的目录和日志文件名，将当前用户目录设置为LOG_PATH
#
LOG_PATH=/zj
LOG_FILE=$LOG_PATH/`date +%m%d%H`_nc1.log
#
# 输出报表头信息
#
report_header >$LOG_FILE

# 检查 CPU的使
echo "***************************************** Check CPU *****************************************">>$LOG_FILE
vmstat 1 10 | awk '{print $0;if($1 ~ /^[0-9].*/) (totalcpu+=$16);(avecpu=100-totalcpu/10)}; END {print "The average usage of cpu is :"avecpu}' >/zj/cpu_info

cat /zj/cpu_info >>$LOG_FILE

cpu_used_pct=`cat /zj/cpu_info | grep "The average usage of cpu is" |awk -F ":" '{print $2}' `
if [ "$cpu_used_pct" -gt "50" ] ; then
    echo "LOG-Warnning:`date +%Y'-'%m'-'%d' '%H':'%M':'%S`, CPU负载超过阀值设置，请检查系统!!">>$LOG_FILE
else
 echo "\t\t\t\t CPU负载正常!!">>$LOG_FILE
fi


#
# 内存使用监控，包括交换区的使用情况监控
#                               
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check memory useage *****************************************">>$LOG_FILE
cat /zj/cpu_info  | awk '{print $0;if($1 ~ /^[0-9].*/) (totalpi+=$6)(totalpo+=$7)};\
END {if(totalpi<10 && totalpo<10) print "\t\t\t\tMemory负载正常!!"; if(totalpi>10 || totalpo>10) print "Memory负载异常，请检查系统!!"} '>>$LOG_FILE 

#
# 检查磁盘空间.
#
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check disk space *****************************************">>$LOG_FILE
df -g >>$LOG_FILE
df -g |grep -v proc |grep -v Filesystem |awk '{x=1*$4}{print $1","$2","$3","$4","$5","$6","$7}'>/zj/disk_info

cat /zj/disk_info| grep -v '^#' | while read line
do
item1=$(echo $line | awk -F ',' '{print $1}')
item2=$(echo $line | awk -F ',' '{print $2}')
item3=$(echo $line | awk -F ',' '{print $3}')
item4=$(echo $line | awk -F ',' '{print $4}' |awk -F '%' '{print $1}')
item5=$(echo $line | awk -F ',' '{print $5}')
item6=$(echo $line | awk -F ',' '{print $6}')
item7=$(echo $line | awk -F ',' '{print $7}')
if [ "$item4" -gt "80" ]; then
    echo "LOG-Warnning: `date +%Y'-'%m'-'%d' '%H':'%M':'%S`, 磁盘$item7\t剩余空间不足，请处理!!" >>$LOG_FILE
else
    echo "\t\t\t\t 磁盘空间$item7\t\t使用正常!!" >>$LOG_FILE
fi
done
#
# 检查磁盘的io进行监控，iostat
# 
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check iostat *****************************************">>$LOG_FILE
iostat 1 3 >>$LOG_FILE

#
# 对网络流量进行监控，在这里可以作一个主机列表，对每个主机ping检查网络是否连通。
#
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check netstat *****************************************">>$LOG_FILE
netstat -i >>$LOG_FILE

#
# 检查主机的告警日志 
#
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check system err *****************************************">>$LOG_FILE
errpt | head -10 >>$LOG_FILE


#
# 检查HA的运行是否正常                
#
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check HACMP status *****************************************">>$LOG_FILE
lspv >> $LOG_FILE

#
# 检查ntpd的运行是否正常                
#
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check ntpd status *****************************************">>$LOG_FILE
lssrc -ls xntpd >> $LOG_FILE

#
# 检查CRS的运行是否正常                
#
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check HACMP CRS *****************************************">>$LOG_FILE
cd /
./oracle/product/10.2/crs/bin/crs_stat -t >>$LOG_FILE

#
# 检查数据库进程.   
#                                   
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check oracle process *****************************************">>$LOG_FILE
ps -ef|grep ora_|grep -v grep >> $LOG_FILE


#
# 检查数据库监听进程.   
#                                   
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check oracle listener *****************************************">>$LOG_FILE
ps -ef|grep -i listener|grep -v grep >>$LOG_FILE


#
# 检查数据库alert.   
#                                   
echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check oracle alert *****************************************">>$LOG_FILE
tail -100 /oracle/admin/nc/bdump/alert_nc1.log |grep ORA->>$LOG_FILE
tail -100 /oracle/admin/nc/bdump/alert_nc1.log |grep WARNING>>$LOG_FILE


echo >>$LOG_FILE
echo >>$LOG_FILE
echo "***************************************** check backup  *****************************************">>$LOG_FILE
ls -l /back/ncv502/iufoautobak1.dmp /back/ncv502/autobak1.dmp.gz>>$LOG_FILE 
tail -1 /back/ncv502/iufoautobak.log>>$LOG_FILE 
tail -1 /back/ncv502/v5autobak.log>>$LOG_FILE 
tail -1 /back/ncv502/interface.log>>$LOG_FILE 


FTP_FILE=`date +%m%d%H`_nc1.log

ftp -i -in  << !!!
open 172.19.100.115 21 
user ncv5 ncv5_123 
lcd /zj
cd log

put $FTP_FILE
bye

!!!

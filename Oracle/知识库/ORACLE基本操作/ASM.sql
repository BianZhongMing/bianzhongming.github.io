export ORACLE_SID=+ASM1
asmcmd

-----------
查使用空间：
1.查看v$asm_diskgroup视图
SQL> select group_number,name,total_mb,free_mb from v$asm_diskgroup;

2.进入asmcmd查看
rac2:oracle:rac2 > export ORACLE_SID=+ASM1
rac2:oracle:rac2 > asmcmd
ASMCMD> lsdg
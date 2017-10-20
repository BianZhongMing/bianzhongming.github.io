--查询数据库分区表

select * from user_tables where partitioned='YES';
--1  IA_MONTHLEDGER        VALID                          N  143271627  11635130  0  0  0  137  0  0           1           1      N  ENABLED  143271627  2014/9/20 17:47:54  YES  	N	N	NO		DISABLED	YES	NO		DISABLED	YES		DISABLED		NO

select * from dba_tables where partitioned='YES' ;

select partition_name
  from user_tab_partitions
 where table_name = 'IA_MONTHLEDGER';

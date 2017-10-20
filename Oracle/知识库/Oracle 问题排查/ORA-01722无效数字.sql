【原因】筛选数据类型和数据库数据类型不符
【解决】where条件逐一排查，查看是否符合数据类型，若条件较多则采用分批试运行排查的方法
   
   select *
  from workflow_requestlog
 where workflowid = 5085
   and logtype = '3' -- and logtype = 3 logtype是char(1)
   and nodeid in ('11173', '11168')
   and OPERATEDATE > '2014-01-01'

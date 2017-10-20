--drop procedure 存储过程名称;  删除存储过程
--创建/修改存储过程
/*CREATE OR REPLACE PROCEDURE GYLCRKD_TB AS
BEGIN
--SQL语句--e.g Update table
end;
/
SQL> show errors --显示编译错误
*/


--定时任务
--注意：PLSQL查看存储过程不准确，要用语句查
/*
用法DEMO:  
     DBMS_JOB.SUBMIT(:jobno,//job号   
          'your_procedure;',//要执行的过程   
        trunc(sysdate)+1/24,//下次执行时间  TRUNC(SYSDATE)+间隔天数+几点/24 
        'trunc(sysdate)+1/24+1'//每次间隔时间   对应dba_jobs.INTERVAL:用于计算下一运行时间的表达式 
         );   
*/

VARIABLE JOBNO NUMBER;
VARIABLE INSTNO NUMBER;
BEGIN
SELECT INSTANCE_NUMBER INTO :INSTNO FROM V$INSTANCE;
DBMS_JOB.SUBMIT(:JOBNO,'test11;
',TRUNC(SYSDATE)+1/24+1,'TRUNC(SYSDATE)+7+1/24',TRUE,:INSTNO);
COMMIT;
END;
/

--JOBNO 192

---删除定时任务
select * from dba_jobs where job='192';--user_jobs;
--1       305   2009-3-4 3:10:14                   2009-3-6 2:00:00          "ANALYZE_TB;
--删除存储过程
drop procedure NAME;



exec sys.dbms_job.remove('192');

--插删表案例（注：运行过程中不能存在错误，否则会中断）
create or replace procedure Tbzm20141212
as
delTab varchar2(2048);
InsTable varchar2(2048);
grantTable varchar2(2048);
begin
delTab := ' drop table xian_CL purge';
InsTable := q'[create table xian_CL as (SELECT f.INVCODE,f.INVNAME,d.province,d.citycounty,a.VBATCHCODE,a.PINPAI,a.ZIPINPAI,a.CHANGJIAKUANHAO,a.ZHUSHIZHONGLIANG,a.SHOUCUNCHANGDU,
a.YANSE,a.JINGDU,a.QIEGONG,a.ZONGZHONG,a.JIANCEZHENGSHU,a.jiangshangzhengshu,a.vdef37 chicun,a.vdef38 diaogong,
a.vdef39 zhidi,a.vdef40 yuyi,a.XIAOSHOUHANSHUIJIA,
b.nonhandnum,d.unitname
  FROM  IC_ONHANDNUM B, bd_corp d,ts_batchcode a,bd_invcl e,bd_invbasdoc f
 WHERE A.VBATCHCODE = B.VLOT
   and a.pk_invbasdoc=f.pk_invbasdoc
   and f.pk_invcl=e.pk_invcl
   AND NONHANDNUM <> 0
   AND B.DR = 0
   AND substr(e.invclasscode, 1, 1) NOT in ('8', '9')
  and substr(a.vbatchcode,1,2)<>'TL'
   and b.pk_corp=d.pk_corp
   and substr(d.unitcode,1,1) in('E','J')
   and b.pk_corp not in ('1003','1514','1003','1514'))]';
grantTable := 'GRANT SELECT ON "NCV502"."XIAN_CL" TO sqlserconn';
execute immediate delTab;
execute immediate InsTable;
execute immediate grantTable;
commit;
end;
/


exec Tbzm20141212;

--定时任务


trunc(sysdate,'d') --(星期天)返回当前星期的第一天
select  TRUNC(sysdate,'d')+1/24 from dual;

--每周日晚1点
VARIABLE JOBNO NUMBER;
VARIABLE INSTNO NUMBER;
BEGIN
SELECT INSTANCE_NUMBER INTO :INSTNO FROM V$INSTANCE;
DBMS_JOB.SUBMIT(:JOBNO,'Tbzm20141212;
',TRUNC(SYSDATE)+6+1/24,'TRUNC(SYSDATE)+7+1/24',TRUE,:INSTNO);
COMMIT;
END;
/

--dba_jobs：
字段（列）               数据类型              描述   
JOB                    NUMBER               任务的唯一标示号   
LOG_USER               VARCHAR2(30)         提交任务的用户   
PRIV_USER              VARCHAR2(30)         赋予任务权限的用户   
SCHEMA_USER            VARCHAR2(30)         对任务作语法分析的用户模式   
LAST_DATE              DATE                 最后一次成功运行任务的时间   
LAST_SEC               VARCHAR2(8)          如HH24:MM:SS格式的last_date日期的小时，分钟和秒   
THIS_DATE              DATE                 正在运行任务的开始时间，如果没有运行任务则为null   
THIS_SEC               VARCHAR2(8)          如HH24:MM:SS格式的this_date日期的小时，分钟和秒   
NEXT_DATE              DATE                 下一次定时运行任务的时间   
NEXT_SEC               VARCHAR2(8)          如HH24:MM:SS格式的next_date日期的小时，分钟和秒   
TOTAL_TIME             NUMBER               该任务运行所需要的总时间，单位为秒   
BROKEN                 VARCHAR2(1)          标志参数，Y标示任务中断，以后不会运行   
INTERVAL               VARCHAR2(200)        用于计算下一运行时间的表达式   
FAILURES               NUMBER               任务运行连续没有成功的次数   
WHAT                   VARCHAR2(2000)       执行任务的PL/SQL块   
CURRENT_SESSION_LABEL  RAW MLSLABEL         该任务的信任Oracle会话符   
CLEARANCE_HI           RAW MLSLABEL         该任务可信任的Oracle最大间隙   
CLEARANCE_LO           RAW MLSLABEL         该任务可信任的Oracle最小间隙   
NLS_ENV                VARCHAR2(2000)       任务运行的NLS会话设置   
MISC_ENV               RAW(32)              任务运行的其他一些会话参数  
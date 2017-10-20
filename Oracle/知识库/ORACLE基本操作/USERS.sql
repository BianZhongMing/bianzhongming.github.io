--创建用户
create user USERNAME identified by 密码;
grant create session to USERNAME; --创建session的权限，没有无法进行连接
Grant connect,dba to USERNAME; --最大权限

--授权 grant #P on tablename to username;
--#P:all / select  / drop / insert(特定字段，可选) /  update(特定字段，可选) / alter all
select 'Grant all on '||table_name||'to user2 ;' from all_tables where owner = upper(user1);
e.g.
grant update on tablename to USERNAME; --授予修改表的权限
grant update(id) on tablename to USERNAME;--授予对指定表特定字段的插入和修改权限，注意，只能是insert和update
grant alter all table to USERNAME;--授予用户alter任意表的权限
--撤销权限  基本语法同grant,关键字为revoke

--查看用户或角色系统权限(直接赋值给用户或角色的系统权限)：
select * from dba_sys_privs; --查看当前用户所有权限
select * from user_sys_privs; --查看当前用户所拥有的权限
select * from user_tab_privs;--查看所用用户对表的权限
--查看角色(只能查看登陆用户拥有的角色)所包含的权限
sql>select * from role_sys_privs;

--修改密码
alter user sys identified by 新密码;

--锁定和解锁用户
alter user test account lock;
alter user test account unlock;

--查看所有用户：
select *（username） from dba_users;   
select * from all_users;   
select * from user_users;

--查看用户对象权限：
select * from dba_tab_privs;   
select * from all_tab_privs;   
select * from user_tab_privs;

--删除用户
SQL> drop user test cascade; 
drop user test cascade
*
ERROR at line 1:
ORA-01940: cannot drop a user that is currently connected
  --通过查看用户的进行，并kill用户进程，然后删除用户
SQL> select sid,serial# from v$session where username='TEST';   --注意用户名字母都用大写
       SID    SERIAL#
---------- ----------
      1105        132
SQL> alter system kill session '1105,132';
System altered.
SQL> drop user ncv3 cascade;
User dropped.

【ORACLE 11G 默认密码180天过期设置】
--确定是由于oracle11g中默认在default概要文件中设置了“PASSWORD_LIFE_TIME=180天”所导致。
--密码过期后，业务进程连接数据库异常，影响业务使用。
1、查看用户的proifle是哪个，一般是default：
SELECT username,PROFILE FROM dba_users;
2、查看指定概要文件（如default）的密码有效期设置：
SELECT * FROM dba_profiles s WHERE s.profile='DEFAULT' AND resource_name='PASSWORD_LIFE_TIME';
3、将密码有效期由默认的180天修改成“无限制”：
sql>ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
修改之后不需要重启动数据库，会立即生效。

/*
总体解释：
DML（data manipulation language）：操作
e.g. SELECT,UPDATE,INSERT,DELETE,EXPLAIN,CALL
DDL（data definition language）：定义/改变表(表之间的链接和约束等初始化工作)
e.g. CREATE,ALTER,DROP,TRUNCATE,COMMENT(注释)
DCL（Data Control Language）：控制(设置或更改数据库用户或角色权限)
e.g. grant,deny,revoke
*/
--事务主要是针对dml语句来说的,dml语句对数据的修改需要commit才能生效，如果rollback，将回滚你的修改。


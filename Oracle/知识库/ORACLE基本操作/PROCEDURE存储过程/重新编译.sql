--查找到无效对象
select 'Alter '||object_type||' '||object_name||' compile;' from user_objects where status = 'INVALID';

--重新编译存储过程 pro_backup_call 执行下面脚本即可
alter procedure pro_backup_call compile;
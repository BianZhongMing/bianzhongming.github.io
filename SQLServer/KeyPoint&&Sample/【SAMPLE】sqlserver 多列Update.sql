use testdb

update [dbo].[testable]  set UPDATE_BY=b.UPDATE_BY,UPDATE_TIME=b.UPDATE_TIME
from [dbo].[testable]  a,[10.10.10.10,3306].[testdb].[dbo].[testable] b
where a.id=b.id --Ö÷¼ü
and a.UPDATE_BY='[SP:sys_chk_exe_by_rul]'

update [dbo].[testable]  set UPDATE_BY=NULL
where UPDATE_BY='[SP:sys_chk_exe_by_rul]' 

Ð£Ñé£º
select  id,UPDATE_BY,UPDATE_TIME from [dbo].[testable] 
where UPDATE_BY='[SP:sys_chk_exe_by_rul]'  
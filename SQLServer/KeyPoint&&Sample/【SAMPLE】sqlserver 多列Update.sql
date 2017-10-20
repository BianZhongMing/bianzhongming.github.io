use datayesdb

update [dbo].[bond]  set UPDATE_BY=b.UPDATE_BY,UPDATE_TIME=b.UPDATE_TIME
from [dbo].[bond]  a,[10.21.139.64,3306].[datayesdb].[dbo].[bond] b
where a.id=b.id --Ö÷¼ü
and a.UPDATE_BY='[SP:sys_chk_exe_by_rul]'

update [dbo].[bond]  set UPDATE_BY=NULL
where UPDATE_BY='[SP:sys_chk_exe_by_rul]' 

Ð£Ñé£º
select  id,UPDATE_BY,UPDATE_TIME from [dbo].[bond] 
where UPDATE_BY='[SP:sys_chk_exe_by_rul]'  
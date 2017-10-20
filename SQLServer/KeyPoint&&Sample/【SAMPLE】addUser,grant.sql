
use master;
GO
create login uts_sync with password='_utssync123', default_database=DYMaster;
--获取对应DB的访问和管理权限
use DYMaster;
GO
create user uts_sync for login uts_sync with default_schema=dbo;
exec sp_addrolemember 'db_owner', 'uts_sync';

use DYMaster;
GO
create user talend_load for login talend_load with default_schema=dbo;
USE [DYMaster]
GO
ALTER ROLE [db_datareader] ADD MEMBER [talend_load]
GO

create table test
(id int,num int)
select * from test
insert test (id,num)values(1,1),(2,2)
delete  from test where id=1 
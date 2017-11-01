
use master;
GO
create login db_sync with password='yourpassword', default_database=TESTDB;
--获取对应DB的访问和管理权限
use TESTDB;
GO
create user db_sync for login db_sync with default_schema=dbo;
exec sp_addrolemember 'db_owner', 'db_sync';

use TESTDB;
GO
create user talend_load for login talend_load with default_schema=dbo;
USE [TESTDB]
GO
ALTER ROLE [db_datareader] ADD MEMBER [talend_load]
GO

create table test
(id int,num int)
select * from test
insert test (id,num)values(1,1),(2,2)
delete  from test where id=1 
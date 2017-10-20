--执行字符串
EXECUTE sp_executesql 
          N'select CREATE_TIME from md_institution where PARTY_ID=93'
--执行变量生成结果集
declare @test nvarchar(500)  /*类型nvarchar，最长4000*/
set @test='select CREATE_TIME from md_institution where PARTY_ID=93'
EXECUTE sp_executesql  @test

--执行字符串2
exec ('select CREATE_TIME from md_institution where PARTY_ID=93')
Create function Testbzm(@inpute varchar(10))
Returns varchar(10)
As
Begin
   Declare @output varchar(10)
   Select @output=name_en from sys_table
Where table_id = @inpute
Return @output
End

select dbo.testbzm('458')

drop function testbzm;

--函数不能执行exec（不能调用存储过程）
--函数不能创建表，删除表，插入表数据
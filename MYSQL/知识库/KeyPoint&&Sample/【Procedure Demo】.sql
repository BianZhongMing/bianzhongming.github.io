create procedure t()
begin
declare a int ;
set a=1;

select id from testbzm where id=a;
end

call t()

drop procedure t
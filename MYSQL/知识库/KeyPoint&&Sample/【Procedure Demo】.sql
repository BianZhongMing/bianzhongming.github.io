create procedure t()
begin
declare a int ;
set a=1;

select id from testbzm where id=a;
end

call t()

drop procedure t


--Ñ­»·
create procedure t()
begin
declare i int ;
set i=0;
-- -
while(i<10000)
do
insert into rt_f_nhx_kdl_bill_201604_0(TRANDT,BILLSQ,TIMSTP)
(select 
date_format(now(),'%Y%m%d'),
floor(rand()*100000000000),
date_format(now(),'%Y-%m-%d %h:%i:%s'));
set i=i+1;
END while;
-- -
end
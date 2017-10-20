if(object_id('dbo.saleorder','U') is not null) drop table saleorder;
create table saleorder(orderid varchar(50) primary key,orderPrice decimal(20,8) null,orderdate date not null,userid varchar(50) not null);
insert into saleorder values 
('1001',100.23,'2015-01-01','001'),
('1002',140.23,'2015-11-01','001'),
('1003',150.23,'2015-03-01','001'),
('1004',110.23,'2015-09-01','002'),
('1005',160.23,'2015-06-01','002'),
('1006',130.23,'2015-03-01','002');

select *,
(select max(orderid) from saleorder i where i.orderid< o.orderid) 上个订单的ID,
(select min(orderid) from saleorder i where i.orderid> o.orderid) 下个订单的ID,
(select max(orderid) from saleorder i where i.userid=o.userid and orderid< o.orderid) 按用户分组上个订单的ID,
(select min(orderid) from saleorder i where i.userid=o.userid and i.orderid> o.orderid) 按用户分组下个订单的ID
 from saleorder o

 select *,
lag(orderid,1,NULL) over (order by orderid) 上个订单的ID,
lead(orderid,1,NULL) over (order by orderid) 下个订单的ID,
lag(orderid,1,NULL) over (partition by userid order by orderid) 按用户分组上个订单的ID,
lead(orderid,1,NULL) over (partition by userid order by orderid)  按用户分组下个订单的ID
 from saleorder o
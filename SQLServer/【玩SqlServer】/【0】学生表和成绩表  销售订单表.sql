--创建学生表
if(object_id('Tstudent') is not null ) drop table Tstudent;
go
create table Tstudent(
sno varchar(3) primary key,
sname varchar(4),
class varchar(3)
)
--创建成绩表
if(object_id('Tgrade') is not null) drop table Tgrade;
GO
create table Tgrade(
sno varchar(3) ,
les varchar(3) ,
grade  decimal(5,2)
)

--插入学生数据
insert into Tstudent values('001','gh','101')
insert into Tstudent values('002','lxg','102')
insert into Tstudent values('003','hs','103')
--插入成绩数据
insert into Tgrade values('001','yw',98)
insert into Tgrade values('001','yy',93)
insert into Tgrade values('001','sx',94)
insert into Tgrade values('002','yw',93)
insert into Tgrade values('002','yy',95)
insert into Tgrade values('002','sx',96)

--check
select * from Tstudent
select * from Tgrade


--clear
drop table Tstudent
drop table Tgrade



-----------------------------
if(object_id('dbo.saleorder','U') is not null) drop table saleorder;
create table saleorder(orderid varchar(50) primary key,orderPrice decimal(20,8) null,orderdate date not null,userid varchar(50) not null);
insert into saleorder values 
('1001',100.23,'2015-01-01','001'),
('1002',140.23,'2015-11-01','001'),
('1003',150.23,'2015-03-01','001'),
('1004',110.23,'2015-09-01','002'),
('1005',160.23,'2015-06-01','002'),
('1006',130.23,'2015-03-01','002');
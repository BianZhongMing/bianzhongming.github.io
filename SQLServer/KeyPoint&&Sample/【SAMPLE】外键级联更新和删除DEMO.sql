--创建学生表
if(object_id('Tstudent') is not null ) drop table Tstudent;
go
create table Tstudent(
stuno varchar(3) primary key,
stuname varchar(4),
stuclass varchar(3)
)
--创建成绩表
if(object_id('Tgrade') is not null) drop table Tgrade;
GO
create table Tgrade(
grade_stuno varchar(3) ,
grade_lessonno varchar(3) ,
grade  varchar(3)
)

--插入学生数据
insert into Tstudent values('001','gh','101')
insert into Tstudent values('002','lxg','102')
insert into Tstudent values('003','hs','103')
--插入成绩数据
insert into Tgrade values('001','yw','98')
insert into Tgrade values('001','yy','99')
insert into Tgrade values('001','sx','94')
insert into Tgrade values('002','yw','93')
insert into Tgrade values('002','yy','95')
insert into Tgrade values('002','sx','96')

--check
select * from Tstudent
/*
001	gh	101
002	lxg	102
003	hs	103
*/
select * from Tgrade
/*
001	yw	98
001	yy	99
001	sx	94
002	yw	93
002	yy	95
002	sx	96
*/

------------成绩表外键级联更新
alter table Tgrade add constraint FK_StudentNo foreign key (grade_stuno) references Tstudent (stuno) ON UPDATE CASCADE

update Tstudent set stuno='008' where stuname='gh'
select * from Tgrade
/*
008	yw	98
008	yy	99
008	sx	94
002	yw	93
002	yy	95
002	sx	96
*/

-------------级联删除
alter table Tgrade DROP constraint FK_StudentNo
alter table Tgrade add constraint FK_StudentNo foreign key (grade_stuno) references Tstudent (stuno) ON DELETE CASCADE

DELETE FROM Tstudent WHERE stuno='002'
select * from Tgrade
/*
008	yw	98
008	yy	99
008	sx	94
*/


-------------SET 值
if(object_id('Tstudent') is not null ) drop table Tstudent;
go
create table Tstudent(
stuno varchar(3) primary key,
stuname varchar(4),
stuclass varchar(3)
)
if(object_id('Tgrade') is not null) drop table Tgrade;
GO
create table Tgrade(
grade_stuno varchar(3) default('001'), /*Notice*/
grade_lessonno varchar(3) ,
grade  varchar(3)
)

insert into Tstudent values('001','gh','101')
insert into Tstudent values('002','lxg','102')
insert into Tstudent values('003','hs','103')
insert into Tgrade values('001','yw','98')
insert into Tgrade values('001','yy','99')
insert into Tgrade values('001','sx','94')
insert into Tgrade values('002','yw','93')
insert into Tgrade values('002','yy','95')
insert into Tgrade values('002','sx','96')

------------SET NULL
alter table Tgrade add constraint FK_StudentNo foreign key (grade_stuno) references Tstudent (stuno) ON UPDATE SET NULL
update Tstudent set stuno='008' where stuname='gh'
select * from Tgrade
/*
NULL	yw	98
NULL	yy	99
NULL	sx	94
002	yw	93
002	yy	95
002	sx	96*/
alter table Tgrade DROP constraint FK_StudentNo
alter table Tgrade add constraint FK_StudentNo foreign key (grade_stuno) references Tstudent (stuno) ON DELETE  SET NULL
DELETE FROM Tstudent WHERE stuno='002'
select * from Tgrade
/*
NULL	yw	98
NULL	yy	99
NULL	sx	94
NULL	yw	93
NULL	yy	95
NULL	sx	96
*/
alter table Tgrade DROP constraint FK_StudentNo
truncate table Tgrade;
truncate table Tstudent;
insert into Tstudent values('001','gh','101')
insert into Tstudent values('002','lxg','102')
insert into Tstudent values('003','hs','103')
insert into Tgrade values('001','yw','98')
insert into Tgrade values('001','yy','99')
insert into Tgrade values('001','sx','94')
insert into Tgrade values('002','yw','93')
insert into Tgrade values('002','yy','95')
insert into Tgrade values('002','sx','96')

------------SET DEFAULT
alter table Tgrade add constraint FK_StudentNo foreign key (grade_stuno) references Tstudent (stuno) ON UPDATE SET DEFAULT
update Tstudent set stuno='008' where stuname='gh'
/*消息 547，级别 16，状态 0，第 139 行
The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_StudentNo". The conflict occurred in database "njtestdb", table "dbo.Tstudent", column 'stuno'.
The statement has been terminated.
*/
update Tstudent set stuno='008' where stuno='002'
select * from Tgrade
/*
001	yw	98
001	yy	99
001	sx	94
001	yw	93
001	yy	95
001	sx	96
*/
select * from Tstudent

--Clear
drop table Tgrade
drop table Tstudent

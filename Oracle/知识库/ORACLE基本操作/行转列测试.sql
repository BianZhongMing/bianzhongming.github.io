----创建测试表
create table student_score(
       name varchar2(20),
       subject varchar2(20),
       score number(4,1)
       );
 
  
 
-----插入测试数据
 
insert into student_score (name,subject,score)values('张三','语文',78);
insert into student_score (name,subject,score)values('张三','数学',88);
insert into student_score (name,subject,score)values('张三','英语',98);
insert into student_score (name,subject,score)values('李四','语文',89);
insert into student_score (name,subject,score)values('李四','数学',76);
insert into student_score (name,subject,score)values('李四','英语',90);
insert into student_score (name,subject,score)values('王五','语文',99);
 
  
 
insert into student_score (name,subject,score)values('王五','数学',66);
 
  
 
insert into student_score (name,subject,score)values('王五','英语',91);
 
  
 select * from student_score
-----decode行转列
 
select name "姓名",
 
       sum(decode(subject, '语文', nvl(score, 0), 0)) "语文",
 
       sum(decode(subject, '数学', nvl(score, 0), 0)) "数学",
 
       sum(decode(subject, '英语', nvl(score, 0), 0)) "英语"
 
  from student_score
 
 group by name;
 
  
 
----创建测试表
 

create table student_score(
 
       name varchar2(20),
 
       subject varchar2(20),
 
       score number(4,1)

);
 
  
 
-----插入测试数据
 
insert into student_score (name,subject,score)values('张三','语文',78);
 
  
 
insert into student_score (name,subject,score)values('张三','数学',88);
 
  
 
insert into student_score (name,subject,score)values('张三','英语',98);
 
  
 
  
 
insert into student_score (name,subject,score)values('李四','语文',89);
 
  
 
insert into student_score (name,subject,score)values('李四','数学',76);
 
  
 
insert into student_score (name,subject,score)values('李四','英语',90);
 
  
 
  
 
insert into student_score (name,subject,score)values('王五','语文',99);
 
  
 
insert into student_score (name,subject,score)values('王五','数学',66);
 
  
 
insert into student_score (name,subject,score)values('王五','英语',91);
 
  
 select * from student_score
-----decode行转列
 
select name "姓名",
 
       sum(decode(subject, '语文', nvl(score, 0), 0)) "语文",
 
       sum(decode(subject, '数学', nvl(score, 0), 0)) "数学",
 
       sum(decode(subject, '英语', nvl(score, 0), 0)) "英语"
 
  from student_score
 
 group by name;
 
 ------ case when 行转列
select name "姓名",
 
       sum(case when subject='语文'
 
       then nvl(score,0)
 
       else 0
 
       end) "语文",
 
       sum(case when subject='数学'
 
       then nvl(score,0)
 
       else 0
 
       end) "数学",
 
       sum(case when subject='英语'
 
       then nvl(score,0)
 
       else 0
 
       end) "英语"
 
      from student_score
 
       group by name;
 
 
 --导出，按照逗号分列 
 
 select a.name,wmsys.wm_concat(a.subject||','||a.score) from student_score a
 group by a.name --for update
 
 --wmsys.wm_concat(tableA.t1) :1,2,3
 select * from student_score for update
 
 drop table student_score purge;

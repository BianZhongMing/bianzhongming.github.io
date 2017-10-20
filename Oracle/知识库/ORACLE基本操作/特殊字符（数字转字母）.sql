--特殊字符包含：
--可见字符：&,_,%
--不可见字符：制表符,制表符,回车符
--处理方法：ASCII码法，转义（escape）法，define法（针对自定义变量）

不可见字符处理： --ASCII码法
制表符： CHR(9)     换行符： CHR(10)    回车符： CHR(13)
--eg
select changjiakuanhao,vbatchcode from ts_batchcode where changjiakuanhao like '%'||chr(10)||'%' 

create table t_test_escape(name varchar2(20));
SQL> set define off  --使用set define off 关闭替代变量的功能，插入含有&的特殊字符。
SQL> insert into t_test_escape(name) values('Oracle%&_hello');
1 row inserted

%字符处理   --转义（escape）法
select * from t_test_escape where name like '%a%%' escape 'a';--上面使用的转义字符为'a'

&字符处理
--【1】define法
SQL> set define off --关闭替代变量功能之后可以直接将&当做普通字符，不用escape
select * from t_test_escape where name like '%&%';
--【2】ASCII码法
SQL> set define on  --打开替代变量功能
select ascii('&') from dual; --结果：38    --通过查询出'&'的ascii来绕过这个障碍 
SQL> select * from t_test_escape where name like '%' || chr(38) || '%'; --使用chr(38)去替代特殊字符'&'
--【3】define法  --将替代变量的特殊字符改为$
SQL> set define $
SQL> select * from t_test_escape where name like '%&%';

_字符处理   --转义（escape）法
select * from t_test_escape where name like '%a_%' escape 'a';


总结：escape关键字去转义特殊字符的时候，并不是对于所有的特殊字符都能够转义成功，使用escape是能够成功转义'%', '_'的，不能转义'&'

--数字转字母
chr(rownum+64)--直接转
chr(mod(rownum-1,26)+1+64)--循环生成A-Z
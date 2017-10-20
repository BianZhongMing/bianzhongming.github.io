--SQL注入
/* 概念
定义：一种代码注入技术，用于攻击基于数据库的应用，基本原理是将SQL语句插入到参数位置执行。
SQL 注入通过应用软件的安全漏洞（比如说用户输入的特殊字符没有被转义、或用户输入不是强类型导致意外执行）

本质：用户输入作为SQL命令被执行

Steps：
1. APP将表格发送给用户.
2. 攻击者将带有SQL注入的参数发送给WEB服务器.
3. APP利用用户输入的数据构建SQL串.
4. APP将SQL发送给DB.
5. DB执行了被注入的SQL，返回结果给APP.
6. APP将数据返回给用户.

危害：
1.越权增删改查数据。
2.修改数据库，入侵服务器（通过xp_cmdshell提权）
3.损害公司或者产品形象
*/
--DEMO---------可信部分-----不可信部分（ID=1）
--http://www.mysite.com/Widget?Id= 1
--SELECT * FROM Widget WHERE ID = 1

--注入种类
--select
SELECT columns
FROM InjectionPoint1 
WHERE InjectionPoint2
ORDER BY InjectionPoint3

--Insert
INSERT INTO table(col1, col2, ...) VALUES (InjectionPoint1, InjectionPoint2, ...)
/*
手段：不断加输入值，直道不再报错
foo’)--
foo’, 1)--
foo’, 1, 1)--
*/

--Update
UPDATE table
SET col1=InjectionPoint1, col2=InjectionPoint2, ...
WHERE InjectionPointN
--请小心Where子句注入，黑客在尝试过程就可能导致：
--’ OR 1=1 将会是灾难

--Union-Based Injection
--允许攻击者读取任意表
--foo’ UNION SELECT number FROM cc--
/*要求
–结果集必须是同样的列数和同样数据类型
–攻击者必须知道表名称
–DB返回的列名是第一个查询的列名称
注入方法：
使用NULL找到列数量
– UNION SELECT NULL--
– UNION SELECT NULL, NULL--
– UNION SELECT NULL, NULL, NULL--
使用Order By找到列数量
– ORDER BY 1--
– ORDER BY 2--
– ORDER BY 3--
找到哪一列是字符串类型列
– UNION SELECT 'a', NULL, NULL—
– UNION SELECT NULL, 'a', NULL--
– UNION SELECT NULL, NULL, 'a'--
*/


--基于错误的注入（Error-Based Injection）
--http://localhost:12587/Default.aspx?id=2 or x=1
--永远不要将数据库错误信息在生产环境中返回！！！500类错误重定向！


--推理注入
/*
基于布尔的注入和基于时间的注入统称为推理注入
这是由于应用程序可能不返回对应数据，所以需要借助这种比较麻烦的办法
确定页面是否可注入
–http://site/blog?message=5 AND 1=1
–http://site/blog?message=5 AND 1=2
注入方式取决于想象力
*/

--盲目注入（Blind-Based Injection）
/*
注入真假条件，根据返回内容的不同猜测结果
涉及大量的尝试，人工完成非常耗时，通常由工具进行注入
开多线程容易对服务器有损耗（DB被注入,CPU报警后发现有人开大量线程注入）
*/


--基于时间的注入（Time-based Injection）
--在上述注入方式都无法奏效时，考虑使用基于时间的注入
--基于时间的注入有时也被称为深度盲注
--基本原理：
SELECT * FROM products WHERE id=1; WAIT FOR DELAY '00:00:15'
SELECT * FROM products WHERE id=1;IF SYSTEM_USER='sa' WAIT FOR DELAY '00:00:15'


----------------------------
SQL注入工具
SqlMap
•http://sqlmap.org
•SQLMap是一个基于Python的开源测试工具，用于自动化检测和数据库控制工具。
使用说明：https://github.com/sqlmapproject/sqlmap/wiki/Usage
帮助：sqlmap.py --help (Script guy必备技能)
基本Get方式注入
–sqlmap.py -u “http://127.0.0.1/xx.aspx?category=1”
基本Post方式注入
–sqlmap.py--data "username=xyz&password=xyz"-u http://127.0.0.1/xx.aspx
表单注入
–sqlmap.py --forms -u "http://localhost:12587/Post.aspx"
SQLMap获取一些信息
当前用户：--current-user
当前数据库：--current-db
是否为管理员：--is-dba
数据库中所有用户：--users
列出所有数据库：--dbs
列出所有表：--tables
获取所有列：--columns
限制只扫描某库：-D database_name
限制只扫描某表：-T TableName


SQL注入方式选择
--technique
–B: Boolean-based blind
–E: Error-based
–U: Union query-based
–S: Stacked queries
–T: Time-based blind
–Q: Inline queries
默认是所有
线程选择--threads 5


预防方法：
1.强类型（参数化，类型不符报错）：强制限制输入参数类型
2.特殊字符过滤（筛查，报错）
3.简单检测
输入参数用单引号
–程序报错，则说明可注入
–程序未报错，则查看返回结果是否有变化
输入参数用两个单引号
–数据库中通常’’等同于一个’
–如果错误消失，则说明可注入
4.防范手段-减少Surface Area
数据库严禁暴漏在公网中（例：某银行信用卡系统）
应用程序从网络端限制不应该的请求
5.不要相信用户输入的数据，不要拼接数据到最终执行的SQL中
6.很多SQL注入攻击依赖于长SQL，对输入长度进行限制
7.按照业务范围对输入值范围进行过滤（年龄在0到100，登录名中是否包含空格，等等）
8.参数化查询
9.权限
基本原则：不应赋予多于所需权限的权限
应用程序连接数据库帐号的正确姿势
–数据库的DataReader组
–数据库的DataWriter组
–Grant Exec to [用户名]
拒绝SA作为生产环境应用程序帐号
–不幸的是，90%以上的传统企业是这么做的。
所需在用户库禁用的应用程序用户权限
–DENY SELECT ON sys.sysobjects TO [用户名]
当前用户必须添加到Master库中，还需要在Master库中禁用的权限
–DENY SELECT ON information_schema.tables TO [用户名]
–DENY SELECT ON sys.sysobjects TO [用户名]
10.更激进的防范措施
具有成本！需要考虑Trade-Off
可以利用SQL TRACE或扩展事件对SQL报错进行记录(DEMO)
监控执行语句，对可疑语句进行捕捉
–;--
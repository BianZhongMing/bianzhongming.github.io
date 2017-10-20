sql*loader  是一个程序,  用来把  文本文件里面的数据,   导入到 Oracle 数据库里面。

下面是一个简单的例子：

SQL*Loader

首先需要一个 控制文件test_main.ctl，内容如下：
LOAD DATA
INFILE *
INTO TABLE test_main
FIELDS TERMINATED BY ','
(ID, VALUE)
BEGINDATA
1,Test

其中，
第一行LOAD DATA意思是告诉SQL*Loader，要干啥? 这里是加载数据。
第二行INFILE *意思是数据从哪里来? 这里是包含在控制文件中。
第三行INTO TABLE 意思是数据要导到哪里？ 这里是要到 test_main 表。
第四行FIELDS TERMINATED BY意思是数据之间用什么符号分隔？ 这里是用 逗号 分隔。
第五行是数据要按什么顺序写到列里面
第六行BEGINDATA是告诉SQL*Loader，后面的都是数据了。

然后开始运行 sqlldr 程序

D:\temp>sqlldr userid=test/test123 control=test_main.ctl
SQL*Loader: Release 10.2.0.1.0 - Production on 星期日 3月 13 14:58:22 2011
Copyright (c) 1982, 2005, Oracle.  All rights reserved.
SQL*Loader-601:  对于 INSERT 选项, 表必须为空。表 TEST_MAIN 上出错

在 SQL Plus 中，
SQL> truncate table test_main;
表被截断。
以后，再次测试执行

D:\temp>sqlldr userid=test/test123 control=test_main.ctl
SQL*Loader: Release 10.2.0.1.0 - Production on 星期日 3月 13 14:58:56 2011
Copyright (c) 1982, 2005, Oracle.  All rights reserved.
达到提交点 - 逻辑记录计数 1
【定义】Oracle字符集是一个字节数据的解释的符号集合,有大小之分,有相互的包容关系。

 

影响Oracle数据库字符集最重要的参数是NLS_LANG参数。

它的格式如下: NLS_LANG = language_territory.charset

它有三个组成部分(语言、地域和字符集)，每个成分控制了NLS子集的特性。

其中:

Language： 指定服务器消息的语言， 影响提示信息是中文还是英文

Territory： 指定服务器的日期和数字格式，

Charset：  指定字符集。

如:AMERICAN _ AMERICA. ZHS16GBK

从NLS_LANG的组成我们可以看出，真正影响数据库字符集的其实是第三部分。

所以两个数据库之间的字符集只要第三部分一样就可以相互导入导出数据，前面影响的只是提示信息是中文还是英文。

如

 

二、. 查看数据库字符集

数据库服务器字符集select * from nls_database_parameters，其来源于props$，是表示数据库的字符集。
　　
　　客户端字符集环境select * from nls_instance_parameters,其来源于v$parameter，
　　
　　表示客户端的字符集的设置，可能是参数文件，环境变量或者是注册表
　　
　　会话字符集环境 select * from nls_session_parameters，其来源于v$nls_parameters，表示会话自己的设置，可能是会话的环境变量或者是alter session完成，如果会话没有特殊的设置，将与nls_instance_parameters一致。
　　
　　客户端的字符集要求与服务器一致，才能正确显示数据库的非Ascii字符。如果多个设置存在的时候，alter session>环境变量>注册表>参数文件
　　
　　字符集要求一致，但是语言设置却可以不同，语言设置建议用英文。如字符集是zhs16gbk，则nls_lang可以是American_America.zhs16gbk。


涉及三方面的字符集，

1. oracel server端的字符集;

2. oracle client端的字符集;

3. dmp文件的字符集。

 

在做数据导入的时候，需要这三个字符集都一致才能正确导入。

 

2.1 查询oracle server端的字符集

有很多种方法可以查出oracle server端的字符集，比较直观的查询方法是以下这种:

SQL> select userenv('language') from dual;

USERENV('LANGUAGE')

----------------------------------------------------

SIMPLIFIED CHINESE_CHINA.ZHS16GBK

 

SQL>select userenv(‘language’) from dual;

AMERICAN _ AMERICA. ZHS16GBK

 

2.2 如何查询dmp文件的字符集

用oracle的exp工具导出的dmp文件也包含了字符集信息，dmp文件的第2和第3个字节记录了dmp文件的字符集。如果dmp文件不大，比如只有几M或几十M，可以用UltraEdit打开(16进制方式)，看第2第3个字节的内容，如0354，然后用以下SQL查出它对应的字符集:

SQL> select nls_charset_name(to_number('0354','xxxx')) from dual;

ZHS16GBK

 

如果dmp文件很大，比如有2G以上(这也是最常见的情况)，用文本编辑器打开很慢或者完全打不开，可以用以下命令(在unix主机上):

cat exp.dmp |od -x|head -1|awk '{print $2 $3}'|cut -c 3-6

然后用上述SQL也可以得到它对应的字符集。

 

2.3 查询oracle client端的字符集

在windows平台下，就是注册表里面相应OracleHome的NLS_LANG。还可以在dos窗口里面自己设置，

比如: set nls_lang=AMERICAN_AMERICA.ZHS16GBK

这样就只影响这个窗口里面的环境变量。

 

在unix平台下，就是环境变量NLS_LANG。

$echo $NLS_LANG

AMERICAN_AMERICA.ZHS16GBK

 

如果检查的结果发现server端与client端字符集不一致，请统一修改为同server端相同的字符集。

 

补充：

(1).数据库服务器字符集

select * from nls_database_parameters

来源于props$，是表示数据库的字符集。

 

(2).客户端字符集环境

select * from nls_instance_parameters

其来源于v$parameter，表示客户端的字符集的设置，可能是参数文件，环境变量或者是注册表

 

(3).会话字符集环境

select * from nls_session_parameters

来源于v$nls_parameters，表示会话自己的设置，可能是会话的环境变量或者是alter session完成，如果会话没有特殊的设置，将与nls_instance_parameters一致。

 

(4).客户端的字符集要求与服务器一致，才能正确显示数据库的非Ascii字符。

如果多个设置存在的时候，NLS作用优先级别：Sql function > alter session > 环境变量或注册表 > 参数文件 > 数据库默认参数

 

字符集要求一致，但是语言设置却可以不同，语言设置建议用英文。如字符集是zhs16gbk，则nls_lang可以是American_America.zhs16gbk。

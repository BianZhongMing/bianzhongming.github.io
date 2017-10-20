一、CONCAT（）函数
CONCAT（）函数用于将多个字符串连接成一个字符串。
使用数据表Info作为示例，其中SELECT id,name FROM info LIMIT 1;的返回结果为
+----+--------+
| id | name   |
+----+--------+
|  1 | BioCyc |
+----+--------+
1、语法及使用特点：
CONCAT(str1,str2,…)                       
返回结果为连接参数产生的字符串。如有任何一个参数为NULL ，则返回值为 NULL。可以有一个或多个参数。

2、使用示例：
SELECT CONCAT(id, ‘，’, name) AS con FROM info LIMIT 1;返回结果为
+----------+
| con      |
+----------+
| 1,BioCyc |
+----------+

SELECT CONCAT(‘My’, NULL, ‘QL’);返回结果为
+--------------------------+
| CONCAT('My', NULL, 'QL') |
+--------------------------+
| NULL                     |
+--------------------------+

3、如何指定参数之间的分隔符
使用函数CONCAT_WS（）。使用语法为：CONCAT_WS(separator,str1,str2,…)
CONCAT_WS() 代表 CONCAT With Separator ，是CONCAT()的特殊形式。第一个参数是其它参数的分隔符。分隔符的位置放在要连接的两个字符串之间。分隔符可以是一个字符串，也可以是其它参数。如果分隔符为 NULL，则结果为 NULL。函数会忽略任何分隔符参数后的 NULL 值。但是CONCAT_WS()不会忽略任何空字符串。 (然而会忽略所有的 NULL）。

如SELECT CONCAT_WS('_',id,name) AS con_ws FROM info LIMIT 1;返回结果为
+----------+
| con_ws   |
+----------+
| 1_BioCyc |
+----------+

SELECT CONCAT_WS(',','First name',NULL,'Last Name');返回结果为
+----------------------------------------------+
| CONCAT_WS(',','First name',NULL,'Last Name') |
+----------------------------------------------+
| First name,Last Name                         |
+----------------------------------------------+

二、GROUP_CONCAT（）函数
GROUP_CONCAT函数返回一个字符串结果，该结果由分组中的值连接组合而成。
使用表info作为示例，其中语句SELECT locus,id,journal FROM info WHERE locus IN('AB086827','AF040764');的返回结果为
+----------+----+--------------------------+
| locus    | id | journal                  |
+----------+----+--------------------------+
| AB086827 |  1 | Unpublished              |
| AB086827 |  2 | Submitted (20-JUN-2002)  |
| AF040764 | 23 | Unpublished              |
| AF040764 | 24 | Submitted (31-DEC-1997)  |
+----------+----+--------------------------+

1、使用语法及特点：
GROUP_CONCAT([DISTINCT] expr [,expr ...]
[ORDER BY {unsigned_integer | col_name | formula} [ASC | DESC] [,col ...]]
[SEPARATOR str_val])
在 MySQL 中，你可以得到表达式结合体的连结值。通过使用 DISTINCT 可以排除重复值。如果希望对结果中的值进行排序，可以使用 ORDER BY 子句。
SEPARATOR 是一个字符串值，它被用于插入到结果值中。缺省为一个逗号 (",")，可以通过指定 SEPARATOR "" 完全地移除这个分隔符。
可以通过变量 group_concat_max_len 设置一个最大的长度。在运行时执行的句法如下： SET [SESSION | GLOBAL] group_concat_max_len = unsigned_integer;
如果最大长度被设置，结果值被剪切到这个最大长度。如果分组的字符过长，可以对系统参数进行设置：SET @@global.group_concat_max_len=40000;

2、使用示例：
语句 SELECT locus,GROUP_CONCAT(id) FROM info WHERE locus IN('AB086827','AF040764') GROUP BY locus; 的返回结果为
+----------+------------------+
| locus    | GROUP_CONCAT(id) |
+----------+------------------+
| AB086827 | 1,2              |
| AF040764 | 23,24            |
+----------+------------------+

语句 SELECT locus,GROUP_CONCAT(distinct id ORDER BY id DESC SEPARATOR '_') FROM info WHERE locus IN('AB086827','AF040764') GROUP BY locus;的返回结果为
+----------+----------------------------------------------------------+
| locus    | GROUP_CONCAT(distinct id ORDER BY id DESC SEPARATOR '_') |
+----------+----------------------------------------------------------+
| AB086827 | 2_1                                                      |
| AF040764 | 24_23                                                    |
+----------+----------------------------------------------------------+

语句SELECT locus,GROUP_CONCAT(concat_ws(', ',id,journal) ORDER BY id DESC SEPARATOR '. ') FROM info WHERE locus IN('AB086827','AF040764') GROUP BY locus;的返回结果为
+----------+--------------------------------------------------------------------------+
| locus    | GROUP_CONCAT(concat_ws(', ',id,journal) ORDER BY id DESC SEPARATOR '. ') |
+----------+--------------------------------------------------------------------------+
| AB086827 | 2, Submitted (20-JUN-2002). 1, Unpublished                               |
| AF040764 | 24, Submitted (31-DEC-1997) . 23, Unpublished                            |
+----------+--------------------------------------------------------------------------+
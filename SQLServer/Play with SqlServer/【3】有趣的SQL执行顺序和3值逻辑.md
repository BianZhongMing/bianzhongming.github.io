## 1 那些能看出SQL执行顺序蛛丝马迹的DEMO
>sql执行顺序：from>where>group by>having>select（over>distinct>top）>order by
>相同优先级的执行顺序：ANSI标准：同时执行；sqlserver实现：select部分同时执行(ALL-AT-ONCE OPERATION)，where部分除去优先级（AND>OR）sqlserver会按照COST大小选择（COST小的先执行）
### DEMO1 where>select>order
```sql
select name,sum(val) sval from test where sval<10 group by name --ERROR
select name,sum(val) sval from test group by name order by sval
/*order 可以引用别名，where 不行*/
```
### DEMO2 group >select（over>distinct）
```sql
--查询name的值去重并标注上row_number
select distinct row_number() over(order by name) id,name from test --Distinct没有发挥作用
select row_number() over(order by name) id,name from test group by name
```

## 2 SQL中的三值逻辑
>SQL中有三种逻辑，TRUE，FALSE，UNKNOWN(NULL)
### SQL中对UNKNOWN的处理：
1. where:TRUE，FALSE和UNKNOW被筛除；
2. check约束：非FALSE，TRUE和UNKNOWN被接受；
### SQL中对UNKNOWN的运算：
1. NULL和任何运算符的运算结果都是NULL，运算NULL=NULL 的结果是UNKNOWN（NULL只能用IS NULL/IS NOT NULL检测）*=NULL和is NULL的差异
2. UNIQUE约束中认为NULL=NULL是TRUE（mysql认为不等）
参考：http://blog.csdn.net/asktommorow/article/details/54411110
3. order by 认为 NULL和NULL的大小相等（T-SQL认为NULL>NOT NULL）
### 小结：需要在编写每一条查询语句的时候都意识到正在使用三值谓词逻辑
--从表中随机取记录 从bd_corp表中随机取3条记录
select * from (select * from bd_corp order by dbms_random.random) where rownum < 4
     
--产生随机数【整数】
SELECT DBMS_RANDOM.RANDOM FROM DUAL;  --任意大小的随机数
SELECT ABS(MOD(DBMS_RANDOM.RANDOM,100)) FROM DUAL;  --0～100以内的随机数
select trunc(dbms_random.value(100,1000)) from dual; -- 100～1000之间的随机数
--产生16位随机数
select to_char(trunc(dbms_random.value(1000000000000000,9999999999999999))) from dual; 

--产生随机数【小数】
SELECT dbms_random.value FROM dual; --0～1之间的随机数
SELECT dbms_random.value(10,20) FROM dual;  --10～20之间的随机数
SELECT dbms_random.normal FROM dual;
--NORMAL函数返回服从正态分布的一组数。此正态分布标准偏差为1，期望值为0。这个函数返回的数值中有68%是介于-1与+1之间，95%介于-2与+2之间，99%介于-3与+3之间。

--产生随机字符串
select dbms_random.string('P',20) from dual;  --P 表示printable，即字符串由任意可打印字符构成，20为字符串长度
select dbms_random.string(opt, length) from dual
      opt可取值如下：
      'u','U'    :    大写字母
      'l','L'    :    小写字母
      'a','A'    :    大、小写字母
      'x','X'    :    数字、大写字母
      'p','P'    :    可打印字符
--e.g.:   select dbms_random.string('x', 5) from dual

--随机日期
select to_date(2457161+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J') from dual
--通过下面的语句获得指定日期的基数
 select to_char(sysdate,'J') from dual

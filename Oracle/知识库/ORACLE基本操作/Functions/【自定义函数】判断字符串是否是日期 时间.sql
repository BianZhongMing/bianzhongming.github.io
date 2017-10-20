/*判断字符串是否是日期格式*/ 

CREATE OR REPLACE FUNCTION is_date(parameter VARCHAR2) RETURN NUMBER IS
  val DATE;
BEGIN
  val := TO_DATE(NVL(parameter, 'a'), 'yyyy-mm-dd hh24:mi:ss');
  RETURN 1;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END; 

/*调用*/ 

select is_date('12000') from dual; /*返回0*/
select is_date('1949-10-01') from dual; /*返回1*/ 

  

  

/*判断字符串是否是数字格式*/ 

CREATE OR REPLACE FUNCTION is_number(parameter VARCHAR2) RETURN NUMBER IS
  val NUMBER;
BEGIN
  val := TO_NUMBER(NVL(parameter, 'a'));
  RETURN 1;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END; 

/*调用*/ 

select is_date('abc') from dual; /*返回0*/
select is_date('123') from dual; /*返回1*/

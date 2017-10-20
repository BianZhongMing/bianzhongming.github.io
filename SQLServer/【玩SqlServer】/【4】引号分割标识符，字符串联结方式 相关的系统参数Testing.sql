-------------引号分割标识符
select '1223' nn,"1233445" mm;
--消息 207，级别 16，状态 1，第 1 行
--Invalid column name '1233445'.

set QUOTED_IDENTIFIER OFF;
select '1223' nn,"1233445" mm
--1223	1233445

set QUOTED_IDENTIFIER ON; --符合标准SQL规定【default】


---------------字符串联结方式（NULL）
select NULL+'aa' --NULL

set CONCAT_NULL_YIELDS_NULL OFF; --NULL按照空串处理

select NULL+'aa' --aa

set CONCAT_NULL_YIELDS_NULL ON;  --ANSI SQL规定【default】
-- mysql实现指定序数字符串位置获取
-- 字符串例子：'test_env_Log_10098'，需求：获取最后的数字部分10098

-- 1.嵌套实现，比较费劲
set @chr='test_env_Log_10098';
select substr(@chr,instr(@chr,'_')+1) -- 一次一个嵌套：substr(@chr,instr(@chr,'_')+1)，总共嵌套3次，费时费力

-- 2.substring_index实现
set @chr='test_env_Log_10098';
select substring_index(@chr,'_',-1)


-- 3.自定义函数实现






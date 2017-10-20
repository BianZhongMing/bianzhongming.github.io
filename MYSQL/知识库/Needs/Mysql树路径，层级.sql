-- -------------节点名只能是数字，且根节点为1，父节点出现在子节点之前才能出正确结果
CREATE TABLE `treenodes` (
  `id` int , -- 节点ID
  `nodename` varchar (60), -- 节点名称
  `pid` int -- 节点父ID
);

INSERT INTO `treenodes` (`id`, `nodename`, `pid`)
VALUES
	('1', 'A', '0'),
	('2', 'B', '1'),
	('3', 'C', '1'),
	('4', 'D', '2'),
	('5', 'E', '2'),
	('6', 'F', '3'),
	('7', 'G', '6'),
	('8', 'H', '0'),
	('9', 'I', '8'),
	('10', 'J', '8'),
	('11', 'K', '8'),
	('12', 'L', '9'),
	('13', 'M', '9'),
	('14', 'N', '12'),
	('15', 'O', '12'),
	('16', 'P', '15'),
	('17', 'Q', '15'),
	('18', 'R', '3'),
	('19', 'S', '2'),
	('20', 'T', '6'),
	('21', 'U', '8');

SELECT id AS ID,pid AS 父ID ,levels+1 AS 父到子之间级数, concat(paths,',',id) AS 父到子路径 FROM (
   SELECT id,pid,
   @le:= IF (pid = 0 ,0, 
     IF( LOCATE( CONCAT('|',pid,':'),@pathlevel)  > 0 ,   
         SUBSTRING_INDEX( SUBSTRING_INDEX(@pathlevel,CONCAT('|',pid,':'),-1),'|',1) +1
    ,@le+1) ) levels
   , @pathlevel:= CONCAT(@pathlevel,'|',id,':', @le ,'|') pathlevel
   , @pathnodes:= IF( pid =0,'0', 
      CONCAT_WS(',',
      IF( LOCATE( CONCAT('|',pid,':'),@pathall) > 0 , 
        SUBSTRING_INDEX( SUBSTRING_INDEX(@pathall,CONCAT('|',pid,':'),-1),'|',1)
       ,@pathnodes ) ,pid ) )paths
  ,@pathall:=CONCAT(@pathall,'|',id,':', @pathnodes ,'|') pathall 
    FROM treenodes, 
  (SELECT @le:=0,@pathlevel:='', @pathall:='',@pathnodes:='') vv
  ORDER BY pid,id
  ) src
ORDER BY id;

drop table treenodes;

-- -------------ID为字母类型
CREATE TABLE `treenodes` (
  `id` varchar(10) , -- 节点ID
  `nodename` varchar (60), -- 节点名称
  `pid` varchar(10) -- 节点父ID
);

INSERT INTO `treenodes` (`id`, `nodename`, `pid`)
VALUES
	('A1', 'A', NULL),
	('A2', 'B', 'A1'),
	('A3', 'C', 'A1'),
	('A4', 'D', 'A2'),
	('A5', 'E', 'A2'),
	('A6', 'F', 'A3'),
	('A7', 'G', 'A6');

SELECT id AS ID,pid AS 父ID ,levels AS 父到子之间级数, concat(paths,',',id) AS 父到子路径 FROM (
   SELECT id,pid,
   @le:= IF (pid = NULL ,0, 
     IF( LOCATE( CONCAT('|',pid,':'),@pathlevel)  > 0 ,   
         SUBSTRING_INDEX( SUBSTRING_INDEX(@pathlevel,CONCAT('|',pid,':'),-1),'|',1) +1
    ,@le+1) ) levels
   , @pathlevel:= CONCAT(@pathlevel,'|',id,':', @le ,'|') pathlevel
   , @pathnodes:= IF( pid =NULL,'0', 
      CONCAT_WS(',',
      IF( LOCATE( CONCAT('|',pid,':'),@pathall) > 0 , 
        SUBSTRING_INDEX( SUBSTRING_INDEX(@pathall,CONCAT('|',pid,':'),-1),'|',1)
       ,@pathnodes ) ,pid ) )paths
  ,@pathall:=CONCAT(@pathall,'|',id,':', @pathnodes ,'|') pathall 
    FROM treenodes, 
  (SELECT @le:=0,@pathlevel:='', @pathall:='',@pathnodes:='') vv
  ORDER BY pid,id
  ) src
ORDER BY id

drop table treenodes;


-- 最简单写法：
/* 
规范ID命名规则，按照类似
N01 N00
N03 N00
N0101 N01
N0102 N01
N0301 N03
命名，使父节点和子节点存在关联关系，这样会对查询有很多好处
*/

------------------------------replace into
mysql> CREATE TABLE `bond_id` (  
-- 创建测试表，唯一约束为：(`BOND_ID`,`INFO_SOURCE`,`SRC_ID`)
  `ID` bigint(20) NOT NULL AUTO_INCREMENT ,
  `BOND_ID` varchar(20) NOT NULL ,
  `SRC_ID` bigint(20) NOT NULL ,
  `INFO_SOURCE` varchar(50) NOT NULL ,
  `VV` VARCHAR(20) DEFAULT NULL ,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `BPK_AK_KEY_2` (`BOND_ID`,`INFO_SOURCE`,`SRC_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='债券ID';
Query OK, 0 rows affected

mysql> insert into bond_id (BOND_ID,SRC_ID,INFO_SOURCE,VV)
values(10010,'11101','gg','bzm');
Query OK, 1 row affected

mysql> select * from bond_id;
+----+---------+--------+-------------+-----+
| ID | BOND_ID | SRC_ID | INFO_SOURCE | VV  |
+----+---------+--------+-------------+-----+
|  1 | 10010   |  11101 | gg          | bzm |
+----+---------+--------+-------------+-----+
1 row in set

-- 替代数据
mysql> replace into   
    bond_id(BOND_ID,SRC_ID,INFO_SOURCE,VV)   
(SELECT 10010,'11101','gg','bzmaa');
Query OK, 2 rows affected
Records: 1  Duplicates: 1  Warnings: 0

-- 注意自增ID变化了
mysql> select * from bond_id;
+----+---------+--------+-------------+-------+
| ID | BOND_ID | SRC_ID | INFO_SOURCE | VV    |
+----+---------+--------+-------------+-------+
|  2 | 10010   |  11101 | gg          | bzmaa |
+----+---------+--------+-------------+-------+
1 row in set

-- 新增数据
mysql> replace into   
    bond_id(BOND_ID,SRC_ID,INFO_SOURCE,VV)   
(SELECT 10011,'11101','gg','bzmaa');
Query OK, 1 row affected
Records: 1  Duplicates: 0  Warnings: 0

mysql> select * from bond_id;
+----+---------+--------+-------------+-------+
| ID | BOND_ID | SRC_ID | INFO_SOURCE | VV    |
+----+---------+--------+-------------+-------+
|  2 | 10010   |  11101 | gg          | bzmaa |
|  3 | 10011   |  11101 | gg          | bzmaa |
+----+---------+--------+-------------+-------+
2 rows in set

-- 插入时指定ID
mysql> replace into   
    bond_id(ID,BOND_ID,SRC_ID,INFO_SOURCE,VV)   
(SELECT 2,10010,'11101','gg','bzmaa');
Query OK, 2 rows affected
Records: 1  Duplicates: 1  Warnings: 0

-- ID未发生改变
mysql> select * from bond_id;
+----+---------+--------+-------------+-------+
| ID | BOND_ID | SRC_ID | INFO_SOURCE | VV    |
+----+---------+--------+-------------+-------+
|  2 | 10010   |  11101 | gg          | bzmaa |
|  3 | 10011   |  11101 | gg          | bzmaa |
+----+---------+--------+-------------+-------+
2 rows in set

-- 留空某个字段
mysql> replace into   
    bond_id(ID,BOND_ID,SRC_ID,INFO_SOURCE)   
(SELECT 2,10010,'11101','gg');
Query OK, 2 rows affected
Records: 1  Duplicates: 1  Warnings: 0

-- 插入的是NULL
mysql> select * from bond_id;
+----+---------+--------+-------------+-------+
| ID | BOND_ID | SRC_ID | INFO_SOURCE | VV    |
+----+---------+--------+-------------+-------+
|  2 | 10010   |  11101 | gg          | NULL  |
|  3 | 10011   |  11101 | gg          | bzmaa |
+----+---------+--------+-------------+-------+
2 rows in set

mysql> drop table bond_id;
Query OK, 0 rows affected


小结：replace into 能实现该需求，但注意操作逻辑是先按照唯一约束查找数据，若能找到则删除系统中数据然后插入新数据（新插入数据不完整会导致字段数据丢失），否则直接插入。




-- ------------------------------------INSERT INTO ON DUPLICATE KEY UPDATE
drop table testa;
create table testa(id int primary key AUTO_INCREMENT,name varchar(10),note varchar(10),
`UPDATE_TIME` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
UNIQUE KEY `BPK_AK_KEY_2` (`name`,`note`)
  );
insert into testa(name,note) values('XB','1111111'),('XH','2222222');

select * from testa;

INSERT INTO testa (id,name) 
VALUES (2, 'XHua')
ON DUPLICATE KEY UPDATE
name='XHua'

INSERT INTO testa (id,name) 
VALUES (3, 'XHua')
ON DUPLICATE KEY UPDATE
name='XHua'

-- 不涉及主键插入（相当于直接插入数据）
INSERT INTO testa (name) 
VALUES ('XHua')
ON DUPLICATE KEY UPDATE
name='XHua'

-- 表增加唯一约束插入测试
INSERT INTO testa (id,name) 
VALUES (2, 'XHua')
ON DUPLICATE KEY UPDATE
name='XHuaaa' -- update
-- 唯一约束重复插入
INSERT INTO testa (name,note) 
VALUES ('XB', '1111111')
ON DUPLICATE KEY UPDATE
name='XHua'  -- update

-- ON DUPLICATE KEY UPDATE 按照主键重复判断更新还是插入，
-- 更新数据不会丢失数据（不同于replace into）。但更新时信息提示受影响的行: 2,
-- 仍有可能先删除，后插入，不过插入时会对数据进行处理，避免原来存在的数据被覆盖掉。

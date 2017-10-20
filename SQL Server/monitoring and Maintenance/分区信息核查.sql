SELECT t.name AS TableName,
       partition_id,
       partition_number,
       rows
  FROM sys.partitions AS p JOIN sys.tables AS t ON p.object_id = t.object_id
 WHERE p.partition_id IS NOT NULL
-- and partition_number > 1 /*partition_number>1即表示存在多分区*/
--AND t.name = 'eco_data_china';

SELECT t.object_id AS Object_ID,
       t.name AS TableName,
       ic.column_id AS PartitioningColumnID,
       c.name AS PartitioningColumnName
  FROM sys.tables AS t
       JOIN sys.indexes AS i ON t.object_id = i.object_id
       JOIN sys.columns AS c ON t.object_id = c.object_id
       JOIN sys.partition_schemes AS ps ON ps.data_space_id = i.data_space_id
       JOIN sys.index_columns AS ic
          ON     ic.object_id = i.object_id
             AND ic.index_id = i.index_id
             AND ic.partition_ordinal > 0
 WHERE i.type <= 1 AND c.column_id = 1;
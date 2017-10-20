SELECT
    source_name,item_name,monitor_name,nocunnormal,nocnormal,checked,
    SUBSTRING_INDEX(
        SUBSTRING_INDEX(own_by, ',', seq),
        ',' ,- 1
    ) own_by,
    mgr_by
FROM
    ( -- SEQ
SELECT
        D1.seq + D2.seq * 10 seq
    FROM
        (select 0 seq union all
select 1 seq union all
select 2 seq union all
select 3 seq union all
select 4 seq union all
select 5 seq union all
select 6 seq union all
select 7 seq union all
select 8 seq union all
select 9 seq ) D1
    CROSS JOIN (select 0 seq union all
select 1 seq union all
select 2 seq union all
select 3 seq union all
select 4 seq union all
select 5 seq union all
select 6 seq union all
select 7 seq union all
select 8 seq union all
select 9 seq ) D2
) sequence
CROSS JOIN ( -- JOIN SQL
select         
		  (select  s.name_cn  from monitor.m_monitor_item i,monitor.m_monitor_conn_item c,monitor.m_data_source s WHERE i.id=c.item_id and c.monitor_id=m.id  and s.id=i.source_id limit 1) as source_name, 
		  (select  i.name_cn  from monitor.m_monitor_item i,monitor.m_monitor_conn_item c WHERE i.id=c.item_id and c.monitor_id=m.id limit 1) as item_name, 
			 m.name_cn as monitor_name, 
   		IFNULL((select COUNT(r2.id) from monitor.m_result r2 WHERE r2.monitor_id = r.monitor_id  AND r2.item_id = r.item_id AND r2.result_state = '1' AND r2.check_state = '0'  AND r2.getdata_time > '2016-09-05 00:00:00'),0)  as nocunnormal, 
		  IFNULL((select COUNT(r2.id)from monitor.m_result r2 WHERE r2.monitor_id = r.monitor_id  AND r2.item_id = r.item_id and  r2.result_state = '0' AND r2.check_state = '0'  AND r2.getdata_time > '2016-09-05 00:00:00'),0)  as nocnormal,
      IFNULL((select COUNT(r2.id)from monitor.m_result r2 WHERE r2.monitor_id = r.monitor_id  AND r2.item_id = r.item_id and r2.check_state = '1'  AND r2.getdata_time > '2016-09-05 00:00:00'),0)  as checked,
      m.own_by,  
			m.mgr_by 
		FROM 
			monitor.m_result r, 
			monitor.m_monitor m 
		WHERE 
			r.monitor_id = m.id  
		AND r.getdata_time > '2016-09-05 00:00:00'  
		GROUP BY 
			r.monitor_id,r.item_id
) testbzm
WHERE
    seq BETWEEN 1
AND (
    SELECT
        1 + LENGTH(own_by) - LENGTH(REPLACE(own_by, ',', ''))
)
ORDER BY
   source_name,item_name,monitor_name,nocunnormal,nocnormal,checked,own_by,mgr_by;




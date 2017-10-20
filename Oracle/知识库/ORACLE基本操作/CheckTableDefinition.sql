-- CheckTableDefinition.sql

set long 100000
set lines 168
set pages 1000

select dbms_metadata.get_ddl( upper(rtrim(ltrim('&object_type'))),
                              upper(rtrim(ltrim('&object_name'))),
							  upper(rtrim(ltrim('&object_owner')))
                            ) 
  from dual;

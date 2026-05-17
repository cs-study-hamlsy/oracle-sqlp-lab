whenever sqlerror exit failure rollback

prompt [1] reset test table
begin
    execute immediate 'drop table t purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

prompt [2] create test table
create table t
as
select d.no, e.*
from scott.emp e,
     (select rownum no from dual connect by level <= 1000) d;

prompt [3] create indexes
create index t_x01 on t(deptno, no);
create index t_x02 on t(deptno, job, no);

prompt [4] gather stats
exec dbms_stats.gather_table_stats(user, 'T');

prompt [5] done

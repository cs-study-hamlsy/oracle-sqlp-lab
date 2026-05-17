set echo on
set linesize 200
set pagesize 100
set autotrace traceonly explain

prompt ===== base query =====
select *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;

prompt ===== index(t t_x02) query =====
select /*+ index(t t_x02) */ *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;

prompt ===== full(t) query =====
select /*+ full(t) */ *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;

set autotrace off

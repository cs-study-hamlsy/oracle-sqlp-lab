set echo on
set linesize 200
set pagesize 100

delete from plan_table where statement_id in ('BASE_QUERY', 'INDEX_T_X02_QUERY', 'FULL_SCAN_QUERY');
commit;

prompt ===== base query explain =====
explain plan set statement_id = 'BASE_QUERY' for
select *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;

select *
from table(dbms_xplan.display(null, 'BASE_QUERY', 'BASIC +COST +BYTES +PREDICATE +ALIAS'));

prompt ===== index(t t_x02) explain =====
explain plan set statement_id = 'INDEX_T_X02_QUERY' for
select /*+ index(t t_x02) */ *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;

select *
from table(dbms_xplan.display(null, 'INDEX_T_X02_QUERY', 'BASIC +COST +BYTES +PREDICATE +ALIAS'));

prompt ===== full(t) explain =====
explain plan set statement_id = 'FULL_SCAN_QUERY' for
select /*+ full(t) */ *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;

select *
from table(dbms_xplan.display(null, 'FULL_SCAN_QUERY', 'BASIC +COST +BYTES +PREDICATE +ALIAS'));

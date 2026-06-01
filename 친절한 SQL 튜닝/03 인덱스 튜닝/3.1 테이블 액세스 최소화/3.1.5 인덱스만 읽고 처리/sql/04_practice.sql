prompt ============================================
prompt 3.1.5 인덱스만 읽고 처리 - 연습 문제
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 어떤 SQL이 커버드 상태를 유지하고, 어떤 SQL은 다시 테이블 방문이 필요한지 판단한다.
- select list, aggregate, order by 변화가 실행계획에 미치는 영향을 확인한다.

체크 포인트
- 인덱스에 없는 컬럼을 select 하면 즉시 테이블 액세스가 필요함을 이해하는가
- group by/order by가 인덱스 순서와 맞는지 판단하는가

예상 해석
- 커버드 인덱스는 특정 SQL 패턴에 매우 강력하지만, select list가 바뀌면 금방 깨질 수 있다.
*/

prompt
prompt 문제 1. 아래 SQL은 (DEPT_CODE, QTY) 인덱스로 커버되는가?
prompt select dept_code, sum(qty) from t_index_only_demo where dept_code like '123%' group by dept_code;

prompt
prompt 문제 2. 아래 SQL은 왜 다시 테이블 액세스가 필요한가?
prompt select dept_code, sum(amount) from t_index_only_demo where dept_code like '123%' group by dept_code;

prompt
prompt 문제 3. 아래 SQL은 커버 여부와 별개로 어떤 정렬 이슈를 봐야 하는가?
prompt select dept_code, qty from t_index_only_demo where dept_code like '123%' order by qty;

alter session set statistics_level = all;

select /*+ gather_plan_statistics index(d idx_index_only_x2) */
       d.dept_code,
       sum(d.qty) as sum_qty
from t_index_only_demo d
where d.dept_code like '123%'
group by d.dept_code;

select *
from table(dbms_xplan.display_cursor(null, null, 'allstats last +predicate'));

select /*+ gather_plan_statistics index(d idx_index_only_x2) */
       d.dept_code,
       sum(d.amount) as sum_amount
from t_index_only_demo d
where d.dept_code like '123%'
group by d.dept_code;

select *
from table(dbms_xplan.display_cursor(null, null, 'allstats last +predicate'));

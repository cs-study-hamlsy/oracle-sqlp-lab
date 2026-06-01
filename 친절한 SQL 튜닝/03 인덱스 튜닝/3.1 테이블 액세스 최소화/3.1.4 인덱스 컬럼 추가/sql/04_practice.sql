prompt ============================================
prompt 3.1.4 인덱스 컬럼 추가 - 연습 문제
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 어떤 조건에서 뒤쪽 컬럼 추가 효과가 큰지 스스로 판단해 본다.
- 액세스 조건과 필터 조건을 구분하는 연습을 한다.

체크 포인트
- 각 SQL에서 SAL 추가가 인덱스 단계 필터링에 도움이 되는지 판단하는가
- 결과 건수와 후보 건수 차이가 클수록 효과가 커진다는 점을 연결하는가

예상 해석
- 같은 컬럼 추가라도 SQL 형태에 따라 효과 차이가 다르다.
- select list에 따라 테이블 액세스가 남을 수도 있고, 거의 그대로일 수도 있다.
*/

prompt
prompt 문제 1. 아래 SQL은 SAL 컬럼 추가 효과가 큰가?
prompt select count(*) from t_idx_add_col_demo where deptno = 30 and sal >= 2500;

prompt
prompt 문제 2. 아래 SQL은 SAL 컬럼 추가 효과가 상대적으로 작은가?
prompt select count(*) from t_idx_add_col_demo where deptno = 30;

prompt
prompt 문제 3. 아래 SQL에서 JOB까지 조건이 있으면 SAL 추가 컬럼의 의미가 어떻게 달라지는가?
prompt select avg(sal) from t_idx_add_col_demo where deptno = 30 and job = 'SALESMAN' and sal >= 1800;

alter session set statistics_level = all;

select /*+ gather_plan_statistics index(d idx_add_col_x2) */
       count(*) as cnt_q1
from t_idx_add_col_demo d
where d.deptno = 30
and   d.sal >= 2500;

select *
from table(dbms_xplan.display_cursor(null, null, 'allstats last +predicate'));

select /*+ gather_plan_statistics index(d idx_add_col_x2) */
       count(*) as cnt_q2
from t_idx_add_col_demo d
where d.deptno = 30;

select *
from table(dbms_xplan.display_cursor(null, null, 'allstats last +predicate'));

select /*+ gather_plan_statistics index(d idx_add_col_x2) */
       avg(d.sal) as avg_sal_q3
from t_idx_add_col_demo d
where d.deptno = 30
and   d.job = 'SALESMAN'
and   d.sal >= 1800;

select *
from table(dbms_xplan.display_cursor(null, null, 'allstats last +predicate'));

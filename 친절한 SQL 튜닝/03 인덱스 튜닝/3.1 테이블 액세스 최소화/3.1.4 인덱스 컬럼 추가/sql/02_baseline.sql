prompt ============================================
prompt 3.1.4 인덱스 컬럼 추가 - 기본 확인
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- (DEPTNO, JOB) 인덱스만 있을 때 SAL 조건이 테이블 단계에서 검사되는 구조를 확인한다.
- 인덱스를 타더라도 테이블 랜덤 액세스가 과도하면 느릴 수 있음을 관찰한다.

체크 포인트
- INDEX RANGE SCAN은 IDX_ADD_COL_X1을 사용하는가
- TABLE ACCESS BY INDEX ROWID 단계에서 많은 로우를 방문하는가
- SAL >= 2500 조건이 테이블 필터 성격으로 처리되는가

예상 해석
- DEPTNO = 30 조건으로는 인덱스를 사용하지만, SAL이 인덱스에 없어 테이블에서 대량 필터링이 발생한다.
- 결과 건수보다 테이블 방문 건수가 훨씬 많으면 개선 대상이다.
*/

alter session set statistics_level = all;

select /*+ gather_plan_statistics index(d idx_add_col_x1) */
       sum(length(d.emp_name)) as total_name_len,
       sum(d.sal) as total_sal
from t_idx_add_col_demo d
where d.deptno = 30
and   d.sal >= 2500;

select *
from table(
    dbms_xplan.display_cursor(
        null,
        null,
        'allstats last +cost +predicate +alias'
    )
);

prompt
prompt 관찰 포인트
prompt - IDX_ADD_COL_X1 스캔 건수와 TABLE ACCESS BY INDEX ROWID 실제 로우 수를 비교한다.
prompt - 결과 집합은 적은데 테이블 방문은 많다면 SAL 컬럼 추가 후보로 본다.

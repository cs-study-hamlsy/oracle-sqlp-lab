prompt ============================================
prompt 3.1.5 인덱스만 읽고 처리 - 기본 확인
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- DEPT_CODE 단일 인덱스만 있을 때 SUM(QTY)를 위해 테이블 방문이 발생하는지 확인한다.
- 조건에 맞는 로우가 대부분 결과 계산에 사용될 때 왜 느릴 수 있는지 관찰한다.

체크 포인트
- IDX_INDEX_ONLY_X1 인덱스를 타는가
- TABLE ACCESS BY INDEX ROWID가 발생하는가
- 집계에 필요한 QTY가 인덱스에 없어 테이블을 읽는 구조가 드러나는가

예상 해석
- 필터 손실이 거의 없으므로 테이블 방문 대부분이 실제 작업이 된다.
- 이런 경우에는 단순 필터 컬럼 추가보다 커버드 인덱스가 더 효과적이다.
*/

alter session set statistics_level = all;

select /*+ gather_plan_statistics index(d idx_index_only_x1) */
       d.dept_code,
       sum(d.qty) as sum_qty
from t_index_only_demo d
where d.dept_code like '123%'
group by d.dept_code
order by d.dept_code;

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
prompt - 인덱스로 ROWID를 찾은 뒤 QTY를 읽기 위해 테이블을 방문하는지 확인한다.
prompt - 결과 그룹 수보다 실제 방문 로우 수가 훨씬 많을 수 있다는 점을 본다.

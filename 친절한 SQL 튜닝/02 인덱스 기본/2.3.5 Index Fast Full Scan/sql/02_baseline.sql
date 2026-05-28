prompt ============================================
prompt 2.3.5 Index Fast Full Scan - 기본 확인
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 인덱스에 포함된 컬럼만 조회하는 SQL에서 INDEX FAST FULL SCAN 기본 사례를 확인한다.

체크 포인트
- INDEX FAST FULL SCAN 이 나타나는가
- TABLE ACCESS 가 뒤따르지 않는가
- 결과 정렬을 보장하는 계획이 아니라는 점을 이해하는가

예상 해석
- 조회 컬럼이 인덱스에 모두 포함돼 있으므로 Fast Full Scan 후보가 된다.
- 인덱스 세그먼트를 대량 읽기하는 방식이라 ORDER BY 제거 목적과는 다르다.
*/

explain plan for
select /*+ index_ffs(t idx_iffs_deptno_sal) */
       deptno, sal
from t_idx_ffs_demo t
where deptno between 10 and 59;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

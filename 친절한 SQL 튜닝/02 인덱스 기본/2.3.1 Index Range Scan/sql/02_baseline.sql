prompt ============================================
prompt 2.3.1 Index Range Scan - 기본 확인
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 교재의 핵심 문장처럼 루트에서 리프까지 내려간 뒤 필요한 범위만 읽는 INDEX RANGE SCAN을 확인한다.
- SELECT * 조회에서 TABLE ACCESS BY INDEX ROWID가 함께 나타나는지 확인한다.

체크 포인트
- IDX_IRS_DEPTNO_EMPNO 인덱스가 INDEX RANGE SCAN으로 사용되는가
- DEPTNO, EMPNO 조건이 access predicate로 들어가는가
- TABLE ACCESS BY INDEX ROWID가 함께 나타나는가

예상 해석
- 복합 인덱스 선두 컬럼과 후행 범위 조건이 함께 주어졌으므로 전형적인 INDEX RANGE SCAN이 나타난다.
- 조회 컬럼이 많으므로 인덱스에서 ROWID를 찾은 뒤 테이블 블록을 다시 방문한다.
*/

explain plan for
select *
from t_idx_range_scan_demo
where deptno = 20
  and empno between 50000 and 80000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 관찰 포인트
prompt - INDEX RANGE SCAN 이 나타나는지 확인
prompt - DEPTNO = 20, EMPNO BETWEEN ... 조건이 access로 들어가는지 확인
prompt - TABLE ACCESS BY INDEX ROWID 가 뒤따르는지 확인

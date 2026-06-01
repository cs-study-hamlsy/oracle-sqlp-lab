prompt ============================================
prompt 2.3.5 Index Fast Full Scan - 연습 문제 해설
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- Fast Full Scan 판단 기준을 실행계획과 함께 확인한다.

체크 포인트
- 정렬 보장 여부와 인덱스 포함 컬럼 조건을 구분하는가
- Table Full Scan 과의 차이를 설명할 수 있는가

예상 해석
- Fast Full Scan은 인덱스 세그먼트 대량 읽기다.
- 정렬이 필요하면 Full Scan, 대량 읽기면 Fast Full Scan 쪽이 유리할 수 있다.
*/

prompt
prompt [해설 1] 인덱스 컬럼만 조회
explain plan for
select /*+ index_ffs(t idx_iffs_deptno_sal) */
       deptno, sal
from t_idx_ffs_demo t
where sal > 9000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [해설 2] 정렬 순서가 필요한 경우
explain plan for
select /*+ index(t idx_iffs_deptno_sal) */
       deptno, sal
from t_idx_ffs_demo t
where sal > 9000
order by deptno, sal;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [해설 3] 비인덱스 컬럼 포함
explain plan for
select deptno, sal, emp_name
from t_idx_ffs_demo
where sal > 9000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 정리
prompt - Fast Full Scan 은 결과 순서를 보장하지 않는 대신 Multiblock I/O 로 빠르게 읽는다.
prompt - 인덱스만으로 끝나는 SQL 에서 특히 가치가 크다.

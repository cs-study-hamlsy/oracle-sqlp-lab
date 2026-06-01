prompt ============================================
prompt 2.3.5 Index Fast Full Scan - Full Scan 과 비교
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- INDEX FULL SCAN, INDEX FAST FULL SCAN, TABLE FULL SCAN 차이를 비교한다.

체크 포인트
- [A] INDEX FULL SCAN 은 정렬 순서 활용 관점인지 본다
- [B] INDEX FAST FULL SCAN 은 인덱스 세그먼트 대량 읽기인지 본다
- [C] SELECT * 에서는 테이블 방문 때문에 Fast Full Scan 이 애매해질 수 있음을 본다
- [D] FULL 힌트 시 테이블 전체 읽기와 비교한다

예상 해석
- ORDER BY가 있으면 Index Full Scan이 정렬 생략 쪽으로 유리할 수 있다.
- ORDER BY가 없고 인덱스 컬럼만 필요하면 Fast Full Scan이 더 자연스럽다.
*/

prompt
prompt [A] INDEX FULL SCAN 유도 - 정렬 순서 활용
explain plan for
select /*+ index(t idx_iffs_deptno_sal) */
       deptno, sal
from t_idx_ffs_demo t
where sal > 9000
order by deptno, sal;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] INDEX FAST FULL SCAN 유도 - 정렬 불필요, 인덱스만 조회
explain plan for
select /*+ index_ffs(t idx_iffs_deptno_sal) */
       deptno, sal
from t_idx_ffs_demo t
where sal > 9000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] 비인덱스 컬럼 포함 조회
explain plan for
select /*+ index_ffs(t idx_iffs_deptno_sal) */
       deptno, sal, emp_name
from t_idx_ffs_demo t
where sal > 9000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [D] TABLE FULL SCAN 비교
explain plan for
select /*+ full(t) */
       deptno, sal
from t_idx_ffs_demo t
where sal > 9000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

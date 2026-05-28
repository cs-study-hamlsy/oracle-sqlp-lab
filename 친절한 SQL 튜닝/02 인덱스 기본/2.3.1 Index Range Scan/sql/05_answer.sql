prompt ============================================
prompt 2.3.1 Index Range Scan - 연습 문제 해설
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 연습 문제의 예상 실행계획과 판단 기준을 확인한다.
- Range Scan 해석에서 범위와 테이블 액세스가 왜 중요한지 다시 정리한다.

체크 포인트
- 좁은 범위와 넓은 범위의 차이를 계획에서 확인하는가
- 인덱스만으로 처리 가능한 SQL과 아닌 SQL을 구분하는가

예상 해석
- [1-A]가 [1-B]보다 더 효율적인 Range Scan 이다.
- count(*)는 인덱스만으로 처리될 여지가 크지만, 비인덱스 컬럼 조회는 테이블 방문이 필요하다.
*/

prompt
prompt [1-A] 해설 - 더 효율적인 Range Scan
explain plan for
select *
from t_idx_range_scan_demo
where deptno = 10
  and empno between 10000 and 13000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [1-B] 해설 - 같은 Range Scan 이어도 읽는 범위가 매우 큼
explain plan for
select *
from t_idx_range_scan_demo
where deptno = 10
  and empno between 10000 and 29000000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [2-A] 해설 - 인덱스만으로 끝날 가능성이 큰 집계
explain plan for
select count(*)
from t_idx_range_scan_demo
where deptno = 30
  and empno between 90000 and 120000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [2-B] 해설 - ENAME, SAL 조회를 위해 테이블 방문 가능성이 큼
explain plan for
select ename, sal
from t_idx_range_scan_demo
where deptno = 30
  and empno between 90000 and 120000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 정리
prompt - Range Scan 의 평가는 연산자 이름이 아니라 실제 읽는 범위와 ROWID 기반 테이블 방문량으로 해야 한다.
prompt - 인덱스만으로 처리 가능한 SQL 은 랜덤 테이블 액세스를 줄일 수 있어 훨씬 유리할 수 있다.

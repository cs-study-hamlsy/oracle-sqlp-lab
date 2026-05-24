prompt ============================================
prompt 2.2.2 인덱스를 Range Scan할 수 없는 이유 - 기준선 확인
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 가공되지 않은 선두 컬럼 조건에서 정상적인 INDEX RANGE SCAN을 확인한다.
- 선두 컬럼이 없을 때와 인덱스 컬럼을 가공했을 때의 차이를 비교한다.

체크 포인트
- [A]에서 IDX_RSD_DEPT_EMPNO 기반 INDEX RANGE SCAN이 나타나는가
- [B]에서 선두 컬럼 부재로 인해 기대한 Range Scan이 약해지거나 다른 경로가 나오는가
- [C], [D]에서 access/filter 차이가 보이는가

예상 해석
- 인덱스를 Range Scan하기 위한 첫 번째 조건은 인덱스 선두 컬럼이 조건절에 있어야 하는 것이다.
- 여기에 더해 선두 컬럼이 가공되지 않은 상태여야 한다.
*/

prompt
prompt [A] 정상 사례 - 선두 컬럼을 가공하지 않고 사용
explain plan for
select *
from t_range_scan_demo
where deptno = 10
  and empno between 1000 and 25000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] 선두 컬럼 부재 - 후행 컬럼만으로 조회
explain plan for
select *
from t_range_scan_demo
where empno between 1000 and 25000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] 선두 컬럼 가공 - DEPTNO + 0
explain plan for
select *
from t_range_scan_demo
where deptno + 0 = 10
  and empno between 1000 and 25000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [D] 날짜 컬럼 가공 - TRUNC(HIREDATE)
explain plan for
select *
from t_range_scan_demo
where trunc(hiredate) = date '1981-02-20';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [E] 날짜 컬럼 비가공 - 범위 조건으로 재작성
explain plan for
select *
from t_range_scan_demo
where hiredate >= date '1981-02-20'
  and hiredate <  date '1981-02-21';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 관찰 포인트
prompt - [A]에서 DEPTNO, EMPNO 조건이 access 로 처리되는지 확인
prompt - [B]에서 선두 컬럼 없이도 정말 원하는 인덱스 접근이 가능한지 확인
prompt - [C]에서 DEPTNO + 0 조건이 탐색 조건이 아니라 필터 성격으로 밀리는지 확인
prompt - [D]와 [E]의 차이를 통해 TRUNC(HIREDATE) 남용 위험을 해석

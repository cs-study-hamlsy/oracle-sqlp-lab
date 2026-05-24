prompt ============================================
prompt 2.2.2 인덱스를 Range Scan할 수 없는 이유 - OR Expansion 과 INLIST ITERATOR
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- OR 조건에서 OR Expansion이 일어날 수 있는 형태를 확인한다.
- OR Expansion이 불리하거나 어렵게 만드는 조건을 비교한다.
- IN 조건절에서 INLIST ITERATOR가 나타나는지 확인한다.

체크 포인트
- [A]에서 CONCATENATION 또는 분기별 INDEX RANGE SCAN이 보이는가
- [B]에서 가공된 OR 분기 때문에 계획이 덜 깔끔해지는가
- [C]에서 INLIST ITERATOR가 보이는가

예상 해석
- OR 자체가 문제라기보다, 각 분기를 인덱스 친화적으로 분해할 수 있느냐가 중요하다.
- IN 조건은 같은 컬럼에 대한 여러 개의 등치 조건이므로, 잘 맞으면 반복적인 Range Scan으로 풀린다.
*/

prompt
prompt [A] OR Expansion 기대 사례 - 각 분기가 같은 인덱스를 탈 수 있는 형태
explain plan for
select *
from t_range_scan_demo
where (deptno = 10 and empno between 1000 and 12000)
   or (deptno = 20 and empno between 1000 and 12000);

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] OR 분기 중 하나가 가공된 사례
explain plan for
select *
from t_range_scan_demo
where (deptno + 0 = 10 and empno between 1000 and 12000)
   or (deptno = 20 and empno between 1000 and 12000);

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] IN 조건절 - INLIST ITERATOR 확인
explain plan for
select *
from t_range_scan_demo
where deptno in (10, 20, 30)
  and empno between 1000 and 12000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [D] 추가 비교 - JOB 까지 함께 주어 복합 인덱스 정합성 강화
explain plan for
select *
from t_range_scan_demo
where deptno in (10, 20)
  and job = 'MANAGER'
  and empno between 1000 and 12000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 해석 포인트
prompt - OR Expansion 시 CONCATENATION 이 보이는지 확인
prompt - 각 분기에서 INDEX RANGE SCAN 이 반복되는지 확인
prompt - IN 조건에서 INLIST ITERATOR 가 나타나면 값별 반복 탐색으로 이해
prompt - JOB 조건이 추가될 때 IDX_RSD_DEPT_JOB_EMPNO 활용 가능성이 높아지는지 비교

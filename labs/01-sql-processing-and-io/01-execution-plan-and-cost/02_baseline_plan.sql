prompt ============================================
prompt 실행계획과 비용 - 기준 실행계획 확인
prompt ============================================

/*
목적
- 힌트 없이도 옵티마이저가 어떤 경로를 선택하는지 본다.
- 조건절 컬럼 구성이 복합 인덱스와 얼마나 잘 맞는지 확인한다.

예상 해석
- deptno =, job =, no between 조건을 모두 사용하는 만큼
  T_X02(DEPTNO, JOB, NO)가 상대적으로 유리할 가능성이 높다.
*/

explain plan for
select *
from t
where deptno = 10
  and job = 'MANAGER'
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt 체크 포인트
prompt - INDEX RANGE SCAN이 보이는가
prompt - 어떤 인덱스가 선택되었는가
prompt - Predicate Information에서 DEPTNO, JOB, NO가 어떻게 적용되는가

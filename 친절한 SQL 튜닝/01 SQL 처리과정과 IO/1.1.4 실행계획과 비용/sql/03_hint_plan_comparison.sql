prompt ============================================
prompt 실행계획과 비용 - 힌트별 실행계획 비교
prompt ============================================

/*
목적
- 같은 SQL에 힌트를 달아 액세스 경로를 바꾸고 차이를 비교한다.

SQLP/실무 해석 포인트
- 힌트는 정답이 아니라 경로 제어 도구다.
- 강제로 특정 인덱스나 FULL SCAN을 선택하게 한 뒤,
  왜 비용이 달라지는지 설명할 수 있어야 한다.
*/

prompt
prompt [A] T_X02 힌트 강제
explain plan for
select /*+ index(t t_x02) */ *
from t
where deptno = 10
  and job = 'MANAGER'
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] T_X01 힌트 강제
explain plan for
select /*+ index(t t_x01) */ *
from t
where deptno = 10
  and job = 'MANAGER'
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] FULL 힌트 강제
explain plan for
select /*+ full(t) */ *
from t
where deptno = 10
  and job = 'MANAGER'
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt 비교 질문
prompt - 왜 T_X02가 T_X01보다 유리할 수 있는가
prompt - JOB 컬럼 포함 여부가 액세스 범위에 어떤 차이를 만드는가
prompt - FULL SCAN이 비효율적이라면 그 이유는 무엇인가

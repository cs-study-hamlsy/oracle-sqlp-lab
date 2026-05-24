prompt ============================================
prompt 실행계획과 비용 - 연습문제 정답
prompt ============================================

/*
목적
- 04_practice.sql의 질문에 대한 예시 정답 SQL과 해석 방향을 제공한다.
- 실행계획, Cost, 인덱스 컬럼 구성 차이를 직접 비교하도록 돕는다.

체크 포인트
- JOB 조건 제거 시 T_X01, T_X02 중 어떤 인덱스가 더 자연스러운지 확인하는가
- 범위가 넓어질수록 인덱스 경로와 FULL SCAN 비용 관계가 어떻게 달라지는지 보는가
- 통계정보가 없거나 오래되면 왜 판단이 흔들릴 수 있는지 설명 가능한가
*/

prompt
prompt 문제 1 정답 - JOB 조건 제거
prompt - JOB 조건이 없으면 (DEPTNO, NO) 구성인 T_X01이 더 자연스럽다.

explain plan for
select *
from t
where deptno = 10
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select /*+ index(t t_x01) */ *
from t
where deptno = 10
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 2 정답 - 범위를 1~900으로 확대
prompt - 범위가 넓어지면 인덱스 장점이 약해질 수 있으므로 FULL 경로와 함께 비교한다.

explain plan for
select *
from t
where deptno = 10
  and no between 1 and 900;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select /*+ full(t) */ *
from t
where deptno = 10
  and no between 1 and 900;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 3 정답 - FULL 힌트와 원본 계획 비교
prompt - 힌트는 정답이 아니라 강제 선택이므로 Cost와 액세스 경로를 같이 본다.

explain plan for
select *
from t
where deptno = 10
  and job = 'MANAGER'
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select /*+ full(t) */ *
from t
where deptno = 10
  and job = 'MANAGER'
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 4 정답 - 통계정보가 없을 때의 위험
prompt - 통계정보 삭제 후 계획을 보고, 다시 수집해 비교한다.

begin
    dbms_stats.delete_table_stats(user, 'T');
end;
/

explain plan for
select *
from t
where deptno = 10
  and job = 'MANAGER'
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

begin
    dbms_stats.gather_table_stats(user, 'T', cascade => true);
end;
/

explain plan for
select *
from t
where deptno = 10
  and job = 'MANAGER'
  and no between 1 and 100;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 해석 포인트
prompt - JOB 조건 제거 시 T_X01이 T_X02보다 더 직접적인 선두 컬럼 구성을 가진다.
prompt - 범위 확대는 인덱스 재방문 비용을 키우므로 FULL과 비용 비교가 중요하다.
prompt - 통계정보가 사라지면 옵티마이저 판단 근거가 약해져 계획이 흔들릴 수 있다.

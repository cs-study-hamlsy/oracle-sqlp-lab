prompt ============================================
prompt 2.2.2 인덱스를 Range Scan할 수 없는 이유 - 연습문제 정답
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 04_practice.sql의 문제에 대한 정답 SQL과 해석 방향을 제공한다.
- 가공되지 않은 선두 컬럼 조건, OR Expansion, INLIST ITERATOR를 정답 SQL로 확인한다.

체크 포인트
- 컬럼 가공 제거, 날짜 범위 재작성, OR -> UNION ALL 분해가 왜 유리한지 설명할 수 있는가
- INLIST ITERATOR와 복합 인덱스 정합성을 실행계획으로 연결해 볼 수 있는가
*/

prompt
prompt 문제 1 정답 - DEPTNO + 0 제거

explain plan for
select *
from t_range_scan_demo
where deptno = 10
  and empno between 1000 and 25000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 2 정답 - TRUNC(HIREDATE) 조건을 범위 조건으로 재작성

explain plan for
select *
from t_range_scan_demo
where hiredate >= date '1981-02-20'
  and hiredate <  date '1981-02-21';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 3 정답 - OR 조건을 UNION ALL 로 수동 분해

explain plan for
select *
from t_range_scan_demo
where (deptno = 10 and empno between 1000 and 12000)
   or (deptno = 20 and empno between 1000 and 12000);

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select *
from (
    select *
    from t_range_scan_demo
    where deptno = 10
      and empno between 1000 and 12000
    union all
    select *
    from t_range_scan_demo
    where deptno = 20
      and empno between 1000 and 12000
);

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 4 정답 - IN 과 OR 비교

explain plan for
select *
from t_range_scan_demo
where deptno in (10, 20, 30)
  and empno between 1000 and 12000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select *
from t_range_scan_demo
where (deptno = 10 and empno between 1000 and 12000)
   or (deptno = 20 and empno between 1000 and 12000)
   or (deptno = 30 and empno between 1000 and 12000);

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 5 정답 - JOB 조건 추가/제거 비교

explain plan for
select *
from t_range_scan_demo
where deptno in (10, 20)
  and empno between 1000 and 12000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select *
from t_range_scan_demo
where deptno in (10, 20)
  and job = 'MANAGER'
  and empno between 1000 and 12000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 6 정답 - 실무에서 자주 보는 컬럼 가공 재작성 예시
prompt - TRUNC(date_col) = DATE ''2025-05-01''
prompt   => date_col >= DATE ''2025-05-01'' and date_col < DATE ''2025-05-02''
prompt - NVL(status_code, ''X'') = ''A''
prompt   => status_code = ''A'' 또는 업무 요건에 따라 IS NULL 분기 분리 검토
prompt - TO_CHAR(number_col) = ''100''
prompt   => number_col = 100

prompt
prompt 해석 포인트
prompt - 선두 컬럼이 가공되지 않아야 access predicate 로 안정적으로 잡히기 쉽다.
prompt - OR 조건은 각 분기를 인덱스 친화적으로 만들 수 있으면 Range Scan 가능성이 있다.
prompt - IN 조건은 INLIST ITERATOR 로 반복적인 인덱스 탐색으로 풀릴 수 있다.

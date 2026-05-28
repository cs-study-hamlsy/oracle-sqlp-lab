prompt ============================================
prompt 2.3.2 Index Full Scan - 연습 문제 해설
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 연습 문제의 판단 기준을 실행계획으로 확인한다.
- Index Full Scan의 효용과 한계를 다시 정리한다.

체크 포인트
- 선두 컬럼 조건 부재가 왜 Range Scan 제약이 되는지 설명할 수 있는가
- 선택도와 부분범위 처리 목표에 따라 계획 해석이 달라지는가

예상 해석
- ENAME 조건이 없으므로 (ENAME, SAL) 인덱스로는 일반적인 Range Scan 시작점을 좁히기 어렵다.
- 선택도가 높고 ORDER BY ENAME이 중요할 때 Index Full Scan 효용이 커진다.
*/

prompt
prompt [문제 1] 선두 컬럼 조건이 없는 기본 사례
explain plan for
select *
from t_idx_full_scan_demo
where sal > 12000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [문제 2-A] 선택도가 더 높은 경우
explain plan for
select *
from t_idx_full_scan_demo
where sal > 16000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [문제 2-B] 대부분 행을 읽는 경우
explain plan for
select *
from t_idx_full_scan_demo
where sal > 1000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [문제 3] FIRST_ROWS 전략 확인
explain plan for
select /*+ first_rows(20) */
       *
from t_idx_full_scan_demo
where sal > 1000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 정리
prompt - Index Full Scan 은 인덱스를 못 탄 실패가 아니라, 정렬 생략과 얇은 저장 구조를 활용한 차선책일 수 있다.
prompt - 다만 SELECT * 로 많은 행을 끝까지 읽으면 TABLE ACCESS BY INDEX ROWID 누적으로 비효율이 커질 수 있다.
prompt - FIRST_ROWS 는 첫 응답 최적화 전략이며, 실제로 중간에 fetch 를 멈추는 업무와 맞아야 효과가 크다.

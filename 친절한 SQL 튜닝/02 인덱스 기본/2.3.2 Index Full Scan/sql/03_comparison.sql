prompt ============================================
prompt 2.3.2 Index Full Scan - 효용성과 한계 비교
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 선택도와 옵티마이저 목표에 따라 Index Full Scan의 의미가 달라짐을 비교한다.
- Table Full Scan + Sort 와의 관점 차이를 이해한다.

체크 포인트
- [A] 고선택도 필터에서 INDEX FULL SCAN이 합리적인지 본다
- [B] FULL 힌트로 테이블 전체 읽기와 정렬 계획을 비교한다
- [C] FIRST_ROWS 목표에서 정렬 생략 효과가 계획에 반영되는지 본다
- [D] 대부분 행을 읽는 조건에서 인덱스 전체 스캔의 부담을 해석한다

예상 해석
- 조건을 만족하는 행이 적으면 얇은 인덱스를 먼저 읽는 전략이 유리할 수 있다.
- 대부분 행을 읽는다면 TABLE ACCESS BY INDEX ROWID 누적으로 오히려 불리할 수 있다.
*/

prompt
prompt [A] 고선택도 조건 - 남는 행이 비교적 적음
explain plan for
select *
from t_idx_full_scan_demo
where sal > 16000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] FULL 힌트로 비교 - 테이블 전체 읽기 + 정렬 관점
explain plan for
select /*+ full(t) */
       *
from t_idx_full_scan_demo t
where sal > 16000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] FIRST_ROWS 목표 - 첫 결과를 빨리 받는 전략
explain plan for
select /*+ first_rows(20) */
       *
from t_idx_full_scan_demo
where sal > 1000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [D] 대부분 행이 조건을 만족하는 경우
explain plan for
select *
from t_idx_full_scan_demo
where sal > 1000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 해석 포인트
prompt - [A]는 적은 행을 찾기 위해 얇은 인덱스를 먼저 읽는 이점이 있는지 확인
prompt - [B]는 FULL 힌트 시 SORT ORDER BY 가 나타나는지 비교
prompt - [C]는 FIRST_ROWS 가 정렬 생략과 빠른 첫 응답 중심으로 작동하는지 확인
prompt - [D]는 전체를 끝까지 읽는 경우 인덱스 전체 스캔이 왜 불리할 수 있는지 해석

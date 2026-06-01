prompt ============================================
prompt 2.3.1 Index Range Scan - 연습 문제
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 어떤 SQL이 더 전형적인 INDEX RANGE SCAN인지 스스로 예측해 본다.
- 같은 Range Scan이어도 어느 쪽이 더 비쌀지 판단해 본다.

체크 포인트
- 각 SQL에서 사용할 인덱스와 예상 액세스 방식을 먼저 적어본다
- access predicate 와 table access 발생 여부를 예측한다

예상 해석
- 선두 컬럼이 고정되고 범위가 좁을수록 유리하다.
- SELECT * 는 인덱스만으로 끝나지 않아 테이블 방문이 뒤따를 가능성이 높다.
*/

prompt
prompt 문제 1. 아래 두 SQL 중 어느 쪽이 더 전형적인 INDEX RANGE SCAN 이며 왜 그런가?
prompt
prompt [1-A]
prompt select *
prompt from t_idx_range_scan_demo
prompt where deptno = 10
prompt   and empno between 10000 and 13000;
prompt
prompt [1-B]
prompt select *
prompt from t_idx_range_scan_demo
prompt where deptno = 10
prompt   and empno between 10000 and 29000000;

prompt
prompt 문제 2. 아래 SQL에서 TABLE ACCESS BY INDEX ROWID 가 나타날지 예측해 보라.
prompt
prompt [2-A]
prompt select count(*)
prompt from t_idx_range_scan_demo
prompt where deptno = 30
prompt   and empno between 90000 and 120000;
prompt
prompt [2-B]
prompt select ename, sal
prompt from t_idx_range_scan_demo
prompt where deptno = 30
prompt   and empno between 90000 and 120000;

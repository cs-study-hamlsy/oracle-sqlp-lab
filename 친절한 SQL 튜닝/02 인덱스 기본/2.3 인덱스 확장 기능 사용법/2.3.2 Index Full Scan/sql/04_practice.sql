prompt ============================================
prompt 2.3.2 Index Full Scan - 연습 문제
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 어떤 상황에서 Index Full Scan이 차선책으로 유리한지 스스로 판단해 본다.
- 부분범위 처리와 전체 범위 처리의 차이를 생각해 본다.

체크 포인트
- 선두 컬럼 조건 유무를 먼저 본다
- ORDER BY 와 인덱스 정렬 순서의 일치 여부를 본다
- 반환 건수가 많을 때 테이블 랜덤 액세스 부담을 함께 생각한다

예상 해석
- 정렬 생략 이점이 있고 필터링 후 남는 행이 많지 않으면 Index Full Scan이 합리적일 수 있다.
- 대부분 행을 읽는다면 Table Full Scan 쪽이 나을 수 있다.
*/

prompt
prompt 문제 1. 아래 SQL에서 Index Range Scan 이 어려운 이유를 설명해 보라.
prompt
prompt select *
prompt from t_idx_full_scan_demo
prompt where sal > 12000
prompt order by ename;

prompt
prompt 문제 2. 아래 두 상황 중 어느 쪽에서 Index Full Scan 의 효용이 더 큰지 판단해 보라.
prompt
prompt [2-A] sal > 16000 order by ename
prompt [2-B] sal > 1000  order by ename

prompt
prompt 문제 3. FIRST_ROWS 힌트를 사용할 때 주의할 점을 설명해 보라.

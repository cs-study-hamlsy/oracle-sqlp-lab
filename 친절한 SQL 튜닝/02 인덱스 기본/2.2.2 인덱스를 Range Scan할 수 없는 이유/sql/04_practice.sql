prompt ============================================
prompt 2.2.2 인덱스를 Range Scan할 수 없는 이유 - 직접 해보는 연습
prompt ============================================

/*
목적
- 직접 조건절을 바꿔 보면서 인덱스 Range Scan 가능 조건을 체감한다.
- 실행계획 이름만 보지 말고 access/filter, CONCATENATION, INLIST ITERATOR를 함께 읽는 연습을 한다.

체크 포인트
- 선두 컬럼 유무, 컬럼 가공 유무, OR/IN 형태에 따라 계획이 어떻게 달라지는지 설명할 수 있는가
- "왜 그런지"를 인덱스 정렬 구조와 옵티마이저 관점으로 풀어낼 수 있는가
*/

prompt 문제 1
prompt - [02_baseline.sql]의 [C] 쿼리를 deptno = 10 형태로 다시 바꿔 실행계획을 비교하시오.
prompt - DEPTNO + 0 이 access 를 깨뜨리는지 Predicate Information 으로 설명하시오.

prompt
prompt 문제 2
prompt - TRUNC(HIREDATE) = DATE ''1981-02-20'' 조건을 범위 조건으로 직접 재작성하시오.
prompt - 왜 같은 의미인데 실행계획이 달라질 수 있는지 설명하시오.

prompt
prompt 문제 3
prompt - 다음 OR 조건을 UNION ALL 형태로 수동 분해해서 실행계획을 비교하시오.
prompt - 원본 OR SQL
prompt   (deptno = 10 and empno between 1000 and 12000)
prompt   or
prompt   (deptno = 20 and empno between 1000 and 12000)
prompt - CONCATENATION, INDEX RANGE SCAN 여부를 비교하시오.

prompt
prompt 문제 4
prompt - deptno in (10, 20, 30) and empno between 1000 and 12000 조건에서
prompt   INLIST ITERATOR 가 나타나는지 확인하시오.
prompt - IN 을 OR 로 풀어 썼을 때와 실행계획을 비교하시오.

prompt
prompt 문제 5
prompt - job = ''MANAGER'' 조건을 추가/제거하면서
prompt   IDX_RSD_DEPT_JOB_EMPNO 와 IDX_RSD_DEPT_EMPNO 중 무엇이 유리한지 비교하시오.
prompt - 복합 인덱스에서 선두 컬럼과 후행 컬럼의 역할을 설명하시오.

prompt
prompt 문제 6
prompt - 실무에서 화면 검색 SQL 에서 자주 보이는 컬럼 가공 사례를 3개 적고,
prompt   각각 어떻게 SQL 을 재작성할지 적어보시오.
prompt - 예: TRUNC(date_col), NVL(col, ...), TO_CHAR(number_col)

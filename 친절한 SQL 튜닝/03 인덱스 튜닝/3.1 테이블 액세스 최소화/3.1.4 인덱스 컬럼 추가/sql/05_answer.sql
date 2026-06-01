prompt ============================================
prompt 3.1.4 인덱스 컬럼 추가 - 해설
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 연습 문제의 해석 관점을 정리한다.
- 인덱스 컬럼 추가가 언제 “테이블 액세스 감소”로 이어지는지 명확히 한다.

체크 포인트
- 액세스 조건/필터 조건 구분을 설명할 수 있는가
- 결과 건수 대비 테이블 방문 건수를 기준으로 효과를 판단하는가

예상 해석
- 뒤쪽 컬럼 추가는 범위 절단보다 테이블 방문 억제 효과가 중심이다.
- JOB까지 함께 주어지면 SAL이 더 적극적으로 액세스에 기여할 가능성이 커진다.
*/

prompt
prompt 정답 1
prompt - deptno = 30 and sal >= 2500 은 SAL 추가 효과가 큰 대표 사례다.
prompt - 후보는 많지만 결과는 상대적으로 적으므로, 인덱스 단계 필터링으로 테이블 방문을 크게 줄일 수 있다.

prompt
prompt 정답 2
prompt - deptno = 30 만 있는 SQL은 SAL 추가 여부와 무관하다.
prompt - SAL을 전혀 사용하지 않으므로 인덱스 컬럼 추가 효과가 거의 없다.

prompt
prompt 정답 3
prompt - deptno, job 조건이 모두 있으면 (deptno, job, sal) 구조에서 SAL이 더 강하게 활용될 수 있다.
prompt - 이 경우 SAL은 단순 필터를 넘어 범위 축소에 기여할 여지가 커진다.

prompt
prompt 실무 결론
prompt - 인덱스 컬럼 추가의 1차 목적은 TABLE ACCESS BY INDEX ROWID 감소다.
prompt - 선두 컬럼이 아니어도 필터링용으로 충분히 값어치가 있다.
prompt - 다만 인덱스 폭 증가, 리프 블록 증가, DML 부하는 반드시 함께 본다.

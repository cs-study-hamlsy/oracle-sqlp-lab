prompt ============================================
prompt 3.1.5 인덱스만 읽고 처리 - 해설
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 커버드 쿼리 판단 기준을 정리한다.
- Oracle 복합 인덱스와 SQL Server INCLUDE 인덱스의 차이를 실무 관점에서 요약한다.

체크 포인트
- 필요한 컬럼이 모두 인덱스에 있는지로 커버 여부를 판단하는가
- Oracle에 INCLUDE 문법이 없다는 점을 설명할 수 있는가

예상 해석
- 커버드 인덱스는 랜덤 테이블 액세스를 제거하는 데 매우 강력하다.
- 하지만 범용성, 저장공간, DML 비용을 함께 고려해야 한다.
*/

prompt
prompt 정답 1
prompt - dept_code, sum(qty) 쿼리는 (dept_code, qty) 인덱스로 커버된다.
prompt - WHERE, GROUP BY, 집계 대상 컬럼이 모두 인덱스에 있기 때문이다.

prompt
prompt 정답 2
prompt - amount가 select/aggregate에 등장하면 인덱스에 없으므로 다시 테이블 방문이 필요하다.
prompt - 즉, 커버드 상태는 select list가 바뀌면 쉽게 깨질 수 있다.

prompt
prompt 정답 3
prompt - order by qty는 인덱스 선두가 dept_code인 구조와 정렬 요구가 다르므로 별도 sort 가능성을 함께 봐야 한다.
prompt - 커버 여부와 정렬 생략 여부는 같은 문제가 아니다.

prompt
prompt Oracle vs SQL Server INCLUDE
prompt - Oracle은 SQL Server처럼 INCLUDE 문법이 없다.
prompt - Oracle에서는 복합 인덱스로 커버 효과를 만든다.
prompt - 따라서 탐색 효율, 정렬 효율, 인덱스 폭 증가를 함께 고려해야 한다.

prompt ============================================
prompt 2.3.6 Index Range Scan Descending - 연습 문제
prompt ============================================

/*
목적
- 어떤 SQL이 Descending Scan 또는 MIN/MAX 최적화 후보인지 판단해 본다.

체크 포인트
- ORDER BY DESC 와 인덱스 컬럼 일치 여부를 먼저 본다
- MAX/MIN 집계가 인덱스 끝값 한 건으로 처리될 수 있는지 생각한다

예상 해석
- 내림차순 정렬 제거와 끝값 조회는 같은 인덱스 정렬 활용이라는 공통점을 가진다.
*/

prompt 문제 1. where empno > 120000 order by empno desc 는 왜 Descending Scan 후보가 되는가?
prompt 문제 2. max(sal) where deptno = :x 는 왜 (DEPTNO, SAL) 인덱스가 있으면 매우 빨라질 수 있는가?
prompt 문제 3. min(sal), max(sal) 최적화와 일반 집계 Full Scan 의 차이를 설명해 보라.
prompt 문제 4. order by empno desc 이지만 empno 조건이 전혀 없다면 어떤 점을 추가로 검토해야 하는가?

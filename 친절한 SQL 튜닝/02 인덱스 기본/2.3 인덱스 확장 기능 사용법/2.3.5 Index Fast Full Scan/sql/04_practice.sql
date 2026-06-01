prompt ============================================
prompt 2.3.5 Index Fast Full Scan - 연습 문제
prompt ============================================

/*
목적
- 어떤 SQL이 Index Fast Full Scan 후보인지 판단해 본다.

체크 포인트
- 조회 컬럼이 모두 인덱스에 포함되는지 먼저 본다
- 정렬 순서 보장이 필요한지 판단한다
- 대량 읽기와 병렬 처리 성격인지 생각한다

예상 해석
- 인덱스 컬럼만 대량 조회하고 정렬 불필요하면 FFS 후보가 된다.
- ORDER BY 제거 목적이면 Index Full Scan 쪽 판단이 필요하다.
*/

prompt 문제 1. select deptno, sal from t_idx_ffs_demo where sal > 9000 는 왜 FFS 후보가 되는가?
prompt 문제 2. 같은 SQL에 order by deptno, sal 이 붙으면 왜 Index Full Scan 쪽 비교가 중요해지는가?
prompt 문제 3. select deptno, sal, emp_name ... 처럼 비인덱스 컬럼이 추가되면 FFS 장점이 왜 약해질 수 있는가?
prompt 문제 4. FFS 와 Full Table Scan 중 무엇이 유리한지는 어떤 관점으로 비교해야 하는가?

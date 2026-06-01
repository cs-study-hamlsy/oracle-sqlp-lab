prompt ============================================
prompt 2.3.4 Index Skip Scan - 작동 조건과 한계 비교
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- Skip Scan이 효과적인 경우와 비효율적인 경우를 비교한다.
- 힌트로 Skip Scan을 유도하거나 막아 계획 차이를 확인한다.

체크 포인트
- [A] 좁은 후행 조건에서 Skip Scan이 설득력 있는가
- [B] 넓은 후행 조건에서는 Skip Scan 비용이 커지는가
- [C] no_index_ss 힌트 시 Full Scan 또는 다른 경로와 비교되는가
- [D] 3컬럼 인덱스에서 중간 컬럼 누락 상태의 Skip Scan이 보이는가

예상 해석
- 후행 컬럼 선택도가 좋을수록 Skip Scan 가치가 커진다.
- 범위가 넓어지면 선두 distinct value별 반복 탐색 비용이 부담이 된다.
*/

prompt
prompt [A] 좁은 연령 구간
explain plan for
select /*+ index_ss(t idx_iss_gender_age) */
       count(*)
from t_idx_skip_scan_demo t
where age between 30 and 31;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] 넓은 연령 구간
explain plan for
select /*+ index_ss(t idx_iss_gender_age) */
       count(*)
from t_idx_skip_scan_demo t
where age between 20 and 60;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] Skip Scan 방지
explain plan for
select /*+ no_index_ss(t idx_iss_gender_age) */
       count(*)
from t_idx_skip_scan_demo t
where age between 30 and 31;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [D] 기준일자 범위 + 중간 컬럼 누락
explain plan for
select /*+ index_ss(t idx_iss_type_code_dt) */
       biz_type, base_dt, amount
from t_idx_skip_scan_demo t
where biz_type = 'T2'
  and base_dt between date '2024-02-01' and date '2024-02-10';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

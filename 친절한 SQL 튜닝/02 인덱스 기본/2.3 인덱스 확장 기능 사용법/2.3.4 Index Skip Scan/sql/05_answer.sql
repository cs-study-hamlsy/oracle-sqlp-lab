prompt ============================================
prompt 2.3.4 Index Skip Scan - 연습 문제 해설
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- Skip Scan 판단 기준을 예시 계획과 함께 정리한다.

체크 포인트
- Distinct Value 수와 선택도 관점이 설명에 반영되는가
- 차선책과 최선책을 구분하는가

예상 해석
- Skip Scan은 반복적인 부분 탐색 전략이다.
- 중요 SQL이라면 전용 인덱스가 더 나은 경우가 많다.
*/

prompt
prompt [해설 1] 좁은 후행 조건
explain plan for
select /*+ index_ss(t idx_iss_gender_age) */
       *
from t_idx_skip_scan_demo t
where age between 30 and 31;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [해설 2] 넓은 후행 조건
explain plan for
select /*+ index_ss(t idx_iss_gender_age) */
       *
from t_idx_skip_scan_demo t
where age between 20 and 60;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [해설 3] 중간 컬럼 누락된 복합 인덱스
explain plan for
select /*+ index_ss(t idx_iss_type_code_dt) */
       *
from t_idx_skip_scan_demo t
where biz_type = 'T1'
  and base_dt between date '2024-03-01' and date '2024-03-31';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 정리
prompt - 선두 컬럼 distinct value 가 적고 후행 컬럼 조건이 강하면 Skip Scan 이 성립하기 쉽다.
prompt - 그러나 중요 SQL 에서는 Skip Scan 을 만능 해법으로 보지 말고 전용 인덱스 설계를 검토해야 한다.

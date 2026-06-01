prompt ============================================
prompt 2.3.4 Index Skip Scan - 기본 확인
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 선두 컬럼 조건이 있을 때의 Range Scan과, 선두 컬럼이 빠졌을 때의 Skip Scan을 비교한다.

체크 포인트
- [A]에서 INDEX RANGE SCAN 이 나타나는가
- [B]에서 INDEX SKIP SCAN 이 나타나는가
- [C]에서 중간 컬럼이 비어 있는 복합 인덱스에도 Skip Scan 가능성이 보이는가

예상 해석
- 선두 컬럼 GENDER를 사용하면 일반적인 Range Scan이 유리하다.
- GENDER 조건이 빠져도 AGE 조건 선택도가 적당하면 Skip Scan 차선책이 가능하다.
- (BIZ_TYPE, BIZ_CODE, BASE_DT) 인덱스에서 BIZ_CODE가 빠진 상태에서도 BASE_DT 조건으로 Skip Scan 가능성이 있다.
*/

prompt
prompt [A] 선두 컬럼 조건 포함 - 일반적인 Range Scan
explain plan for
select *
from t_idx_skip_scan_demo
where gender = 'M'
  and age between 30 and 32;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] 선두 컬럼 조건 없음 - Skip Scan 후보
explain plan for
select /*+ index_ss(t idx_iss_gender_age) */
       *
from t_idx_skip_scan_demo t
where age between 30 and 32;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] 중간 컬럼이 비어 있는 3컬럼 인덱스
explain plan for
select /*+ index_ss(t idx_iss_type_code_dt) */
       *
from t_idx_skip_scan_demo t
where biz_type = 'T1'
  and base_dt between date '2024-03-01' and date '2024-03-31';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

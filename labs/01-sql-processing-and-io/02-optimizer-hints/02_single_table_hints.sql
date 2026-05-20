/*
목적
- 단일 테이블 조회에서 힌트가 액세스 경로를 어떻게 바꾸는지 비교한다.

해석 포인트
- 좁은 범위 조회에서는 INDEX RANGE SCAN이 유리할 수 있다.
- 넓은 범위 조회에서는 FULL SCAN이 더 자연스러울 수 있다.
- 힌트가 반영되었는지 항상 실행계획으로 검증해야 한다.
*/

prompt ============================================
prompt 1. 단일 테이블 힌트 비교
prompt ============================================

prompt
prompt [A] 힌트 없이 실행계획 확인
explain plan for
select c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.customer_status = 'ACTIVE'
  and c.signup_at >= date '2025-01-01'
  and c.signup_at < date '2025-02-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] INDEX 힌트 강제
explain plan for
select /*+ index(c idx_customer_status_signup) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.customer_status = 'ACTIVE'
  and c.signup_at >= date '2025-01-01'
  and c.signup_at < date '2025-02-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] FULL 힌트 강제
explain plan for
select /*+ full(c) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.customer_status = 'ACTIVE'
  and c.signup_at >= date '2025-01-01'
  and c.signup_at < date '2025-02-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [D] 넓은 범위 조회에서 FULL 힌트 비교
explain plan for
select /*+ full(c) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.signup_at >= date '2024-01-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 체크 포인트
prompt - ACTIVE + 한 달 범위 조건에서는 INDEX RANGE SCAN이 나오는지 확인
prompt - FULL 힌트를 주면 TABLE ACCESS FULL로 바뀌는지 확인
prompt - 결과가 넓은 범위일 때 FULL이 더 자연스러운지 해석

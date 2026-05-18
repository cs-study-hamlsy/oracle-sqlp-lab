prompt ============================================
prompt 2. 조인 힌트 비교
prompt ============================================

prompt
prompt [A] 힌트 없이 조인 실행계획 확인
explain plan for
select c.customer_name,
       c.phone_number,
       o.order_amount,
       o.order_at
from customer_contacts c
join customer_orders o
  on o.customer_id = c.customer_id
where c.customer_status = 'VIP'
  and c.signup_at >= date '2025-01-01'
  and o.order_at >= date '2025-02-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] LEADING + USE_NL + INDEX 힌트
explain plan for
select /*+ leading(c o) use_nl(o) index(c idx_customer_status_signup) index(o idx_orders_customer_date) */
       c.customer_name,
       c.phone_number,
       o.order_amount,
       o.order_at
from customer_contacts c
join customer_orders o
  on o.customer_id = c.customer_id
where c.customer_status = 'VIP'
  and c.signup_at >= date '2025-01-01'
  and o.order_at >= date '2025-02-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] ORDERED + USE_NL로 조인 순서 고정
explain plan for
select /*+ ordered use_nl(o) */
       c.customer_name,
       c.phone_number,
       o.order_amount,
       o.order_at
from customer_contacts c,
     customer_orders o
where o.customer_id = c.customer_id
  and c.customer_status = 'VIP'
  and c.signup_at >= date '2025-01-01'
  and o.order_at >= date '2025-02-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 체크 포인트
prompt - VIP 고객을 먼저 읽는지 확인
prompt - CUSTOMER_ORDERS가 INDEX RANGE SCAN으로 붙는지 확인
prompt - NESTED LOOPS와 HASH JOIN의 차이를 비교

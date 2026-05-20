/*
목적
- 조인에서 액세스 경로뿐 아니라 조인 순서와 조인 방식이 어떻게 달라지는지 확인한다.

해석 포인트
- 작은 집합을 먼저 읽고 큰 집합을 인덱스로 붙이면 NESTED LOOPS가 유리할 수 있다.
- LEADING은 시작 집합, USE_NL은 조인 방식에 영향을 준다.
- 힌트를 줬더라도 실제로 HASH JOIN이 남아 있는지, NESTED LOOPS로 바뀌는지 반드시 본다.
*/

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

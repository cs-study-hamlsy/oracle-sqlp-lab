prompt ============================================
prompt 1.1.5 옵티마이저 힌트 - 연습문제 정답
prompt ============================================

/*
목적
- 04_practice.sql의 문제에 대한 정답 SQL과 힌트 해석 방향을 제공한다.
- FULL, INDEX, LEADING, USE_NL 힌트가 언제 유리하고 불리한지 실행계획으로 확인한다.

체크 포인트
- 같은 SQL이라도 힌트에 따라 액세스 경로와 조인 순서가 달라지는가
- 넓은 범위에서는 FULL SCAN이 더 자연스러울 수 있음을 설명할 수 있는가
- 비효율적인 힌트를 일부러 써보고 왜 안 좋은지 해석할 수 있는가
*/

prompt
prompt 문제 1 정답 - SEOUL 고객의 2025년 2월 가입자 조회

explain plan for
select c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.city = 'SEOUL'
  and c.signup_at >= date '2025-02-01'
  and c.signup_at < date '2025-03-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select /*+ index(c idx_customer_city_signup) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.city = 'SEOUL'
  and c.signup_at >= date '2025-02-01'
  and c.signup_at < date '2025-03-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 2 정답 - 범위를 넓혀 거의 전체 고객 조회
prompt - 범위가 넓을 때는 FULL이 더 자연스러울 수 있다.

explain plan for
select c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.signup_at >= date '2024-01-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select /*+ index(c idx_customer_city_signup) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.signup_at >= date '2024-01-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

explain plan for
select /*+ full(c) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.signup_at >= date '2024-01-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 3 정답 - VIP 고객의 최근 주문 조회

explain plan for
select c.customer_name,
       c.phone_number,
       o.order_amount,
       o.order_at
from customer_contacts c
join customer_orders o
  on o.customer_id = c.customer_id
where c.customer_status = 'VIP'
  and o.order_at >= date '2025-03-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

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
  and o.order_at >= date '2025-03-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 문제 4 정답 - 일부러 비효율적인 힌트 주기
prompt - 선택도가 좋은 조건인데 FULL을 강제하면 불리할 수 있다.

explain plan for
select /*+ full(c) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.city = 'SEOUL'
  and c.signup_at >= date '2025-02-01'
  and c.signup_at < date '2025-03-01';

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 해석 포인트
prompt - 선택도가 좋고 선두 컬럼이 맞으면 INDEX 힌트가 자연스럽다.
prompt - 범위가 넓으면 FULL SCAN이 더 단순하고 유리할 수 있다.
prompt - LEADING, USE_NL은 조인 순서와 방식 제어 도구이며 정답 자체가 아니다.

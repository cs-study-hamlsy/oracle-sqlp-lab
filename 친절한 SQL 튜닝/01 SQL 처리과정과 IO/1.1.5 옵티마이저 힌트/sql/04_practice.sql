prompt ============================================
prompt 3. 직접 해보는 실습
prompt ============================================

prompt
prompt 문제 1
prompt - 서울(SEOUL) 고객 중 2025년 2월 가입자만 조회하는 SQL을 작성해보세요.
prompt - 힌트 없이 실행계획을 보고, INDEX(city, signup_at) 힌트를 붙여 다시 비교하세요.

prompt
prompt 예시 뼈대
prompt select c.customer_name, c.phone_number, c.address, c.signup_at
prompt from customer_contacts c
prompt where c.city = 'SEOUL'
prompt   and c.signup_at >= date '2025-02-01'
prompt   and c.signup_at < date '2025-03-01';

prompt
prompt 문제 2
prompt - 가입일시 조건을 아주 넓게 잡아 거의 전체 고객을 읽게 만들어보세요.
prompt - 이때 INDEX 힌트와 FULL 힌트 중 어느 쪽이 더 자연스러운지 실행계획으로 설명해보세요.

prompt
prompt 문제 3
prompt - VIP 고객의 최근 주문을 조회하는 조인 SQL을 작성하세요.
prompt - 힌트 없이 실행한 뒤, LEADING(c o)와 USE_NL(o)를 붙여 조인 순서를 비교하세요.

prompt
prompt 문제 4
prompt - 일부러 비효율적인 힌트를 하나 넣어보세요.
prompt - 왜 그 힌트가 현재 데이터 분포에서 손해일 수 있는지 이유를 적어보세요.

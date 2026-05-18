# 1.1.5 옵티마이저 힌트

이 주제는 "Oracle이 SQL을 어떤 길로 실행할지"에 대해 사람이 힌트를 주는 방법을 쉬운 예시로 익히는 실습이다.

이번 실습에서는 아래처럼 익숙한 컬럼을 사용한다.

- 고객명
- 연락처
- 주소
- 가입일시

여기에 상태값, 도시, 주문 테이블을 조금 더 붙여서 `FULL`, `INDEX`, `LEADING`, `USE_NL` 힌트를 비교한다.

핵심 질문은 아래 네 가지다.

- 힌트가 없을 때 옵티마이저는 어떤 실행계획을 고르는가
- `INDEX` 힌트를 주면 정말 인덱스를 타는가
- `FULL` 힌트는 언제 오히려 자연스러운 선택이 될 수 있는가
- 조인에서는 왜 `LEADING`, `USE_NL` 같은 힌트가 중요할 수 있는가

## 학습 목표

- 옵티마이저 힌트의 역할을 쉬운 말로 설명할 수 있다.
- `FULL`, `INDEX`, `LEADING`, `USE_NL` 힌트의 용도를 구분할 수 있다.
- 실행계획에서 `TABLE ACCESS FULL`, `INDEX RANGE SCAN`, `NESTED LOOPS`, `HASH JOIN`을 구분할 수 있다.
- 힌트는 "성능 마법"이 아니라 "실행 방향 제어"라는 점을 이해할 수 있다.

## 핵심 개념

옵티마이저는 SQL을 보고 아래 같은 질문을 스스로 판단한다.

- 어느 테이블부터 읽을까
- 인덱스를 탈까, 풀 스캔할까
- 조인은 어떤 순서와 어떤 방식으로 할까

힌트는 이 판단에 대해 사람이 방향을 주는 것이다.

예를 들어:

- `FULL(c)`는 "고객 테이블 `c`는 인덱스보다 풀 스캔으로 읽어봐"에 가깝다.
- `INDEX(c idx_customer_status_signup)`은 "이 인덱스를 이용하는 계획을 우선 고려해봐"에 가깝다.
- `LEADING(c o)`는 "조인을 `c`부터 시작해봐"에 가깝다.
- `USE_NL(o)`는 "주문 테이블 `o`는 Nested Loop로 붙여봐"에 가깝다.

## 힌트는 언제 쓰는가

아래 상황에서 특히 많이 검토한다.

- 통계정보가 완벽하지 않아 옵티마이저가 자주 다른 선택을 할 때
- 특정 인덱스를 사용하는지 검증하고 싶을 때
- 조인 순서가 바뀌면 성능 차이가 크게 날 때
- 튜닝 전후 실행계획을 비교하며 학습할 때

반대로, 이유 없이 힌트를 고정하면 데이터가 커진 뒤 오히려 나쁜 계획을 강제할 수도 있다.

## 실습 구성

이 폴더에는 아래 파일이 있다.

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/01_setup.sql)
  실습 테이블, 인덱스, 통계정보 준비
- [sql/02_hint_examples.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/02_hint_examples.sql)
  단일 테이블 기준 `FULL`, `INDEX` 힌트 비교
- [sql/03_join_hint_examples.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/03_join_hint_examples.sql)
  조인 기준 `LEADING`, `USE_NL` 비교
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/04_practice.sql)
  직접 해보는 문제
- [pro-c/hint_plan_test.pc](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/pro-c/hint_plan_test.pc)
  PRO-C에서 핵심 실행계획을 한 번에 비교하는 예제

## 실습 데이터 설명

### 1. 고객 테이블

`customer_contacts`

- `customer_id`: 고객 식별자
- `customer_name`: 고객명
- `phone_number`: 연락처
- `address`: 주소
- `city`: 도시
- `customer_status`: 고객 상태
- `signup_at`: 가입일시

### 2. 주문 테이블

`customer_orders`

- `order_id`: 주문 식별자
- `customer_id`: 고객 식별자
- `order_amount`: 주문금액
- `order_status`: 주문 상태
- `order_at`: 주문일시

## 만들어 두는 인덱스

```sql
create index idx_customer_status_signup
    on customer_contacts(customer_status, signup_at);

create index idx_customer_city_signup
    on customer_contacts(city, signup_at);

create index idx_orders_customer_date
    on customer_orders(customer_id, order_at);
```

의도는 단순하다.

- 상태값과 가입일시로 좁혀 읽는 경우를 본다.
- 도시와 가입일시 조건으로도 비교해본다.
- 고객을 먼저 찾고 주문을 붙일 때 주문 테이블 접근 경로를 본다.

## 힌트별 쉬운 해석

### 1. `INDEX`

```sql
select /*+ index(c idx_customer_status_signup) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.customer_status = 'ACTIVE'
  and c.signup_at >= date '2025-01-01'
  and c.signup_at < date '2025-02-01';
```

이 경우는 조건으로 걸러지는 범위가 작다면 인덱스가 잘 맞는다.

예상 실행계획 예시:

```text
SELECT STATEMENT
 TABLE ACCESS BY INDEX ROWID CUSTOMER_CONTACTS
  INDEX RANGE SCAN IDX_CUSTOMER_STATUS_SIGNUP
```

왜 효율적일 수 있는가:

- `customer_status`, `signup_at` 순서로 인덱스를 탈 수 있다.
- 전체 고객을 다 읽지 않고 필요한 구간만 찾을 수 있다.

### 2. `FULL`

```sql
select /*+ full(c) */
       c.customer_name, c.phone_number, c.address, c.signup_at
from customer_contacts c
where c.signup_at >= date '2024-01-01';
```

이 경우는 가입일시 조건이 너무 넓어서 결과가 대부분이라면 풀 스캔이 자연스러울 수 있다.

예상 실행계획 예시:

```text
SELECT STATEMENT
 TABLE ACCESS FULL CUSTOMER_CONTACTS
```

왜 효율적일 수 있는가:

- 어차피 많은 로우를 읽어야 하면 인덱스를 타고 다시 테이블로 돌아오는 비용이 더 클 수 있다.
- 큰 범위를 읽는 SQL에서는 풀 스캔이 더 단순할 수 있다.

### 3. `LEADING` + `USE_NL`

```sql
select /*+ leading(c o) use_nl(o) index(o idx_orders_customer_date) */
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
```

예상 실행계획 예시:

```text
SELECT STATEMENT
 NESTED LOOPS
  TABLE ACCESS BY INDEX ROWID CUSTOMER_CONTACTS
   INDEX RANGE SCAN IDX_CUSTOMER_STATUS_SIGNUP
  TABLE ACCESS BY INDEX ROWID CUSTOMER_ORDERS
   INDEX RANGE SCAN IDX_ORDERS_CUSTOMER_DATE
```

왜 효율적일 수 있는가:

- 먼저 VIP 고객을 적게 뽑는다.
- 그 다음 각 고객의 주문만 인덱스로 찾는다.
- 작은 집합을 먼저 찾는 조인에서는 Nested Loop가 잘 맞을 수 있다.

## 어떤 힌트가 더 효율적인가

정답은 항상 하나가 아니다. 조건과 데이터 양에 따라 달라진다.

### `INDEX`가 잘 맞는 경우

- 조건 선택도가 높다.
- 결과 로우 수가 작다.
- 인덱스 선두 컬럼을 조건절에서 잘 사용한다.

### `FULL`이 잘 맞는 경우

- 결과가 테이블 대부분이다.
- 대량 조회나 배치성 조회다.
- 인덱스를 타도 결국 대부분의 테이블 블록을 다시 읽게 된다.

### `LEADING` + `USE_NL`이 잘 맞는 경우

- 먼저 읽을 작은 집합이 분명하다.
- 뒤쪽 테이블에 조인 인덱스가 잘 준비돼 있다.
- 반복 탐색 비용이 낮다.

## 실행계획을 볼 때 읽는 순서

실행계획을 처음 볼 때는 아래 순서로 보면 편하다.

1. 가장 큰 연산이 `TABLE ACCESS FULL`인지 `INDEX RANGE SCAN`인지 본다.
2. 조인이 있으면 `NESTED LOOPS`인지 `HASH JOIN`인지 본다.
3. Predicate Information에서 어떤 조건이 인덱스에서 소화되는지 본다.
4. 힌트를 줬다면 정말 반영됐는지 확인한다.

## SQL*Plus 실습 순서

```sql
@sql/01_setup.sql
@sql/02_hint_examples.sql
@sql/03_join_hint_examples.sql
@sql/04_practice.sql
```

## PRO-C 실습 순서

전제:

- `proc` 사용 가능
- C 컴파일러 사용 가능
- Oracle Client 헤더/라이브러리 설정 가능

실행:

```powershell
.\run.ps1
```

이 스크립트는 `pro-c/hint_plan_test.pc`를 전처리하고, C 컴파일 후 실행해 핵심 실행계획을 출력한다.

## 체크리스트

실습 후 아래 내용을 설명할 수 있으면 좋다.

- 왜 `INDEX`가 항상 빠른 것이 아닌가
- 왜 `FULL`이 나쁜 힌트라고만 볼 수 없는가
- 왜 조인에서는 접근 경로보다 "어느 테이블부터 읽는가"가 더 중요할 수 있는가
- 왜 힌트는 실행계획으로 검증해야 하는가

## 주의할 점

- 아래 실행계획은 실습 설명용 예시다.
- 실제 비용(`Cost`)과 로우 수는 데이터 양, 통계정보, Oracle 버전에 따라 달라질 수 있다.
- 따라서 이 주제에서는 "힌트 종류와 방향성"을 먼저 이해하고, 실제 환경에서는 반드시 `DBMS_XPLAN.DISPLAY` 결과를 직접 확인해야 한다.

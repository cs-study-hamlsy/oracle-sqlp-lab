# 2.3.6 Index Range Scan Descending

## 학습 목표

- `Index Range Scan Descending`이 일반 `Index Range Scan`과 본질은 같고, 읽는 방향만 반대라는 점을 이해한다.
- 인덱스를 뒤에서부터 읽어 `order by ... desc`를 정렬 없이 처리하는 원리를 설명할 수 있다.
- `MAX`/`MIN` 최적화와 `INDEX RANGE SCAN (MIN/MAX)`가 어떤 상황에서 나타나는지 이해한다.
- SQLP 시험에서 `Descending`, `MIN/MAX`, `FIRST ROW` 계획을 연결해 해석할 수 있다.

## 교재 내용 정리

교재는 `Index Range Scan Descending`을 기본적으로 `Index Range Scan`과 동일한 스캔 방식이라고 설명한다. 다른 점은 인덱스를 뒤에서부터 앞으로 스캔하기 때문에 내림차순으로 정렬된 결과집합을 얻는다는 것이다.

예를 들어 `EMPNO` 인덱스가 있는 상태에서 아래 SQL을 수행하면:

```sql
select *
from emp
where empno > 0
order by empno desc;
```

옵티마이저는 별도 정렬 대신 인덱스를 거꾸로 읽는 계획을 세울 수 있다. 이때 실행계획에 `INDEX (RANGE SCAN DESCENDING)`이 나타난다.

교재는 또 하나 중요한 사례를 보여준다. `(deptno, sal)` 인덱스가 있을 때 부서별 최대 급여를 구하는 상관 서브쿼리에서, Oracle은 인덱스를 뒤에서부터 읽다가 첫 건만 읽고 멈추는 `INDEX RANGE SCAN (MIN/MAX)` 형태를 자동으로 선택할 수 있다.

즉, Descending 계열 스캔은 단순 정렬용일 뿐 아니라 `MAX`/`MIN`을 아주 빠르게 찾는 최적화와도 연결된다.

## 핵심 원리

### 1. 왜 정렬을 생략할 수 있는가

인덱스는 기본적으로 오름차순 정렬 구조다. 그런데 리프 블록은 양방향으로 연결되어 있으므로 뒤에서 앞으로 읽는 것도 가능하다. 따라서 `order by key desc`가 필요하면 굳이 전체 결과를 읽고 정렬할 필요 없이, 인덱스를 역방향으로 읽어 바로 내림차순 결과를 만들 수 있다.

이것이 `Index Range Scan Descending`의 본질이다.

### 2. 일반 Range Scan과 무엇이 같은가

시작점까지 수직 탐색하고, 필요한 구간만 읽는다는 점은 동일하다. 즉, `Descending`은 "다른 종류의 스캔"이라기보다 "Range Scan의 읽기 방향 변형"으로 이해하는 것이 정확하다.

### 3. MAX/MIN 최적화

교재 예시처럼 `(deptno, sal)` 인덱스가 있으면 `where deptno = :x` 조건 아래에서 `max(sal)`을 구할 때 Oracle은 해당 `deptno` 구간의 가장 뒤쪽 값 하나만 읽고 멈출 수 있다. 그래서 실행계획에 다음 같은 단서가 나타난다.

- `FIRST ROW`
- `INDEX RANGE SCAN (MIN/MAX)`

이 계획은 굉장히 강력하다. 집계를 위해 전체 행을 읽는 것이 아니라, 인덱스 끝단의 한 건만 찾고 종료하기 때문이다.

### 4. index_desc 힌트

교재는 옵티마이저가 인덱스를 거꾸로 읽지 않는다면 `index_desc` 힌트로 유도할 수 있다고 설명한다. 다만 실무에서는 힌트보다 인덱스 구조와 SQL 형태가 Descending 스캔에 자연스럽게 맞는지 먼저 보는 것이 바람직하다.

## Oracle 내부 동작 원리

### 1. 리프 블록을 역방향으로 읽는다

리프 블록은 순차 연결 구조를 갖는다. 오름차순 읽기는 앞에서 뒤로, 내림차순 읽기는 뒤에서 앞으로 이동하는 식이다. 이 때문에 `order by ... desc`를 위해 소트 메모리와 TEMP를 별도로 쓰지 않아도 되는 경우가 생긴다.

### 2. 부분범위 처리와 잘 맞는다

`Descending` 스캔은 특히 "상위 N건", "최댓값", "최신 데이터 몇 건"처럼 뒤쪽 일부만 빨리 읽으면 되는 패턴과 잘 맞는다. 예를 들어 최근 주문 10건, 최고 금액 1건 같은 SQL은 내림차순 인덱스 접근만으로 매우 빨라질 수 있다.

### 3. MIN/MAX는 한 건 읽고 멈출 수 있다

일반 집계는 여러 행을 읽어야 하지만, 인덱스 정렬을 활용하면 `MAX`나 `MIN`은 첫 리프 엔트리 한 건으로 답이 나올 수 있다. 이 점이 집계 함수 최적화의 핵심이다.

## 실행계획 또는 튜닝 포인트 해석

실행계획에서 다음 연산을 구분해 본다.

- `INDEX RANGE SCAN DESCENDING`
- `INDEX RANGE SCAN (MIN/MAX)`
- `FIRST ROW`

해석 순서는 보통 아래와 같다.

1. 정렬 제거 목적의 Descending 스캔인가
2. 상위 일부나 최대/최소값을 빠르게 얻기 위한 계획인가
3. 선두 컬럼 조건이 인덱스 구조와 맞는가
4. 테이블 랜덤 액세스가 뒤따르는가

## 실무 점검 포인트

- `order by ... desc` SQL에 불필요한 sort가 발생하는지 본다.
- 최근 데이터/최대값 조회 패턴이 많으면 인덱스 정렬 구조를 적극 활용한다.
- `max(col)`를 위해 Full Scan하고 있지 않은지 점검한다.
- `index_desc` 힌트는 검증용으로만 신중하게 사용한다.
- `Top-N`, 최신 N건, 부서별 최대값 패턴에서 특히 유용하다.

## SQLP 시험 포인트

- `Index Range Scan Descending`은 일반 Range Scan과 본질적으로 동일하고 읽는 방향만 반대다.
- `order by ... desc`를 정렬 없이 처리할 수 있다.
- `MAX`/`MIN` 최적화에서는 `INDEX RANGE SCAN (MIN/MAX)`가 나타날 수 있다.
- `FIRST ROW`가 함께 보이면 한 건만 읽고 멈추는 계획일 가능성이 높다.

## 실습 파일 설명

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/01_setup.sql)
  - Descending 및 MIN/MAX 실습용 테이블과 인덱스를 생성한다.
- [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/02_baseline.sql)
  - `order by ... desc`에서 `INDEX RANGE SCAN DESCENDING`을 확인한다.
- [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/03_comparison.sql)
  - 내림차순 정렬 제거와 `MAX/MIN` 최적화를 비교한다.
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/04_practice.sql)
  - 어떤 SQL이 Descending 또는 MIN/MAX 후보인지 예측한다.
- [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/05_answer.sql)
  - 예시 계획과 해설을 제공한다.
- [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/99_cleanup.sql)
  - 실습 객체를 정리한다.

## SQL Developer 실행 가이드

1. [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/01_setup.sql)을 실행한다.
2. [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/02_baseline.sql)에서 `INDEX RANGE SCAN DESCENDING`을 확인한다.
3. [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/03_comparison.sql)으로 `MAX/MIN` 최적화를 비교한다.
4. [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/04_practice.sql)에서 직접 예측한다.
5. [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.6%20Index%20Range%20Scan%20Descending/sql/05_answer.sql)로 해설을 확인한다.

## 왜 그런지

Descending 스캔의 진짜 가치는 "정렬 생략"과 "끝값 한 건만 읽고 종료"에 있다. 즉, 전체를 다 읽어 정렬하는 방식이 아니라, 이미 정렬된 구조를 거꾸로 활용하는 것이다. 그래서 최신값, 최고값, Top-N 같은 패턴에서 매우 강력하다.

DBA 관점에서는 이 연산을 볼 때 "인덱스를 뒤에서 읽는구나"로 끝내지 말고, "이 SQL이 소트를 아끼는지", "한 건만 읽고 멈출 수 있는지"까지 연결해서 해석해야 한다.

# 2.2.2 인덱스를 Range Scan할 수 없는 이유

## 학습 목표

- 인덱스 Range Scan이 무엇인지, 왜 빠를 수 있는지 이해한다.
- 인덱스 컬럼을 가공하면 왜 정상적인 Range Scan이 어려워지는지 이해한다.
- OR 조건에서 OR Expansion이 일어날 때와 일어나지 않을 때 실행계획 차이를 해석할 수 있다.
- `IN` 조건절에서 `INLIST ITERATOR`가 어떤 의미인지 실행계획으로 확인할 수 있다.
- 인덱스를 정상적으로 Range Scan하기 위한 첫 번째 조건이 "가공되지 않은 인덱스 선두 컬럼 조건"임을 설명할 수 있다.

## 교재 내용 정리

인덱스는 정렬된 탐색 구조다. 그래서 Oracle은 인덱스 선두 컬럼부터 조건을 타고 들어가 필요한 시작 지점을 찾은 뒤, 그 이후 구간만 순차적으로 읽을 수 있다. 이것이 Range Scan의 핵심이다.

반대로 인덱스 컬럼을 함수로 가공하거나 산술 연산을 적용하면, Oracle 입장에서는 인덱스에 저장된 원래 정렬 순서를 그대로 이용하기 어려워진다. 예를 들어 `trunc(hiredate)`, `substr(col, ...)`, `col + 1`, `nvl(col, ...)` 같은 표현은 "조건값을 찾기 위해 인덱스 트리를 따라 내려가는" 접근을 방해한다. 이 경우 인덱스를 읽더라도 정상적인 Access Predicate가 아니라 Filter Predicate로 처리되거나, 아예 Full Scan 쪽이 유리하다고 판단할 수 있다.

이 챕터의 핵심 문장은 다음과 같다.

- 인덱스 컬럼을 가공하면 인덱스를 정상적으로 사용하기 어렵다.
- 인덱스 Range Scan의 출발점은 인덱스 선두 컬럼이다.
- 선두 컬럼이 조건절에 있어도 가공된 상태라면 정상적인 범위 탐색이 깨질 수 있다.
- OR 조건은 항상 나쁜 것이 아니라, OR Expansion이 되면 각 분기에서 Range Scan이 가능할 수 있다.
- `IN` 조건은 같은 컬럼에 대한 여러 개의 등치 조건으로 볼 수 있으며, 이때 `INLIST ITERATOR`가 나타날 수 있다.

## 핵심 원리

### 1. 인덱스 Range Scan이란 무엇인가

인덱스 Range Scan은 인덱스 루트 블록에서 시작해 브랜치 블록을 거쳐 리프 블록에서 시작점을 찾고, 필요한 범위까지만 순서대로 읽는 방식이다.

이 방식이 빠른 이유는 다음과 같다.

- 전체 테이블을 읽지 않는다.
- 필요한 키 범위만 읽는다.
- 리프 블록이 정렬되어 있으므로 시작점과 종료점을 효율적으로 찾을 수 있다.

실행계획에서는 보통 아래 조합으로 관찰된다.

- `INDEX RANGE SCAN`
- `TABLE ACCESS BY INDEX ROWID`

즉, 인덱스에서 후보 ROWID를 찾고, 실제 테이블 블록을 방문해 필요한 컬럼을 읽는 흐름이다.

### 2. 왜 인덱스 컬럼 가공이 문제인가

인덱스는 "원본 컬럼값의 정렬 상태"를 이용한다. 따라서 조건절이 원본 컬럼 형태를 유지해야 옵티마이저가 시작점과 끝점을 계산하기 쉽다.

예를 들어 다음 두 SQL은 의미는 비슷해 보여도 옵티마이저 입장에서는 다르다.

```sql
where hiredate >= date '1981-02-20'
  and hiredate <  date '1981-02-21'
```

```sql
where trunc(hiredate) = date '1981-02-20'
```

첫 번째는 원본 `hiredate` 값 자체에 범위를 주기 때문에 인덱스 Range Scan이 가능하다. 두 번째는 `trunc(hiredate)`라는 계산 결과를 비교하므로, 일반적인 `hiredate` 인덱스로는 탐색 구간을 직접 계산하기 어렵다.

실행계획 해석 포인트는 `Predicate Information`이다.

- `access(...)`에 잡히면 인덱스 탐색 조건으로 잘 사용되는 경우가 많다.
- `filter(...)`에만 잡히면 일단 읽고 나서 거르는 의미가 강하다.

### 3. 선두 컬럼이 가장 먼저 중요한 이유

복합 인덱스는 컬럼 순서가 매우 중요하다. 예를 들어 `(deptno, empno)` 인덱스는 `deptno`를 기준으로 먼저 정렬되고, 그 안에서 `empno`가 정렬된다.

따라서 `empno` 조건만 있고 `deptno` 조건이 없으면, Oracle은 인덱스의 큰 정렬 축을 바로 타고 들어가기 어렵다. 이런 이유로 "인덱스를 Range Scan하기 위한 가장 첫 번째 조건은 인덱스 선두 컬럼이 조건절에 있어야 한다"는 말이 나온다.

여기에 한 가지 조건이 더 붙는다.

- 선두 컬럼이 조건절에 있어야 한다.
- 그 선두 컬럼이 가공되지 않은 상태여야 한다.

즉, `deptno = 10`은 좋지만 `deptno + 0 = 10`, `to_char(deptno) = '10'` 같은 형태는 정상적인 탐색을 어렵게 만든다.

### 4. OR 조건과 OR Expansion

OR 조건이 나오면 많은 수험생이 무조건 "인덱스를 못 쓴다"고 단순화해서 외우는데, 정확한 표현은 아니다.

옵티마이저는 필요하면 OR 조건을 여러 개의 분기로 나누는 쿼리 변환을 할 수 있다. 이것이 OR Expansion이다. 내부적으로는 `UNION ALL`과 유사한 형태로 분해해 각 분기에서 인덱스를 별도로 타게 만드는 전략이다.

예를 들어 아래와 같은 SQL을 생각해볼 수 있다.

```sql
where (deptno = 10 and empno between 1000 and 2000)
   or (deptno = 20 and empno between 1000 and 2000)
```

각 분기 모두 `(deptno, empno)` 인덱스를 정상적으로 탈 수 있다면, 옵티마이저는 OR Expansion을 통해 두 번의 Range Scan으로 처리할 수 있다.

실행계획에서 주로 확인할 수 있는 힌트는 다음과 같다.

- `CONCATENATION`
- 분기별 `INDEX RANGE SCAN`

반대로 OR Expansion이 일어나지 않으면, OR 전체를 한 번에 평가해야 하므로 인덱스 접근이 애매해지고 Full Scan이나 비효율적인 경로로 기울 수 있다.

실무에서는 아래를 같이 본다.

- OR 각 분기가 같은 인덱스를 탈 수 있는가
- 각 분기의 선택도가 좋은가
- OR 조건 중 일부가 가공되어 있거나 선두 컬럼을 놓치고 있지 않은가

### 5. IN 조건절과 INLIST ITERATOR

`IN` 조건은 같은 컬럼에 대한 여러 개의 등치 조건으로 해석할 수 있다.

```sql
where deptno in (10, 20, 30)
  and empno between 1000 and 2000
```

이 경우 `(deptno, empno)` 인덱스가 있다면, Oracle은 `deptno = 10`, `deptno = 20`, `deptno = 30` 각각에 대해 범위 탐색을 반복 수행하는 형태를 선택할 수 있다. 이때 실행계획에 `INLIST ITERATOR`가 보일 수 있다.

`INLIST ITERATOR`는 "IN 리스트의 각 값에 대해 인덱스 접근을 반복한다"는 의미로 이해하면 된다. 즉, `IN`이라고 해서 Range Scan이 불가능한 것이 아니라, 오히려 조건이 잘 맞으면 여러 번의 효율적인 Range Scan으로 풀릴 수 있다.

### 6. Range Scan이 가능하도록 SQL을 작성하는 방법

- 인덱스 선두 컬럼을 조건절에 포함한다.
- 선두 컬럼을 가공하지 않는다.
- 날짜 비교는 `trunc(col)`보다 시작값/종료값 범위 조건으로 바꾼다.
- OR 조건은 각 분기가 인덱스를 탈 수 있게 정리하고, 필요하면 `UNION ALL`로 명시적 분해를 검토한다.
- `IN` 조건은 선두 컬럼과 결합되면 `INLIST ITERATOR`로 효율적으로 동작할 수 있음을 이해한다.
- 정말 가공이 불가피하면 함수기반 인덱스(Function-Based Index)를 검토한다. 다만 이는 "가공해도 괜찮다"는 뜻이 아니라, 가공 조건을 인덱스 구조에 반영한 별도 설계다.

## Oracle 내부 동작 원리

### 1. Access Predicate와 Filter Predicate의 차이

인덱스 튜닝에서 가장 먼저 봐야 할 것은 실행계획 이름 자체보다 Predicate Information이다.

- `access`는 인덱스 탐색 시작점과 범위를 줄이는 데 직접 기여하는 조건이다.
- `filter`는 읽은 뒤 걸러내는 조건이다.

같은 인덱스를 사용해도 어떤 조건이 `access`로 들어가느냐에 따라 성능 차이가 크게 난다.

### 2. 복합 인덱스의 정렬 구조

복합 인덱스 `(a, b, c)`는 실제로 `a` 값 기준으로 먼저 모이고, 그 안에서 `b`, 다시 그 안에서 `c` 순서로 정렬된다. 그래서 `a`를 건너뛰고 `b`나 `c`만으로 효율적인 범위 탐색을 하기는 어렵다.

이 구조를 이해하면 아래 문장을 정확히 해석할 수 있다.

- 선두 컬럼이 빠지면 인덱스 활용성이 급격히 떨어진다.
- 선두 컬럼이 있어도 가공되면 탐색 시작점을 제대로 잡기 어렵다.

### 3. 쿼리 변환과 실행계획

옵티마이저는 원본 SQL을 그대로만 실행하지 않는다. OR Expansion, View Merging, Predicate Pushing 같은 여러 쿼리 변환을 시도한 뒤 더 유리한 계획을 선택할 수 있다.

따라서 SQLP 문제에서 OR 조건이 등장하면 단순히 "OR이 있으니 인덱스 불가"라고 판단하면 위험하다. 실행계획상 `CONCATENATION`, `INLIST ITERATOR`, `INDEX RANGE SCAN`이 나타나는지까지 연결해서 판단해야 한다.

## 실행계획 또는 튜닝 포인트 해석

### 정상적인 Range Scan으로 볼 수 있는 신호

- `INDEX RANGE SCAN`이 보인다.
- 선두 컬럼 조건이 `access(...)`에 잡힌다.
- 범위 조건도 인덱스 키 순서에 맞춰 적용된다.

### 비정상적이거나 주의가 필요한 신호

- 인덱스 컬럼 가공 조건이 `filter(...)`로 내려간다.
- OR 조건 때문에 `TABLE ACCESS FULL`이 선택된다.
- 선두 컬럼이 없어서 복합 인덱스가 기대만큼 활용되지 않는다.

### OR/IN 관련 실행계획 체크 포인트

- `CONCATENATION`이 보이면 OR Expansion 가능성을 먼저 본다.
- `INLIST ITERATOR`가 보이면 IN 리스트 값별 반복 인덱스 탐색으로 해석한다.
- `INDEX RANGE SCAN`이 분기마다 반복되는지 확인한다.

## 실무 점검 포인트

- 조건절에서 인덱스 컬럼에 함수나 연산이 숨어 있지 않은가
- 날짜 검색을 `trunc(date_col)` 형태로 작성하고 있지 않은가
- 복합 인덱스 선두 컬럼 없이 후행 컬럼만 검색하고 있지 않은가
- OR 조건이 많은 SQL에서 각 분기 선택도가 좋은가
- `IN` 리스트가 너무 커서 반복 탐색 비용이 커지고 있지는 않은가
- 함수기반 인덱스를 써야 할 업무 요건인지, SQL 재작성으로 해결 가능한지 구분했는가

## SQLP 시험 포인트

- "인덱스를 Range Scan하기 위한 첫 번째 조건은 인덱스 선두 컬럼이 조건절에 있어야 한다"는 문장을 기억한다.
- 단, 선두 컬럼이 있어도 가공되면 정상적인 Range Scan이 어려울 수 있다.
- OR 조건은 OR Expansion이 되면 인덱스 Range Scan이 가능할 수 있다.
- `IN` 조건은 `INLIST ITERATOR`와 연결해 해석할 수 있어야 한다.
- 실행계획 문제에서는 연산 이름만 보지 말고 `Predicate Information`의 `access/filter`를 함께 봐야 한다.

## 실습 파일 설명

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/01_setup.sql)
  - 실습용 테이블과 인덱스를 생성하고 통계정보를 수집한다.
- [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/02_baseline.sql)
  - 정상적인 Range Scan, 선두 컬럼 부재, 컬럼 가공 사례를 기준선으로 비교한다.
- [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/03_comparison.sql)
  - OR Expansion, OR Expansion 실패 가능성, `INLIST ITERATOR`를 실행계획으로 확인한다.
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/04_practice.sql)
  - 직접 SQL을 바꿔 보며 Range Scan 가능 조건을 점검한다.
- [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/05_answer.sql)
  - 연습 문제 정답과 SQL 재작성 방향을 확인한다.
- [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/99_cleanup.sql)
  - 실습 객체를 정리한다.

## SQL Developer 실행 가이드

1. [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/01_setup.sql)을 열고 `F5`로 실행한다.
2. [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/02_baseline.sql)에서 `Predicate Information`을 중심으로 본다.
3. [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/03_comparison.sql)에서 `CONCATENATION`, `INLIST ITERATOR`, `INDEX RANGE SCAN` 여부를 비교한다.
4. [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/04_practice.sql)에서 직접 SQL을 수정해 본다.
5. [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/05_answer.sql)에서 정답 SQL과 실행계획을 비교한다.
6. 필요하면 [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.2.2%20인덱스를%20Range%20Scan할%20수%20없는%20이유/sql/99_cleanup.sql)로 정리한다.

## 관찰 결과 해석 포인트

- `deptno = :값 and empno between ...` 형태에서 `(deptno, empno)` 인덱스가 자연스럽게 Range Scan 되는가
- `deptno + 0 = :값`, `trunc(hiredate) = :값`처럼 가공하면 `access`가 무너지는가
- OR 조건에서 `CONCATENATION`이 생기면 각 분기가 Range Scan 되는가
- `IN (10, 20, 30)` 조건에서 `INLIST ITERATOR`가 나타나는가
- 같은 의미라도 SQL을 어떻게 작성하느냐에 따라 실행계획이 달라지는가

## 실무에서 무엇을 확인해야 하는지

- 개발 SQL에서 검색 컬럼을 습관적으로 가공하고 있지 않은지 확인해야 한다.
- 날짜 검색은 특히 `trunc()` 남용 여부를 자주 점검해야 한다.
- OR 조건이 많은 화면 조회 SQL은 분기별 선택도와 인덱스 정합성을 따져야 한다.
- 튜닝 시 인덱스를 더 만들기 전에, 먼저 SQL을 인덱스 친화적으로 다시 쓸 수 있는지 검토해야 한다.

## 추가 연습 포인트

- 함수기반 인덱스를 만들면 어떤 경우에 다시 Range Scan이 가능해지는지 생각해 본다.
- `(deptno, job, empno)` 인덱스에서 `deptno`만 있을 때와 `deptno, job`이 함께 있을 때 차이를 비교해 본다.
- OR 조건을 직접 `UNION ALL`로 바꿨을 때 실행계획이 더 안정적으로 나오는지 확인해 본다.

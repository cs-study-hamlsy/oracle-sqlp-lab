# 2.3.4 Index Skip Scan

## 학습 목표

- `Index Skip Scan`이 선두 컬럼 조건이 없는데도 복합 인덱스를 활용하는 원리를 이해한다.
- 선두 컬럼의 `Distinct Value` 개수가 적고, 후행 컬럼 선택도가 좋을 때 왜 Skip Scan이 효과적인지 설명할 수 있다.
- `INDEX (SKIP SCAN)`이 실행계획에 나타났을 때 Range Scan의 대체 전략인지, 아니면 비효율 신호인지 구분할 수 있다.
- SQLP 시험에서 `Skip Scan`의 작동 조건과 한계를 정확히 판단한다.

## 교재 내용 정리

교재는 인덱스 선두 컬럼을 조건절에 사용하지 않으면 옵티마이저가 기본적으로 `Table Full Scan`을 고려한다고 설명한다. 다만 Table Full Scan보다 I/O를 줄일 수 있거나, 정렬된 결과를 더 쉽게 얻을 수 있다면 `Index Full Scan`도 고려할 수 있고, 한걸음 더 나아가 선두 컬럼이 빠진 복합 인덱스를 활용하는 새로운 방식이 `Index Skip Scan`이라고 말한다.

핵심 아이디어는 단순하다. 복합 인덱스 `(성별, 연봉)`이 있을 때, `성별` 조건이 없더라도 `연봉 between 2000 and 4000`처럼 후행 컬럼 조건이 충분히 강하면 Oracle은 인덱스를 "성별 = 남" 구간, "성별 = 여" 구간처럼 선두 컬럼의 각 distinct value별로 나누어 여러 번 Range Scan 비슷하게 탐색한다. 즉, 선두 컬럼을 통째로 건너뛰는 것이 아니라, 선두 컬럼의 가능한 값들을 내부적으로 순회하면서 필요한 리프 블록만 골라 읽는 것이다.

교재는 특히 다음 조건을 강조한다.

- 선두 컬럼의 Distinct Value 개수가 적어야 한다.
- 후행 컬럼의 Distinct Value 개수는 많고 선택도가 좋아야 한다.

예를 들어 고객 테이블에서 `(성별, 고객번호)` 인덱스가 있으면 `성별`은 값 종류가 적고, `고객번호`는 값 종류가 많다. 이런 구조에서 `고객번호` 조건이 강하면 Skip Scan 후보가 된다.

## 핵심 원리

### 1. Skip Scan은 어떻게 동작하는가

`(a, b)` 인덱스가 있고 SQL이 `where b = :x` 또는 `where b between :1 and :2` 형태라고 가정해 보자. 일반적인 `Index Range Scan`이라면 선두 컬럼 `a` 조건이 없어 시작점을 곧바로 정하기 어렵다. 이때 Oracle은 `a`의 가능한 값들을 내부적으로 여러 개의 작은 탐색 단위로 나눠 아래처럼 접근할 수 있다.

- `a = value1`인 구간에서 `b` 조건을 만족할 수 있는 리프 블록 탐색
- `a = value2`인 구간에서 다시 탐색
- `a = value3`인 구간에서 다시 탐색

즉, `Skip Scan`은 선두 컬럼을 무시하는 스캔이 아니라, 선두 컬럼 값별로 인덱스를 쪼개서 반복 탐색하는 방식이다.

### 2. 왜 선두 컬럼 Distinct Value가 적어야 하는가

선두 컬럼 값 종류가 너무 많으면, 내부적으로 반복해야 할 탐색 횟수가 급격히 늘어난다. 그러면 Skip Scan은 금방 비싸진다. 그래서 `성별`, `구분코드`, `업종유형코드`처럼 값 종류가 적은 컬럼이 선두일 때만 실익이 있다.

반대로 후행 컬럼은 선택도가 좋아야 한다. 후행 컬럼 조건이 약하면 선두 컬럼 값별로 여러 번 진입한 뒤에도 읽는 양이 너무 많아져 Full Scan보다 나을 이유가 줄어든다.

### 3. 선두 컬럼이 완전히 없어야만 Skip Scan이 되는 것은 아니다

교재는 아주 중요한 포인트를 하나 더 설명한다. 인덱스가 `(업종유형코드, 업종코드, 기준일자)`처럼 3개 이상 컬럼으로 구성돼 있을 때, 선두 컬럼 `업종유형코드` 조건은 있고 중간 컬럼 `업종코드` 조건은 없지만 마지막 컬럼 `기준일자` 조건이 있는 경우에도 Skip Scan이 가능하다.

즉, Skip Scan은 "인덱스 첫 컬럼이 빠졌을 때만"이 아니라, 복합 인덱스 중간의 일부 선두축이 비어 있어도 남은 조건으로 부분 탐색 가능성이 있으면 선택될 수 있다.

### 4. 범위 조건이나 LIKE 조건에서도 가능하다

교재는 선두 컬럼이 `부등호`, `BETWEEN`, `LIKE` 같은 범위검색 조건일 때도 Skip Scan을 사용할 수 있다고 설명한다. 핵심은 단순히 "=" 조건이냐가 아니라, 인덱스 내부에서 "조건을 만족할 가능성이 있는 리프 블록만 좁혀 들어갈 수 있느냐"다.

## Oracle 내부 동작 원리

### 1. 루트/브랜치 정보를 이용해 가능성 있는 리프만 고른다

교재 설명대로 Skip Scan은 루트 또는 브랜치 블록에서 읽은 컬럼 값 정보를 이용해 조건에 부합하는 레코드를 포함할 가능성이 있는 리프 블록만 골라 액세스한다. 즉, 모든 리프를 순서대로 읽는 것이 아니라 건너뛸 수 있는 리프는 건너뛰고, 가능성이 있는 구간만 접근한다.

이 때문에 이름은 `Skip Scan`이지만, 실제로는 "아무 데나 건너뛰는" 것이 아니라 브랜치 정보에 근거한 선택적 접근이다.

### 2. Range Scan의 최선책이 아니라 차선책

교재도 마지막에 분명히 말한다. `Index Skip Scan`이 때로는 유용하지만 최선책일 수는 없다. 인덱스는 기본적으로 최적의 `Index Range Scan`을 목표로 설계해야 한다. 즉, Skip Scan은 "적절한 인덱스가 없을 때의 구제책"에 가깝다.

따라서 실무에서는 다음처럼 판단해야 한다.

- 수행 빈도가 낮은 SQL이라면 Skip Scan을 차선책으로 수용할 수 있다.
- 수행 빈도가 높고 중요 SQL이라면 후행 컬럼 기준의 별도 인덱스를 검토해야 한다.

## 실행계획 또는 튜닝 포인트 해석

실행계획에 `INDEX (SKIP SCAN)`이 보이면 아래를 확인한다.

1. 어떤 복합 인덱스를 타고 있는가
2. 선두 컬럼 조건이 없는가, 또는 중간 컬럼이 비어 있는가
3. 선두 컬럼 Distinct Value가 적은가
4. 후행 컬럼 조건 선택도가 충분한가
5. 이것이 전략적 차선책인지, 아니면 인덱스 설계 미스의 신호인지

## 실무 점검 포인트

- 선두 컬럼 값 종류가 적은 인덱스인지 본다.
- 후행 컬럼 조건이 강해 실제 읽는 리프 블록이 제한되는지 본다.
- `Skip Scan`이 자주 발생하는 SQL이면 별도 인덱스 설계를 검토한다.
- `index_ss`, `no_index_ss` 힌트는 학습/검증용으로만 신중하게 사용한다.
- AWR/SQL Monitor에서 실제 buffer gets를 보고 Full Scan 대비 이득이 있는지 확인한다.

## SQLP 시험 포인트

- `Index Skip Scan`은 선두 컬럼 조건이 없어도 복합 인덱스를 활용하는 스캔 방식이다.
- 선두 컬럼 Distinct Value 개수가 적고, 후행 컬럼 선택도가 좋을 때 효과적이다.
- 선두 컬럼이 없어도, 또는 중간 컬럼이 비어 있어도 일부 조건 조합에서 Skip Scan이 가능하다.
- 범위 조건, `BETWEEN`, `LIKE`에서도 가능하다.
- 그러나 이는 보통 최선책이 아니라 차선책이다.

## 실습 파일 설명

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/01_setup.sql)
  - Skip Scan 관찰용 테이블과 복합 인덱스를 만든다.
- [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/02_baseline.sql)
  - 선두 컬럼 조건이 있을 때의 Range Scan과 선두 컬럼이 빠졌을 때의 Skip Scan을 비교한다.
- [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/03_comparison.sql)
  - Distinct Value 수와 힌트에 따른 계획 차이를 비교한다.
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/04_practice.sql)
  - 어떤 경우에 Skip Scan을 수용하고, 어떤 경우에 별도 인덱스를 만들지 판단해 본다.
- [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/05_answer.sql)
  - 예시 계획과 해설을 제공한다.
- [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/99_cleanup.sql)
  - 실습 객체를 정리한다.

## SQL Developer 실행 가이드

1. [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/01_setup.sql)을 실행한다.
2. [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/02_baseline.sql)에서 `INDEX RANGE SCAN`과 `INDEX SKIP SCAN` 차이를 확인한다.
3. [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/03_comparison.sql)에서 `index_ss`, `no_index_ss` 힌트와 Distinct Value 조건을 비교한다.
4. [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/04_practice.sql)로 직접 예측한다.
5. [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.4%20Index%20Skip%20Scan/sql/05_answer.sql)로 해설을 확인한다.

## 왜 그런지

Skip Scan은 "인덱스를 억지로 타는 기술"이 아니라, 선두 컬럼의 값 종류가 적을 때 인덱스를 여러 개의 작은 논리 구간으로 나눠서 활용하는 방식이다. 그래서 구조가 맞으면 surprisingly 잘 먹히지만, 구조가 안 맞으면 반복 탐색 비용 때문에 오히려 Full Scan보다 못해질 수 있다.

결국 DBA 관점의 판단은 분명하다. `INDEX SKIP SCAN`이 나왔다고 무조건 반기지 말고, "이 SQL은 차선책으로 충분한가, 아니면 전용 인덱스를 따로 줘야 하는가"를 구분해야 한다.

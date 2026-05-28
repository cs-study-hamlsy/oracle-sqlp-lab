# 2.3.1 Index Range Scan

## 학습 목표

- B*Tree 인덱스에서 `Index Range Scan`이 가장 일반적인 액세스 방식인 이유를 이해한다.
- 인덱스가 "루트에서 리프까지 수직 탐색한 뒤 필요한 구간만 읽는다"는 의미를 실행계획 관점에서 해석한다.
- 같은 `INDEX RANGE SCAN`이라도 실제 성능은 `인덱스 스캔 범위`와 `TABLE ACCESS BY INDEX ROWID` 횟수에 따라 크게 달라진다는 점을 확인한다.
- SQLP 시험에서 `INDEX RANGE SCAN`이 보이면 무엇을 추가로 판단해야 하는지 정리한다.

## 교재 내용 정리

교재는 `Index Range Scan`을 B*Tree 인덱스의 가장 일반적이고 정상적인 액세스 방식이라고 설명한다. 의미는 단순하다. 인덱스 루트 블록에서 시작해 브랜치 블록을 거쳐 리프 블록까지 수직적으로 내려간 다음, 조건을 만족하는 첫 리프 엔트리를 찾고 그 지점부터 필요한 범위만 순차적으로 읽는다.

핵심은 "인덱스 전체를 읽지 않는다"는 데 있다. 즉, 탐색 시작점까지는 수직 탐색이고, 그 이후부터는 필요한 리프 구간만 수평 탐색한다. 그래서 조건절이 인덱스 정렬 순서를 잘 활용할 수 있을수록 비용이 낮아진다.

다만 교재가 같이 강조하는 중요한 경계선이 있다. 실행계획에 `INDEX RANGE SCAN`이 보인다고 해서 성능이 자동으로 좋은 것은 아니다. 성능은 결국 두 가지에 달려 있다.

- 인덱스 리프 블록을 얼마나 넓게 스캔하는가
- 인덱스에서 찾은 ROWID로 테이블 블록을 몇 번이나 다시 방문하는가

즉, `Range Scan`은 "좋은 출발점"이지 "성능 보장" 그 자체가 아니다.

## 핵심 원리

### 1. 왜 Range Scan이 빠른가

인덱스는 정렬 구조다. 따라서 `=` 조건, `BETWEEN`, `>=`, `<` 같은 범위 조건이 인덱스 선두 정렬 순서와 맞아떨어지면 Oracle은 조건을 만족하는 첫 지점을 빠르게 찾을 수 있다. 그 다음부터는 필요한 리프 엔트리만 따라 읽으면 된다.

예를 들어 `(deptno, empno)` 인덱스에서 아래 SQL은 매우 전형적인 `Index Range Scan` 대상이다.

```sql
where deptno = 20
  and empno between 2000 and 2999
```

`deptno = 20`으로 시작 지점을 찾고, 같은 `deptno` 그룹 안에서 `empno` 범위만 읽으면 되기 때문이다.

### 2. Range Scan 이후에는 왜 테이블을 다시 읽는가

인덱스에는 보통 필요한 모든 컬럼이 들어 있지 않다. 그래서 인덱스에서 조건에 맞는 엔트리와 ROWID를 찾은 다음, 실제 데이터 블록을 다시 읽어 나머지 컬럼을 가져온다. 이 단계가 실행계획의 `TABLE ACCESS BY INDEX ROWID`다.

실무적으로는 이 단계가 더 비싼 경우가 많다. 인덱스 리프는 정렬되어 있지만, 테이블 블록은 물리적으로 흩어져 있을 수 있기 때문이다. 즉, 인덱스 스캔 자체보다 테이블 랜덤 액세스가 병목이 되는 경우가 많다.

### 3. 같은 Range Scan이어도 성능이 달라지는 이유

아래 두 SQL은 둘 다 `INDEX RANGE SCAN`이 나올 수 있다.

```sql
where deptno = 20
  and empno between 2000 and 2999
```

```sql
where deptno = 20
```

첫 번째는 읽어야 할 리프 구간도 짧고 테이블 방문 건수도 상대적으로 적다. 반면 두 번째는 같은 `deptno = 20`에 해당하는 행을 거의 다 읽어야 하므로 리프 스캔 범위도 커지고, 테이블 방문도 많아진다.

즉, 실행계획 연산자 이름은 같아도 성능 체감은 전혀 다를 수 있다.

### 4. 인덱스만으로 끝나는 경우

조회 컬럼이 모두 인덱스에 포함되어 있으면 테이블을 다시 읽지 않을 수 있다. 예를 들어 `(deptno, empno)` 인덱스가 있고 `count(*)`나 인덱스 컬럼만 조회한다면 `TABLE ACCESS BY INDEX ROWID`가 사라지거나 최소화될 수 있다.

이 차이는 DBA 관점에서 매우 중요하다. 같은 `Range Scan`이라도 "인덱스 탐색 + 대량 테이블 랜덤 액세스"인지, 아니면 "인덱스만 읽고 끝나는지"에 따라 I/O 성격이 완전히 달라지기 때문이다.

## Oracle 내부 동작 원리

### 1. 루트 -> 브랜치 -> 리프

B*Tree 인덱스는 루트, 브랜치, 리프 블록으로 구성된다.

- 루트 블록: 탐색 시작점
- 브랜치 블록: 하위 블록 방향 결정
- 리프 블록: 인덱스 키 값과 ROWID 저장

`Index Range Scan`은 먼저 수직 탐색으로 시작 리프를 찾고, 그 뒤에는 리프 블록 체인을 따라 필요한 만큼만 읽는다.

### 2. Access Predicate와 Filter Predicate

실행계획을 해석할 때는 연산자 이름만 보지 말고 `Predicate Information`을 함께 봐야 한다.

- `access(...)`: 인덱스 탐색 시작점과 범위를 줄이는 조건
- `filter(...)`: 읽고 난 뒤 걸러내는 조건

`Range Scan`이 잘 작동하는 SQL은 핵심 조건이 `access`로 들어간다. 반대로 `filter` 비중이 커질수록 인덱스를 타더라도 읽는 양이 많아질 수 있다.

### 3. 클러스터링 팩터와 테이블 방문 비용

인덱스에서 찾은 ROWID가 테이블 블록상에서 서로 가깝게 모여 있으면 적은 블록 방문으로 많은 행을 읽을 수 있다. 반대로 흩어져 있으면 랜덤 I/O가 늘어난다. 이것이 실무에서 `클러스터링 팩터`를 보는 이유다.

교재가 "테이블 액세스 횟수를 얼마나 줄일 수 있느냐가 중요하다"고 말하는 배경이 바로 여기에 있다.

## 실행계획 또는 튜닝 포인트 해석

`Index Range Scan`을 볼 때는 아래 순서로 해석하는 것이 좋다.

1. 어떤 인덱스를 탔는가
2. 어떤 조건이 `access`로 들어갔는가
3. 범위가 좁은가 넓은가
4. `TABLE ACCESS BY INDEX ROWID`가 뒤따르는가
5. 반환 건수가 많다면 차라리 다른 액세스가 유리하지 않은가

특히 대량 데이터에서 `Range Scan + 테이블 랜덤 액세스`가 반복되면, 계획 이름만 좋아 보이고 실제 응답시간은 느릴 수 있다.

## 실무 점검 포인트

- 인덱스를 타는지 여부보다 "얼마나 적게 읽는지"를 먼저 본다.
- `INDEX RANGE SCAN` 뒤에 `TABLE ACCESS BY INDEX ROWID`가 대량으로 따라붙는지 본다.
- 인덱스 컬럼만으로 처리 가능한 SQL인지 검토한다.
- 반환 건수가 많으면 Full Scan이 더 유리한지 비교한다.
- AWR/ASH나 SQL Monitor에서 실제 row 수와 buffer gets를 확인한다.

## SQLP 시험 포인트

- `Index Range Scan`은 B*Tree 인덱스의 가장 일반적인 액세스 방식이다.
- 루트에서 리프까지 수직 탐색한 후, 필요한 리프 구간만 읽는다.
- 실행계획에 `INDEX RANGE SCAN`이 보이더라도 성능은 스캔 범위와 테이블 액세스 횟수에 따라 달라진다.
- `TABLE ACCESS BY INDEX ROWID`가 함께 보이면 인덱스만으로 끝나지 않는다는 뜻이다.
- 인덱스 컬럼만 조회하는 경우 테이블 액세스가 줄거나 사라질 수 있다.

## 실습 파일 설명

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/01_setup.sql)
  - 실습용 테이블과 인덱스를 생성하고 통계정보를 수집한다.
- [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/02_baseline.sql)
  - 전형적인 `INDEX RANGE SCAN`과 `TABLE ACCESS BY INDEX ROWID` 조합을 확인한다.
- [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/03_comparison.sql)
  - 좁은 범위, 넓은 범위, 인덱스만 읽는 경우를 비교한다.
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/04_practice.sql)
  - 직접 실행계획을 예측해보는 연습 문제다.
- [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/05_answer.sql)
  - 연습 문제 해설과 예시 SQL을 제공한다.
- [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/99_cleanup.sql)
  - 실습 객체를 정리한다.

## SQL Developer 실행 가이드

1. [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/01_setup.sql)을 `F5`로 실행한다.
2. [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/02_baseline.sql)에서 `INDEX RANGE SCAN`, `TABLE ACCESS BY INDEX ROWID`, `Predicate Information`을 확인한다.
3. [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/03_comparison.sql)으로 읽는 범위 차이를 비교한다.
4. [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/04_practice.sql)에서 직접 계획을 예측한다.
5. [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.1%20Index%20Range%20Scan/sql/05_answer.sql)로 해설을 확인한다.

## 관찰 결과 해석 포인트

- `deptno = 20 and empno between ...`에서 `IDX_IRS_DEPTNO_EMPNO`가 `INDEX RANGE SCAN`으로 잡히는지 본다.
- 같은 Range Scan이라도 범위를 넓히면 cost, cardinality, table access 부담이 커지는지 본다.
- `count(*)`처럼 인덱스만으로 처리 가능한 경우 테이블 액세스가 줄어드는지 본다.
- 실행계획 이름보다 실제 읽는 row 수와 액세스 방식이 더 중요하다는 점을 체감한다.

## 왜 그런지

`Index Range Scan`이 효율적인 이유는 필요한 구간만 읽기 때문이다. 그런데 그 "필요한 구간"이 생각보다 넓다면 이야기가 달라진다. 그리고 거기서 끝나지 않고 테이블까지 다시 많이 방문해야 한다면, 인덱스를 탔더라도 성능은 기대보다 나쁘게 나올 수 있다.

교재가 이 지점을 먼저 잡는 이유는, 이후 나오는 `Index Full Scan`, `Index Unique Scan`, `Index Skip Scan` 등을 비교할 때 기준점이 되기 때문이다. 즉, Range Scan은 가장 기본적이지만 동시에 "성능 판단의 출발점"이기도 하다.

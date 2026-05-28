# 2.3.5 Index Fast Full Scan

## 학습 목표

- `Index Fast Full Scan`이 `Index Full Scan`보다 왜 빠를 수 있는지 물리 I/O 관점에서 이해한다.
- `Index Full Scan`과 `Index Fast Full Scan`의 차이를 `정렬 보장`, `Multiblock I/O`, `병렬 처리`, `사용 가능 조건` 측면에서 비교할 수 있다.
- `Index Fast Full Scan`은 인덱스 트리 구조를 따라 읽는 것이 아니라 세그먼트 전체를 물리 순서대로 읽는다는 점을 설명할 수 있다.
- SQLP 시험에서 두 스캔 방식을 혼동하지 않는다.

## 교재 내용 정리

교재는 `Index Fast Full Scan`이 말 그대로 `Index Full Scan`보다 빠르다고 설명한다. 이유는 논리적인 인덱스 트리 구조를 무시하고, 인덱스 세그먼트 전체를 `Multiblock I/O` 방식으로 스캔하기 때문이다.

`Index Full Scan`은 루트, 브랜치, 리프를 따라 논리적 순서대로 읽고 결과 집합 순서를 보장한다. 반면 `Index Fast Full Scan`은 디스크에 저장된 물리적 순서대로 인덱스 블록을 대량으로 읽는다. 그래서 빠르지만 인덱스 키 순서로 정렬된 결과를 보장하지 않는다.

교재는 이 차이를 아래처럼 요약한다.

- `Index Full Scan`
  - 인덱스 구조를 따라 스캔
  - 결과집합 순서 보장
  - Single Block I/O
  - 비파티션 인덱스는 병렬스캔 불가
  - 인덱스에 없는 컬럼 조회 시에도 사용 가능

- `Index Fast Full Scan`
  - 세그먼트 전체 스캔
  - 결과집합 순서 보장 안 됨
  - Multiblock I/O
  - 병렬스캔 가능
  - 인덱스에 포함된 컬럼으로만 조회할 때 사용 가능

## 핵심 원리

### 1. 왜 더 빠른가

핵심은 I/O 방식이다. `Index Full Scan`은 리프 블록 연결 리스트와 트리 구조를 따라가며 비교적 잘게 읽는다. 반면 `Index Fast Full Scan`은 Full Table Scan처럼 읽어야 할 익스텐트 목록을 잡고, 그 물리 블록들을 대량으로 읽는다. 그래서 디스크에서 많은 블록을 빠르게 가져와야 할 때 유리하다.

### 2. 왜 결과 순서가 보장되지 않는가

인덱스 키 순서로 읽지 않기 때문이다. `Fast Full Scan`은 인덱스 리프 노드 간의 논리 연결을 따라가지 않고, 물리적으로 배치된 순서대로 읽는다. 따라서 인덱스를 읽더라도 `order by`를 생략할 수 있는 성격은 아니다.

이 지점이 `Index Full Scan`과의 가장 큰 차이다.

### 3. 왜 인덱스에 포함된 컬럼만 조회할 때만 유리한가

교재가 말하듯 `Index Fast Full Scan`은 쿼리에 사용한 컬럼이 모두 인덱스에 포함돼 있을 때만 사용할 수 있다는 점을 기억해야 한다. 이유는 인덱스를 대량 스캔하는 장점이, 결국 테이블을 다시 대량 랜덤 액세스하면 크게 희석되기 때문이다.

실무에서는 보통 `count(*)`, `count(1)`, 인덱스 컬럼만 조회하는 집계/목록 SQL에서 자주 관찰된다.

### 4. 병렬 처리 가능성

`Index Fast Full Scan`은 Full Table Scan과 유사한 대량 읽기 성격이어서 병렬 처리와도 잘 맞는다. 교재도 비파티션 인덱스여도 병렬 쿼리가 가능하다는 점을 특징으로 든다. 대용량 집계 SQL에서 이 차이는 실제 성능에 꽤 크게 작용한다.

## Oracle 내부 동작 원리

### 1. 세그먼트 전체를 읽는다

`Fast Full Scan`은 논리적 루트/브랜치 탐색이 본질이 아니다. 필요한 것은 인덱스 세그먼트의 블록들이다. 루트와 브랜치 블록도 읽을 수는 있지만, 검색에 꼭 필요 없는 구조 블록은 버려진다. 핵심은 "인덱스를 탐색"하는 것이 아니라 "인덱스 세그먼트를 대량 읽기"하는 데 있다.

### 2. Full Table Scan과 닮아 있다

교재 각주가 말하듯, 읽어야 할 익스텐트 목록을 익스텐트 맵에서 얻는 방식은 Table Full Scan과 유사하다. 즉, Fast Full Scan은 이름만 인덱스 스캔이지 물리적으로는 Full Table Scan과 비슷한 접근 전략을 취한다.

### 3. 정렬 보장 안 됨

따라서 `order by` 제거 목적으로는 `Index Full Scan`이 맞고, 빠른 대량 읽기 목적으로는 `Index Fast Full Scan`이 맞다. 두 연산을 바꿔 생각하면 시험과 실무 둘 다 틀리기 쉽다.

## 실행계획 또는 튜닝 포인트 해석

실행계획에 `INDEX FAST FULL SCAN`이 보이면 아래를 확인한다.

1. 조회 컬럼이 모두 인덱스에 포함돼 있는가
2. 결과 정렬이 필요한 SQL인가
3. 병렬 처리나 대량 집계 목적과 맞는가
4. Full Table Scan과 비교해 인덱스가 더 얇은가
5. 테이블 랜덤 액세스가 뒤따르지 않는가

## 실무 점검 포인트

- `count(*)`, `distinct`, 집계 SQL에서 인덱스만으로 끝낼 수 있는지 본다.
- 정렬된 결과가 필요한 SQL에 Fast Full Scan이 유리한지 따로 검토한다.
- `INDEX FULL SCAN`과 `INDEX FAST FULL SCAN`을 이름만 보고 혼동하지 않는다.
- 병렬 쿼리에서 Fast Full Scan이 유리한지 확인한다.
- 인덱스가 테이블보다 충분히 얇은지 검토한다.

## SQLP 시험 포인트

- `Index Fast Full Scan`은 인덱스 구조를 따라가지 않고 세그먼트 전체를 읽는다.
- `Multiblock I/O`를 사용하므로 `Index Full Scan`보다 빠를 수 있다.
- 결과집합 순서를 보장하지 않는다.
- 병렬 스캔이 가능하다.
- 보통 쿼리 컬럼이 모두 인덱스에 포함될 때 유효하다.

## 실습 파일 설명

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/01_setup.sql)
  - Full Scan과 Fast Full Scan 비교용 테이블과 인덱스를 생성한다.
- [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/02_baseline.sql)
  - `index_ffs` 힌트로 `INDEX FAST FULL SCAN` 기본 사례를 확인한다.
- [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/03_comparison.sql)
  - `INDEX FULL SCAN`, `INDEX FAST FULL SCAN`, `TABLE FULL SCAN`을 비교한다.
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/04_practice.sql)
  - 어떤 SQL이 FFS 후보인지 예측한다.
- [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/05_answer.sql)
  - 예시 실행계획과 해설을 제공한다.
- [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/99_cleanup.sql)
  - 실습 객체를 정리한다.

## SQL Developer 실행 가이드

1. [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/01_setup.sql)을 실행한다.
2. [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/02_baseline.sql)에서 `INDEX FAST FULL SCAN`을 확인한다.
3. [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/03_comparison.sql)으로 정렬 보장 여부와 테이블 접근 여부를 비교한다.
4. [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/04_practice.sql)에서 후보 SQL을 예측한다.
5. [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.5%20Index%20Fast%20Full%20Scan/sql/05_answer.sql)로 해설을 확인한다.

## 왜 그런지

Fast Full Scan은 "인덱스니까 정렬돼 있겠지"라는 직관을 깨는 연산이다. Oracle 입장에서는 정렬 순서가 중요하지 않고, 인덱스만으로 필요한 데이터를 다 얻을 수 있다면 굳이 트리 구조를 따라갈 이유가 없다. 그냥 더 얇은 세그먼트를 대량으로 읽는 편이 빠르다.

그래서 DBA 관점에서는 이 연산을 "정렬용 인덱스 활용"이 아니라 "인덱스를 이용한 대량 읽기 최적화"로 이해해야 한다.

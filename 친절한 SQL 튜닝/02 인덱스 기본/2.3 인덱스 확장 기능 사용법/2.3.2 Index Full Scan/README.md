# 2.3.2 Index Full Scan

## 학습 목표

- `Index Full Scan`이 "인덱스를 못 타는 실패 사례"가 아니라, 특정 조건에서 옵티마이저가 전략적으로 고르는 액세스 방식임을 이해한다.
- 선두 컬럼 조건이 없어 `Index Range Scan`은 불가능하지만, 인덱스 전체를 정렬 순서대로 읽는 것이 더 유리한 상황을 해석한다.
- `ORDER BY` 정렬 생략과 `FIRST_ROWS` 기반 부분범위 처리에서 `Index Full Scan`이 왜 선택될 수 있는지 이해한다.
- SQLP 시험에서 `Index Full Scan`과 `Table Full Scan + Sort`의 선택 기준을 비교할 수 있다.

## 교재 내용 정리

교재는 `Index Full Scan`을 "수직적 탐색 없이 인덱스 리프 블록을 처음부터 끝까지 수평적으로 탐색하는 방식"이라고 설명한다. 즉, `Range Scan`처럼 시작 지점을 좁혀 들어가는 것이 아니라, 인덱스 전체를 순서대로 읽는다.

교재 예시는 `(ename, sal)` 인덱스를 만든 뒤 아래 SQL을 보여준다.

```sql
select *
from emp
where sal > 2000
order by ename;
```

이 SQL은 `sal` 조건은 있지만 인덱스 선두 컬럼 `ename` 조건이 없다. 따라서 `Index Range Scan`은 어렵다. 그럼에도 `sal`이 인덱스 안에 있고, 결과를 `ename` 순으로 정렬해야 하므로 Oracle은 인덱스 전체를 순서대로 읽으면서 `sal > 2000` 조건을 필터링하는 전략을 고려할 수 있다. 이것이 `Index Full Scan`이다.

즉, `Index Full Scan`의 핵심은 "선두 컬럼 조건이 없더라도 인덱스 전체를 읽는 편이 테이블 전체를 읽고 정렬하는 것보다 나을 수 있다"는 데 있다.

## 핵심 원리

### 1. 왜 Full Scan인데도 인덱스를 읽는가

인덱스는 보통 테이블보다 훨씬 얇다. 컬럼 수가 적고, 저장 구조도 탐색 중심으로 압축되어 있기 때문이다. 그래서 적절한 범위 스캔은 안 되더라도, 테이블 전체를 읽는 것보다 인덱스 전체를 읽는 편이 더 싸게 먹히는 경우가 있다.

특히 아래 조건이 겹치면 `Index Full Scan`의 실익이 커진다.

- 테이블은 크고 넓다
- 인덱스는 상대적으로 얇다
- 조건절 컬럼이 인덱스에 포함돼 있다
- 결과 정렬 순서가 인덱스 정렬 순서와 맞아떨어진다

### 2. Range Scan과 본질적으로 무엇이 다른가

`Range Scan`은 시작 지점과 종료 지점을 비교적 명확하게 정할 수 있을 때 유리하다. 반면 `Index Full Scan`은 시작 지점을 좁혀 찾지 못하므로, 리프 블록을 처음부터 끝까지 읽어가며 조건에 맞는 행을 걸러낸다.

즉, 인덱스를 읽는다고 해도 접근 철학이 다르다.

- `Range Scan`: 필요한 구간만 읽는다
- `Full Scan`: 인덱스 전체를 정렬 순서대로 읽는다

그래서 `Index Full Scan`은 보통 차선책이다. 교재도 "적절한 인덱스가 없어 Range Scan의 차선책으로 선택된다"고 설명한다.

### 3. 정렬 생략 효과

`Index Full Scan`은 인덱스 키 순서대로 읽기 때문에 결과가 자연스럽게 정렬되어 나온다. 그래서 `ORDER BY`를 별도로 수행하지 않아도 되는 경우가 있다.

예를 들어 `(ename, sal)` 인덱스가 있으면 `order by ename`은 인덱스 정렬 순서와 일치한다. 이 경우 Oracle은 `Table Full Scan + Sort Order By` 대신 `Index Full Scan + Table Access By ROWID`를 선택할 수 있다.

이 부분이 실무적으로 매우 중요하다. 정렬 비용은 메모리와 TEMP 사용량까지 연결되기 때문이다.

### 4. FIRST_ROWS와 부분범위 처리

교재는 `first_rows` 힌트를 함께 설명한다. 사용자가 전체 결과를 끝까지 다 읽는 것이 아니라 "처음 몇 건을 빨리 보고 싶다"는 목적이면, 옵티마이저는 전체 처리량보다 첫 응답 속도를 중시하는 계획을 선택할 수 있다.

이때 `Index Full Scan`은 정렬을 생략하고 인덱스 순서대로 바로 결과를 반환할 수 있어 유리해진다. 하지만 사용자가 실제로는 fetch를 멈추지 않고 끝까지 다 읽는다면 이야기가 달라진다. 교재가 경고하듯, 이 경우에는 `Table Full Scan`보다 더 많은 I/O를 일으켜 오히려 느릴 수 있다.

즉, `FIRST_ROWS` 기반 `Index Full Scan`은 "부분범위 처리"가 전제될 때만 빛난다.

## Oracle 내부 동작 원리

### 1. 리프 블록을 처음부터 끝까지 읽는다

`Index Full Scan`은 인덱스 리프 블록 체인을 처음부터 끝까지 따라가며 읽는다. 정렬 순서를 유지해야 하므로 `Index Fast Full Scan`처럼 멀티블록 I/O 기반의 무정렬 대량 읽기와는 성격이 다르다.

시험에서는 둘을 자주 헷갈린다.

- `Index Full Scan`: 정렬 순서 보장, 순차적 리프 탐색
- `Index Fast Full Scan`: 정렬 순서 보장 안 됨, 대량 읽기 성격

### 2. 필터링과 테이블 방문

조건 컬럼이 인덱스에 있더라도 `select *`라면 결국 테이블을 다시 방문해야 한다. 그래서 `Index Full Scan`의 실제 비용은 다음 조합으로 생각해야 한다.

- 인덱스 전체 읽기 비용
- 필터링 후 남은 ROWID 수
- 남은 ROWID로 테이블 블록을 방문하는 비용

필터 결과가 적으면 유리할 수 있지만, 조건을 만족하는 행이 너무 많으면 랜덤 액세스가 폭증해 비효율적일 수 있다.

### 3. 정렬 생략 vs 전체 처리량

옵티마이저는 항상 "인덱스를 타는 것"을 우선하지 않는다. `ALL_ROWS` 모드라면 전체 처리량 관점에서 `Table Full Scan + Sort`가 더 유리하다고 판단할 수 있다. 반면 `FIRST_ROWS` 계열 모드에서는 정렬 생략과 첫 결과 반환 속도가 더 중요해질 수 있다.

따라서 `Index Full Scan`은 단순한 액세스 방식이 아니라, 옵티마이저 목표와 응답 패턴까지 반영된 선택 결과로 봐야 한다.

## 실행계획 또는 튜닝 포인트 해석

`Index Full Scan`을 보면 아래 순서로 판단하는 것이 좋다.

1. 왜 `Range Scan`이 아닌가
2. 선두 컬럼 조건이 없는가
3. 정렬 생략 이득이 있는가
4. 조건 컬럼이 인덱스에 포함되어 인덱스 단계에서 필터링 가능한가
5. 반환 건수가 많아 테이블 랜덤 액세스가 폭증하지 않는가
6. `FIRST_ROWS` 성격인지, 전체 결과 처리인지

## 실무 점검 포인트

- `order by`를 위해 불필요한 sort가 발생하는지 본다.
- 선두 컬럼 조건이 없더라도 인덱스 전체 스캔이 더 얇은 경로인지 비교한다.
- 필터 후 남는 row 수가 많은데 `select *`를 하고 있다면 테이블 랜덤 액세스 부담을 의심한다.
- 사용자 화면이 정말 부분범위 처리인지, 아니면 결국 전체 결과를 다 읽는지 확인한다.
- `FIRST_ROWS` 힌트가 업무 특성과 맞는지 검토한다.

## SQLP 시험 포인트

- `Index Full Scan`은 수직 탐색 없이 인덱스 리프 블록을 처음부터 끝까지 읽는 방식이다.
- 선두 컬럼 조건이 없어 `Index Range Scan`이 어려울 때 차선책으로 선택될 수 있다.
- 결과 정렬 순서가 인덱스 순서와 일치하면 `Sort Order By`를 생략할 수 있다.
- 부분범위 처리에서는 `FIRST_ROWS`와 결합해 유리할 수 있다.
- 하지만 전체 결과를 끝까지 읽으면 `Table Full Scan`보다 불리할 수 있다.
- `Index Fast Full Scan`과 혼동하지 않아야 한다.

## 실습 파일 설명

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/01_setup.sql)
  - `(ename, sal)` 인덱스를 포함한 실습용 테이블을 생성한다.
- [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/02_baseline.sql)
  - 교재 흐름과 유사한 `where sal > ... order by ename` 패턴을 확인한다.
- [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/03_comparison.sql)
  - 고선택도 필터, 저선택도 필터, `FIRST_ROWS`, `FULL` 힌트 비교를 수행한다.
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/04_practice.sql)
  - 어떤 상황에서 `Index Full Scan`이 유리할지 스스로 판단해 본다.
- [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/05_answer.sql)
  - 실행계획과 해설을 확인한다.
- [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/99_cleanup.sql)
  - 실습 객체를 정리한다.

## SQL Developer 실행 가이드

1. [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/01_setup.sql)을 실행한다.
2. [sql/02_baseline.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/02_baseline.sql)에서 `INDEX FULL SCAN` 여부와 `ORDER BY` 정렬 생략 여부를 본다.
3. [sql/03_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/03_comparison.sql)으로 부분범위 처리와 전체 처리량 관점의 차이를 비교한다.
4. [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/04_practice.sql)에서 직접 예측한다.
5. [sql/05_answer.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/02%20인덱스%20기본/2.3.2%20Index%20Full%20Scan/sql/05_answer.sql)로 해설을 확인한다.

## 관찰 결과 해석 포인트

- 선두 컬럼 `ename` 조건이 없는데도 `(ename, sal)` 인덱스를 읽는 이유를 이해한다.
- `order by ename` 때문에 sort가 생략되는지 본다.
- `sal > 16000`처럼 선택도가 높을 때는 인덱스 전체를 읽어 필터링하는 전략이 왜 유리할 수 있는지 본다.
- `sal > 1000`처럼 대부분이 걸리는 조건에서 `FIRST_ROWS`와 전체 fetch의 관점이 왜 다른지 해석한다.

## 왜 그런지

`Index Full Scan`은 언뜻 비효율적으로 보이지만, Oracle은 "어차피 정렬도 해야 하고, 테이블은 더 크고, 필요한 필터 컬럼은 인덱스에 있다"는 상황이면 인덱스 전체를 읽는 쪽을 선택할 수 있다. 즉, 이 방식의 본질은 "범위를 잘 못 좁히는 대신, 더 얇은 구조를 정렬된 상태로 읽어 손해를 줄이는 것"이다.

다만 교재가 끝까지 강조하는 것처럼, 이 판단은 어디까지나 사용 패턴과 함께 봐야 한다. 첫 몇 건만 빨리 가져오는 화면이라면 매우 좋은 선택일 수 있지만, 사용자가 끝까지 모두 읽는 배치성 SQL이라면 오히려 더 느릴 수 있다.

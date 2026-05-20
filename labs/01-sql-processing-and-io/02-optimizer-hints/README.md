# 옵티마이저 힌트

## 실습 목적

옵티마이저 힌트가 실행계획을 어떻게 바꾸는지, 그리고 왜 그것이 항상 정답이 아닌지를 이해합니다.

## 핵심 개념

- `FULL`
- `INDEX`
- `LEADING`
- `USE_NL`
- 선택도
- 조인 순서
- 조인 방식

## 실행 순서

1. [01_setup.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/01_setup.sql)
2. [02_single_table_hints.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/02_single_table_hints.sql)
3. [03_join_hints.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/03_join_hints.sql)
4. [04_practice.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/04_practice.sql)

## SQL Developer 실행 가이드

- `01_setup.sql`은 파일 전체를 `F5`로 실행합니다.
- `02_single_table_hints.sql`은 파일 전체를 `F5`로 실행합니다.
- `03_join_hints.sql`은 파일 전체를 `F5`로 실행합니다.
- `04_practice.sql`은 문제 안내용입니다. 파일을 그대로 실행해도 되지만, 실제 실습은 예시 SQL을 복사해 조건과 힌트를 직접 바꿔가며 실행하는 방식을 권장합니다.

## 실습 전제

- `DBMS_XPLAN.DISPLAY` 조회가 가능해야 합니다.
- 테이블 생성 권한과 인덱스 생성 권한이 있는 실습 계정이 필요합니다.
- `01_setup.sql`을 다시 실행하면 테스트 데이터가 재생성됩니다.

## 관찰 포인트

- 힌트가 실제로 반영되었는가
- 액세스 경로만 바뀌었는가, 조인 순서까지 바뀌었는가
- `FULL`이 유리한 상황과 `INDEX`가 유리한 상황을 설명할 수 있는가

## 실무 확인 포인트

- 통계가 부정확한데 힌트로 임시 봉합하고 있지는 않은가
- 조인 순서 강제가 다른 바인드 값에서도 안전한가
- 힌트 의존 SQL이 시간이 지나며 오히려 리스크가 되지 않는가

## SQLP 시험 포인트

- 힌트는 옵티마이저 판단을 보조 또는 강제하는 도구입니다.
- 조인에서는 액세스 경로보다 "어느 집합을 먼저 읽는가"가 더 중요해질 수 있습니다.
- `INDEX`가 있다고 항상 빠른 것이 아니며, 결과 집합이 크면 FULL SCAN이 합리적일 수 있습니다.

## 실행 예시

1. SQL Developer에서 [01_setup.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/01_setup.sql) 파일을 열고 `F5`로 전체 실행합니다.
2. [02_single_table_hints.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/02_single_table_hints.sql) 파일 전체를 실행해 `FULL`과 `INDEX` 차이를 봅니다.
3. [03_join_hints.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/03_join_hints.sql) 파일 전체를 실행해 조인 순서와 조인 방식 변화를 봅니다.
4. [04_practice.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/04_practice.sql)의 문제를 보고 예시 SQL을 별도 워크시트에서 직접 수정해 실험합니다.

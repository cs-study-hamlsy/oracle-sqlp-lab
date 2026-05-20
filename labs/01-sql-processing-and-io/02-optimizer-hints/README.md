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

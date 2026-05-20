# 1.1.5 옵티마이저 힌트

옵티마이저 힌트가 실행계획을 어떻게 바꾸는지, 그리고 왜 그것이 항상 정답이 아닌지를 이해하는 실습입니다.

## 학습 목표

- `FULL`, `INDEX`, `LEADING`, `USE_NL` 힌트의 역할을 구분한다.
- 단일 테이블과 조인에서 힌트가 액세스 경로와 조인 방식에 미치는 영향을 이해한다.
- 힌트는 실행계획으로 검증해야 한다는 점을 익힌다.

## 실습 전제

- `DBMS_XPLAN.DISPLAY` 조회가 가능해야 합니다.
- 테이블 생성 권한과 인덱스 생성 권한이 있는 실습 계정이 필요합니다.
- `sql/01_setup.sql`을 다시 실행하면 테스트 데이터가 재생성됩니다.

## SQL Developer 실행 가이드

1. [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/01_setup.sql) 파일을 열고 `F5`로 전체 실행합니다.
2. [sql/02_hint_examples.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/02_hint_examples.sql) 파일을 열고 `F5`로 전체 실행합니다.
3. [sql/03_join_hint_examples.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/03_join_hint_examples.sql) 파일을 열고 `F5`로 전체 실행합니다.
4. [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/04_practice.sql)의 문제를 읽고, 예시 SQL을 별도 워크시트에서 직접 수정해 실험합니다.

## 실습 파일 구성

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/01_setup.sql)
  - 실습 테이블, 인덱스, 통계정보 준비
- [sql/02_hint_examples.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/02_hint_examples.sql)
  - 단일 테이블 기준 `FULL`, `INDEX` 비교
- [sql/03_join_hint_examples.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/03_join_hint_examples.sql)
  - 조인 기준 `LEADING`, `USE_NL` 비교
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/sql/04_practice.sql)
  - 직접 해보는 문제

## 관찰 포인트

- 힌트가 실제로 반영되었는가
- 액세스 경로만 바뀌었는가, 조인 순서까지 바뀌었는가
- `FULL`이 유리한 상황과 `INDEX`가 유리한 상황을 설명할 수 있는가

## SQLP 시험 포인트

- 힌트는 옵티마이저 판단을 보조 또는 강제하는 도구입니다.
- 조인에서는 액세스 경로보다 "어느 집합을 먼저 읽는가"가 더 중요할 수 있습니다.
- `INDEX`가 있다고 항상 빠른 것이 아니며, 결과 집합이 크면 FULL SCAN이 합리적일 수 있습니다.

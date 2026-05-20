# 실행계획과 비용

## 실습 목적

같은 SQL이라도 왜 옵티마이저가 다른 액세스 경로를 선택하는지 이해합니다.

## 핵심 개념

- `TABLE ACCESS FULL`
- `INDEX RANGE SCAN`
- `TABLE ACCESS BY INDEX ROWID`
- 선택도와 복합 인덱스 선두 컬럼
- 비용(`Cost`)은 절대값이 아니라 옵티마이저의 상대 비교 지표

## 실행 순서

1. [01_setup.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/01_setup.sql)
2. [02_baseline_plan.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/02_baseline_plan.sql)
3. [03_hint_plan_comparison.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/03_hint_plan_comparison.sql)
4. [04_practice.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/04_practice.sql)
5. 필요 시 [99_cleanup.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/99_cleanup.sql)

## SQL Developer 실행 가이드

- `01_setup.sql`은 파일 전체를 `F5`로 실행합니다.
- `02_baseline_plan.sql`도 파일 전체를 `F5`로 실행합니다.
- `03_hint_plan_comparison.sql`도 파일 전체를 `F5`로 실행합니다.
- `04_practice.sql`은 문제를 읽는 파일입니다. 파일 자체를 실행해도 되지만, 실제 실습은 문제에서 요구한 SQL을 별도 워크시트에 복사해 조건을 바꿔가며 실행하는 편이 좋습니다.
- `99_cleanup.sql`은 실습 오브젝트를 지우고 싶을 때만 파일 전체 실행합니다.

## 실습 전제

- 이 실습은 `SCOTT.EMP`가 존재해야 합니다.
- `DBMS_XPLAN.DISPLAY` 조회가 가능해야 합니다.
- 별도 실습 계정으로 실행하는 것을 권장합니다.

## 관찰 포인트

- 왜 `t_x02(deptno, job, no)`가 유리한지 설명할 수 있는가
- `FULL(t)` 힌트가 왜 오히려 손해일 수 있는가
- `Cost` 변화와 액세스 경로 변화를 함께 읽고 있는가

## 실무 확인 포인트

- 통계정보 수집 시점이 최신인가
- 조건 선택도가 실제 데이터 분포와 일치하는가
- 힌트 없이도 좋은 계획이 나오도록 통계와 인덱스 설계가 되어 있는가

## SQLP 시험 포인트

- 복합 인덱스는 선두 컬럼 사용 여부가 중요합니다.
- 인덱스가 존재한다고 해서 항상 인덱스 경로가 정답은 아닙니다.
- `Cost`가 낮아도 비즈니스 조건과 실제 데이터량을 같이 보아야 합니다.

## 실행 예시

1. SQL Developer에서 [01_setup.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/01_setup.sql) 파일을 연다.
2. `F5`로 파일 전체를 실행한다.
3. 이어서 [02_baseline_plan.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/02_baseline_plan.sql) 파일 전체를 실행한다.
4. 출력된 `DBMS_XPLAN.DISPLAY` 결과에서 액세스 경로와 Predicate Information을 본다.
5. [03_hint_plan_comparison.sql](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/03_hint_plan_comparison.sql) 파일 전체를 실행해 힌트별 차이를 비교한다.

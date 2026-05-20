# 1.1.4 실행계획과 비용

같은 SQL이라도 왜 옵티마이저가 다른 액세스 경로를 선택하는지 이해하는 실습입니다.

## 학습 목표

- `TABLE ACCESS FULL`, `INDEX RANGE SCAN`, `TABLE ACCESS BY INDEX ROWID`를 구분한다.
- 비용(`Cost`)이 옵티마이저의 상대 비교값이라는 점을 이해한다.
- 인덱스 컬럼 순서와 조건절 구성이 접근 경로 선택에 어떤 영향을 주는지 확인한다.

## 실습 전제

- `SCOTT.EMP`가 존재해야 합니다.
- `DBMS_XPLAN.DISPLAY` 조회가 가능해야 합니다.
- 가능하면 `SYSTEM` 대신 별도 실습 계정을 사용합니다.

## SQL Developer 실행 가이드

1. [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/01_setup.sql) 파일을 열고 `F5`로 전체 실행합니다.
2. [sql/02_baseline_plan.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/02_baseline_plan.sql) 파일을 열고 `F5`로 전체 실행합니다.
3. [sql/03_hint_plan_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/03_hint_plan_comparison.sql) 파일을 열고 `F5`로 전체 실행합니다.
4. [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/04_practice.sql)의 문제를 읽고, 예시 SQL을 별도 워크시트에 복사해 직접 바꿔가며 실행합니다.
5. 필요하면 [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/99_cleanup.sql)을 `F5`로 실행해 정리합니다.

## 실습 파일 구성

- [sql/01_setup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/01_setup.sql)
  - 테스트 테이블 `T`, 인덱스 `T_X01`, `T_X02`, 통계정보 준비
- [sql/02_baseline_plan.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/02_baseline_plan.sql)
  - 힌트 없이 기준 실행계획 확인
- [sql/03_hint_plan_comparison.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/03_hint_plan_comparison.sql)
  - `INDEX(t t_x02)`, `INDEX(t t_x01)`, `FULL(t)` 비교
- [sql/04_practice.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/04_practice.sql)
  - 직접 해보는 문제
- [sql/99_cleanup.sql](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/sql/99_cleanup.sql)
  - 정리용

## 관찰 포인트

- 왜 `t_x02(deptno, job, no)`가 `t_x01(deptno, no)`보다 더 유리할 수 있는가
- `FULL(t)` 힌트가 왜 손해일 수 있는가
- `Cost` 변화와 액세스 경로 변화를 함께 읽고 있는가

## SQLP 시험 포인트

- 복합 인덱스는 선두 컬럼 사용 여부가 중요합니다.
- 인덱스가 존재한다고 해서 항상 인덱스 경로가 정답은 아닙니다.
- `Cost`가 낮아도 실제 데이터량과 선택도를 같이 봐야 합니다.

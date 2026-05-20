# SQL Developer 빠른 시작

## 목적

이 저장소의 실습을 가장 쉽게 수행하는 방법은 Oracle SQL Developer에서 SQL 파일을 순서대로 실행하는 것입니다.

## 권장 방식

1. Oracle SQL Developer에서 실습 계정으로 접속합니다.
2. `labs/` 아래 원하는 실습 폴더를 엽니다.
3. `01_setup.sql`부터 순서대로 실행합니다.
4. 각 SQL의 `prompt`와 주석을 읽으며 실행계획을 비교합니다.

## 추천 접속 계정

- 가능하면 `SYSTEM` 대신 별도 실습 계정을 사용합니다.
- 이유는 오브젝트 관리, 권한 통제, 실습 반복성 측면에서 더 안전하기 때문입니다.

## 실습 전 확인

- `DBMS_XPLAN.DISPLAY` 조회 가능 여부
- `PLAN_TABLE` 사용 가능 여부
- 샘플 스키마 또는 실습용 계정 준비 여부

## 실습 중 꼭 볼 것

- `TABLE ACCESS FULL`
- `INDEX RANGE SCAN`
- `TABLE ACCESS BY INDEX ROWID`
- `NESTED LOOPS`
- `HASH JOIN`
- Predicate Information

## SQLP 관점 팁

- 힌트가 먹었는지 여부만 보지 말고, 왜 그 힌트가 유리하거나 불리한지도 설명해봐야 합니다.
- `Cost` 숫자만 외우지 말고 액세스 경로 변화와 조건 선택도를 함께 보아야 합니다.

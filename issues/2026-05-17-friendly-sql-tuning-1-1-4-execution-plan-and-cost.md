# [STUDY] 친절한 SQL 튜닝 1.1.4 실행계획과 비용 실습 정리 및 테스트 경로 확립

## 학습 교재

- [x] 친절한 SQL 튜닝
- [ ] 오라클 성능 고도화 원리와 해법 1
- [ ] 오라클 성능 고도화 원리와 해법 2

## 파트 / 주제

- 파트: 01 SQL 처리과정과 IO
- 주제: 1.1.4 실행계획과 비용

## 목표

- 실행계획 미리보기 관점에서 기본 SQL, `INDEX(t t_x02)` 힌트, `FULL(t)` 힌트의 차이를 비교한다.
- `t_x01(deptno, no)`와 `t_x02(deptno, job, no)`의 차이를 인덱스 내비게이션 관점에서 설명할 수 있게 정리한다.
- SQL*Plus/SQLcl과 PRO-C에서 동일 실습을 재현할 수 있는 구조를 만든다.

## 선행 조건

- 로컬 Docker Oracle 컨테이너가 이미 실행 중이어야 한다.
- 기본 접속값은 `localhost:8521/FREEPDB1`를 사용한다.
- `SCOTT.EMP` 테이블이 존재해야 한다.
- `DBMS_XPLAN` 사용이 가능해야 한다.
- `AUTOTRACE` 사용 시 SQL*Plus 또는 SQLcl 환경이 필요하다.

## 실습 항목

- [x] 테스트 테이블 `t` 생성 SQL 정리
- [x] 인덱스 `t_x01`, `t_x02` 생성 SQL 정리
- [x] `dbms_stats.gather_table_stats(user, 'T')` 반영
- [x] 기본 SQL 실행계획 비교 절차 정리
- [x] `INDEX(t t_x02)` 힌트 실행계획 비교 절차 정리
- [x] `FULL(t)` 힌트 실행계획 비교 절차 정리
- [x] 내비게이션 개념 README 정리
- [x] SQL 스크립트 기반 실행 경로 추가
- [x] PRO-C 예제 파일 보강
- [x] SQL 중심 실습에 맞춰 PRO-C 단일 실행 구조로 정리

## 산출물

- `친절한 SQL 튜닝/01 SQL 처리과정과 IO/1.1.4 실행계획과 비용/README.md`
- `친절한 SQL 튜닝/01 SQL 처리과정과 IO/1.1.4 실행계획과 비용/sql/01_setup.sql`
- `친절한 SQL 튜닝/01 SQL 처리과정과 IO/1.1.4 실행계획과 비용/sql/02_autotrace_tests.sql`
- `친절한 SQL 튜닝/01 SQL 처리과정과 IO/1.1.4 실행계획과 비용/sql/03_explain_plan_tests.sql`
- `친절한 SQL 튜닝/01 SQL 처리과정과 IO/1.1.4 실행계획과 비용/pro-c/plan_test.pc`

## 완료 조건

- [x] README에 개념, 선행 조건, 실행 순서, 막히기 쉬운 포인트가 정리되어 있다.
- [x] SQL*Plus/SQLcl에서 바로 테스트 가능한 SQL 스크립트가 있다.
- [x] PRO-C 파일에 실습 목적과 흐름을 설명하는 주석이 있다.
- [ ] 실제 로컬 Oracle 환경에서 SQL 스크립트 실행 결과를 확인한다.
- [ ] 실제 로컬 Pro*C 환경에서 전처리 및 컴파일 여부를 확인한다.

## 검증 포인트

- 기본 SQL에서 어떤 접근 경로가 선택되는가
- `t_x02` 힌트 시 실제로 `t_x02`가 사용되는가
- `FULL(t)` 힌트 시 `TABLE ACCESS FULL`이 나타나는가
- `t_x02`가 `t_x01`보다 유리한 이유를 선두 컬럼과 내비게이션 관점에서 설명할 수 있는가

## 메모

- 현재 문서와 예제 코드는 작성 완료 상태다.
- 아직 실제 Oracle 로컬 환경에서 SQL 실행/컴파일 검증은 남아 있다.
- GitHub App 권한 부족으로 실제 이슈 생성은 실패했으므로, 이 파일을 이슈 초안으로 사용한다.

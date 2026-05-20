# oracle-sqlp-lab

SQLP, Oracle SQL 튜닝, 실행계획, 성능 분석을 학습하기 위한 Oracle 실습 저장소입니다.

이 저장소는 이제 `C/Pro*C 실행 프로젝트`보다 `SQL Developer에서 바로 열어 실행하는 SQL 실습 저장소`를 기본 모델로 삼습니다.

## 냉정한 현재 진단

- 현재 구조는 SQL 학습 저장소라기보다 C/Pro*C 실행 예제 저장소처럼 보입니다.
- 학습자가 가장 먼저 봐야 할 것은 SQL, 실행계획, 튜닝 포인트인데 실제로는 `run.ps1`, `proc`, 컴파일러, 환경변수가 먼저 등장합니다.
- 각 실습이 무엇을 검증하는지, 왜 그 SQL을 실행하는지, 어떤 실행계획이 기대되는지 설명 밀도가 부족합니다.
- 교재명 중심 폴더 구조는 자료 출처 추적에는 유리하지만, 학습 순서와 실습 재사용성 측면에서는 비효율적입니다.
- SQLP 관점에서 중요한 `실행계획 -> 원인 추정 -> 검증 -> 개선 방향` 흐름이 구조에 녹아 있지 않습니다.

즉, 지금 구조는 "만든 사람은 이해할 수 있지만, 다시 학습하려는 사람은 진입비용이 큰 구조"입니다.

## 이번 개편 방향

- SQL Developer 기준으로 바로 열고 실행할 수 있는 SQL 중심 구조
- 실습마다 `목적`, `핵심 개념`, `실행 순서`, `관찰 포인트`, `해석 포인트` 제공
- 교재 분류보다 학습 주제와 튜닝 주제 중심으로 재배치
- 기존 C/Pro*C 자산은 참고 자료로 남기되, 기본 학습 경로에서는 후순위로 배치

## 추천 학습 시작점

1. [guides/sql-developer-quickstart.md](/C:/oracle-sqlp-lab/guides/sql-developer-quickstart.md)
2. [labs/README.md](/C:/oracle-sqlp-lab/labs/README.md)
3. [labs/01-sql-processing-and-io/01-execution-plan-and-cost/README.md](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/README.md)
4. [labs/01-sql-processing-and-io/02-optimizer-hints/README.md](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/README.md)

## 새 구조

```text
oracle-sqlp-lab/
├─ README.md
├─ guides/
│  └─ sql-developer-quickstart.md
├─ docs/
│  └─ project-review-and-restructure.md
├─ labs/
│  ├─ README.md
│  ├─ 00-template/
│  │  └─ README.md
│  └─ 01-sql-processing-and-io/
│     ├─ 01-execution-plan-and-cost/
│     │  ├─ README.md
│     │  ├─ 01_setup.sql
│     │  ├─ 02_baseline_plan.sql
│     │  ├─ 03_hint_plan_comparison.sql
│     │  ├─ 04_practice.sql
│     │  └─ 99_cleanup.sql
│     └─ 02-optimizer-hints/
│        ├─ README.md
│        ├─ 01_setup.sql
│        ├─ 02_single_table_hints.sql
│        ├─ 03_join_hints.sql
│        └─ 04_practice.sql
├─ common/
├─ templates/
├─ 오라클 성능 고도화 원리와 해법 1/
├─ 오라클 성능 고도화 원리와 해법 2/
└─ 친절한 SQL 튜닝/
```

## 구조 원칙

- `labs/`가 앞으로의 표준 실습 경로입니다.
- 한 실습 폴더는 하나의 학습 질문만 다룹니다.
- SQL 파일은 실행 순서가 보이도록 번호를 붙입니다.
- 각 SQL 파일 상단에는 목적과 관찰 포인트를 주석으로 남깁니다.
- README는 실행 방법보다 "왜 이 실습을 하는지"를 먼저 설명합니다.
- `common/`, `templates/`, 기존 교재 폴더는 참고 자료이자 이전 자산으로 유지합니다.

## 실습 운영 방식

- 기본 도구는 Oracle SQL Developer를 가정합니다.
- 필요 시 SQL*Plus에서도 실행할 수 있게 스크립트를 단순 SQL 형태로 유지합니다.
- 실습은 가능하면 아래 순서를 따릅니다.

1. `01_setup.sql`
2. 기준 실행계획 확인
3. 조건 변경 또는 힌트 적용
4. `DBMS_XPLAN.DISPLAY` 결과 비교
5. 왜 달라졌는지 해석
6. 실무에서 어떤 통계와 세션 정보를 더 볼지 정리

## DBA / SQLP 관점 학습 기준

- `Cost`만 보고 판단하지 않습니다.
- 액세스 경로와 조인 방식이 바뀐 이유를 설명할 수 있어야 합니다.
- 인덱스가 있다고 해서 항상 빠른 것이 아닙니다.
- 힌트는 정답이 아니라 실행 방향을 제어하는 도구입니다.
- 시험에서는 "주어진 조건에서 옵티마이저가 왜 그렇게 판단했는가"를 읽는 능력이 중요합니다.

## 참고 문서

- 개편 배경과 상세 피드백: [docs/project-review-and-restructure.md](/C:/oracle-sqlp-lab/docs/project-review-and-restructure.md)
- SQL Developer 시작 가이드: [guides/sql-developer-quickstart.md](/C:/oracle-sqlp-lab/guides/sql-developer-quickstart.md)
- 새 실습 표준: [labs/README.md](/C:/oracle-sqlp-lab/labs/README.md)
- SQL 우선 학습 원칙: [docs/why-sql-first.md](/C:/oracle-sqlp-lab/docs/why-sql-first.md)
- 출처 폴더 매핑: [docs/source-to-labs-mapping.md](/C:/oracle-sqlp-lab/docs/source-to-labs-mapping.md)

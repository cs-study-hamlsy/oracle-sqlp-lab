# oracle-sqlp-lab

SQLP, Oracle SQL 튜닝, 실행계획, 성능 분석을 학습하기 위한 Oracle 실습 저장소입니다.

이 저장소는 `교재 > 파트 > 주제` 맥락을 유지한 상태에서, SQL Developer로 바로 실행 가능한 SQL 실습을 기본 모델로 삼습니다.

## 핵심 원칙

- 실습의 정체성은 교재에 있습니다.
- 새 실습은 반드시 해당 교재의 파트/주제 폴더 안에 둡니다.
- 기본 실습 방식은 C/Pro*C가 아니라 SQL-only 입니다.
- 각 주제 폴더에서는 `README.md`와 `sql/` 디렉터리를 표준으로 사용합니다.

## 추천 학습 시작점

1. [guides/sql-developer-quickstart.md](/C:/oracle-sqlp-lab/guides/sql-developer-quickstart.md)
2. [친절한 SQL 튜닝/README.md](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/README.md)
3. [친절한 SQL 튜닝/01 SQL 처리과정과 IO/1.1.4 실행계획과 비용/README.md](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/README.md)
4. [친절한 SQL 튜닝/01 SQL 처리과정과 IO/1.1.5 옵티마이저 힌트/README.md](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.5%20옵티마이저%20힌트/README.md)

## 권장 구조

```text
oracle-sqlp-lab/
├─ README.md
├─ guides/
│  └─ sql-developer-quickstart.md
├─ docs/
│  ├─ project-review-and-restructure.md
│  └─ why-sql-first.md
├─ templates/
│  └─ topic-template/
├─ common/
├─ 친절한 SQL 튜닝/
│  └─ 01 SQL 처리과정과 IO/
│     ├─ 1.1.4 실행계획과 비용/
│     │  ├─ README.md
│     │  └─ sql/
│     └─ 1.1.5 옵티마이저 힌트/
│        ├─ README.md
│        └─ sql/
├─ 오라클 성능 고도화 원리와 해법 1/
└─ 오라클 성능 고도화 원리와 해법 2/
```

## 주제 폴더 표준

```text
교재 폴더/
└─ 파트 폴더/
   └─ 주제 폴더/
      ├─ README.md
      └─ sql/
         ├─ 01_setup.sql
         ├─ 02_baseline.sql
         ├─ 03_comparison.sql
         ├─ 04_practice.sql
         ├─ 05_answer.sql
         └─ 99_cleanup.sql
```

## 학습 운영 방식

- `sql/01_setup.sql`부터 번호 순서대로 실행합니다.
- `01_`, `02_`, `03_`, `05_`, `99_` 파일은 SQL Developer에서 `F5`로 파일 전체 실행하는 것을 권장합니다.
- `04_practice.sql`은 문제를 읽고 예시 SQL을 복사해 직접 바꿔가며 먼저 풀어봅니다.
- `05_answer.sql`은 `04_practice.sql`을 풀어본 뒤 정답 SQL과 실행계획 차이를 비교하는 해설용 스크립트입니다.
- README는 개념과 해석 가이드, SQL 파일은 실행 가능한 실습 노트 역할을 합니다.

## DBA / SQLP 관점 기준

- `Cost`만 보고 판단하지 않습니다.
- 액세스 경로와 조인 방식이 바뀐 이유를 설명할 수 있어야 합니다.
- 인덱스가 있다고 해서 항상 빠른 것이 아닙니다.
- 힌트는 정답이 아니라 실행 방향을 제어하는 도구입니다.
- 시험에서는 "왜 그 실행계획이 선택됐는가"를 읽는 능력이 중요합니다.

## 참고 문서

- SQL Developer 시작 가이드: [guides/sql-developer-quickstart.md](/C:/oracle-sqlp-lab/guides/sql-developer-quickstart.md)
- SQL 우선 학습 원칙: [docs/why-sql-first.md](/C:/oracle-sqlp-lab/docs/why-sql-first.md)
- 개편 배경 메모: [docs/project-review-and-restructure.md](/C:/oracle-sqlp-lab/docs/project-review-and-restructure.md)

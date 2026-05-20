# Labs

이 디렉터리는 앞으로의 표준 학습 경로입니다.

## 설계 원칙

- 교재명보다 주제 중심으로 분류합니다.
- 한 폴더는 한 개의 학습 질문을 다룹니다.
- SQL Developer에서 바로 실행할 수 있어야 합니다.
- 각 실습은 `준비 -> 기준 관찰 -> 비교 -> 연습` 순서를 따릅니다.

## 현재 제공 실습

- [01-sql-processing-and-io/01-execution-plan-and-cost/README.md](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/01-execution-plan-and-cost/README.md)
- [01-sql-processing-and-io/02-optimizer-hints/README.md](/C:/oracle-sqlp-lab/labs/01-sql-processing-and-io/02-optimizer-hints/README.md)

## 파일 번호 규칙

- `01_`: 실습 환경 준비
- `02_`: 기준 SQL 또는 기본 실행계획
- `03_`: 비교 실험
- `04_`: 직접 해보는 연습
- `99_`: 정리 또는 cleanup

## 문서 작성 규칙

- README는 설명서이고, SQL 파일은 실행 가능한 실습 노트입니다.
- SQL 파일 상단 주석에는 반드시 목적과 체크 포인트를 남깁니다.
- 성능 주제는 가능하면 `실행계획 -> 예상 원인 -> 검증 방법 -> 개선 방향` 순서로 씁니다.
- 새 실습을 만들 때는 [templates/topic-template/README.md](/C:/oracle-sqlp-lab/templates/topic-template/README.md)와 같은 SQL 중심 템플릿을 따른다.

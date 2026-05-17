# oracle-sqlp-lab

SQLP 자격증 준비를 위한 Oracle 실습 저장소입니다.

C, PRO-C, ORACLE을 중심으로 실습하고, 교재별 파트/주제 단위로 학습 내용을 정리합니다.

## 목표

- SQLP 대비를 위한 Oracle 성능, 튜닝, SQL 실습 기록
- C / PRO-C 기반의 Oracle 연동 예제 축적
- 교재별 학습 흐름과 실습 결과를 구조적으로 관리

## 기술 스택

- C
- PRO-C
- ORACLE

## 학습 순서

1. 친절한 SQL 튜닝
2. 오라클 성능 고도화 원리와 해법 1
3. 오라클 성능 고도화 원리와 해법 2

## 저장소 구조

```text
oracle-sqlp-lab/
├─ .github/
│  ├─ ISSUE_TEMPLATE/
│  │  ├─ config.yml
│  │  └─ study-task.md
│  └─ pull_request_template.md
├─ templates/
│  └─ topic-template/
│     ├─ README.md
│     ├─ c/
│     │  └─ .gitkeep
│     └─ pro-c/
│        └─ .gitkeep
├─ 친절한 SQL 튜닝/
│  └─ README.md
├─ 오라클 성능 고도화 원리와 해법 1/
│  └─ README.md
├─ 오라클 성능 고도화 원리와 해법 2/
│  └─ README.md
└─ .gitignore
```

## 학습 단위 운영 방식

루트에는 교재 폴더를 두고, 각 교재 안에서 파트와 주제를 나눠 학습합니다.

예시:

```text
친절한 SQL 튜닝/
└─ 01-파트명/
   └─ 01-주제명/
      ├─ README.md
      ├─ c/
      │  └─ example.c
      └─ pro-c/
         └─ example.pc
```

## 작성 규칙

- 교재 폴더명은 실제 교재명을 그대로 사용합니다.
- 파트/주제 폴더는 `01-이름`, `02-이름` 형식으로 정렬 가능하게 작성합니다.
- 각 주제 폴더에는 최소한 다음을 둡니다.
  - `README.md`: 학습 내용, 실행 방법, 트러블슈팅, 참고 사항
  - `c/`: C 실습 코드
  - `pro-c/`: PRO-C 실습 코드

## 실습 기록 권장 항목

주제별 `README.md`에는 아래 내용을 권장합니다.

- 학습 목표
- 핵심 개념
- 실습 환경
- 실행 방법
- 결과 및 관찰 내용
- 문제 해결 기록
- 추가로 확인할 내용

## 템플릿 사용 방법

새 주제를 만들 때는 [templates/topic-template/README.md](/C:/oracle-sqlp-lab/templates/topic-template/README.md)를 기준으로 복사해서 사용하면 됩니다.

예시:

1. 교재 폴더 안에 파트 폴더 생성
2. 파트 폴더 안에 주제 폴더 생성
3. `templates/topic-template` 구조를 주제 폴더에 맞게 복사
4. `README.md`, `c/`, `pro-c/`를 채우며 학습 진행

## 브랜치 / 협업 메모

- 이슈 단위로 학습 목표를 관리합니다.
- PR에는 무엇을 학습했고 어떤 실습을 추가했는지 기록합니다.
- 작은 단위로 자주 커밋해 학습 흐름을 남깁니다.

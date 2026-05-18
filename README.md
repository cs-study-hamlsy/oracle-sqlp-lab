# oracle-sqlp-lab

SQLP 자격증 준비를 위한 Oracle 실습 저장소입니다.

C, PRO-C, ORACLE을 중심으로 실습하고, 교재별 파트/주제 단위로 학습 내용을 정리합니다.

실습용 Oracle DB는 로컬 컴퓨터에서 이미 실행 중인 Docker 컨테이너에 접속하는 것을 기본 전제로 합니다.

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
├─ common/
│  ├─ README.md
│  ├─ oracle.env
│  ├─ include/
│  │  └─ oracle_db_config.h
│  ├─ scripts/
│  │  ├─ Import-OracleEnv.ps1
│  │  └─ Invoke-WithOracleEnv.ps1
│  ├─ c/
│  │  ├─ oci_connect.c
│  │  └─ oci_connect.h
│  └─ pro-c/
│     └─ proc_connect.pc
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

## 공통 Oracle 연결 코드

- 프로젝트 공통 연결 샘플은 [common/README.md](/C:/oracle-sqlp-lab/common/README.md)에 정리했습니다.
- C는 OCI 예제를 기준으로 연결합니다.
- PRO-C는 `EXEC SQL CONNECT` 예제를 기준으로 연결합니다.
- 계정 정보는 `common/oracle.env`에서 공통 관리하고, 각 실행 스크립트가 이를 로드합니다.
- Oracle DB는 로컬에서 이미 실행 중인 Docker 컨테이너에 접속하는 것을 기본으로 합니다.

사용 환경변수:

- `ORACLE_USER`
- `ORACLE_PASSWORD`
- `ORACLE_CONNECT_STRING`

예시 값:

- `ORACLE_USER=system`
- `ORACLE_PASSWORD=oracle`
- `ORACLE_CONNECT_STRING=localhost:8521/FREEPDB1`

권장 실행 흐름:

1. 각 주제 폴더의 `run.ps1` 또는 개별 실행 스크립트에서 `common/scripts/Import-OracleEnv.ps1`를 호출합니다.
2. 그 다음 해당 폴더의 Pro*C 또는 C 실행 파일을 실행합니다.
3. 프로그램 내부에서 `CONNECT`가 수행됩니다.

## VS Code 실행 방식

- 기본 실행 단위는 개별 `.pc` 파일이 아니라 주제 폴더의 `run.ps1`입니다.
- PRO-C 주제는 `run.ps1`에서 `proc -> C 컴파일 -> exe 실행`까지 한 번에 처리합니다.
- VS Code에서는 파일을 연 상태에서 `Ctrl + Shift + B`를 누르면 가장 가까운 상위 폴더의 `run.ps1`를 찾아 실행합니다.
- 루트 [.vscode/tasks.json](/C:/oracle-sqlp-lab/.vscode/tasks.json)에 이 동작이 등록되어 있습니다.
- 주제별로 컴파일 옵션이 다르면 해당 주제의 `run.ps1`에서만 조정합니다.

## 로컬 Docker Oracle 운영 전제

- Oracle DB 컨테이너는 이 저장소 바깥에서 이미 실행 중이라고 가정합니다.
- 애플리케이션 및 실습 코드는 `localhost` 기준으로 접속합니다.
- 포트, 서비스명, 계정은 사용하는 이미지 설정에 맞춰 주제별 README에 기록합니다.
- 현재 접속 기준 정보는 아래와 같습니다.

- 컨테이너 이름: `oracle-23ai-free`
- 호스트: `localhost`
- 포트: `8521`
- 서비스명: `FREEPDB1`
- 초기 계정 예시: `system`
- 초기 비밀번호: `oracle`

예시:

- 호스트: `localhost`
- 포트: `8521`
- 서비스명: `FREEPDB1`
- 초기 계정 예시: `system`
- 초기 비밀번호: `oracle`

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

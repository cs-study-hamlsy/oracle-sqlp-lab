# Oracle 공통 연결 가이드

프로젝트 전체에서 재사용할 Oracle DB 연결 예제를 모아둔 디렉터리입니다.

기본 전제는 로컬 컴퓨터에서 이미 실행 중인 Docker Oracle DB 컨테이너에 각 실습 코드가 접속하는 방식입니다.

## 구성

```text
common/
├─ README.md
├─ oracle.env
├─ include/
│  └─ oracle_db_config.h
├─ scripts/
│  ├─ Import-OracleEnv.ps1
│  └─ Invoke-WithOracleEnv.ps1
├─ c/
│  ├─ oci_connect.c
│  └─ oci_connect.h
└─ pro-c/
   └─ proc_connect.pc
```

## 목적

- 교재별 실습에서 반복되는 Oracle 연결 코드를 공통화
- 계정 정보 하드코딩 방지
- C / PRO-C 연결 방식의 기본 골격 통일

## 공통 연결 방식

- DB 접속 정보는 `common/oracle.env` 한 곳에서 관리합니다.
- 각 실습 폴더의 실행 스크립트는 `common/scripts/Import-OracleEnv.ps1`를 먼저 호출해 환경변수를 로드합니다.
- 실제 Oracle 세션 연결은 각 C / PRO-C 프로그램이 실행되면서 내부에서 수행합니다.
- 즉, "미리 외부에서 DB 세션을 열어두는 방식"이 아니라 "실행 전에 env를 준비하고, 프로그램 안에서 CONNECT 하는 방식"입니다.

## 환경변수

아래 환경변수를 사용합니다.

```powershell
$env:ORACLE_USER="system"
$env:ORACLE_PASSWORD="oracle"
$env:ORACLE_CONNECT_STRING="localhost:8521/FREEPDB1"
```

`common/oracle.env` 기본값도 동일하게 `localhost:8521/FREEPDB1`를 사용합니다.

Docker 기반 로컬 접속 기준 예시입니다.

설정 확인 예시:

```powershell
echo $env:ORACLE_USER
echo $env:ORACLE_CONNECT_STRING
```

## PowerShell 공통 로더

현재 프로젝트 기본 실행 방식은 PowerShell 기준입니다.

실습 폴더의 실행 파일에서는 아래 둘 중 하나를 사용하면 됩니다.

1. 현재 셸에 env만 로드

```powershell
& "C:\oracle-sqlp-lab\common\scripts\Import-OracleEnv.ps1"
```

2. env를 로드한 뒤 바로 프로그램 실행

```powershell
& "C:\oracle-sqlp-lab\common\scripts\Invoke-WithOracleEnv.ps1" -ExecutablePath .\proc_plan_test.exe
```

주제 폴더 안에 `run.ps1` 같은 실행 스크립트를 둘 경우, 그 스크립트 안에서 `Import-OracleEnv.ps1`를 먼저 호출하는 패턴을 권장합니다.

## C 연결 방식

- `common/c/oci_connect.c`는 OCI 기반 연결 샘플입니다.
- Oracle Client / Instant Client와 OCI 헤더 및 라이브러리가 필요합니다.
- 교재별 C 실습에서 공통 함수로 복사하거나 include해서 사용할 수 있습니다.
- 접속 대상은 로컬에서 이미 실행 중인 Docker Oracle 컨테이너입니다.

## PRO-C 연결 방식

- `common/pro-c/proc_connect.pc`는 PRO-C 연결 샘플입니다.
- `EXEC SQL CONNECT`와 `sqlca` 상태 확인 흐름을 포함합니다.
- 교재별 PRO-C 실습의 시작점으로 사용하면 됩니다.
- 접속 대상은 로컬에서 이미 실행 중인 Docker Oracle 컨테이너입니다.

## Docker 운영 메모

- 현재 프로젝트 기본 포트 매핑은 `8521:1521`입니다.
- 실습 코드에서는 컨테이너 이름보다 `localhost` 접속을 우선 사용합니다.
- 이 저장소는 Docker 컨테이너를 직접 생성하거나 관리하지 않습니다.
- 이미지별 기본 서비스명 또는 SID가 다를 수 있으므로 실제 값은 주제 README에 함께 기록하는 것을 권장합니다.
- 현재 샘플 기본값은 `localhost:8521/FREEPDB1`입니다.
- Oracle Free 기본 서비스는 `FREE`와 `FREEPDB1`이며, 실습용 기본 연결은 `FREEPDB1`를 사용합니다.
- `ORACLE_PWD=oracle`로 컨테이너를 생성했으므로 초기 비밀번호 예시는 `oracle`입니다.

## 사용 권장 방식

1. 공통 예제를 먼저 확인합니다.
2. 주제 폴더의 실행 스크립트에서 `common/scripts/Import-OracleEnv.ps1`를 먼저 호출합니다.
3. 주제 폴더의 `c/` 또는 `pro-c/`로 복사해 실습 목적에 맞게 수정합니다.
4. 주제별 `README.md`에 실행 방법, 결과, 특이한 접속 조건을 기록합니다.

## 주의 사항

- 계정/비밀번호를 소스코드에 직접 하드코딩하지 않습니다.
- 실제 접속 정보는 환경변수 또는 로컬 개발 환경 설정으로 관리합니다.
- Oracle Client 설치 경로와 라이브러리 링크 옵션은 환경에 따라 달라질 수 있습니다.
- Docker 컨테이너 기동 옵션, 계정 생성 방식, 초기 데이터 구성은 사용하는 Oracle 이미지에 따라 달라질 수 있습니다.

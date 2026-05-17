# Oracle 공통 연결 가이드

프로젝트 전체에서 재사용할 Oracle DB 연결 예제를 모아둔 디렉터리입니다.

기본 전제는 로컬 컴퓨터에서 Docker로 Oracle DB를 띄우고, 각 실습 코드가 그 컨테이너로 접속하는 방식입니다.

## 구성

```text
common/
├─ README.md
├─ include/
│  └─ oracle_db_config.h
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

## 환경변수

아래 환경변수를 사용합니다.

```powershell
$env:ORACLE_USER="scott"
$env:ORACLE_PASSWORD="tiger"
$env:ORACLE_CONNECT_STRING="localhost:1521/XEPDB1"
```

Docker 기반 로컬 접속 기준 예시입니다.

설정 확인 예시:

```powershell
echo $env:ORACLE_USER
echo $env:ORACLE_CONNECT_STRING
```

## C 연결 방식

- `common/c/oci_connect.c`는 OCI 기반 연결 샘플입니다.
- Oracle Client / Instant Client와 OCI 헤더 및 라이브러리가 필요합니다.
- 교재별 C 실습에서 공통 함수로 복사하거나 include해서 사용할 수 있습니다.
- 접속 대상은 로컬 Docker Oracle 컨테이너를 기준으로 합니다.

## PRO-C 연결 방식

- `common/pro-c/proc_connect.pc`는 PRO-C 연결 샘플입니다.
- `EXEC SQL CONNECT`와 `sqlca` 상태 확인 흐름을 포함합니다.
- 교재별 PRO-C 실습의 시작점으로 사용하면 됩니다.
- 접속 대상은 로컬 Docker Oracle 컨테이너를 기준으로 합니다.

## Docker 운영 메모

- 컨테이너 포트는 일반적으로 `1521:1521` 형태로 매핑합니다.
- 실습 코드에서는 컨테이너 이름보다 `localhost` 접속을 우선 사용합니다.
- 이미지별 기본 서비스명 또는 SID가 다를 수 있으므로 실제 값은 주제 README에 함께 기록하는 것을 권장합니다.
- 샘플 기본값은 `localhost:1521/XEPDB1`입니다.

## 사용 권장 방식

1. 공통 예제를 먼저 확인합니다.
2. 주제 폴더의 `c/` 또는 `pro-c/`로 복사해 실습 목적에 맞게 수정합니다.
3. 주제별 `README.md`에 접속 정보 형식, 실행 방법, 결과를 기록합니다.

## 주의 사항

- 계정/비밀번호를 소스코드에 직접 하드코딩하지 않습니다.
- 실제 접속 정보는 환경변수 또는 로컬 개발 환경 설정으로 관리합니다.
- Oracle Client 설치 경로와 라이브러리 링크 옵션은 환경에 따라 달라질 수 있습니다.
- Docker 컨테이너 기동 옵션, 계정 생성 방식, 초기 데이터 구성은 사용하는 Oracle 이미지에 따라 달라질 수 있습니다.

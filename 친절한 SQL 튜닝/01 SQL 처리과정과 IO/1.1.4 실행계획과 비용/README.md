# 1.1.4 실행계획과 비용

이 파트는 실행계획을 "미리보기" 하면서, 같은 SQL이라도 옵티마이저가 어떤 접근 경로를 선택하는지 비교하는 실습이다.

이번 실습의 핵심 질문은 아래 세 가지다.

- 기본 SQL에서는 `T` 테이블을 어떻게 읽는가
- `INDEX(t t_x02)` 힌트를 주면 `t_x02` 인덱스를 타는가
- `FULL(t)` 힌트를 주면 풀 테이블 스캔으로 바뀌는가

실습은 `SCOTT.EMP`를 1000배 확장한 `T` 테이블을 만들고, 두 개의 복합 인덱스를 만든 뒤, 실행계획과 비용을 비교하는 방식으로 진행한다.

## 학습 목표

- 실행계획에서 `TABLE ACCESS FULL`, `INDEX RANGE SCAN`, `TABLE ACCESS BY INDEX ROWID`를 구분한다.
- 비용(`Cost`)이 옵티마이저의 예상값이라는 점을 이해한다.
- 인덱스 컬럼 순서와 조건절 구성이 접근 경로 선택에 어떤 영향을 주는지 확인한다.
- 내비게이션 관점에서 "어떤 길로 데이터를 찾아가는가"를 읽을 수 있다.

## 선행 조건

이 실습은 아래 전제를 만족해야 한다.

- Oracle DB는 로컬에서 이미 실행 중인 Docker 컨테이너에 떠 있어야 한다.
- 기본 접속 예시는 `localhost:8521/FREEPDB1`이다.
- `ORACLE_USER`, `ORACLE_PASSWORD`, `ORACLE_CONNECT_STRING` 환경변수가 설정되어 있어야 한다.
- `SCOTT.EMP` 테이블이 존재해야 한다.
- `DBMS_XPLAN` 사용이 가능해야 한다.

권장 환경변수 예시:

```powershell
$env:ORACLE_USER="system"
$env:ORACLE_PASSWORD="oracle"
$env:ORACLE_CONNECT_STRING="localhost:8521/FREEPDB1"
```

다만 실제 실습은 `SYSTEM`보다 별도 실습 계정에서 진행하는 편이 안전하다. 이 README에서는 저장소의 기본 공통 설정값에 맞춰 설명하지만, 가능하면 `sqlp_lab` 같은 전용 계정을 따로 만들어 사용하는 것을 권장한다.

## 실습 대상 SQL

### 1. 테스트 테이블 생성

```sql
create table t
as
select d.no, e.*
from scott.emp e,
     (select rownum no from dual connect by level <= 1000) d;
```

의도:

- `SCOTT.EMP`의 데이터 패턴은 유지하면서 로우 수만 크게 늘린다.
- 로우 수가 늘어나야 풀 스캔과 인덱스 스캔의 차이를 관찰하기 쉽다.

### 2. 인덱스 생성

```sql
create index t_x01 on t(deptno, no);
create index t_x02 on t(deptno, job, no);
```

의도:

- `t_x01`은 `deptno, no`만 가진다.
- `t_x02`는 `deptno, job, no`를 모두 포함한다.
- 현재 테스트 SQL은 `deptno =`, `job =`, `no between` 조건을 함께 사용하므로, `t_x02`가 더 유리한 후보가 될 가능성이 높다.

### 3. 통계정보 수집

```sql
exec dbms_stats.gather_table_stats(user, 'T');
```

의도:

- 옵티마이저가 최신 통계정보를 기준으로 비용을 계산하도록 한다.
- 통계가 없거나 오래되면 실행계획 비교가 왜곡될 수 있다.

## 실행계획 비교 대상

### 기본 SQL

```sql
select *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;
```

확인 포인트:

- 힌트 없이도 `t_x02`가 선택되는가
- `INDEX RANGE SCAN`이 나오는가
- 인덱스 후 테이블 재방문이 일어나는가

### `t_x02` 힌트 SQL

```sql
select /*+ index(t t_x02) */ *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;
```

확인 포인트:

- `t_x02` 인덱스가 강제로 선택되는가
- 기본 SQL과 비교했을 때 비용이나 Predicate Information이 달라지는가

### `FULL` 힌트 SQL

```sql
select /*+ full(t) */ *
from t
where deptno = 10
and job = 'MANAGER'
and no between 1 and 100;
```

확인 포인트:

- `TABLE ACCESS FULL`이 나오는가
- 인덱스를 탈 때보다 비용이 높아지는가
- 조건 선택도가 낮지 않은 상황에서 왜 풀 스캔이 비효율적일 수 있는지 해석할 수 있는가

## 내비게이션 개념

이 파트에서 말하는 내비게이션은 "조건에 맞는 데이터를 Oracle이 어떤 경로로 찾아가는가"에 대한 개념이다.

- 풀 테이블 스캔은 처음 블록부터 끝 블록까지 넓게 읽는다.
- 인덱스 스캔은 인덱스 트리를 따라 필요한 범위를 먼저 좁힌다.
- 복합 인덱스에서는 선두 컬럼부터 조건이 잘 맞아야 효율적인 내비게이션이 가능하다.

이번 실습에서는 `deptno`, `job`, `no`를 모두 조건으로 사용한다.

따라서 `t_x02(deptno, job, no)`는:

- `deptno = 10`
- `job = 'MANAGER'`
- `no between 1 and 100`

순서로 조건을 잘 태울 수 있어, `t_x01(deptno, no)`보다 더 정교한 내비게이션이 가능할 수 있다.

반면 `FULL(t)` 힌트는 이 내비게이션을 포기하고, 테이블 전체를 모두 읽은 뒤 조건을 적용하라고 강제하는 방식이다.

## 테스트 절차

이 주제는 SQL 스크립트와 PRO-C를 따로 나누지 않고, [pro-c/plan_test.pc](/C:/oracle-sqlp-lab/친절한%20SQL%20튜닝/01%20SQL%20처리과정과%20IO/1.1.4%20실행계획과%20비용/pro-c/plan_test.pc) 하나에 실습용 쿼리를 직접 넣어 진행한다.

즉, 저장소에서 사람이 관리하는 실행 소스는 `plan_test.pc` 하나이고, `proc`가 만들어내는 `plan_test.c`는 빌드 과정에서만 생기는 산출물이다.

`plan_test.pc` 안에는 아래 SQL이 모두 포함되어 있다.

- 테스트 테이블 `T` 생성 SQL
- 인덱스 `T_X01`, `T_X02` 생성 SQL
- `DBMS_STATS.GATHER_TABLE_STATS` 호출
- 기본 SQL, `INDEX(t t_x02)` 힌트 SQL, `FULL(t)` 힌트 SQL
- `EXPLAIN PLAN`과 `DBMS_XPLAN.DISPLAY` 조회 로직

### PRO-C 실행 방식

전제:

- Oracle Pro*C 설치
- `proc` 전처리 가능
- C 컴파일러와 Oracle 라이브러리 연동 가능
- 전처리 결과로 생성된 C 파일을 컴파일할 수 있어야 함

예시 흐름:

```bash
proc iname=pro-c/plan_test.pc
gcc -I%ORACLE_HOME%/precomp/public pro-c/plan_test.c -o proc_plan_test.exe
```

실행:

```bash
proc_plan_test.exe
```

운영체제, Oracle Client 설치 경로, 컴파일러에 따라 실제 옵션은 달라질 수 있다. 따라서 이 README의 목적은 "어떤 순서로 실행하는가"를 안내하는 것이고, 링크 옵션은 로컬 환경에 맞게 조정해야 한다.

정리하면 이 파트는 "PRO-C 하나를 작성하고, 그 안에 실습 SQL을 직접 넣은 뒤, C로 전처리하고 컴파일해서 실행"하는 구조다. 따라서 SQL 파일과 PRO-C 파일을 별도로 나누어 운영하지 않는다.

## 점검 체크리스트

실습 후 아래를 스스로 설명할 수 있어야 한다.

- 기본 SQL에서 어떤 인덱스 또는 접근 경로가 선택되었는가
- `t_x02` 힌트는 실제로 `t_x02`를 사용하게 만들었는가
- `FULL(t)` 힌트는 어떤 연산으로 바뀌었는가
- `t_x01`보다 `t_x02`가 더 유리한 이유는 무엇인가
- 이번 예제에서 내비게이션이 좋다는 말은 정확히 무엇을 뜻하는가

## 막히기 쉬운 포인트

- `SCOTT.EMP`가 없으면 테이블 생성이 실패한다.
- `PLAN_TABLE` 또는 `DBMS_XPLAN` 환경이 없으면 실행계획 조회가 실패할 수 있다.
- `SYSTEM` 계정으로 실습하면 오브젝트 관리가 지저분해질 수 있으므로 전용 실습 계정이 더 적합하다.

## 추천 실행 순서

1. `ORACLE_USER`, `ORACLE_PASSWORD`, `ORACLE_CONNECT_STRING` 환경변수를 설정한다.
2. `proc iname=pro-c/plan_test.pc`로 PRO-C를 전처리한다.
3. 생성된 `plan_test.c`를 컴파일해 실행 파일을 만든다.
4. 실행 파일을 돌려 테이블 생성, 통계정보 수집, 실행계획 비교를 한 번에 확인한다.

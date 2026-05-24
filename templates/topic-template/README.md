# 주제명

## 학습 목표

- 

## 교재 내용 정리

- 이 챕터가 다루는 핵심 메시지를 자세히 정리한다.
- 단순 요약이 아니라, 복습할 때 이 README만 읽어도 핵심을 다시 떠올릴 수 있게 작성한다.

## 상세 개념 정리

### 1. 개념 1

- 

### 2. 개념 2

- 

## Oracle 내부 동작 원리

- 왜 이런 현상이 발생하는지 Oracle 처리 과정 관점에서 설명한다.
- 필요하면 파싱, 옵티마이저 판단, 액세스 경로, 조인 방식, 통계정보, I/O 관점으로 나눈다.

## 실무 관점 해석

- 운영 환경에서는 무엇을 추가로 확인해야 하는지 적는다.
- 관련 뷰, 실행계획, 통계정보, 인덱스 설계, 세션/트랜잭션 관점 포인트를 적는다.

## SQLP 시험 포인트

- 시험에서 자주 헷갈리는 판단 기준
- 보기에서 구분해야 하는 포인트
- 실무와 시험의 관점 차이

## 실습 목적

- 

## 실습 파일 구성

- `sql/01_setup.sql`
- `sql/02_baseline.sql`
- `sql/03_comparison.sql`
- `sql/04_practice.sql`
- `sql/05_answer.sql`
- 필요 시 `sql/99_cleanup.sql`

## 실행 순서

1. `sql/01_setup.sql`
2. `sql/02_baseline.sql`
3. `sql/03_comparison.sql`
4. `sql/04_practice.sql`
5. `sql/05_answer.sql`
6. 필요 시 `sql/99_cleanup.sql`

## 디렉터리 구성

```text
.
├─ README.md
└─ sql/
   ├─ 01_setup.sql
   ├─ 02_baseline.sql
   ├─ 03_comparison.sql
   ├─ 04_practice.sql
   ├─ 05_answer.sql
   └─ 99_cleanup.sql
```

## 실습 환경

- Oracle SQL Developer 또는 SQL*Plus
- 실습 계정:
- 필요 권한:
- 전제 오브젝트:

## SQL Developer 실행 가이드

- `sql/01_setup.sql`, `sql/02_*.sql`, `sql/03_*.sql`, `sql/05_answer.sql`, `sql/99_cleanup.sql`은 보통 `F5`로 파일 전체 실행한다.
- `sql/04_practice.sql`은 문제 안내용이므로, 예시 SQL을 복사해 별도 워크시트에서 수정하며 먼저 실험한다.
- `sql/05_answer.sql`은 직접 풀어본 뒤 비교하는 정답 스크립트이므로, 내 실행계획과 차이를 확인하는 용도로 사용한다.

## 관찰 결과

- 

## 해석 포인트

- 왜 이런 실행계획이 나왔는지
- 실무에서 무엇을 더 확인해야 하는지
- SQLP 시험에서는 어떻게 판단하는지

## 트러블슈팅

- 

## 추가 학습 포인트

- 

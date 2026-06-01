prompt ============================================
prompt 2.3.4 Index Skip Scan - 연습 문제
prompt ============================================

/*
목적
- Skip Scan을 차선책으로 수용할지, 전용 인덱스를 새로 만들어야 할지 판단해 본다.

체크 포인트
- 선두 컬럼 distinct value 수를 먼저 떠올린다
- 후행 컬럼 선택도가 충분한지 판단한다
- SQL 수행 빈도까지 함께 고려한다

예상 해석
- 구조가 맞고 수행 빈도가 낮으면 Skip Scan 수용 가능하다.
- 중요 고빈도 SQL이면 후행 컬럼 기준 인덱스 추가가 더 바람직할 수 있다.
*/

prompt 문제 1. (GENDER, AGE) 인덱스에서 age between 30 and 31 조건만 있는 SQL은 왜 Skip Scan 후보가 되는가?
prompt 문제 2. 같은 인덱스에서 age between 20 and 60 으로 범위가 넓어지면 왜 Skip Scan 이 불리해질 수 있는가?
prompt 문제 3. 중요 배치 SQL이 where age = 33 조건으로 매우 자주 수행된다면, Skip Scan 에 맡길지 AGE 선두 인덱스를 추가할지 판단해 보라.
prompt 문제 4. (BIZ_TYPE, BIZ_CODE, BASE_DT) 인덱스에서 BIZ_TYPE 조건은 있고 BIZ_CODE는 없으며 BASE_DT 범위 조건만 있다면 왜 Skip Scan 가능성이 있는가?

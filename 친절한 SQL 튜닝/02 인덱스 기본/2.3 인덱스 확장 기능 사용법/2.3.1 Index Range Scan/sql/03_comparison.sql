prompt ============================================
prompt 2.3.1 Index Range Scan - 범위와 테이블 액세스 비교
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 같은 INDEX RANGE SCAN이라도 읽는 범위가 달라지면 비용이 달라짐을 비교한다.
- 인덱스만으로 처리 가능한 경우와 테이블까지 다시 읽는 경우를 비교한다.

체크 포인트
- [A]와 [B]가 모두 INDEX RANGE SCAN이더라도 비용/카디널리티 차이가 있는가
- [C]에서 테이블 액세스가 줄거나 사라지는가
- "인덱스를 탔다"보다 "얼마나 적게 읽는가"가 더 중요하다는 점이 보이는가

예상 해석
- 좁은 범위는 인덱스 리프 스캔과 테이블 방문 수가 적다.
- 넓은 범위는 같은 Range Scan이어도 성능상 부담이 커진다.
- 조회 컬럼이 인덱스에 모두 포함되면 테이블 랜덤 액세스 부담을 줄일 수 있다.
*/

prompt
prompt [A] 좁은 범위 조회
explain plan for
select *
from t_idx_range_scan_demo
where deptno = 20
  and empno between 50000 and 52000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] 넓은 범위 조회
explain plan for
select *
from t_idx_range_scan_demo
where deptno = 20
  and empno between 10000 and 25000000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] 인덱스 컬럼만 이용하는 집계
explain plan for
select count(*)
from t_idx_range_scan_demo
where deptno = 20
  and empno between 50000 and 80000;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 해석 포인트
prompt - [A], [B] 모두 INDEX RANGE SCAN 이더라도 cost 와 cardinality 차이를 비교
prompt - [C]는 테이블 컬럼을 읽지 않으므로 TABLE ACCESS BY INDEX ROWID 가 줄어드는지 확인
prompt - 같은 연산자 이름만 보고 성능을 단정하면 안 된다는 점을 확인

prompt ============================================
prompt 2.3.6 Index Range Scan Descending - 기본 확인
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- ORDER BY DESC 에서 Index Range Scan Descending 기본 사례를 확인한다.

체크 포인트
- INDEX RANGE SCAN DESCENDING 이 나타나는가
- ORDER BY DESC 를 위해 별도 SORT 가 생략되는가
- TABLE ACCESS BY INDEX ROWID 가 뒤따르는가

예상 해석
- EMPNO 인덱스를 뒤에서부터 읽어 내림차순 정렬을 대체할 수 있다.
*/

explain plan for
select *
from t_idx_desc_demo
where empno > 100000
order by empno desc;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt ============================================
prompt 2.3.2 Index Full Scan - 기본 확인
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 교재와 유사한 형태로 선두 컬럼 조건 없이 ORDER BY를 수행하는 SQL의 계획을 확인한다.
- INDEX FULL SCAN이 왜 선택될 수 있는지 이해한다.

체크 포인트
- IDX_IFS_ENAME_SAL 인덱스가 INDEX FULL SCAN으로 사용되는가
- 선두 컬럼 ENAME 조건이 없음에도 인덱스를 읽는가
- ORDER BY ENAME 정렬이 별도 SORT 없이 처리되는가

예상 해석
- ENAME 조건이 없으므로 Index Range Scan은 어렵다.
- SAL이 인덱스 안에 있고 ORDER BY ENAME과 인덱스 정렬 순서가 맞아 INDEX FULL SCAN 후보가 된다.
*/

explain plan for
select *
from t_idx_full_scan_demo
where sal > 12000
order by ename;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 관찰 포인트
prompt - INDEX FULL SCAN 이 나타나는지 확인
prompt - ORDER BY 를 위해 별도 SORT ORDER BY 가 생기는지 확인
prompt - TABLE ACCESS BY INDEX ROWID 가 뒤따르는지 확인

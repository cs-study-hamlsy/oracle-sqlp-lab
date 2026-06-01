prompt ============================================
prompt 2.3.6 Index Range Scan Descending - 연습 문제 해설
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- Descending Scan 과 MIN/MAX 최적화 해석 기준을 확인한다.

체크 포인트
- 정렬 제거와 한 건 읽고 종료 전략을 구분하는가
- FIRST ROW, MIN/MAX 흔적을 해석할 수 있는가

예상 해석
- Descending Scan 은 역방향 Range Scan 이다.
- MIN/MAX 최적화는 인덱스 끝단의 한 건만 읽는 전략이다.
*/

prompt
prompt [해설 1] DESC 정렬 제거
explain plan for
select empno, deptno, sal
from t_idx_desc_demo
where empno > 120000
order by empno desc;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [해설 2] MAX 값 최적화
explain plan for
select max(sal)
from t_idx_desc_demo
where deptno = 15;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [해설 3] MIN 값 최적화
explain plan for
select min(sal)
from t_idx_desc_demo
where deptno = 15;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt 정리
prompt - Descending Scan 은 소트 제거 목적에 매우 유용하다.
prompt - MAX/MIN 최적화는 인덱스 정렬 구조를 활용해 한 건만 읽고 종료할 수 있는 강력한 전략이다.

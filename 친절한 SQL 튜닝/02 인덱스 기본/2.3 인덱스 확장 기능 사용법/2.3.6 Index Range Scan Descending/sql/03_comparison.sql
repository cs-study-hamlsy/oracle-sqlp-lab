prompt ============================================
prompt 2.3.6 Index Range Scan Descending - 정렬 제거와 MIN/MAX 비교
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 내림차순 정렬 제거와 MAX/MIN 최적화를 비교한다.

체크 포인트
- [A] DESC 정렬에서 Descending Scan 이 나타나는가
- [B] 힌트로 Descending Scan 을 유도할 수 있는가
- [C] 부서별 MAX(SAL) 조회에서 MIN/MAX 최적화 흔적이 보이는가
- [D] MIN 값 조회도 반대 방향 최적화가 가능한가

예상 해석
- 인덱스를 역방향으로 읽어 Sort Order By 를 줄일 수 있다.
- MAX/MIN 은 적절한 인덱스가 있으면 한 건만 읽고 멈추는 계획이 가능하다.
*/

prompt
prompt [A] DESC 정렬 기본 사례
explain plan for
select empno, deptno, sal
from t_idx_desc_demo
where empno > 120000
order by empno desc;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [B] INDEX_DESC 힌트 사용
explain plan for
select /*+ index_desc(t idx_irsd_empno) */
       empno, deptno, sal
from t_idx_desc_demo t
where empno > 120000
order by empno desc;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [C] 부서별 최대 급여 - MIN/MAX 최적화 후보
explain plan for
select d.deptno,
       (select max(sal)
          from t_idx_desc_demo x
         where x.deptno = d.deptno) as max_sal
from (select distinct deptno from t_idx_desc_demo) d;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

prompt
prompt [D] 특정 부서의 최소 급여
explain plan for
select min(sal)
from t_idx_desc_demo
where deptno = 15;

select * from table(dbms_xplan.display(null, null, 'basic +cost +predicate +alias'));

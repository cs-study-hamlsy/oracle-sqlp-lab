prompt ============================================
prompt 2.2.2 인덱스를 Range Scan할 수 없는 이유 - 실습 환경 준비
prompt ============================================

set serveroutput on
set linesize 200
set pagesize 100

/*
목적
- 인덱스 Range Scan, 컬럼 가공, OR Expansion, INLIST ITERATOR를 확인할 실습용 테이블을 생성한다.
- 선두 컬럼 조건 유무와 컬럼 가공 여부에 따라 실행계획이 달라지는 환경을 만든다.
- SCOTT 샘플 스키마 없이도 현재 접속 계정에서 바로 실행되도록 구성한다.

체크 포인트
- T_RANGE_SCAN_DEMO 테이블이 정상 생성되는가
- IDX_RSD_DEPT_EMPNO, IDX_RSD_HIREDATE, IDX_RSD_DEPT_JOB_EMPNO 인덱스가 생성되는가
- 통계정보 수집 후 EXPLAIN PLAN이 가능한 상태인가

예상 해석
- (DEPTNO, EMPNO) 인덱스는 선두 컬럼 + 범위 조건 학습용이다.
- HIREDATE 인덱스는 TRUNC(HIREDATE) 가공 비교 학습용이다.
- (DEPTNO, JOB, EMPNO) 인덱스는 선두 컬럼과 추가 등치 조건이 결합될 때의 장점을 보는 용도다.
*/

begin
    execute immediate 'drop table t_range_scan_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

/*
설명
- SQL Developer에서 가장 쉽게 재현할 수 있도록 SCOTT.EMP 대신 인라인 샘플 직원을 사용한다.
- DEPTNO 10/20/30, JOB, HIREDATE, EMPNO 분포를 유지한 상태에서
  컬럼 가공, 선두 컬럼 누락, OR Expansion, INLIST ITERATOR 차이를 관찰하기 쉽게 만든다.
*/
create table t_range_scan_demo
as
select
    rownum as id,
    e.empno + ((lv.lv - 1) * 10000) as empno,
    e.ename,
    e.job,
    e.mgr,
    e.hiredate + mod(lv.lv, 5) as hiredate,
    e.sal + mod(lv.lv, 7) * 10 as sal,
    e.comm,
    e.deptno,
    case mod(lv.lv, 3)
        when 0 then 'A'
        when 1 then 'B'
        else 'C'
    end as status_code
from (
        select 1000 empno, 'KING'   ename, 'PRESIDENT' job, cast(null as number) mgr, date '1981-11-17' hiredate, 5000 sal, cast(null as number) comm, 10 deptno from dual
        union all
        select 1100, 'CLARK',  'MANAGER',   1000, date '1981-06-09', 2450, cast(null as number), 10 from dual
        union all
        select 1200, 'MILLER', 'CLERK',     1100, date '1982-01-23', 1300, cast(null as number), 10 from dual
        union all
        select 2000, 'SMITH',  'CLERK',     2100, date '1980-12-17', 800,  cast(null as number), 20 from dual
        union all
        select 2100, 'JONES',  'MANAGER',   1000, date '1981-04-02', 2975, cast(null as number), 20 from dual
        union all
        select 2200, 'SCOTT',  'ANALYST',   2100, date '1987-04-19', 3000, cast(null as number), 20 from dual
        union all
        select 2300, 'FORD',   'ANALYST',   2100, date '1981-12-03', 3000, cast(null as number), 20 from dual
        union all
        select 2400, 'ADAMS',  'CLERK',     2200, date '1987-05-23', 1100, cast(null as number), 20 from dual
        union all
        select 2500, 'ALLEN',  'SALESMAN',  2600, date '1981-02-20', 1600, 300, 30 from dual
        union all
        select 2600, 'BLAKE',  'MANAGER',   1000, date '1981-05-01', 2850, cast(null as number), 30 from dual
        union all
        select 2700, 'WARD',   'SALESMAN',  2600, date '1981-02-22', 1250, 500, 30 from dual
        union all
        select 2800, 'MARTIN', 'SALESMAN',  2600, date '1981-09-28', 1250, 1400, 30 from dual
        union all
        select 2900, 'TURNER', 'SALESMAN',  2600, date '1981-09-08', 1500, 0, 30 from dual
        union all
        select 3000, 'JAMES',  'CLERK',     2600, date '1981-12-03', 950,  cast(null as number), 30 from dual
     ) e,
     (select level as lv from dual connect by level <= 1000) lv;

alter table t_range_scan_demo add constraint pk_t_range_scan_demo primary key (id);

create index idx_rsd_dept_empno on t_range_scan_demo(deptno, empno);
create index idx_rsd_hiredate on t_range_scan_demo(hiredate);
create index idx_rsd_dept_job_empno on t_range_scan_demo(deptno, job, empno);

begin
    dbms_stats.gather_table_stats(
        ownname          => user,
        tabname          => 'T_RANGE_SCAN_DEMO',
        cascade          => true,
        method_opt       => 'for all columns size 1'
    );
end;
/

prompt
prompt 검증 쿼리
select deptno, count(*) as cnt, min(empno) as min_empno, max(empno) as max_empno
from t_range_scan_demo
group by deptno
order by deptno;

prompt 생성 완료
prompt - 테이블: T_RANGE_SCAN_DEMO
prompt - 인덱스1: IDX_RSD_DEPT_EMPNO (DEPTNO, EMPNO)
prompt - 인덱스2: IDX_RSD_HIREDATE (HIREDATE)
prompt - 인덱스3: IDX_RSD_DEPT_JOB_EMPNO (DEPTNO, JOB, EMPNO)
prompt - 통계정보 수집 완료

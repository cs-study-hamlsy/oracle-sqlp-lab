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
from scott.emp e,
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

prompt 생성 완료
prompt - 테이블: T_RANGE_SCAN_DEMO
prompt - 인덱스1: IDX_RSD_DEPT_EMPNO (DEPTNO, EMPNO)
prompt - 인덱스2: IDX_RSD_HIREDATE (HIREDATE)
prompt - 인덱스3: IDX_RSD_DEPT_JOB_EMPNO (DEPTNO, JOB, EMPNO)
prompt - 통계정보 수집 완료

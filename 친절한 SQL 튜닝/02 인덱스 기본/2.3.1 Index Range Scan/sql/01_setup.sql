prompt ============================================
prompt 2.3.1 Index Range Scan - 실습 환경 준비
prompt ============================================

set serveroutput on
set linesize 200
set pagesize 100

/*
목적
- Index Range Scan 실습을 위한 테이블과 인덱스를 생성한다.
- 좁은 범위와 넓은 범위를 비교할 수 있도록 충분한 행 수를 만든다.

체크 포인트
- T_IDX_RANGE_SCAN_DEMO 테이블이 생성되는가
- IDX_IRS_DEPTNO_EMPNO 인덱스가 생성되는가
- 통계정보 수집 후 EXPLAIN PLAN이 가능한가

예상 해석
- (DEPTNO, EMPNO) 복합 인덱스를 이용해 전형적인 INDEX RANGE SCAN을 관찰할 수 있다.
- SELECT * 는 TABLE ACCESS BY INDEX ROWID가 뒤따를 가능성이 높다.
*/

begin
    execute immediate 'drop table t_idx_range_scan_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

create table t_idx_range_scan_demo
as
select
    rownum as id,
    e.empno + ((lv.lv - 1) * 10000) as empno,
    e.ename || '_' || lpad(lv.lv, 4, '0') as ename,
    e.job,
    e.mgr,
    e.hiredate + mod(lv.lv, 5) as hiredate,
    e.sal + mod(lv.lv, 9) * 10 as sal,
    e.comm,
    e.deptno,
    rpad('X', 100, 'X') as padding
from scott.emp e,
     (select level as lv from dual connect by level <= 3000) lv;

alter table t_idx_range_scan_demo
    add constraint pk_idx_range_scan_demo primary key (id);

create index idx_irs_deptno_empno
    on t_idx_range_scan_demo(deptno, empno);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_IDX_RANGE_SCAN_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

prompt 생성 완료
prompt - 테이블 : T_IDX_RANGE_SCAN_DEMO
prompt - 인덱스 : IDX_IRS_DEPTNO_EMPNO (DEPTNO, EMPNO)
prompt - 통계정보 수집 완료

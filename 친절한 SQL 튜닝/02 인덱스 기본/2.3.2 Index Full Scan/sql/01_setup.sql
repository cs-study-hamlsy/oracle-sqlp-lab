prompt ============================================
prompt 2.3.2 Index Full Scan - 실습 환경 준비
prompt ============================================

set serveroutput on
set linesize 200
set pagesize 100

/*
목적
- Index Full Scan 실습을 위한 테이블과 인덱스를 생성한다.
- (ENAME, SAL) 인덱스를 이용해 선두 컬럼 조건 없는 ORDER BY 사례를 재현한다.

체크 포인트
- T_IDX_FULL_SCAN_DEMO 테이블이 생성되는가
- IDX_IFS_ENAME_SAL 인덱스가 생성되는가
- 통계정보 수집 후 EXPLAIN PLAN이 가능한가

예상 해석
- ENAME 선두 컬럼 조건이 없더라도 SAL 필터와 ORDER BY ENAME 조합에서 INDEX FULL SCAN을 관찰할 수 있다.
- SELECT * 는 TABLE ACCESS BY INDEX ROWID가 함께 나타날 가능성이 높다.
*/

begin
    execute immediate 'drop table t_idx_full_scan_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

create table t_idx_full_scan_demo
as
select
    rownum as id,
    e.empno + ((lv.lv - 1) * 10000) as empno,
    e.ename || '_' || lpad(lv.lv, 4, '0') as ename,
    e.job,
    e.mgr,
    e.hiredate + mod(lv.lv, 5) as hiredate,
    e.sal + (lv.lv * 5) as sal,
    e.comm,
    e.deptno,
    rpad('Y', 150, 'Y') as padding
from scott.emp e,
     (select level as lv from dual connect by level <= 2500) lv;

alter table t_idx_full_scan_demo
    add constraint pk_idx_full_scan_demo primary key (id);

create index idx_ifs_ename_sal
    on t_idx_full_scan_demo(ename, sal);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_IDX_FULL_SCAN_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

prompt 생성 완료
prompt - 테이블 : T_IDX_FULL_SCAN_DEMO
prompt - 인덱스 : IDX_IFS_ENAME_SAL (ENAME, SAL)
prompt - 통계정보 수집 완료

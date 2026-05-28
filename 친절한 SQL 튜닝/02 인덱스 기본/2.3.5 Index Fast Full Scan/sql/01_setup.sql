prompt ============================================
prompt 2.3.5 Index Fast Full Scan - 실습 환경 준비
prompt ============================================

set serveroutput on
set linesize 200
set pagesize 100

/*
목적
- Index Full Scan과 Index Fast Full Scan 비교용 실습 객체를 생성한다.
- 인덱스만으로 조회 가능한 상황과 아닌 상황을 함께 만든다.

체크 포인트
- T_IDX_FFS_DEMO 테이블이 생성되는가
- IDX_IFFS_DEPTNO_SAL 인덱스가 생성되는가
- 통계정보 수집 후 Explain Plan이 가능한가

예상 해석
- DEPTNO, SAL만 조회하는 SQL에서는 INDEX FAST FULL SCAN 후보가 된다.
- SELECT * 는 인덱스만으로 끝나지 않아 Fast Full Scan의 장점이 약해질 수 있다.
*/

begin
    execute immediate 'drop table t_idx_ffs_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

create table t_idx_ffs_demo
as
select
    rownum as id,
    mod(rownum, 50) + 10 as deptno,
    trunc(dbms_random.value(1000, 10000)) as sal,
    date '2024-01-01' + mod(rownum, 365) as hiredate,
    rpad('EMP_' || rownum, 40, 'X') as emp_name,
    rpad('Z', 150, 'Z') as padding
from dual
connect by level <= 80000;

alter table t_idx_ffs_demo
    add constraint pk_idx_ffs_demo primary key (id);

create index idx_iffs_deptno_sal
    on t_idx_ffs_demo(deptno, sal);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_IDX_FFS_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

prompt 생성 완료
prompt - 테이블 : T_IDX_FFS_DEMO
prompt - 인덱스 : IDX_IFFS_DEPTNO_SAL (DEPTNO, SAL)

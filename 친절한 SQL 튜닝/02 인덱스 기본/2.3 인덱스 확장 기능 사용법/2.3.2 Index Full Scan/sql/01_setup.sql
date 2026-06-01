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
- SCOTT 샘플 스키마 없이도 현재 접속 계정에서 바로 실행되도록 구성한다.

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

/*
설명
- SQL Developer에서 가장 쉽게 재현할 수 있도록 SCOTT.EMP 대신 인라인 샘플 직원을 사용한다.
- ENAME은 정렬 관찰용으로 유지하고, SAL은 단계적으로 증가시켜
  sal > 12000, sal > 16000, sal > 1000 조건 비교가 가능하도록 만든다.
*/
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

prompt
prompt 검증 쿼리
select count(*) as cnt, min(sal) as min_sal, max(sal) as max_sal
from t_idx_full_scan_demo;

prompt 생성 완료
prompt - 테이블 : T_IDX_FULL_SCAN_DEMO
prompt - 인덱스 : IDX_IFS_ENAME_SAL (ENAME, SAL)
prompt - 통계정보 수집 완료

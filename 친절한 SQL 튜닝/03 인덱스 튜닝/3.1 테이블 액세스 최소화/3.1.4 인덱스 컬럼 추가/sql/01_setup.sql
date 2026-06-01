prompt ============================================
prompt 3.1.4 인덱스 컬럼 추가 - 실습 환경 준비
prompt ============================================

set serveroutput on
set linesize 200
set pagesize 100

/*
목적
- 인덱스 컬럼 추가 전/후 차이를 비교할 실습 테이블을 생성한다.
- 기본 인덱스는 (DEPTNO, JOB)만 두고, SAL이 없는 상태를 먼저 재현한다.
- 테이블 랜덤 액세스가 과도하게 발생하는 상황을 만들기 위해 EMP 유사 데이터를 대량 복제한다.

체크 포인트
- T_IDX_ADD_COL_DEMO 테이블이 생성되는가
- IDX_ADD_COL_X1 인덱스가 생성되는가
- 통계정보 수집이 완료되는가

예상 해석
- DEPTNO = 30 조건은 인덱스로 찾을 수 있지만 SAL 조건은 테이블에 내려가서 검사하게 된다.
- 이후 SAL 컬럼을 인덱스에 추가하면 인덱스 단계에서 먼저 걸러내는 구조로 바뀐다.
*/

begin
    execute immediate 'drop table t_idx_add_col_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

create table t_idx_add_col_demo
as
select
    rownum as emp_id,
    e.deptno,
    e.job,
    e.base_sal
        + case
              when e.job = 'MANAGER' then 300
              when e.job = 'SALESMAN' then mod(lv.lv, 5) * 200
              when e.job = 'CLERK' then mod(lv.lv, 4) * 100
              else mod(lv.lv, 3) * 150
          end as sal,
    e.ename || '_' || lpad(lv.lv, 5, '0') as emp_name,
    case when mod(lv.lv, 10) = 0 then 'N' else 'Y' end as use_yn,
    rpad('X', 120, 'X') as padding
from (
        select 10 as deptno, 'PRESIDENT' as job, 5000 as base_sal, 'KING' as ename from dual union all
        select 10, 'MANAGER', 2450, 'CLARK' from dual union all
        select 10, 'CLERK', 1300, 'MILLER' from dual union all
        select 20, 'MANAGER', 2975, 'JONES' from dual union all
        select 20, 'ANALYST', 3000, 'SCOTT' from dual union all
        select 20, 'ANALYST', 3000, 'FORD' from dual union all
        select 20, 'CLERK', 1100, 'ADAMS' from dual union all
        select 20, 'CLERK', 800, 'SMITH' from dual union all
        select 30, 'MANAGER', 2850, 'BLAKE' from dual union all
        select 30, 'SALESMAN', 1600, 'ALLEN' from dual union all
        select 30, 'SALESMAN', 1250, 'WARD' from dual union all
        select 30, 'SALESMAN', 1250, 'MARTIN' from dual union all
        select 30, 'SALESMAN', 1500, 'TURNER' from dual union all
        select 30, 'CLERK', 950, 'JAMES' from dual
     ) e,
     (select level as lv from dual connect by level <= 3000) lv;

alter table t_idx_add_col_demo
    add constraint pk_idx_add_col_demo primary key (emp_id);

create index idx_add_col_x1
    on t_idx_add_col_demo(deptno, job);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_IDX_ADD_COL_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

prompt
prompt 데이터 분포 확인
select deptno,
       count(*) as cnt,
       min(sal) as min_sal,
       max(sal) as max_sal
from t_idx_add_col_demo
group by deptno
order by deptno;

prompt
prompt 생성 완료
prompt - 테이블 : T_IDX_ADD_COL_DEMO
prompt - 인덱스 : IDX_ADD_COL_X1 (DEPTNO, JOB)

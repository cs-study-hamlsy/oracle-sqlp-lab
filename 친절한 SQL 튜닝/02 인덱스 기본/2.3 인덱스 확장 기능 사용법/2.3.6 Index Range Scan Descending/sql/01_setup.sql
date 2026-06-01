prompt ============================================
prompt 2.3.6 Index Range Scan Descending - 실습 환경 준비
prompt ============================================

set serveroutput on
set linesize 200
set pagesize 100

/*
목적
- Descending 및 MIN/MAX 최적화 실습용 객체를 생성한다.
- ORDER BY DESC 와 부서별 MAX 값 조회를 재현할 수 있는 구조를 만든다.

체크 포인트
- T_IDX_DESC_DEMO 테이블이 생성되는가
- IDX_IRSD_EMPNO, IDX_IRSD_DEPTNO_SAL 인덱스가 생성되는가
- 통계정보 수집 후 Explain Plan이 가능한가

예상 해석
- EMPNO 내림차순 정렬에서 INDEX RANGE SCAN DESCENDING 을 관찰할 수 있다.
- (DEPTNO, SAL) 인덱스로 부서별 MAX(SAL) 최적화 가능성을 볼 수 있다.
*/

begin
    execute immediate 'drop table t_idx_desc_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

create table t_idx_desc_demo
as
select
    rownum as id,
    100000 + rownum as empno,
    mod(rownum, 20) + 10 as deptno,
    trunc(dbms_random.value(1000, 20000)) as sal,
    date '2024-01-01' + mod(rownum, 365) as order_dt,
    rpad('D', 100, 'D') as padding
from dual
connect by level <= 50000;

alter table t_idx_desc_demo
    add constraint pk_idx_desc_demo primary key (id);

create unique index idx_irsd_empno
    on t_idx_desc_demo(empno);

create index idx_irsd_deptno_sal
    on t_idx_desc_demo(deptno, sal);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_IDX_DESC_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

prompt 생성 완료
prompt - 테이블 : T_IDX_DESC_DEMO
prompt - 인덱스 : IDX_IRSD_EMPNO (EMPNO)
prompt - 인덱스 : IDX_IRSD_DEPTNO_SAL (DEPTNO, SAL)

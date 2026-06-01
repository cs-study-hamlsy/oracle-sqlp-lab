prompt ============================================
prompt 3.1.5 인덱스만 읽고 처리 - 실습 환경 준비
prompt ============================================

set serveroutput on
set linesize 200
set pagesize 100

/*
목적
- 인덱스만 읽고 처리하는 커버드 쿼리 실습용 데이터를 생성한다.
- 기본 인덱스는 DEPT_CODE 단일 컬럼만 두어, QTY를 읽기 위해 테이블을 방문하는 상태를 먼저 만든다.

체크 포인트
- T_INDEX_ONLY_DEMO 테이블이 생성되는가
- IDX_INDEX_ONLY_X1 인덱스가 생성되는가
- 통계정보 수집이 완료되는가

예상 해석
- DEPT_CODE LIKE '123%' 조건은 인덱스로 찾을 수 있어도 SUM(QTY)를 위해 테이블 방문이 필요하다.
- 이후 QTY를 인덱스에 추가하면 테이블 방문이 사라질 수 있다.
*/

begin
    execute immediate 'drop table t_index_only_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

create table t_index_only_demo
as
select
    rownum as sales_id,
    case
        when mod(lv.lv, 10) < 6 then '123' || lpad(mod(lv.lv, 50), 3, '0')
        else '900' || lpad(mod(lv.lv, 70), 3, '0')
    end as dept_code,
    mod(lv.lv, 9) + 1 as qty,
    (mod(lv.lv, 9) + 1) * 100 as amount,
    date '2024-01-01' + mod(lv.lv, 365) as sale_dt,
    rpad('Z', 150, 'Z') as padding
from (select level as lv from dual connect by level <= 120000) lv;

alter table t_index_only_demo
    add constraint pk_index_only_demo primary key (sales_id);

create index idx_index_only_x1
    on t_index_only_demo(dept_code);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_INDEX_ONLY_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

prompt
prompt 데이터 분포 확인
select substr(dept_code, 1, 3) as prefix,
       count(*) as cnt,
       sum(qty) as total_qty
from t_index_only_demo
group by substr(dept_code, 1, 3)
order by prefix;

prompt
prompt 생성 완료
prompt - 테이블 : T_INDEX_ONLY_DEMO
prompt - 인덱스 : IDX_INDEX_ONLY_X1 (DEPT_CODE)

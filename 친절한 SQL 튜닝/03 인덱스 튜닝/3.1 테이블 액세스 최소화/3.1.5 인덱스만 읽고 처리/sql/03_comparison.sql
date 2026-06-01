prompt ============================================
prompt 3.1.5 인덱스만 읽고 처리 - 비교 실습
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- (DEPT_CODE, QTY) 복합 인덱스를 만들어 커버드 쿼리로 전환한다.
- TABLE ACCESS BY INDEX ROWID가 사라지는지 확인한다.

체크 포인트
- IDX_INDEX_ONLY_X2 (DEPT_CODE, QTY) 인덱스가 생성되는가
- 같은 집계 SQL에서 테이블 액세스가 없어지는가
- 결과는 동일하지만 읽기량이 감소하는가

예상 해석
- QTY가 인덱스에 포함되면 SUM(QTY)를 인덱스만으로 계산할 수 있다.
- 테이블 액세스가 사라지는 순간 성능이 크게 안정된다.
*/

begin
    execute immediate 'drop index idx_index_only_x2';
exception
    when others then
        if sqlcode != -1418 and sqlcode != -942 then
            raise;
        end if;
end;
/

create index idx_index_only_x2
    on t_index_only_demo(dept_code, qty);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_INDEX_ONLY_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

alter session set statistics_level = all;

prompt
prompt 1) 단일 컬럼 인덱스 강제 사용
select /*+ gather_plan_statistics index(d idx_index_only_x1) */
       d.dept_code,
       sum(d.qty) as sum_qty
from t_index_only_demo d
where d.dept_code like '123%'
group by d.dept_code
order by d.dept_code;

select *
from table(
    dbms_xplan.display_cursor(
        null,
        null,
        'allstats last +cost +predicate +alias'
    )
);

prompt
prompt 2) 커버드 인덱스 강제 사용
select /*+ gather_plan_statistics index(d idx_index_only_x2) */
       d.dept_code,
       sum(d.qty) as sum_qty
from t_index_only_demo d
where d.dept_code like '123%'
group by d.dept_code
order by d.dept_code;

select *
from table(
    dbms_xplan.display_cursor(
        null,
        null,
        'allstats last +cost +predicate +alias'
    )
);

prompt
prompt 해석 가이드
prompt - 두 SQL 결과는 같아야 한다.
prompt - 차이는 QTY를 어디서 읽느냐이다. 단일 인덱스는 테이블, 복합 인덱스는 인덱스에서 읽는다.
prompt - TABLE ACCESS BY INDEX ROWID가 사라지는지 반드시 확인한다.

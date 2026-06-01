prompt ============================================
prompt 3.1.4 인덱스 컬럼 추가 - 비교 실습
prompt ============================================

set linesize 200
set pagesize 100

/*
목적
- 기존 인덱스 뒤에 SAL 컬럼을 추가했을 때 테이블 액세스가 어떻게 줄어드는지 비교한다.
- 인덱스 스캔량은 비슷해도 테이블 방문량 감소만으로 성능이 좋아질 수 있음을 확인한다.

체크 포인트
- IDX_ADD_COL_X2 (DEPTNO, JOB, SAL) 인덱스가 생성되는가
- 같은 SQL에서 TABLE ACCESS BY INDEX ROWID 실제 로우 수가 감소하는가
- SAL 조건이 인덱스 단계 predicate로 보이는가

예상 해석
- JOB 조건이 없어도 SAL이 인덱스 리프에 있으므로 테이블 방문 전 필터링이 가능하다.
- 결과적으로 불필요한 랜덤 액세스가 크게 줄어든다.
*/

begin
    execute immediate 'drop index idx_add_col_x2';
exception
    when others then
        if sqlcode != -1418 and sqlcode != -942 then
            raise;
        end if;
end;
/

create index idx_add_col_x2
    on t_idx_add_col_demo(deptno, job, sal);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_IDX_ADD_COL_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

alter session set statistics_level = all;

prompt
prompt 1) 기존 인덱스 강제 사용
select /*+ gather_plan_statistics index(d idx_add_col_x1) */
       sum(length(d.emp_name)) as total_name_len,
       sum(d.sal) as total_sal
from t_idx_add_col_demo d
where d.deptno = 30
and   d.sal >= 2500;

select *
from table(
    dbms_xplan.display_cursor(
        null,
        null,
        'allstats last +cost +predicate +alias'
    )
);

prompt
prompt 2) SAL 추가 인덱스 강제 사용
select /*+ gather_plan_statistics index(d idx_add_col_x2) */
       sum(length(d.emp_name)) as total_name_len,
       sum(d.sal) as total_sal
from t_idx_add_col_demo d
where d.deptno = 30
and   d.sal >= 2500;

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
prompt - 두 실행 모두 DEPTNO = 30 구간은 비슷하게 읽을 수 있다.
prompt - 차이는 SAL 조건을 테이블에서 확인하느냐, 인덱스에서 먼저 확인하느냐에 있다.
prompt - TABLE ACCESS BY INDEX ROWID 실제 로우 수가 결과 건수에 가까워지면 개선 성공이다.

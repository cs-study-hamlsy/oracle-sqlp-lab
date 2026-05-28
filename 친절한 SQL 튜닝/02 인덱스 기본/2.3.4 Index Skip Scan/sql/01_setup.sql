prompt ============================================
prompt 2.3.4 Index Skip Scan - 실습 환경 준비
prompt ============================================

set serveroutput on
set linesize 200
set pagesize 100

/*
목적
- Index Skip Scan 실습용 테이블과 복합 인덱스를 생성한다.
- 선두 컬럼 distinct value가 적고 후행 컬럼 distinct value가 많은 구조를 만든다.

체크 포인트
- T_IDX_SKIP_SCAN_DEMO 테이블이 생성되는가
- IDX_ISS_GENDER_AGE, IDX_ISS_TYPE_CODE_DT 인덱스가 생성되는가
- 통계정보 수집 후 Explain Plan이 가능한가

예상 해석
- (GENDER, AGE) 인덱스에서 GENDER 조건이 없을 때 AGE 조건으로 INDEX SKIP SCAN 가능성을 볼 수 있다.
- (BIZ_TYPE, BIZ_CODE, BASE_DT) 인덱스에서 중간 컬럼이 비어도 Skip Scan 가능성을 관찰할 수 있다.
*/

begin
    execute immediate 'drop table t_idx_skip_scan_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

create table t_idx_skip_scan_demo
as
select
    rownum as id,
    case mod(rownum, 2)
        when 0 then 'M'
        else 'F'
    end as gender,
    20 + mod(rownum, 45) as age,
    lpad(mod(rownum, 20000), 5, '0') as customer_no,
    'T' || to_char(mod(rownum, 3) + 1) as biz_type,
    'C' || lpad(mod(rownum, 40) + 1, 2, '0') as biz_code,
    date '2024-01-01' + mod(rownum, 180) as base_dt,
    trunc(dbms_random.value(1000, 100000)) as amount,
    rpad('S', 80, 'S') as padding
from dual
connect by level <= 50000;

alter table t_idx_skip_scan_demo
    add constraint pk_idx_skip_scan_demo primary key (id);

create index idx_iss_gender_age
    on t_idx_skip_scan_demo(gender, age);

create index idx_iss_type_code_dt
    on t_idx_skip_scan_demo(biz_type, biz_code, base_dt);

begin
    dbms_stats.gather_table_stats(
        ownname    => user,
        tabname    => 'T_IDX_SKIP_SCAN_DEMO',
        cascade    => true,
        method_opt => 'for all columns size 1'
    );
end;
/

prompt 생성 완료
prompt - 테이블 : T_IDX_SKIP_SCAN_DEMO
prompt - 인덱스 : IDX_ISS_GENDER_AGE (GENDER, AGE)
prompt - 인덱스 : IDX_ISS_TYPE_CODE_DT (BIZ_TYPE, BIZ_CODE, BASE_DT)

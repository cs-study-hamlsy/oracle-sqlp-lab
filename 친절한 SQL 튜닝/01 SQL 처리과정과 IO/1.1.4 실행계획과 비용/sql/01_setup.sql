prompt ============================================
prompt 실행계획과 비용 - 실습 환경 준비
prompt ============================================

/*
목적
- 실행계획 비교용 테스트 테이블 T와 인덱스를 준비한다.
- deptno, job, no 조건 조합에 따라 인덱스 선택성이 어떻게 달라지는지 보기 위한 데이터셋을 만든다.
- SCOTT 샘플 스키마 없이도 현재 접속 계정에서 바로 실행되도록 구성한다.

체크 포인트
- T 테이블이 정상 생성되는가
- T_X01, T_X02 인덱스가 생성되는가
- 통계정보 수집 후 옵티마이저가 비용 기반 판단을 할 수 있는 상태인가
*/

begin
    execute immediate 'drop table t purge';
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
- DEPTNO, JOB 분포를 유지한 상태에서 NO를 1..1000까지 반복 생성해
  복합 인덱스 선택성과 범위 조건 효과를 비교하기 쉽게 한다.
*/
create table t
as
select d.no, e.*
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
     (select rownum no from dual connect by level <= 1000) d;

create index t_x01 on t(deptno, no);
create index t_x02 on t(deptno, job, no);

begin
    dbms_stats.gather_table_stats(user, 'T', cascade => true);
end;
/

prompt
prompt 검증 쿼리
select deptno, job, count(*) as cnt
from t
group by deptno, job
order by deptno, job;

prompt 테이블과 인덱스 준비 완료
prompt - T: 인라인 샘플 직원 x NO 1..1000 반복 데이터
prompt - T_X01: (DEPTNO, NO)
prompt - T_X02: (DEPTNO, JOB, NO)
prompt - 통계정보 수집 완료

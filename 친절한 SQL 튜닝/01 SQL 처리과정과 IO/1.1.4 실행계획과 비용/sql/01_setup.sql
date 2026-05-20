prompt ============================================
prompt 실행계획과 비용 - 실습 환경 준비
prompt ============================================

/*
목적
- 실행계획 비교용 테스트 테이블 T와 인덱스를 준비한다.
- deptno, job, no 조건 조합에 따라 인덱스 선택성이 어떻게 달라지는지 보기 위한 데이터셋을 만든다.

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

create table t
as
select d.no, e.*
from scott.emp e,
     (select rownum no from dual connect by level <= 1000) d;

create index t_x01 on t(deptno, no);
create index t_x02 on t(deptno, job, no);

begin
    dbms_stats.gather_table_stats(user, 'T', cascade => true);
end;
/

prompt 테이블과 인덱스 준비 완료
prompt - T: SCOTT.EMP x 1000 배수 데이터
prompt - T_X01: (DEPTNO, NO)
prompt - T_X02: (DEPTNO, JOB, NO)
prompt - 통계정보 수집 완료

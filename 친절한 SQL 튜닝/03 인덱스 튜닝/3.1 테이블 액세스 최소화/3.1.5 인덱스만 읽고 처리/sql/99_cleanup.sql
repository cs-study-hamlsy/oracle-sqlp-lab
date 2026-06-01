prompt ============================================
prompt 3.1.5 인덱스만 읽고 처리 - 정리
prompt ============================================

/*
목적
- 실습으로 생성한 테이블과 인덱스를 정리한다.

체크 포인트
- T_INDEX_ONLY_DEMO 테이블이 삭제되는가

예상 해석
- purge 옵션으로 휴지통 없이 즉시 정리한다.
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

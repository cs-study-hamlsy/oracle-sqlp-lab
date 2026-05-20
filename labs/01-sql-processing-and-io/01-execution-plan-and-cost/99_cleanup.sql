prompt ============================================
prompt 실행계획과 비용 - 정리
prompt ============================================

begin
    execute immediate 'drop table t purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

prompt 테이블 T 삭제 완료

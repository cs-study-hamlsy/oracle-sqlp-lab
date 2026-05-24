prompt ============================================
prompt 2.2.2 인덱스를 Range Scan할 수 없는 이유 - 정리
prompt ============================================

/*
목적
- 실습 객체를 정리한다.

체크 포인트
- T_RANGE_SCAN_DEMO 테이블이 삭제되는가
*/

begin
    execute immediate 'drop table t_range_scan_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

prompt 테이블 T_RANGE_SCAN_DEMO 정리 완료

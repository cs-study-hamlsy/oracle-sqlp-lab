prompt ============================================
prompt 2.3.1 Index Range Scan - 정리
prompt ============================================

/*
목적
- Index Range Scan 실습 객체를 정리한다.

체크 포인트
- T_IDX_RANGE_SCAN_DEMO 테이블이 삭제되는가

예상 해석
- 테이블 삭제 시 관련 인덱스도 함께 정리된다.
*/

begin
    execute immediate 'drop table t_idx_range_scan_demo purge';
exception
    when others then
        if sqlcode = -942 then
            dbms_output.put_line('T_IDX_RANGE_SCAN_DEMO 가 이미 없습니다.');
        else
            raise;
        end if;
end;
/

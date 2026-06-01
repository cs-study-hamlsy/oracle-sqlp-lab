prompt ============================================
prompt 3.1.4 인덱스 컬럼 추가 - 정리
prompt ============================================

/*
목적
- 실습으로 생성한 테이블과 인덱스를 정리한다.

체크 포인트
- T_IDX_ADD_COL_DEMO 테이블이 삭제되는가

예상 해석
- purge 옵션으로 휴지통 없이 즉시 정리한다.
*/

begin
    execute immediate 'drop table t_idx_add_col_demo purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

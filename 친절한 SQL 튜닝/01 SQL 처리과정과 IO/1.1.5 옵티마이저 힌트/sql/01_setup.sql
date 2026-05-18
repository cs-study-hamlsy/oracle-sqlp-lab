prompt ============================================
prompt 1.1.5 옵티마이저 힌트 - 실습 환경 준비
prompt ============================================

begin
    execute immediate 'drop table customer_orders purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

begin
    execute immediate 'drop table customer_contacts purge';
exception
    when others then
        if sqlcode != -942 then
            raise;
        end if;
end;
/

create table customer_contacts (
    customer_id      number        not null,
    customer_name    varchar2(100) not null,
    phone_number     varchar2(30)  not null,
    address          varchar2(200) not null,
    city             varchar2(40)  not null,
    customer_status  varchar2(20)  not null,
    signup_at        date          not null,
    constraint pk_customer_contacts primary key (customer_id)
);

create table customer_orders (
    order_id       number         not null,
    customer_id    number         not null,
    order_amount   number(10, 2)  not null,
    order_status   varchar2(20)   not null,
    order_at       date           not null,
    constraint pk_customer_orders primary key (order_id),
    constraint fk_customer_orders_customer
        foreign key (customer_id) references customer_contacts(customer_id)
);

insert /*+ append */ into customer_contacts
select
    level as customer_id,
    '고객' || to_char(level, 'FM000000') as customer_name,
    '010-' || lpad(mod(level, 10000), 4, '0') || '-' || lpad(mod(level * 7, 10000), 4, '0') as phone_number,
    '서울시 샘플로 ' || mod(level, 500) || '번지' as address,
    case mod(level, 5)
        when 0 then 'SEOUL'
        when 1 then 'BUSAN'
        when 2 then 'INCHEON'
        when 3 then 'DAEGU'
        else 'GWANGJU'
    end as city,
    case
        when mod(level, 20) = 0 then 'VIP'
        when mod(level, 3) = 0 then 'INACTIVE'
        else 'ACTIVE'
    end as customer_status,
    date '2024-01-01' + mod(level, 450) as signup_at
from dual
connect by level <= 20000;

insert /*+ append */ into customer_orders
select
    level as order_id,
    mod(level, 20000) + 1 as customer_id,
    mod(level * 37, 500000) / 10 + 10 as order_amount,
    case mod(level, 4)
        when 0 then 'PAID'
        when 1 then 'READY'
        when 2 then 'CANCEL'
        else 'DELIVERY'
    end as order_status,
    date '2025-01-01' + mod(level, 120) as order_at
from dual
connect by level <= 120000;

create index idx_customer_status_signup
    on customer_contacts(customer_status, signup_at);

create index idx_customer_city_signup
    on customer_contacts(city, signup_at);

create index idx_orders_customer_date
    on customer_orders(customer_id, order_at);

begin
    dbms_stats.gather_table_stats(user, 'CUSTOMER_CONTACTS', cascade => true);
    dbms_stats.gather_table_stats(user, 'CUSTOMER_ORDERS', cascade => true);
end;
/

commit;

prompt 테이블 생성 완료
prompt - CUSTOMER_CONTACTS: 20000건
prompt - CUSTOMER_ORDERS:   120000건
prompt - 통계정보 수집 완료

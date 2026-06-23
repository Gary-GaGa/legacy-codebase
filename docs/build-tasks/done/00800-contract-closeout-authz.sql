-- EPROZ00800 implementation closeout authz verification.
-- SELECT only. Do not add DML here.

set pagesize 200
set linesize 32767
set trimspool on
set tab off

prompt == EPROZ00800 final TB_API_AUTH rows ==
with endpoints(api_id, expected_ref_function_id, mutating) as (
    select 'epl-case-query-reviseditem', 'EPROZ00800', 'N' from dual union all
    select 'epl-case-insert-reviseditem', 'EPROZ00800', 'Y' from dual
)
select e.api_id,
       e.expected_ref_function_id,
       e.mutating,
       case when auth.api_id is null then 'MISSING' else 'FOUND' end as status,
       auth.role,
       auth.ref_function_id,
       case
           when auth.api_id is null then 'MISSING'
           when auth.ref_function_id = e.expected_ref_function_id then 'REF_OK'
           else 'REF_MISMATCH'
       end as ref_check
  from endpoints e
  left join tb_api_auth auth
    on auth.api_id = e.api_id
 order by e.api_id;

prompt == EPROZ00800 TB_API_AUTH duplicate check ==
select api_id,
       count(*) as row_count,
       listagg(ref_function_id, ';') within group (order by ref_function_id) as ref_function_ids
  from tb_api_auth
 where api_id in ('epl-case-query-reviseditem', 'epl-case-insert-reviseditem')
 group by api_id
having count(*) > 1
 order by api_id;

prompt == EPROZ00800 closeout pass condition ==
select case
           when count(*) = 2
            and sum(case when ref_function_id = 'EPROZ00800' then 1 else 0 end) = 2
           then 'PASS'
           else 'BLOCKER'
       end as db_d7_result,
       count(*) as found_rows
  from tb_api_auth
 where api_id in ('epl-case-query-reviseditem', 'epl-case-insert-reviseditem');

prompt == EPROZ00800 page-column auth detail mapping rows ==
select function_id,
       column_type,
       column_name,
       auth_type,
       is_show,
       can_edit,
       secure_attribute,
       lon_type_code,
       product_code,
       case_progress,
       system_ver,
       other_ver
  from tb_page_column_auth_detail
 where function_id = 'EPROZ00800'
   and (
        (column_type = 'revised' and column_name = 'item')
     or (column_type = 'reason' and column_name = 'item')
     or (column_type = 'button' and column_name in ('butSave', 'butFinish'))
   )
order by column_type, column_name, auth_type, system_ver desc, other_ver desc;

prompt == TB_PAGE_COLUMN_AUTH_DETAIL physical columns ==
select column_id,
       column_name,
       data_type,
       data_length,
       nullable
  from user_tab_columns
 where table_name = 'TB_PAGE_COLUMN_AUTH_DETAIL'
 order by column_id;

prompt == EPROZ00800 page-column auth category rows ==
select function_id,
       auth_type,
       role,
       isquery,
       case_progress
  from tb_page_column_auth_category
 where function_id = 'EPROZ00800'
 order by auth_type, isquery, role, case_progress;

prompt == EPROZ00800 page-column closeout pass condition ==
with expected(column_type, column_name, expected_can_edit, expected_is_show) as (
    select 'revised', 'item', 'Y', null from dual union all
    select 'reason', 'item', 'Y', null from dual union all
    select 'button', 'butSave', null, 'Y' from dual union all
    select 'button', 'butFinish', null, 'Y' from dual
),
matches as (
    select e.column_type,
           e.column_name
      from expected e
     where exists (
           select 1
             from tb_page_column_auth_detail d
            where d.function_id = 'EPROZ00800'
              and d.column_type = e.column_type
              and d.column_name = e.column_name
              and (e.expected_can_edit is null or d.can_edit = e.expected_can_edit)
              and (e.expected_is_show is null or d.is_show = e.expected_is_show)
     )
)
select case when count(*) = 4 then 'PASS' else 'BLOCKER' end as page_column_result,
       count(*) as matched_rows
  from matches;

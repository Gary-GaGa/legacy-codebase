-- SELECT-only verification for pilot SRS pending items.
-- Scope: EPROZ00100 and EPROC00118.
-- Safe to run with sqlplus/new.cmd; no DML is included.

set pagesize 500
set linesize 260
set trimspool on
set tab off
set feedback on
set verify off

prompt == ENV ==
select sys_context('USERENV', 'CURRENT_SCHEMA') as current_schema from dual;

prompt == TB_API_AUTH primary key shape ==
select uc.constraint_name,
       uc.constraint_type,
       listagg(ucc.column_name, ',') within group (order by ucc.position) as columns
  from user_constraints uc
  join user_cons_columns ucc
    on ucc.constraint_name = uc.constraint_name
   and ucc.table_name = uc.table_name
 where uc.table_name = 'TB_API_AUTH'
   and uc.constraint_type = 'P'
 group by uc.constraint_name, uc.constraint_type
 order by uc.constraint_name;

prompt == EPROZ00100 role display baseline ==
with roles(role_id) as (
    select '001' from dual union all
    select '002' from dual union all
    select '003' from dual union all
    select '101' from dual union all
    select '102' from dual union all
    select '103' from dual union all
    select '201' from dual union all
    select '202' from dual union all
    select '203' from dual union all
    select '301' from dual union all
    select '302' from dual union all
    select '402' from dual union all
    select '403' from dual union all
    select '404' from dual union all
    select '405' from dual
)
select r.role_id,
       case when rd.role_id is null then 'MISSING' else 'FOUND' end as status,
       rd.role_name,
       rd.role_desc
  from roles r
  left join tb_role_define rd
    on rd.role_id = r.role_id
 order by r.role_id;

prompt == PENDING-Z002 process code semantics seed ==
with wanted(code) as (
    select 'D1' from dual union all
    select 'C1' from dual union all
    select 'R0305' from dual union all
    select 'R0313' from dual union all
    select 'R0397' from dual union all
    select '21' from dual union all
    select '22' from dual union all
    select '23' from dual union all
    select '24' from dual union all
    select '25' from dual
)
select w.code,
       case when pc.app_process_code is null then 'MISSING' else 'FOUND' end as status,
       pc.app_process_name,
       pc.process_desc,
       pc.is_show,
       pc.process_type
  from wanted w
  left join tb_process_code pc
    on pc.app_process_code = w.code
 order by w.code;

prompt == PENDING-Z007 delete/close reason seeds ==
with wanted(msg_code) as (
    select 'DEL_REASON' from dual union all
    select 'CLO_REASON' from dual
)
select w.msg_code,
       cofo.msg_option,
       cofo.msg_ser_no,
       cofo.is_show,
       mla.lang_type,
       mla.lang_name
  from wanted w
  left join tb_common_field_options cofo
    on cofo.sys_code = 'EPRO'
   and cofo.msg_code = w.msg_code
  left join tb_multi_lang mla
    on mla.lang_key = cofo.lang_key
 order by w.msg_code, cofo.msg_ser_no, cofo.msg_option, mla.lang_type;

prompt == EPROZ00100 final TB_API_AUTH seed baseline ==
with endpoints(api_id, expected_roles, note) as (
    select 'epl-init-z0-todolist', '001;002;003;101;102;103;201;202;203;301;302;402;404;405', 'final init/redistribution endpoint' from dual union all
    select 'epl-list-todolist', '001;002;003;101;102;103;201;202;203;301;302;402;404;405', 'implemented refactor artifact' from dual union all
    select 'epl-case-insert-delreason', '001;002', 'delete case mutation' from dual union all
    select 'epl-case-insert-cloreason', '404;405', 'close CAD/TLOD mutation' from dual union all
    select 'epl-file-z0-proposal-download', '101;102;103;201;202;203;301;302', 'final proposal download endpoint' from dual union all
    select 'epl-session-z0-current-application', '001;002;003;101;102;103;201;202;203;301;302;402;404;405', 'final migration-only session bridge endpoint' from dual union all
    select 'epl-sele-z0-delete-reason', '001;002', 'final delete reason seed endpoint' from dual union all
    select 'epl-sele-z0-close-reason', '404;405', 'final close reason seed endpoint' from dual
)
select e.api_id,
       e.expected_roles,
       case when auth.api_id is null then 'MISSING' else 'FOUND' end as status,
       auth.role,
       auth.ref_function_id,
       e.note
  from endpoints e
  left join tb_api_auth auth
    on auth.api_id = e.api_id
 order by e.api_id;

prompt == EPROZ00100 TB_APP_HISTORY physical columns ==
select column_id,
       column_name,
       data_type,
       data_length,
       nullable
  from user_tab_columns
 where table_name = 'TB_APP_HISTORY'
 order by column_id;

prompt == EPROZ00100 legacy PROCESS_AGENT column probe ==
select column_id,
       column_name,
       data_type,
       data_length,
       nullable
  from user_tab_columns
 where table_name = 'TB_APP_HISTORY'
   and column_name in ('PROCESS_AGENT_CODE', 'PROCESS_AGENT_NAME')
 order by column_id;

prompt == PENDING-002 checkpoint columns for EPROC00118/RC branch ==
select table_name,
       column_id,
       column_name,
       data_type,
       data_length,
       nullable
  from user_tab_columns
 where table_name in ('TB_CHECK_POINTS_CS', 'TB_CHECK_POINTS_CU')
   and (column_name like '%EPROC00118%'
        or column_name like '%EPROC0_0218%'
        or column_name like '%0218%')
 order by table_name, column_id;

prompt == PENDING-007/PENDING-010 EPROC00118 score parameter summary ==
with vars(var_name) as (
    select 'B_V1' from dual union all
    select 'B_V10' from dual union all
    select 'B_V14' from dual union all
    select 'B_V18' from dual union all
    select 'B_V21' from dual union all
    select 'B_V4' from dual union all
    select 'B_V5' from dual union all
    select 'B_V20' from dual union all
    select 'B_V19' from dual union all
    select 'B_V9' from dual union all
    select 'B_V6' from dual union all
    select 'B_V7' from dual union all
    select 'B_V8' from dual union all
    select 'B_V2' from dual union all
    select 'B_V3' from dual union all
    select 'B_V22' from dual union all
    select 'B_V15' from dual union all
    select 'B_V16' from dual union all
    select 'B_V17' from dual union all
    select 'B_V11' from dual union all
    select 'B_V12' from dual union all
    select 'B_V13' from dual
)
select v.var_name,
       count(d.doc_id) as row_count,
       count(distinct d.var_code) as var_code_count,
       min(d.st_date) as min_st_date,
       max(d.st_date) as max_st_date,
       sum(case when d.st_date is null then 1 else 0 end) as null_st_date_count,
       min(d.end_date) as min_end_date,
       max(d.end_date) as max_end_date,
       sum(case when d.end_date is null then 1 else 0 end) as null_end_date_count,
       sum(case when d.score is not null
                 and not regexp_like(trim(d.score), '^-?[0-9]+(\.[0-9]+)?$')
                then 1 else 0 end) as nonnumeric_score_count
  from vars v
  left join tb_score_card_param_detail d
    on d.var_name = v.var_name
 group by v.var_name
 order by v.var_name;

prompt == PENDING-016 nonnumeric EPROC00118 score seed detail ==
with vars(var_name) as (
    select 'B_V1' from dual union all
    select 'B_V10' from dual union all
    select 'B_V14' from dual union all
    select 'B_V18' from dual union all
    select 'B_V21' from dual union all
    select 'B_V4' from dual union all
    select 'B_V5' from dual union all
    select 'B_V20' from dual union all
    select 'B_V19' from dual union all
    select 'B_V9' from dual union all
    select 'B_V6' from dual union all
    select 'B_V7' from dual union all
    select 'B_V8' from dual union all
    select 'B_V2' from dual union all
    select 'B_V3' from dual union all
    select 'B_V22' from dual union all
    select 'B_V15' from dual union all
    select 'B_V16' from dual union all
    select 'B_V17' from dual union all
    select 'B_V11' from dual union all
    select 'B_V12' from dual union all
    select 'B_V13' from dual
)
select var_name,
       var_code,
       score,
       var_desc,
       st_date,
       end_date
  from tb_score_card_param_detail
 where var_name in (select var_name from vars)
   and score is not null
   and not regexp_like(trim(score), '^-?[0-9]+(\.[0-9]+)?$')
 order by var_name, var_code, st_date;

prompt == PENDING-012 EPROC00118 TB_API_AUTH target rows ==
with endpoints(api_id, expected_roles, source_i0_api_id) as (
    select 'epl-sele-c0-corporateScorecard-list', '001;002;003;101;102;103;201;202;203;301;302;401;404;405',
           'epl-sele-i0-corporateScorecard-list' from dual union all
    select 'epl-info-c0-corporateScorecard', '001;002;003;101;102;103;201;202;203;301;302;401;402;403;404;405',
           'epl-info-i0-corporateScorecard' from dual union all
    select 'epl-calc-c0-corporateScorecard', '001;002;102;103',
           'epl-calc-i0-corporateScorecard' from dual union all
    select 'epl-save-c0-corporateScorecard', '001;002;102;103',
           'epl-save-i0-corporateScorecard' from dual
)
select e.api_id,
       e.expected_roles,
       case when target.api_id is null then 'MISSING' else 'FOUND' end as target_status,
       target.role as target_role,
       target.ref_function_id as target_ref_function_id,
       e.source_i0_api_id,
       source.role as source_i0_role,
       source.ref_function_id as source_i0_ref_function_id
  from endpoints e
  left join tb_api_auth target
    on target.api_id = e.api_id
  left join tb_api_auth source
    on source.api_id = e.source_i0_api_id
 order by e.api_id;

exit


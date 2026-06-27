# EPROZ00700 deputy PK reverify findings

Status: 等人審

## Conclusion

✅ 已對齊複合 PK。`TB_EMP_PROXY` entity 使用 `@EmbeddedId`，key 由 `EMP_ID` + `STR_TIME` 組成；deputy `save` 只會在同一組 `(EMP_ID, STR_TIME)` 上 upsert，不會按 `EMP_ID` 覆蓋一人所有代理期間；delete 也不是按 `EMP_ID` 全刪，而是至少帶 `EMP_ID` + `STR_TIME` 單筆識別條件。

## DB authority

| Evidence | DB reality |
|---|---|
| `<epro-db>\out\legacy_schema_reverify_new02_pk.tsv:139-140` | `TB_EMP_PROXY_PK` column order is `EMP_ID`, `STR_TIME`. |
| `<epro-db>\out\legacy_schema_reverify_new02_columns.tsv:1023-1029` | `EMP_ID VARCHAR2(10) NOT NULL`, `STR_TIME TIMESTAMP(6) NOT NULL`, plus non-key columns `PROXY_ID`, `END_TIME`, `UPDATE_EMP_ID`, `UPDATE_DATE`, `RETURN_CASE_TO_CA`. |
| `docs/build-tasks/legacy-schema-db-reverify-findings.md:45` | Earlier single-key assertion was DB-pushed back; correct PK is `PK(EMP_ID, STR_TIME)`. |
| `docs/build-tasks/legacy-schema-db-reverify-findings.md:70` | Linked impact explicitly names deputy entity identity and upsert/delete assumptions. |

## Findings

| Question | Code evidence | Finding | Verdict |
|---|---|---|---|
| Entity `@Id` form | `backend/src/main/java/khd/svc/epro/entity/TBEmpProxyEntity.java:14` maps `TB_EMP_PROXY`; `backend/src/main/java/khd/svc/epro/entity/TBEmpProxyEntity.java:17-18` declares `@EmbeddedId private TBEmpProxyId id`; `backend/src/main/java/khd/svc/epro/entity/TBEmpProxyEntity.java:35-43` declares `@Embeddable TBEmpProxyId` with `EMP_ID` and `STR_TIME`; `backend/src/main/java/khd/svc/epro/repository/TBEmpProxyRepository.java:16` uses `JpaRepository<TBEmpProxyEntity, TBEmpProxyId>`. | Entity is composite `@EmbeddedId`, not single `@Id EMP_ID`. | ✅ aligned |
| Save / upsert | `backend/src/main/java/khd/svc/epro/controller/common/DeputyController.java:58-60` routes insert to `deputyService.doInsertDeputy`; `backend/src/main/java/khd/svc/epro/service/common/impl/DeputyServiceImpl.java:128-134` chooses `empId` and sets `tbEmpProxyId.strTime` + `tbEmpProxyId.empId`; `backend/src/main/java/khd/svc/epro/service/common/impl/DeputyServiceImpl.java:135-140` sets payload fields and id; `backend/src/main/java/khd/svc/epro/service/common/impl/DeputyServiceImpl.java:141` calls `tBEmpProxyRepository.save(tbEmpProxyEntity)`. | Save key is `(empId, strTime)`. Same employee with different `STR_TIME` can be separate rows; only the same composite key is upserted. No insert path evidence of pre-delete or overwrite by `EMP_ID` alone. | ✅ aligned |
| Query shape | `backend/src/main/java/khd/svc/epro/repository/TBEmpProxyRepository.java:26-31` filters by date range and optional `PROXY.EMP_ID`, orders by `PROXY.STR_TIME`; `backend/src/main/java/khd/svc/epro/service/common/impl/DeputyServiceImpl.java:178-195` iterates the returned list into `deputyList`. | Query is list-oriented and date-range oriented; it does not assume one row per `EMP_ID`. | ✅ aligned |
| Delete | `backend/src/main/java/khd/svc/epro/dto/request/common/deputy/DeleteDeputyRequest.java:11-26` carries `deputyDate`, `deputy`, `applicant`, `isOthers`, `returnCaseToCa`; `backend/src/main/java/khd/svc/epro/service/common/impl/DeputyServiceImpl.java:204-212` splits `deputyDate` into `strTime/endTime`, derives `empId`, then calls repository delete; `backend/src/main/java/khd/svc/epro/repository/TBEmpProxyRepository.java:39-50` deletes with `EMP_ID = :empId` and `STR_TIME = TO_DATE(:strTime, 'DD/MM/YYYY')`, plus `END_TIME`, `PROXY_ID`, `RETURN_CASE_TO_CA` guards. | Delete is not `EMP_ID` full delete. It targets the composite-key row by `EMP_ID + STR_TIME`, with extra guards from the selected UI row. | ✅ aligned |

## Scope notes

- This recon is backend read-only. No backend code was changed.
- No `deputy` PK repair card is opened from this evidence; the specific feared gap, "single `EMP_ID` key causing one-person all-period overwrite/delete", was not found.
- Separate from the PK question, some DTO/UI parsing still works with 5-character displayed employee ids (`backend/src/main/java/khd/svc/epro/dto/request/common/deputy/InsertDeputyRequest.java:25-32`, `backend/src/main/java/khd/svc/epro/service/common/impl/DeputyServiceImpl.java:205-207`) while DB column length is 10. This is not classified as the composite-PK gap here; review only if a later employee-id-length card is opened.

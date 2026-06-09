# QA Cases — EPROZ00800 Revised Item

> 每條 `covers: Rn`（對 `spec.md`）；上游＝PRD `CDC-EPRO-0001 v1.1` §10。
> `@PENDING` = 受 `RP1`(TBD-006) 等未關 TBD 控制，**TBD 關閉前不列入驗收門檻 ⑤**，但先寫好。
> Gate ④＝可跑綠、⑤＝每個 `Rn` 至少被一條 case `covers`。

## 由 PRD §10 轉入
| ID | covers | Given / When / Then | DB 驗證點 |
|---|---|---|---|
| QA-001 | R2 | 案件有 REVISED_ITEM 資料 / 開頁 init-query / 顯示既有勾選 + REASON_MEMO | `TB_REVISED_ITEM` by APPLICATION_NO 與畫面一致 |
| QA-002 | R2,R9 | 案件無 REVISED_ITEM、但 code table 有選項 / init-query / 顯示選項、ITEM 初始空白 | `TB_REVISED_ITEM` 無資料；revisedType 來自 `TB_COMMON_FIELD_OPTIONS` |
| QA-003 | R3 | 未勾任一 / 按儲存 / 阻擋 + 提示至少選一 | 無新增/異動 |
| QA-004 | R4 | 已勾但 REASON 空 / 按儲存 / 阻擋 + 提示必填 | 無新增/異動 |
| QA-005 | R5 | `LON_TYPE_CODE=03` / 進頁 / ITEM1 強制勾且不可編輯 | `LON_TYPE_CODE=03`；儲存後 ITEM1=Y |
| QA-006 | R6 | `isCU=true` / 進頁 / ITEM3 強制不勾且不可編輯 | 儲存後 ITEM3=N |
| QA-007 `@PENDING RP1` | R13.1 | 既有 ITEM2=Y、新=N、reference 有 guarantor / 確認提示後儲存 / 清目前 guarantor 並由 reference 還原 | `GUARANTOR_INFO`/`_CORP` 筆數與 reference 一致；`IS_ANY_GUARANTOR` 正確 |
| QA-008 `@PENDING RP1` | R13.3 | 既有 ITEM3=Y、新=N、reference 有 collateral / 確認後儲存 / 清 collateral 並還原 | `COLL_*`/`COLL_PROVIDER_INFO`/`COLL_TITLE_REGIS_OWNER` 正確；`IS_ANY_COLLATERAL_PROVIDER` 更新 |
| QA-009 `@PENDING RP1` | R13.4,R13.5 | ITEM1/4~11 任一 Y→N / 確認後儲存 / detail 依組合刪或還原 | `LOAN_CONDITION_DETAIL`/`REVISED_ITEM_DETAIL` 符 RI-MAT-004/005 |
| QA-010 | R13.6 | `LON_TYPE=04`、既有 ITEM12=N、新=Y / 儲存 / 刪 fee | `LOAN_CONDITION_FEE` 目前 APPLICATION_NO 無資料 |
| QA-011 | R14 | 備 IS/IU/CS/CU 四種案件 / 各儲存 / 正確 checkpoint 表 + page-menu flag | `CHECK_POINT_RC`/`_IU`/`_CORP`/`_CU` 對應 `_0260` 欄=Y |
| QA-012 | R10 | execute 中模擬 DAO exception / 送出 / rollback + `COMMON_MSG_SAVE_FAIL` | `TB_REVISED_ITEM`、關聯表、checkpoint **均無部分更新** |

## SRS 補強（PRD §10 未涵蓋、但規則需驗）
| ID | covers | Given / When / Then | 驗證點 |
|---|---|---|---|
| QA-013 | R10 | execute endpoint / 呼叫 / **為 POST**（非 GET）| `epl-case-insert-reviseditem` method=POST |
| QA-014 | R9 | execute body item 帶非 Y/N（如空字串/"X")/ 送出 / BE 拒絕或正規化、DB 不存非 Y/N | `TB_REVISED_ITEM.ITEMn ∈ {Y,N}` |
| QA-015 | R11 | request `isNotSame=false` 但 DB 既有與新值不同 / execute / **後端仍依 DB 比對觸發側效**（不被 isNotSame 擋）| 側效依 DB 差異發生 |
| QA-016 | R14 | execute 成功 / response / 含 `pageMenuCondition`（重處理頁 key=Y）| response DTO 有 pageMenuCondition |
| QA-017 | R4 | REASON 輸入 3001 字 / 送出 / 阻擋（上限 3000）；前後空白 trim | DB REASON ≤3000、已 trim |
| QA-018 | R1 | 模擬 attrMap 取得失敗 / 開頁 prompt / 回 `MSG_INITIAL_FAIL`、停止載入 | — |
| QA-019 | R7 | `attrMap.isEdit=false` / 進頁 / 所有欄位唯讀 + 隱藏完成鈕 | — |
| QA-020 | R8 | checkbox 與既有不同 / 按儲存 / 送出前顯示「移除會清除相關修改」提示，確認後才送 | — |
| QA-021 | R12 | 案件已有 REVISED_ITEM / execute / 舊筆被刪、新 ITEM1~14+REASON+UPD_DATE 正確 insert | `TB_REVISED_ITEM` 僅 1 筆且值正確 |

## 覆蓋率（gate ⑤）
- R1：QA-018｜R2：QA-001/002｜R3：QA-003｜R4：QA-004/017｜R5：QA-005｜R6：QA-006｜R7：QA-019｜R8：QA-020｜R9：QA-002/014｜R10：QA-012/013｜R11：QA-015｜R12：QA-021｜R13.1–5：QA-007/008/009（@PENDING RP1）｜R13.6：QA-010｜R14：QA-011/016｜R15：QA-012（**僅 rollback 分支**；成功/not-found path 尚無實 case → QA-022 RD 補，未撰寫）｜R16：QA-012（transaction）+ perf/log/audit（RD 補）。
- 每個 `Rn` 至少 1 case ✅；但 R15 目前僅覆蓋 rollback 分支、R16 僅覆蓋 transaction，成功/not-found/perf/log/audit 之 happy/error path 待 RD 補實 case（QA-022 等尚未撰寫，不可當已覆蓋）。@PENDING（QA-007/008/009）＝待 TBD-006 關，不計入 gate⑤。

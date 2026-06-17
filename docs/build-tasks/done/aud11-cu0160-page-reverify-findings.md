# AUD-11 CU0160 Page Reverify Findings

Date: 2026-06-17

## Conclusion

**總判：UNFOUND，先不關 AUD-11。**

- 新 FE/BE source 未找到獨立 `EPROCU0160`；實際 corporate Loan Condition pageCode、route、endpoint 都指向 `EPROCSU0160` / `epl-*-csu-*`。
- 但本 checkout 未包含 `TB_PAGE_MENU` row data，只有 schema 與查詢邏輯；無法用決定性 routing row 證明 CU 0160 的 `PAGE_CODE` 實際為 `EPROCSU0160`。
- 另有一個實作風險：`CsuLoanConditionServiceImpl` 依 `secureAttribute` 選 CS/CU checkpoint table 後，讀的 key 是 `EPROISU0160`，但 CS/CU 新表欄位都是 `EPROCSU0160`。因此不能宣稱「CU 分流完全正確」。

本次未使用 `feature-inventory`、owner inventory、`docs/legacy/page-mapping.md` 作為判定證據。

## Findings Table

| 對象 | 新系統 file:line | routing(pageMap) | legacy 對照 | 結論 |
|---|---|---|---|---|
| FE pageCode / route | `frontend/src/app/core/models/common/page-code.model.ts:51` 定義 `C_LoanCondition = 'EPROCSU0160'`；`frontend/src/app/pages/case-edition/sub-pages/corporate/corporate-routing.module.ts:90-97` 將 `corporate/loan-condition` route 綁到 `CaseEditionPageCode.C_LoanCondition`；`frontend/src/app/pages/case-edition/config/case-edition-navlink-config.ts:103-105` 將此 key 導到 `corporate/loan-condition`。 | FE tab 由 `pageMap` key 對 `navLinks` key 決定顯示：`frontend/src/app/core/models/pages/case-edition/case-edition-tab-control.ts:65-75`。未找到新 FE `EPROCU0160` hit。 | 舊 CS/CU 各自有 JSP funcId：`legacy-epro/WebContent/html/cathaybk/system/epro/cs/EPROCS_0100/EPROCS0160.jsp:30-34`、`legacy-epro/WebContent/html/cathaybk/system/epro/cu/EPROCU_0100/EPROCU0160.jsp:30-34`。 | 新 FE 實際頁是 `EPROCSU0160`；獨立 `EPROCU0160` source UNFOUND。 |
| FE API surface | `frontend/src/app/pages/case-edition/sub-pages/corporate/loan-condition/services/api.service.ts:94-97` 呼叫 `epl-info-csu-loan-condition`；`api.service.ts:133-136` 呼叫 `epl-sele-csu-loan-condition-list`；`api.service.ts:152-155` 呼叫 `epl-save-csu-loan-condition`；`api.service.ts:168-170` 呼叫 `epl-case-csu-approved-case-list`。 | 這些 API 都在 corporate `loan-condition` route 下使用；沒有 `epl-*-cu-loan-condition` 或 `EPROCU0160` 新 FE endpoint。 | 舊 trx 仍是兩支 handler：`legacy-epro/JavaSource/com/cathaybk/epro/cs/trx/EPROCS_0160.java:53-61`、`legacy-epro/JavaSource/com/cathaybk/epro/cu/trx/EPROCU_0160.java:53-61`。 | 新 FE endpoint 實作併到 CSU；獨立 CU endpoint UNFOUND。 |
| BE controller / endpoint | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuLoanConditionController.java:21-23` 是 `CsuLoanConditionController`；`CsuLoanConditionController.java:35-38`、`:88-91`、`:127-130` 分別提供 `epl-sele-csu-loan-condition-list`、`epl-info-csu-loan-condition`、`epl-save-csu-loan-condition`。新 BE exact search 未找到 `EPROCU0160`。 | `backend/src/main/java/khd/svc/epro/repository/TBLonSummaryInfoRepository.java:425-433` 以 `TB_LON_SUMMARY_INFO` join `TB_PAGE_MENU` 取 `PAME.PAGE_CODE AS "pageCode"`；`backend/src/main/java/khd/svc/epro/service/common/impl/EPROAuthorizationServiceImpl.java:337-344`、`:371-388` 將 `pageCode` 字串拆成 `pageMap` key/value。 | 舊 `EPROCS_0160` / `EPROCU_0160` handler 僅 funcId、URL、module name 分離，主要流程同構；見 trx diff anchors above。 | 新 BE actual endpoint 是 CSU；但缺 `TB_PAGE_MENU` row data，不能驗明 CU row 實際指向 `EPROCSU0160`。 |
| `TB_PAGE_MENU` / new-case pageMap | `backend/src/main/java/khd/svc/epro/repository/TBPageMenuRepository.java:16-24` 以 `lonAttribute`、`secureAttribute`、`productCode`、`lonTypeCode` 查 `PAGE_CODE`；`backend/src/main/java/khd/svc/epro/entity/TBPageMenuEntity.java:21-34` 定義這些欄位。 | `backend/src/main/java/khd/svc/epro/service/common/impl/NewCaseApplicationServiceImpl.java:241-260` 取 `findPageCode(...)` 後把 page code token 放進 `insertCheckMap`。本 repo / epro-db out 只有 schema，未找到 `TB_PAGE_MENU` row export。 | 舊 legacy 有 DAO，但非新 row 證據；本次不以 legacy page mapping 表推論。 | 決定性 routing row 缺失，總判須保留 `UNFOUND`。 |
| CS/CU checkpoint schema and update | `backend/src/main/java/khd/svc/epro/entity/TBCheckPointsCsEntity.java:53-54` 與 `backend/src/main/java/khd/svc/epro/entity/TBCheckPointsCuEntity.java:50-51` 都是 `EPROCSU0160` 欄位；`backend/src/main/java/khd/svc/epro/repository/TBCheckPointsCuRepository.java:42-47` CU select 也含 `EPROCSU0160`。 | `backend/src/main/java/khd/svc/epro/util/NewCaseUtil.java:556-564` CS 建案寫 `insertCheckMap.get("EPROCSU0160")`；`NewCaseUtil.java:628-635` CU 建案也寫 `insertCheckMap.get("EPROCSU0160")`。`backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuMainBorrowerInfoServiceImpl.java:277-297`、`CsuGuarantorServiceImpl.java:321-332`、`CsuCoBorrowerInfoServiceImpl.java:526-538` 都按 CS/CU 表分流但寫 `EPROCSU0160`。 | 舊 CS/CU checkpoint key 分別是 `EPROCS_0160` / `EPROCU_0160`：`legacy-epro/WebContent/html/cathaybk/system/epro/cs/EPROCS_0100/EPROCS0160.jsp:814-818`、`legacy-epro/WebContent/html/cathaybk/system/epro/cu/EPROCU_0100/EPROCU0160.jsp:800-804`。 | 新 checkpoint 設計明顯併為 `EPROCSU0160`，含 CU table；這支持併頁，但仍需 row data 補強 routing。 |
| CS/CU 分流與風險 | `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuLoanConditionServiceImpl.java:81-85` 同時注入 CS/CU checkpoint repository；`CsuLoanConditionServiceImpl.java:590-596` 依 `secureAttribute` 選 `TB_CHECK_POINTS_CS` 或 `TB_CHECK_POINTS_CU`。 | 同一段後續讀 `StringUtil.nvl(sql9Entity.get("EPROISU0160"))`：`CsuLoanConditionServiceImpl.java:597`，但新 CS/CU checkpoint 欄位是 `EPROCSU0160`。 | 舊 CU module 使用 `EPRO_TB_CHECK_POINT_CU` 且 key 為 `EPROCU_0160`：`legacy-epro/JavaSource/com/cathaybk/epro/cu/module/EPROCU_0160_mod.java:337-338`、`:356`、`:383-384`；舊 CS module 使用 corporate checkpoint：`legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0160_mod.java:333-334`、`:352`、`:411-412`。 | `secureAttribute` 表分流存在，但 0160 key mismatch 使「CU 分流正確」不能成立；需另開小修卡或人審確認是否為既知 bug。 |
| legacy CS/CU twin 程度 | 新系統不保留舊 `EPROCS_0160` / `EPROCU_0160` 新頁名；只保留 `EPROCSU0160`。 | N/A | 舊 CS/CU JSP/trx 高度同構，但不是逐字相同。CU loan purpose 較寬：`legacy-epro/JavaSource/com/cathaybk/epro/cu/module/EPROCU_0160_mod.java:87-91` vs CS `EPROCS_0160_mod.java:87-88`；CS 有房貸/擔保品 deviation 回寫：`EPROCS_0160_mod.java:370-415`，CU execute 省略該段並只更新 CU checkpoint：`EPROCU_0160_mod.java:374-388`。 | legacy 命名 artifact / 可共用頁的判斷「有支持」，但舊碼差異要求新頁以 `secureAttribute` guard 正確處理，不足以直接判 typo 關案。 |

## Direct Answer

- **新系統 source 層：**沒有找到獨立 `EPROCU0160`；目前實作是 `EPROCSU0160` pageCode + corporate `loan-condition` route + `CsuLoanConditionController`。
- **routing row 層：**`TB_PAGE_MENU` row data 缺失，不能證明 `LON_ATTRIBUTE=C`、`SECURE_ATTRIBUTE=U`、0160 對應 row 的 `PAGE_CODE` 實際是 `EPROCSU0160`。
- **服務正確性層：**CS/CU checkpoint table 分流存在，但 `CsuLoanConditionServiceImpl.java:597` 的 `EPROISU0160` key 與 `TB_CHECK_POINTS_CS/CU.EPROCSU0160` 不一致。

## Disposition

**AUD-11 建議先維持 open / pending。**

Minimal viable next step:

```sql
SELECT LON_ATTRIBUTE, SECURE_ATTRIBUTE, PRODUCT_CODE, LON_TYPE_CODE, PAGE_CODE
FROM TB_PAGE_MENU
WHERE LON_ATTRIBUTE = 'C'
  AND SECURE_ATTRIBUTE = 'U'
  AND PAGE_CODE LIKE '%0160%';
```

判定門檻：

- 若 row `PAGE_CODE` 含 `EPROCSU0160` 且修正/確認 `CsuLoanConditionServiceImpl.java:597` checkpoint key 後 CU flow 正常，才可改判 **typo／併入正確**。
- 若 row `PAGE_CODE` 含 `EPROCU0160`，現新系統沒有對應 FE/BE source，應改判 **真分歧／缺口**。

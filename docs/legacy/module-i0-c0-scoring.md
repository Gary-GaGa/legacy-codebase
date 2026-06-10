# i0 / c0 財報 · 評分 · CBC 盤點（D6 結果）

> **結論：i0/c0 可共用「同一套 shell + config」**——但只共用外殼與流程配置，**各頁 trx/DAO/SQL/表不可硬合**。
> c0 的評分/財報/CBC **不是獨立旁路**：被 `pageCheckMap`/checkpoint 綁在主流程裡 → **維持綁定**。
> ⚠️ **修正**：這些子頁**多為「輸入表單」（會寫回），非唯讀檢視**；唯 FinStatement（0116/0119/0216/0219）額外有 printPDF（R2 暫緩）。

## 1. 容器與子頁
### i0（容器 `EPROI0_0110`，依 `BUSINESS_TYPE` 切頁）
| funcId | 用途 | 類型 |
|---|---|---|
| 0111 | Financial Evaluation | 輸入 |
| 0112 | CBC | CBC 查詢/維護 |
| 0113 | Scorecard（person）| 輸入 |
| 0114 | Scorecard（collateral）| 輸入 |
| 0115 | Borrower Group Exposure | 輸入 |
| 0116 | Financial Statement_GI | 輸入 + 報表列印 |
| 0117 | Financial Evaluation_GI | 輸入 |
| 0118 | Corporate Scorecard | 輸入 |
| 0119 | Financial Statement_FI | 輸入 + 報表列印 |
| 0120 | Financial Evaluation_FI | 輸入 |
### c0（容器 `EPROC0_0110`）
`0112` CBC、`0114` Scorecard（CS/!old 分支）、`0115` BGE、`0116` FinStmt_GI(+print)、`0117` FinEval_GI、`0118` Corp Scorecard、`0119` FinStmt_FI(+print)、`0120` FinEval_FI。
### review shell（`0210` 這層才用 `pageCheckMap` 管完成度）
- `EPROC0_0210_mod` 的 `CHANGE_PAGE` 把 `0211/0213/0216/0217/0218/0219/0220` 綁成同組流程頁。
- 子頁：0211 FinEval / 0212 CBC / 0213 Scorecard(person) / 0214 Scorecard(collateral) / 0215 BGE / 0216 FinStmt_GI(+print) / 0217 FinEval_GI / 0218 Corp Scorecard / 0219 FinStmt_FI(+print) / 0220 FinEval_FI。

## 2. i0 vs c0：平行、可共用 shell（非 1:1 頁碼）
- **共用**：外層 shell、tab manager（`Tabs.js`）、`pageCheckMap`、done 狀態、共用 layout、`getTabsCheckPage()`/`getCheckedProgress*()`/`isAllTabsCheck`。
- **不可硬合**：各頁 trx / DAO / SQL / 表 / 欄位。
- 差異軸：前綴 `EPROI0_*` vs `EPROC0_*`；checkpoint 表（個金 `TB_CHECK_POINT`/`_IU`、企金 `TB_CHECK_POINT_RC_CORP`/`_RC_CU`）；角色分支（isIS/isIU vs isCS/isCU）；tab 組合（依 `BUSINESS_TYPE`/`old`/CS-CU）。

## 3. c0 評分橋接（綁主流程）
鏈路：前端每次存檔送 `pageCheckMap` → 後端 `getTabsCheckPage(pageCheckMap,"EPROC0_0210")` 取本 shell 的 tabs → `getCheckedProgressRC_CORP()` 算 `isAllTabsCheck` → 前端依此更新外層流程節點 `done`。
- `pageCheckMap` = **整個 shell 的頁面完成狀態集合**（非單頁），讓 `pageMenu` 依整體完成度更新外層 done。
- c0 評分**是主流程檢核步驟**（切業務型態會連同 `0218` 重置）→ **維持綁定，勿拆旁路**。

## 4. 資料來源（✅ 新 DB 名，無 `EPRO_` 前綴；明細 schema 見 `db-schema-catalog.md` B3）
- **CBC**：`TB_CBC_BBL(_INFO)`、`TB_CBC_BGL(_INFO)`、`TB_CBC_GBGL(_INFO)`。查詢/維護，非報表。
- **財報**：`TB_FIN_STATEMENT_MAIN`、`_BALANCE_FI/GI`、`_CASHFLOW_FI/GI`、`_INCOME_FI/GI`；`0216`/`0219` 加 `RptUtils`/`ReportUtil` 產 PDF（R2）。
- **財務評估**：`TB_FINANCIAL_EVALUATION_INFO`/`_INFO_CORP`/`_GI`/`_FI`/`_INFO_S`(staff)、`TB_IND_SCRCARD`、checkpoint `TB_CHECK_POINTS_IS/IU/CS/CU`。
- **Scorecard**：`TB_SCORE_CARD_PARAM_MAIN/SUB/DETAIL`、`TB_MAIN_BORROWER_PERSONAL/WORK/FAMILY_INFO`、`TB_COLL_ASS`、`TB_CORP_SCRCARD`。
- **輸入（寫回）**：0111/0211、0112/0212、0113/0213、0114/0214、0115/0215、0117/0217、0118/0218、0120/0220。
- **可編輯也可列印**：0116/0119、0216/0219。

## 5. 報表/列印（R2 暫緩）
- 僅 `0116`/`0119`/`0216`/`0219` 走 printPDF/Jasper（**頁面本身仍是輸入表單**；PDF 匯出依 R2 暫緩）。其餘純畫面/存檔。

## 6. CBC = 獨立「資料接入」track（R8，非報表軌）
- CBC 是外部信用/聯徵資料的**資料接入與維護**；repo 內透過本地 `EPRO_TB_CBC_*` 表讀寫，未見獨立報表軌。
- 定位：**外部資料整合**；shell 可共用，**資料來源/adapter 分開**。

## 7. → 新架構判定
- [x] i0/c0 **共用「shell + config」**（個人/企金僅 config 差；各頁 trx/表分開）。
- [x] c0 評分**併入** `loan-application` shell（`group=scoring`，`checkStatus` 由 `pageCheckMap` 完成度回寫）；**綁 M4/M5**。
- [x] **CBC 拆為獨立資料接入 track（R8）**；FinStatement PDF 匯出歸 R2。
- **真正該抽的共用資產**（一次做好，loan flow / i0 / c0 共用）：
  1. **tab shell**（外層流程 + 內層 tabs）
  2. **`pageCheckMap` / checkpoint 完成度回寫**
  3. **done 狀態聚合**（`isAllTabsCheck` → 外層節點 done）
  4. **print / open 行為封裝**

# EPROZ00800 SRS bundle — spec-reviewer 語意審查 findings（2026-06-16）

> **怎麼來的**：機械閘門 `check-srs-bundle.py` PASS（exit 0）後，依 CLAUDE.md §4「先機械、再語意」跑 `spec-reviewer`（唯讀 agent）審 `docs/specs/srs/EPROZ00800/`。**§6 紀律：審者不改、只報；裁定權在 owner/RD。本檔＝記帳，主流程改前須 owner 拍板。**
> **驗證註記**：B-1/B-2 的 PRD 依據我已 spot-check 坐實（見下）。⚠️ **一個坑**：PRD §6.4 是 markdown 表格、底線跳脫成 `MSG\_OVER\_COUNT\_LIMIT`——用 literal `_` grep 會誤判「PRD 無此碼」。**讀 rendered 內容才準**（我第一次 grep 差點誤判 reviewer confabulate，實為 reviewer 對、我的 grep 漏跳脫）。

## 🔴 Blocker（未登記、新；已坐實）
### B-1 — PRD §6.4 兩個 initQuery 錯誤碼在 SRS R15 + openapi 完全落空、REQ-007 未完整承載、無 disclaim
- **PRD 依據（坐実）**：`PRD-CDC-EPRO-0001-v1.1-EPROZ00800.md` §6.4 Error Response 表（≈line 438-439）列：
  - `MSG_OVER_COUNT_LIMIT`｜400｜initQuery｜查詢筆數超過系統限制｜提示縮小查詢範圍
  - `MSG_QUERY_FAIL`｜500｜initQuery｜查詢失敗｜顯示查詢失敗
- **SRS 落空（坐實）**：`spec.md:92`（R15）只承載 `MSG_INITIAL_FAIL`/`COMMON_MSG_ERROR_LON`/`MSG_DATA_NOT_FOUND`/`COMMON_MSG_SAVE_FAIL`/`COMMON_MSG_SAVE_SUCCESS`——**這兩碼皆無**（spec.md 用未跳脫 `_`、grep 確認 absent）。`openapi.yaml` query endpoint 只 200/400/404，**無 500、400 也只 map `COMMON_MSG_ERROR_LON`**（`openapi.yaml:32` 的 500 是 execute rollback，非 query）。
- **追溯破口**：`spec.md:141` Traceability `REQ-007→R15`，但 R15 漏這兩碼 → REQ-007 未完整承載（違 DoD「每 PRD REQ 完整對應、缺漏 error 要補」）。
- **修向（owner/RD 裁）**：R15 補這兩碼 + openapi query endpoint 補 400(`MSG_OVER_COUNT_LIMIT`)/500(`MSG_QUERY_FAIL`) response；**或**明文 disclaim「init-query 無分頁→count-limit 非本頁適用」+ owner 簽。

### B-2 — R15 把「查詢失敗(500)」誤併入「輸入錯誤(400)」，與 PRD §6.4/§8 語意不一致
- **PRD 依據（坐實）**：§6.4 表明分兩列——`COMMON_MSG_ERROR_LON`＝**400**（APPLICATION_NO 空白/不合法，輸入錯誤）；`MSG_QUERY_FAIL`＝**500**（查詢失敗）。兩者 HTTP status + 情境**不同**。
- **SRS 不一致**：`spec.md:92` R15 寫「init/execute **查詢失敗**或查無資料 → `COMMON_MSG_ERROR_LON`/`MSG_DATA_NOT_FOUND`」——把「查詢失敗」折進 input-error 碼，丟了 500 path。
- **修向**：R15 區分「輸入錯誤 400(`COMMON_MSG_ERROR_LON`)」與「查詢失敗 500(`MSG_QUERY_FAIL`)」兩條錯誤路徑、各自對碼。

> B-1/B-2 與已知 **R15 partial / QA-022 待補**（那是 QA 分支覆蓋）**不同類**——這是 SRS 漏承載 PRD 錯誤碼（完整性/一致性），機械閘門 gate⑤/Ⓢ 抓不到。

## 🟡 Should-fix（reviewer advisory；S-2 有旁證，餘未獨立深驗）
- **S-1**　Status 行頁碼形混用（`spec.md:5` vs R14 定版 `EPROISU01xx` `spec.md:89` vs BP4 仍 `0210~0290` `spec.md:122`）→ 統一頁碼形、BP4 註明 RP10 併頁，免 as-is/to-be 混淆。
- **S-2**（有旁證）　openapi `InsertRevisedItemResponse` object 形 vs PRD §6.3 `rtnList[0]/[1]` 陣列形（PRD API-003 坐實見 §6.3）→ 合理 to-be 整形但**未 disclaim**；建議 openapi response 註明形狀轉換，免 RD 按 PRD `rtnList` 實作衝突。
- **S-3**　`checkPointMap` client 送入（`openapi.yaml:68,91-96`）vs R14「BE 自行依 attribute 寫 checkpoint」「以 DDL 為準」→ client 送整個 map 與 R11「後端為準/不信前端」同源張力；RP11 只涵蓋 itemMap、未涵蓋此 → 建議補規則「checkPointMap 哪些 key BE 權威」。
- **S-4**　R8 `covers-prd: §2.3/§3.1-6`（`spec.md:63`）指散章非 REQ；矩陣掛 REQ-003 → 建議 R8 `covers-prd` 補 `REQ-003`，維持 Rn→REQ 乾淨上行。
- **S-5**　矩陣 R9 歸屬漂移（`spec.md:133` REQ-003 列）vs `qa-cases.md:41` R9=QA-002(REQ-002)/QA-014(REQ-003) 跨列 → 矩陣 R9 行註明兩 case。

## 🟢 Nit
- **N-1**　`schema.sql:22` `REASON_MEMO VARCHAR2(3000)` BYTE/CHAR 語意 → 多位元組下 R4「3000 字元」可測性隱缺；QA-017 驗證點補「以多位元組測 3000 字元邊界」。
- **N-2**　`spec.md:8` 版本欄塞 v0.5~v0.9 全史、逾百字 → 移獨立 changelog（純格式）。
- **N-3**　`openapi.yaml:7` `version 0.5.0-draft` vs `spec.md:8` v0.9 版號脫鉤 → 同步或註明獨立。

## meta — 機械閘門盲區（值得 owner 評估硬化）
機械層 `check-srs-bundle.py` **PASS** 卻沒抓到 B-1/B-2——**「PRD §6.4 Error Response 表 → SRS R15 + openapi response 的錯誤碼完整性/一致性」目前無機械 check**。同 06-16 批判輪2 的 gate 硬化精神，可評估加：gate 比對 PRD error 表 ↔ openapi responses ↔ Rn 錯誤碼集（漏碼/HTTP-status 不一致＝warn/fail）。**＝一次性發現 vs 轉換固有病**待 owner 判（若 PRD→SRS 常漏 error 碼＝固有病，值得 gate 化）。

## 處置（owner/RD 裁）
00800 標記「砍掉重建在即（Bible/PRD 待更新）」→ B-1/B-2 可 **(a)** 立即小修（R15 補 2 碼 + openapi query response + 拆 400/500，工小）、或 **(b)** 折進重建 backlog。**採納後須再審一輪**（改 R15 錯誤碼分支會牽動 openapi query response 與 QA-022 待補 case 範圍）。本檔不改 spec（§6 審者不改）。

> **✅ owner 裁定（2026-06-17）＝(b) 折進重建 backlog**：不立即小修；SR-B1/B2 留作 00800 重建**必須承載**的輸入——重建時 R15 補 2 碼（`MSG_OVER_COUNT_LIMIT` 400／`MSG_QUERY_FAIL` 500）+ 拆「輸入錯誤 400／查詢失敗 500」+ openapi query endpoint 補 400/500 response。**安全網＝gateⒺ**：`check-srs-bundle` 每跑必 warn 這 2 碼未承載，重建不可能漏。回填 `pending-register`、`STATUS §五`、`decisions.md` 06-17 列。

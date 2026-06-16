# Findings — 批次層 B001–B008 碼驗（AUD-10；F-OWN-1）

> **來源**：Codex 唯讀碼驗回報摘要（2026-06-16，owner 執行）。**完整 `file:line` 在 Codex 工作樹原檔**（`docs/build-tasks/aud10-batch-layer-reverify-findings.md`，untracked）——本檔為回報摘要的 planning-repo 留底，原檔 push 上來可取代。
> 卡＝`aud10-batch-layer-reverify.md`。**只報不改**。
> ⚠️ **關鍵：新系統批次「重新編號」，不對應 legacy 號碼**——以**職責**對映、非號碼（如 legacy B007 SFTP → 新 `EPROZ0B004`；新 `EPROZ0B005`＝mail sender ≠ legacy B005 匯率）。

## 對映結果
| legacy 批次 | 職責 | 判定 | 新系統等價物 | 性質 |
|---|---|---|---|---|
| **B005** 匯率排程 | 呼 `KH_B_FTR37001` 寫 `TB_EXCHANGE_RATE`（每日預匯入）| 🔴 **app 碼缺** | 新後端有 **inline 匯率 API 更新路徑**（＝A-1 `funcGetExchangeRate`，authorize 時觸發），但**無 scheduled batch 等價物**；新 `EPROZ0B005` 是 mail sender 且 `@Scheduled` 被註解、**不能抵** | **需 domain 判**（見下）|
| **B006** 放款結果檔 async | 讀 result/message 檔→更新通知/歷程/結案/狀態 | ✅ **FOUND** | 新 `EPROZ0B006`＝active scheduled result-file processor | app 有 |
| **B007** SFTP 檔案傳送 | 上傳/傳送批次輸出檔 | ✅ **FOUND** | 拆兩塊：新 `EPROZ0B004`＝排程下載/刪除結果檔 ＋ authorize 流程 **inline 上傳 T24 檔** | app 有 |
| **B008** DB/security log 歸檔 | 搬 log 到 yyyy 目錄 | ⚪ **UNFOUND** | 無 app 等價物 | **ops 確認**（logrotate/平台歸檔？）|
| B001 branch profile 匯入 | →`TB_BRANCH_PROFILE` | ❓ 待完整 findings | （摘要未列）| — |
| B002 emp profile 匯入 | →`TB_EMP_PROFILE` | ❓ 待完整 findings | （摘要未列）| — |
| B003 自動結案/逾期 | →`APP_HISTORY`/狀態 | ❓ 待完整 findings | （摘要未列）| — |
| B004 暫存報表清理 | 刪 Jasper/temp | ❓ 待完整 findings | （legacy B004≠新 B004；摘要未列 legacy B004 去留）| — |

## 結論／待裁
1. 🟢 **撥貸下游交付 FOUND**：B006（結果檔回寫）+ B007（SFTP/上傳 T24）皆有 app 等價物 → **A-1 換匯通 + 下游送檔通**，撥貸端到端的批次下游**不缺**（待 Phase V 實測串起來）。
2. 🔴 **B005 匯率排程＝唯一 app 碼缺，但需 domain 判「缺 vs 刻意」**：
   - 新設計用 **inline 換匯**（A-1，authorize 時抓）取代每日批次預匯入？→ 若**無其他路徑在非-authorize 時讀 `TB_EXCHANGE_RATE`**，則 inline 取代成立、**銷案**。
   - 若有功能（報表/其他頁）讀當日 `TB_EXCHANGE_RATE` 而不經 authorize → 缺每日批次＝**真缺口、需補排程**。
   - **動作**：派 Codex 唯讀查「`TB_EXCHANGE_RATE` 的所有 read 點」→ 有無非-authorize 讀者，再定缺/銷。
3. ⚪ **B008 log 歸檔**：非 app 碼缺、交 ops 確認（logrotate/平台）。
4. ❓ **B001–B004 待完整 findings**（摘要只覆蓋 P0/P1）：B001 連動 B-1 `T24_COMPANY` 接值來源（中優先）。

> 回填：feature-inventory 批次層、pending-register AUD-10、STATUS、decisions。B005 判「缺vs刻意」前 AUD-10 不結。

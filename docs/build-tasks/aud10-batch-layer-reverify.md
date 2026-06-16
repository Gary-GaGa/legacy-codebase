# Build Task — 批次層 B001–B008 碼驗（AUD-10；owner 盤點 F-OWN-1）

> ✅ **碼驗完整回（2026-06-16）→ findings `aud10-batch-layer-reverify-findings.md`（Codex 完整版，含 file:line + 新後端批次盤點）**：**6/8 FOUND**（B001/B002/B003/B004/B006/B007，新批次重編號）；🔴 **B005 匯率排程 app 碼缺**（待 domain 判 inline-取代 vs 漏建）；⚪ **B008 UNFOUND→ops**。**剩 B005 判定 + B008 ops 確認後收**。

> **性質**：唯讀碼驗（Codex 母資料夾，新後端 + legacy 對照）。**只報不改**。
> **背景**：owner 權威盤點表（`legacy/legacy-function-inventory.md`）列 **8 個批次 EPROZ0_B001–B008**，但我們 `feature-inventory`／`diff-vs-inventory` **從未當工作單位追蹤**（F-OWN-1，`refactor-audit/owner-inventory-reconcile.md`）。進度 % 因此漏掉整個批次層；其中 **B005/B006/B007 是撥貸端到端下游交付關鍵**（A-1 把換匯打通了，但「檔案真的送出去 T24」可能還缺批次等價物）。
> **目的**：回答「**新系統有沒有這 8 個批次的等價物？**」——逐個 found/UNFOUND/partial + `file:line`，缺的開卡。

## 待驗清單（owner 表職責）
| 批次 | legacy 職責 | 撥貸關聯 | 優先 |
|---|---|---|---|
| `EPROZ0_B001` | Branch/Dept profile 匯入 → `TB_BRANCH_PROFILE` | B-1 `T24_COMPANY` 接值來源 | 中 |
| `EPROZ0_B002` | Employee profile 匯入 → `TB_EMP_PROFILE` | deputy/權限基礎資料 | 中 |
| `EPROZ0_B003` | 自動結案/逾期放款 → `APP_HISTORY`/`CLO_REASON`/案件狀態 | 案件狀態機 | 中 |
| `EPROZ0_B004` | 暫存報表檔清理（Jasper/temp） | R2 報表 track | 低 |
| **`EPROZ0_B005`** | **匯率匯入（呼 `KH_B_FTR37001`）→ `TB_EXCHANGE_RATE`** | **撥貸換匯排程**（≠ A-1 內聯換匯，是另一條排程路）| **高** |
| **`EPROZ0_B006`** | **放款/訊息結果檔 → 更新通知/歷程/結案/狀態** | **撥貸 async 下游**（triage B-6）| **高** |
| **`EPROZ0_B007`** | **SFTP 檔案傳送** | **撥貸 T24 檔下游交付** | **高** |
| `EPROZ0_B008` | DB/security log 歸檔 | ops | 低 |

## 步驟
1. **新系統批次入口盤點**：grep 新後端 `@Scheduled`/`@EnableScheduling`、batch/job/scheduler package、`ApplicationRunner`/`CommandLineRunner`、quartz/spring-batch；列全部排程/批次入口 + `file:line`。
2. **逐批次對映**：每個 B001–B008 找新系統等價物（依職責/讀寫表/呼叫的 API 對，**非僅靠名稱**）→ `file:line`。
3. **判性質**（關鍵）：缺的要分兩類——
   - **app 碼缺**（新系統該有批次但無）＝真缺口、開卡。
   - **改外部排程**（新架構把批次移到外部 cron/k8s CronJob/排程平台觸發 app endpoint 或 SQL）＝**非 app 碼缺、是 ops 配置**，標明「待 ops 確認」不算 coding 缺口。
   - 不確定＝`UNFOUND`，不猜。
4. **撥貸三高優先**（B005/B006/B007）：特別坐實——若缺，撥貸即使 A-1 通、authorize 成功，**檔案/結果回寫/SFTP 下游可能斷**，端到端仍不完整。

## 鐵則
1. 唯讀；每結論附 `file:line`；推不出＝`UNFOUND`，不准拿 page-mapping/inventory 當證據。
2. 區分「app 內批次」vs「外部排程觸發」——後者非 app 碼缺口，別誤報。
3. 不改碼、不跑 build。

## 回報
產表：`批次 ↔ legacy 職責 ↔ 新等價物 file:line ↔ found/UNFOUND/partial ↔ 性質(app/ops/缺)`，寫 `docs/build-tasks/aud10-batch-layer-reverify-findings.md`。**先報清單給人審**：缺的（尤其 B005/B006/B007）→ 回填 feature-inventory 批次層 + 開修復卡；ops 類 → 交 ops。

> 過了：批次層從「進度盲區」收進 inventory；撥貸端到端的「下游交付」缺口坐實或排除（AUD-10 結）。

# Build Task — 新舊庫 schema 全量 diff（唯讀 recon；agent 自查）

> ✅ **完成（2026-06-12，審過）**：產出＝`schema-diff-findings.md`（**schema 事實 SSOT**，留 live）。頭條：old01≡new01、`OVSLXLON01`=舊 app schema（194 表）/`OVSLXLON02`=新（142 表）；54 舊表-only/2 新表-only（權限表×2）；44 加欄/12 刪欄（MARIAL→MARITAL 家族）；🔴 財評精度縮減（AUD-6）；column-order drift 349 欄/17 表。新增 AUD-6/7/8 入 `pending-register.md`。

> 載具：Codex＋DB 唯讀 wrapper（`C:\work\epro-db\new.cmd`/`old.cmd`；政策＝decisions §三：SELECT only、DML/DDL 禁止）。
> **動機**：文件版 schema 知識已兩度被 DDL 實查打臉（`EPRO_` 前綴誤判、`T24_COMPANY` 漏列＝B-1 假死路）——schema 事實的 SSOT 改為 **DB 實況**。本卡產出供 Phase V schema-map（撥貸 D8、c0/csu 整併風險）與 `db-schema-catalog` 校正。
> ⚠️ **context 衛生**：查詢結果**spool 到本機檔**（`C:\work\epro-db\out\`），agent 只讀檔做 diff、**不把全量 dump 貼進 context**；分批處理（每批 ~20 表）。

## 步驟
1. **定 owner**：兩庫各跑 `SELECT owner, COUNT(*) FROM all_tables WHERE table_name LIKE 'TB_%' GROUP BY owner;`——新庫已知有 `OVSLXLON01`/`OVSLXLON02` 兩 schema：**兩個都抽**，diff 時三方比（old vs new-01 vs new-02；01/02 間差異單獨列——本身就是 A-1 OQ-1 的證據）。
2. **抽 DDL 目錄**（每庫每 owner 一檔，spool）：
   ```sql
   SELECT table_name, column_id, column_name, data_type, data_precision, data_scale, nullable
   FROM all_tab_columns WHERE owner='<OWNER>' AND table_name LIKE 'TB_%'
   ORDER BY table_name, column_id;
   ```
3. **三類 diff**（寫 `docs/build-tasks/schema-diff-findings.md`）：
   - **表級**：舊有新無（含被整併者標推測去向）／新有舊無（新功能表）。
   - **欄級**（共同表）：新增／移除／型別變更／**精度變更（金額欄優先標 🔴）**／nullable 變更。
   - **新庫 01 vs 02**：schema 間差異（理論上應同構；不同構=發現）。
4. **重點對照清單**（findings 內獨立節）：checkpoint 表（舊 vs 新 `TB_CHECK_POINTS_*`/`TB_CHECK_POINT_*` 實名）、`TB_LON_SUMMARY_INFO`（PROJECT_CODE 等增欄）、`TB_BRANCH_PROFILE`（T24_COMPANY 佐證）、撥貸 `TB_DISBUR_*`/`TB_EXCHANGE_RATE`（已查部分引用即可）、`TB_COMMON_FIELD_OPTIONS`（舊 MSG_* vs 新 SYSTEM/FIELD_NAME 設計變更）。

## 鐵則
1. 唯讀 wrapper only；SELECT only；逐批 spool、不灌 context；中斷記斷點（已完成 owner/表範圍）於 findings 檔頭。
2. **只報 diff 不裁定**：發現的疑似風險（精度變更/欄移除）列清單給人審，不自行判 bug。
3. findings 引用格式：`表.欄: 舊型別 → 新型別`，金額/狀態欄標 emoji 嚴重度。

## 回報
- findings 檔＋三類 diff 計數（表級 X/Y、欄級 Z、01vs02 差異 N）；重點對照節;`git status --short`（規劃 repo 只多 findings 檔）。

> 過了：schema 知識 SSOT 換軌（`db-schema-catalog.md` 標註以 findings 為準）；撥貸 D8/Phase V schema-map 直接引用；A-1 OQ-1 拿 01vs02 差異佐證。

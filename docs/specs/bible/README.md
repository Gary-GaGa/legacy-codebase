# `specs/bible/` — 業務聖經（Bible）

> 🧭 **Model A**：Bible 內容（`bible-eproposal.md`）**已移母資料夾、Codex 擁**；本 repo 僅留本導覽。

> flow 第 ① 層：從 Legacy **反推**業務知識（EPRO Expert + AI），讓團隊不分角色一致理解業務。
> 內容＝**北極星、黃金旅程、user story**；鐵律＝**證據接地**（每個主張引 legacy `file:line` / 表名，AI 反推最易 confabulate 的一層）。

## 工具：`/legacy-to-bible <domain>`（已備）
反推 Bible 用 skill `.claude/skills/legacy-to-bible/`（Codex：`docs/env/codex/prompts/legacy-to-bible.md`）——證據接地、敘事非契約。

## 現況：專案級 Bible 已建檔
- ✅ **[`bible-eproposal.md`](bible-eproposal.md)** — 專案級 Bible（全端到端旅程：起案→審核→核定→LC→結案→撥貸），**v1.1-draft**（2026-06-17 ingest，取代 v1.0；v1.0 見 git history）。含北極星/決策準則/黃金旅程/角色/E2E×8/災難情境/**BR-001~030 / SC-001~031** ＋ DB 驗收錨點（OVSLXLON02：狀態碼字典 `TB_PROCESS_CODE`/角色 `TB_ROLE_DEFINE`/`TB_API_AUTH`）。
- 域級深掘（如 `bible-disbursement.md`）日後依需要再拆。
- ⚠️ 本版證據主以 `[HUMAN]`/`[CODE-TBD]` 標記，`file:line` 待 source 驗證階段回填。

下列既有分析仍為 Bible 的**原料/佐證**（補 `file:line` 證據時對照）：

| 原料 | 內容 |
|---|---|
| `../../legacy/module-is-iu-shell.md` | 個金主流程 shell（兩層頁籤、pageMap、IS/IU 差異） |
| `../../legacy/module-cs-cu-shell.md` | 企金主流程 shell（formatCS/CU、c0 橋接） |
| `../../legacy/module-i0-c0-scoring.md` | i0/c0 財報·評分·CBC 結構 |
| `../../legacy/page-mapping.md` | 舊 funcId → 新頁對應（≈250 JSP → 9 模組×兩流程） |
| `../../legacy/db-schema-catalog.md` | DB schema 目錄（TB_PAGE_MENU/權限三層/checkpoint…） |
| `../../decisions.md` §「舊系統(EPRO) 架構事實」 | D1–D6 反推事實（HttpDispatcher、SSO、JasperReports…） |

## 建檔規則（之後寫 Bible 時）
- 一個業務域一檔：`bible-<domain>.md`（如 `bible-loan-origination.md`、`bible-disbursement.md`）。
- 必含：**北極星**（這業務為何存在）、**黃金旅程**（端到端 happy path，案件從建檔到撥貸）、**user story**（角色×目標）、**證據註腳**（legacy `file:line`）。
- 下游：PRD 的 REQ 追溯到 Bible 的 story/旅程節點（funcId 骨幹起點）。

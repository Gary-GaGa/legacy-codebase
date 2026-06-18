# `docs/specs/` — 規格 pipeline（依 flow 分層）

> 資料夾結構＝AI flow 的精煉層級（`assets/ai-workflow.mmd`）。每層一個資料夾、**由上往下讀就是流程**：
> 方法論（三軸、行為 vs 長相、強制點）見 [`../spec-architecture.md`](../spec-architecture.md)。

```
docs/specs/
├── bible/    ① 業務聖經（Legacy 反推：北極星 · 黃金旅程 · user story）— EPRO Expert + AI
├── prd/      ② 產品需求（what/why · REQ-nnn）— PM + AI；外部權威、此處放快照
└── srs/      ③ 系統規格（how）— SA + AI；boundary bundle（spec/openapi/schema/qa-cases）
                 ↳ QA cases 在各 bundle 內（qa-cases.md，covers: Rn）
```

| 層 | 資料夾 | 產出工具 | 驗證 | 下一層 |
|---|---|---|---|---|
| ① Bible | `bible/` | EPRO Expert AI 反推（證據接地 `file:line`） | 人審 | 餵 PRD |
| ② PRD | `prd/` | `/product-brainstorming`、`/write-spec` | 人審（PM） | `/prd-to-srs` |
| ③ SRS（含 QA） | `srs/<funcId>/` | `/prd-to-srs`（Claude skill ∥ Codex prompt） | **機械 `check-srs-bundle.py`（涵蓋見腳本檔頭）+ `spec-reviewer` 語意（＝N 軸 axis A，全軸見 `../process/orchestration-playbook.md §4b`）** | RD 任務單 `../build-tasks/` |

- **追溯骨幹**：funcId 串 ①→②→③→QA→code；`Rn` 標 `covers-prd:`、QA 標 `covers: Rn`。
- **QA → 可跑測試**（gate④ 橋接）：[`qa-to-test.md`](qa-to-test.md)——case 散文→測試的對映 + Testcontainers harness + test-ready 寫法。
- **RD 階段不在此**：任務單在 [`../build-tasks/`](../build-tasks/)（live ↔ `done/`），產品碼在 repo 外。
- **設計規格（UI/UX）不在此**：Adobe XD（repo 外），慣例見 `frontend/AGENTS.md §5` —— 行為進 SRS、長相留 XD。

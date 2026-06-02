# DB Schema Catalog（新 Oracle DB，表名同舊）

> 來源：使用者提供的 Excel —— **已遷移至新 Oracle DB 後的 schema**，表名與舊系統相同。
> `HOME` 工作表 = 全表索引；其餘每個工作表 = 單一表細節。
> 用途：補齊各 entity 的**精確 Oracle 型別 / 長度 / nullable / PK**（直接收掉 **A1**，並供後續各模組 entity 定稿）。

## 1. 全表索引（Prompt A 回填）
| 表名 | 工作表 | 用途/說明 | 欄位數 |
|---|---|---|---|
| _(待 Prompt A)_ | | | |

## 2. Phase 1 三表細節（Prompt B 回填）→ 定稿 `phase1-eproz0_0700-spec.md` §2
- `TB_EMP_PROXY`、`TB_EMP_PROFILE`、`TB_BRANCH_PROFILE`

## 3. 後續高價值表（依模組，之後用 Prompt B 批次抽）
- **CBC**：`EPRO_TB_CBC_BBL/_INFO`、`_BGL/_INFO`、`_GBGL/_INFO`
- **財報**：`EPRO_TB_FIN_STATEMENT_MAIN`、`_BALANCE_GI`、`_CASHFLOW_GI`、`_INCOME_GI`（+`_FI`）
- **財務評估**：`EPRO_TB_FINANCIAL_EVALUATION_INFO/_GI/_FI/_INFO_S`、`EPRO_TB_IND_SCRCARD`
- **Scorecard**：`EPRO_TB_SCORE_CARD_PARAM_DETAIL`、`EPRO_TB_MAIN_BORROWER_PERSONAL/WORK/FAMILY_INFO`、`EPRO_TB_COLL_ASS`、`EPRO_TB_CORP_SCRCARD`
- **Checkpoint**：`EPRO_TB_CHECK_POINT`（/`_IU`/`_RC_CORP`/`_RC_CU`）
- **權限**：`TB_FUNCTION_INFO`、`TB_FUNCTION_AUTH`（順便確認 R7 對映欄位）

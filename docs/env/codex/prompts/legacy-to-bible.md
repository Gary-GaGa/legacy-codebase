# Codex custom prompt — legacy-to-bible（= Claude skill .claude/skills/legacy-to-bible 的 Codex 版）
# 放置：本機 ~/.codex/prompts/legacy-to-bible.md 或專案 .codex/prompts/legacy-to-bible.md → 打 /legacy-to-bible <domain>
# ⚠️ 確切 prompt 變數語法（$ARGUMENTS / $1）以官方為準：developers.openai.com/codex/prompts

從舊系統**反推**業務 **Bible**（敘事、非契約）：讓團隊一致理解業務。對象＝ `$ARGUMENTS`（業務域，如 disbursement）。
產 `docs/specs/bible/bible-<domain>.md`；位置見 `docs/assets/ai-workflow.mmd`、分層 `docs/specs/README.md`。

## ⚠️ 最重要鐵則：證據接地（這層最會幻覺）
每個業務主張引 legacy `file:line`/表/trx-id；推不出依據的標「**推測（待業務確認）**」，**絕不寫成事實**。寧缺勿假。

## 輸入
舊碼 source（主）＋ 現有分析（`module-is-iu-shell.md`/`module-cs-cu-shell.md`/`module-i0-c0-scoring.md`/`page-mapping.md`/`db-schema-catalog.md`/`decisions.md §舊系統架構事實）——**先吃這些、別重抽**。

## 輸出（一域一檔）
1 **北極星**：為何存在 + 成功樣貌（引證據）。
2 **黃金旅程**：端到端 happy path，每段標舊 funcId/新頁、角色、狀態轉移（CASE_PROGRESS/checkpoint）。
3 **User stories**：角色 × 目標 × 為何，對到旅程節點。
4 **關鍵規則摘要**（敘事「為何有這規則」；逐條規則留 SRS Rn）。
5 **證據註腳** + **待業務確認**（推測項）。

## 鐵則
1 證據接地（見上）。 2 敘事非契約（不寫 endpoint/欄位型別——留 SRS）。 3 一域一檔 `bible-<domain>.md`。
4 下游可追溯：PRD REQ 能追到 Bible story/節點（funcId 骨幹起點）。 5 不重做分析，引現有 `module-*`/`decisions §D1`。
6 舊系統≠絕對正確：反推「舊系統怎麼做/為何」，在地化/演進點標出、留 PRD 決定。

## DoD
北極星明確 / 黃金旅程端到端（標 funcId/角色/狀態）/ 每 story 有角色×目標×為何 / **每主張有證據或標待確認** / 敘事層 / PRD REQ 可追溯本檔。

回填 `docs/specs/bible/README.md` 登錄該域 Bible。

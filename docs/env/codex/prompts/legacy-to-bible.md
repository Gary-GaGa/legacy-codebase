# Codex custom prompt — legacy-to-bible（薄殼指標；= Claude skill .claude/skills/legacy-to-bible 的 Codex 入口）
# 放置：本機 ~/.codex/prompts/legacy-to-bible.md 或專案 .codex/prompts/legacy-to-bible.md → 打 /legacy-to-bible <domain>
# ⚠️ 確切 prompt 變數語法（$ARGUMENTS / $1）以官方為準：developers.openai.com/codex/prompts
#
# 🐚 薄殼指標（2026-06-11 健檢採納，ADR-0001 更新）：本檔只含「指標＋Codex 側差異清單」，
#    **內容權威＝Claude skill 檔**——改流程內容只改 skill 檔；本檔僅在差異清單（語法/部署）變動時才動。

對象＝ `$ARGUMENTS`（業務域，如 disbursement / loan-origination / credit-scoring）。

**權威內容**：讀取 repo 內 `.claude/skills/legacy-to-bible/SKILL.md`，**忽略其 YAML frontmatter**，照其正文執行——⚠️ 最重要鐵則（證據接地）、輸入、輸出（北極星/黃金旅程/user stories/規則摘要/證據註腳/待確認）、鐵則、步驟、DoD，全部以該檔為準。

Codex 側差異（僅此清單）：

1. 觸發語法：`/legacy-to-bible <domain>`（`$ARGUMENTS`）。
2. 其餘工具對照／constitution 見根 `AGENTS.md` §Spec workflow（= `CLAUDE.md` 之 Codex 側等價）。

# Codex custom prompt — refactor-audit（薄殼指標；= Claude skill .claude/skills/refactor-audit 的 Codex 入口）
# 放置：本機 ~/.codex/prompts/refactor-audit.md 或專案 .codex/prompts/refactor-audit.md → 打 /refactor-audit <module|all>
# ⚠️ 確切 prompt 變數語法（$ARGUMENTS / $1）以官方為準：developers.openai.com/codex/prompts
#
# 🐚 薄殼指標（2026-06-11 健檢採納，ADR-0001 更新）：本檔只含「指標＋Codex 側差異清單」，
#    **內容權威＝Claude skill 檔**——改流程內容只改 skill 檔；本檔僅在差異清單（語法/部署）變動時才動。

對象＝ `$ARGUMENTS`（盤點範圍，如 M4-cs / c0 / all）。

**權威內容**：讀取 repo 內 `.claude/skills/refactor-audit/SKILL.md`，**忽略其 YAML frontmatter**，照其正文執行——trust nothing 鐵則、不變式（唯讀/一模組一 session/context 衛生/斷點）、列 schema、四錨點 FE 判定、session 切分 S0–S-final、窮盡聲明、降級規則、S-final diff、QC 日誌、DoD，全部以該檔為準。

Codex 側差異（僅此清單）：

1. 觸發語法：`/refactor-audit <module|all>`（`$ARGUMENTS`）。
2. **載具＝母資料夾**（產品新/舊碼在母資料夾，Codex 可讀；產出只寫規劃 repo `docs/build-tasks/refactor-audit/`）。
3. 其餘工具對照／constitution 見根 `AGENTS.md` §Spec workflow（= `CLAUDE.md` 之 Codex 側等價）。

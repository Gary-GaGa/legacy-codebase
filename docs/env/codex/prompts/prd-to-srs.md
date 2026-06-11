# Codex custom prompt — prd-to-srs（薄殼指標；= Claude skill .claude/skills/prd-to-srs 的 Codex 入口）
# 放置：本機 ~/.codex/prompts/prd-to-srs.md 或專案 .codex/prompts/prd-to-srs.md → 互動介面打 /prd-to-srs <PRD 或 funcId>
# ⚠️ 確切 prompt 變數語法（$ARGUMENTS / $1）以官方為準：developers.openai.com/codex/prompts
#
# 🐚 薄殼指標（2026-06-11 健檢採納，ADR-0001 更新）：本檔只含「指標＋Codex 側差異清單」，
#    **內容權威＝Claude skill 檔**——改流程內容只改 skill 檔；本檔僅在差異清單（語法/部署）變動時才動。
#    目的：消除雙軌「全文等價、改一邊同步另一邊」的漂移面。

對象＝ `$ARGUMENTS`（PRD 路徑或 funcId）。

**權威內容**：讀取 repo 內 `.claude/skills/prd-to-srs/SKILL.md`，**忽略其 YAML frontmatter**（name/description 為 Claude Code 載入用），照其正文執行——輸入、輸出（bundle 四檔）、`spec.md` 結構、SRS 撰寫鐵則、Brownfield 鐵則、步驟、DoD，全部以該檔為準。

Codex 側差異（僅此清單）：

1. 觸發語法：`/prd-to-srs <PRD|funcId>`（`$ARGUMENTS`）。
2. 定稿前的 spec 審查用 subagent `.codex/agents/spec-reviewer.toml`（非 Claude subagent；同為唯讀）。
3. 機械閘門同一支：`python scripts/check-srs-bundle.py <bundle>`（涵蓋範圍見腳本檔頭）。
4. 其餘工具對照／constitution 見根 `AGENTS.md` §Spec workflow（= `CLAUDE.md` 之 Codex 側等價）。

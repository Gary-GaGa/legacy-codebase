# Codex 權限/安全護欄（= Claude .claude/settings.json 的 Codex 版）

> Codex 沒有 Claude 的 `permissions.deny` glob；用 **sandbox + approval policy + agent 級 sandbox_mode** 達到等價護欄。
> 放置：本機/專案 `.codex/config.toml`。⚠️ 確切鍵名以官方為準：developers.openai.com/codex/config-reference。

## 1. 全域 sandbox / approval（`.codex/config.toml`）
```toml
# 預設工作區可寫、需網路時逐次核准；危險指令落在核准閘
sandbox_mode   = "workspace-write"   # 不給 full-access；寫限工作區
approval_policy = "on-request"        # 寫檔/跑指令前依風險請求核准
# 網路預設關，要時逐次開（取代「deny curl|sh」）
[sandbox_workspace_write]
network_access = false
```

## 2. 唯讀審查 agent 強制唯讀（取代「審者別改」）
- `spec-reviewer.toml` / `reviewer-c0.toml` 皆設 `sandbox_mode = "read-only"` → 物理上無法改檔。

## 3. 等價對照（Claude `settings.json` deny → Codex）
| 危險 | Claude deny | Codex 對應 |
|---|---|---|
| `sudo` / `rm -rf` | `Bash(...)` deny | approval_policy 攔 + sandbox 不給 full-access |
| `git push --force` / `reset --hard` | deny | 同上（破壞性 git 落核准閘）；建議 PR-only branch 保護 |
| `curl … | sh` | deny | `network_access=false`（要網路逐次核准）|
| 讀 `.env` / secrets | `Read(...)` deny | **secrets 永不進 repo**（守則）+ sandbox 限工作區；敏感檔加 `.gitignore` |

## 4. 形式硬閘門
- `.codex/hooks.json`（範本同目錄）：`Stop`/`PostToolUse` 跑 `python scripts/verify-c0.py --git`。

> 改本檔請同步 `.claude/settings.json` + `CLAUDE.md` 的對照表。

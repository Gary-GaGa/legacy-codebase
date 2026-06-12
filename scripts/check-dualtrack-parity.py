#!/usr/bin/env python3
"""check-dualtrack-parity — 機械驗 CLAUDE.md ↔ AGENTS.md 雙軌 constitution 同步。

動機：雙軌（Claude / Codex）的 spec-workflow 工具對照靠**人工**維持同步——加一個
skill 卻只改一邊，就是 F-1 級的靜默漂移（標對其實漏改）。本腳本把「parity anchor 兩
邊都在」機械化：任一 anchor 缺在任一邊＝FAIL，逼漏改現形。

**設計**：parity anchor 清單＝**本腳本單一出處**（下方 ANCHORS）。新增雙軌工具/共用
參照時，在這裡加一行——這正是同步點。anchor＝「兩份 constitution 在語意上都必須提到的
工具路徑/共用參照/教義關鍵詞」；用具體到不會誤命中的 token（如 `.codex/prompts/x.md`）。

**不檢查**：內容逐字相同（雙軌刻意各自原生格式、薄殼指標＝內容權威在 Claude 版）。本腳本
只驗「**該提的兩邊都提了**」，不驗「怎麼提」。語意對不對仍人審。

用法：
  python scripts/check-dualtrack-parity.py
退出碼：0 = parity 成立；1 = 至少一個 anchor 漂移（漏在某一邊）；2 = constitution 檔找不到。
標記：X=漂移(FAIL，必修) ／ i=資訊。
"""
import os
import sys

CLAUDE = "CLAUDE.md"
AGENTS = "AGENTS.md"

# parity anchor 單一出處：每個 token 兩份 constitution 都必須出現（漏在任一邊＝漂移）。
# 新增雙軌工具/共用參照 → 在對應分組加一行。註解＝該 anchor 的語意。
ANCHORS = [
    # ── 雙軌 skill / 工具入口（CLAUDE §2 表 ↔ AGENTS §Spec workflow）──
    (".codex/prompts/legacy-to-bible.md", "Legacy→Bible 工具"),
    (".codex/prompts/prd-to-srs.md", "PRD→SRS 工具"),
    (".codex/prompts/refactor-audit.md", "進度盤點 zero-based 工具"),
    (".codex/agents/spec-reviewer.toml", "spec 審查（唯讀）工具"),
    (".codex/config.toml", "權限/安全設定"),
    (".codex/hooks.json", "形式硬閘門 hooks"),
    # ── 共用 canonical 參照（兩軌都指同一權威來源）──
    ("ai-workflow.mmd", "AI flow 唯一圖源"),
    ("check-srs-bundle.py", "SRS 機械閘門（雙軌共用、涵蓋範圍以檔頭為準）"),
    ("feature-inventory.md", "狀態 SSOT"),
    ("spec-reviewer", "唯讀語意審角色"),
    # ── 教義關鍵詞（雙軌治理共識）──
    ("薄殼指標", "Codex 鏡像＝薄殼、內容權威＝Claude 版"),
]


def read(path):
    with open(path, "rb") as f:
        raw = f.read()
    if raw[:3] == b"\xef\xbb\xbf":
        raw = raw[3:]
    return raw.decode("utf-8")


def main():
    for p in (CLAUDE, AGENTS):
        if not os.path.isfile(p):
            print(f"找不到 constitution：{p}")
            return 2
    claude_txt, agents_txt = read(CLAUDE), read(AGENTS)

    fails = []
    for token, desc in ANCHORS:
        in_claude = token in claude_txt
        in_agents = token in agents_txt
        if in_claude and in_agents:
            continue
        if not in_claude and not in_agents:
            fails.append(f"`{token}`（{desc}）：**兩邊皆缺**——anchor 已過時？確認該工具是否仍存在")
        else:
            missing = AGENTS if in_claude else CLAUDE
            present = CLAUDE if in_claude else AGENTS
            fails.append(f"`{token}`（{desc}）：在 {present} 有、**{missing} 漏**——雙軌漂移，補同步")

    print("=== dual-track parity（CLAUDE.md ↔ AGENTS.md）===")
    print(f"檢查 {len(ANCHORS)} 個 parity anchor")
    if not fails:
        print("[parity] PASS — 雙軌 anchor 全部兩邊都在。（內容語意正確性仍人審）")
        return 0
    print("[parity] FAIL")
    for m in fails:
        print(f"    X {m}")
    print(f"\ncheck-dualtrack-parity: FAIL — {len(fails)} 個 anchor 漂移。改一軌記得同步另一軌（薄殼指標：內容只改 Claude 版，但兩邊都要提到該工具）。")
    return 1


if __name__ == "__main__":
    sys.exit(main())

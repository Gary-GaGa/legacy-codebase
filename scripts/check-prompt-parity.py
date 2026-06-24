#!/usr/bin/env python3
"""check-prompt-parity — 機械驗 orchestration-playbook（迴圈權威）↔ 各 orchestrator drain
殼（可貼運行殼）的不變式同步。

動機：drain 卡是「可直接貼給 Codex 的 prompt」，必須**內聯完整**才能在 Codex 不讀 playbook
時也跑對；但這就讓迴圈規則在兩處重複（playbook 權威 + drain 殼）。改了 playbook 迴圈規則卻
忘了同步 drain 殼，就是靜默漂移（殼還在跑舊規則）。本腳本把「關鍵不變式 anchor 兩邊都在」
機械化：任一 anchor 缺在任一邊＝FAIL，逼漏改現形。

涵蓋的 flow 殼（皆以 playbook 為權威）：
  - SRS 軌（§5b/§6b）↔ prd-to-srs-orchestrator-drain.md
  - RD  軌（§5c/§6c）↔ rd-orchestrator-drain.md
  〔QA 軌暫移除——QA Agent Flow 待 Bible→PRD→SRS→RD→DoD 跑順後再納入〕

設計＝對照 check-dualtrack-parity.py：anchor 清單＝本腳本單一出處（下方 PAIRS）。新增/改迴圈
不變式時在這裡加一行（同步點）。pilot 卡已歸檔 done/，不納入比對。

不檢查：逐字相同（殼會多出『步驟0/貼這段』等運行語）。只驗「該守的規則兩邊都提了」，不驗
「怎麼提」；語意對不對仍人審。

用法：
  python scripts/check-prompt-parity.py
退出碼：0 = parity 成立；1 = 至少一個 anchor 漂移；2 = 檔找不到。
標記：X=漂移(FAIL，必修) ／ i=資訊。
"""
import os
import sys

PLAYBOOK = "docs/process/orchestration-playbook.md"

# (flow 名, 權威檔, 運行殼, [(anchor, 語意), ...])
# 每個 anchor＝該 flow 的權威(playbook)與殼都必須陳述的迴圈不變式關鍵詞。
PAIRS = [
    ("SRS", PLAYBOOK, "docs/build-tasks/prd-to-srs-orchestrator-drain.md", [
        ("一次只一頁", "序列、一次一頁（context 衛生）"),
        ("prd-ready", "佇列狀態驅動 drain"),
        ("batch checkpoint", "低風險頁批末停一次"),
        ("per-page checkpoint", "T1/金錢/授權頁每頁停"),
        ("A–F", "每頁全 A–F 七正交軸"),
        ("跨模型", "各軸跨模型、反 correlated-blindness"),
        ("n-axis-findings-ledger", "每軸 Blocker/誤報回填度量 ledger"),
        ("in-review", "終點＝in-review，非 approved"),
        ("自宣 approved", "不得自宣 approved（人裁 TBD 才升）"),
        ("circuit-breaker", "系統性失敗暫停整批"),
        ("context 衛生", "每 sub-task 獨立 session、主控只收路徑"),
    ]),
    ("RD", PLAYBOOK, "docs/build-tasks/rd-orchestrator-drain.md", [
        ("rd-ready", "入口閘＝approved 衍生的 rd-ready"),
        ("rd-done", "終點態＝rd-done"),
        ("自宣 Done", "不得自宣 Done（QA 還沒跑）"),
        ("強制點", "RD 軸含強制點落實（BE 權威 enforce）"),
        ("circuit-breaker", "系統性失敗暫停整批"),
        ("context 衛生", "每 sub-task 獨立 session"),
        ("batch checkpoint", "低風險頁批末停"),
        ("per-page 多 agent 驗證", "T1 頁每頁多 agent 跨模型驗、drain 不停人（owner 2026-06-25 改自人審停點）"),
        ("blocked", "單頁 FAIL 標 blocked 離開 ready 集合"),
        ("不並行", "序列非並行"),
    ]),
]


def read(path):
    with open(path, "rb") as f:
        raw = f.read()
    if raw[:3] == b"\xef\xbb\xbf":
        raw = raw[3:]
    return raw.decode("utf-8")


def main():
    files = {PLAYBOOK}
    for _, auth, shell, _a in PAIRS:
        files.add(auth)
        files.add(shell)
    for p in files:
        if not os.path.isfile(p):
            print(f"找不到檔：{p}")
            return 2

    cache = {p: read(p) for p in files}
    total = 0
    fails = []
    for flow, auth, shell, anchors in PAIRS:
        atxt, stxt = cache[auth], cache[shell]
        for token, desc in anchors:
            total += 1
            in_a = token in atxt
            in_s = token in stxt
            if in_a and in_s:
                continue
            if not in_a and not in_s:
                fails.append(f"[{flow}] `{token}`（{desc}）：**兩邊皆缺**——anchor 已過時？確認該規則是否仍在")
            else:
                missing = shell if in_a else auth
                present = auth if in_a else shell
                fails.append(f"[{flow}] `{token}`（{desc}）：在 {present} 有、**{missing} 漏**——權威/殼漂移，補同步")

    print("=== prompt parity（orchestration-playbook ↔ {SRS,RD,QA} orchestrator drain 殼）===")
    print(f"檢查 {len(PAIRS)} 條 flow、共 {total} 個迴圈不變式 anchor")
    if not fails:
        print("[parity] PASS — 迴圈不變式 anchor 權威與運行殼兩邊都在。（語意正確性仍人審）")
        return 0
    print("[parity] FAIL")
    for m in fails:
        print(f"    X {m}")
    print(f"\ncheck-prompt-parity: FAIL — {len(fails)} 個 anchor 漂移。改 playbook 迴圈規則記得同步對應 drain 殼。")
    return 1


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""check-prompt-parity — 機械驗 orchestration-playbook §5b/§6b（迴圈權威）↔
prd-to-srs-orchestrator-drain.md（可貼運行殼）的不變式同步。

動機：drain 卡是「可直接貼給 Codex 的 prompt」，必須**內聯完整**才能在 Codex 不讀
playbook 時也跑對；但這就讓迴圈規則在兩處重複（playbook 權威 + drain 殼）。改了
playbook §4b/§5b/§6b 卻忘了同步 drain 殼，就是靜默漂移（殼還在跑舊規則）。本腳本把
「關鍵不變式 anchor 兩邊都在」機械化：任一 anchor 缺在任一邊＝FAIL，逼漏改現形。

設計＝對照 check-dualtrack-parity.py：anchor 清單＝本腳本單一出處（下方 ANCHORS）。
新增/改迴圈不變式時在這裡加一行（同步點）。anchor＝「權威與殼都必須陳述的迴圈規則
關鍵詞」，用具體到不會誤命中的 token。

不檢查：逐字相同（殼會多出『步驟0/貼這段』等運行語）。只驗「該守的規則兩邊都提了」，
不驗「怎麼提」；語意對不對仍人審。pilot 卡已歸檔 done/，不納入比對。

用法：
  python scripts/check-prompt-parity.py
退出碼：0 = parity 成立；1 = 至少一個 anchor 漂移；2 = 檔找不到。
標記：X=漂移(FAIL，必修) ／ i=資訊。
"""
import os
import sys

PLAYBOOK = "docs/process/orchestration-playbook.md"
DRAIN = "docs/build-tasks/prd-to-srs-orchestrator-drain.md"

# 迴圈不變式 anchor 單一出處：每個 token 權威（playbook）與運行殼（drain）都必須出現。
# 改迴圈規則 → 在此加/改一行＝同步點。註解＝該 anchor 的語意。
ANCHORS = [
    # ── 序列/批次紀律 ──
    ("一次只一頁", "序列、一次只一頁（context 衛生）"),
    ("prd-ready", "佇列狀態驅動 drain"),
    ("batch checkpoint", "低風險頁批末停一次"),
    ("per-page checkpoint", "T1/金錢/授權頁每頁停"),
    # ── 驗證深度（N 軸）──
    ("A–G", "每頁全 A–G 七正交軸"),
    ("跨模型", "各軸跨模型、反 correlated-blindness"),
    ("n-axis-findings-ledger", "每軸 Blocker/誤報回填度量 ledger（驅動軸配置）"),
    # ── 安全網 ──
    ("in-review", "終點＝in-review，非 approved"),
    ("自宣 approved", "不得自宣 approved（人裁 TBD 才升）"),
    ("circuit-breaker", "系統性失敗暫停整批"),
    ("context 衛生", "每 sub-task 獨立 session、主控只收路徑"),
]


def read(path):
    with open(path, "rb") as f:
        raw = f.read()
    if raw[:3] == b"\xef\xbb\xbf":
        raw = raw[3:]
    return raw.decode("utf-8")


def main():
    for p in (PLAYBOOK, DRAIN):
        if not os.path.isfile(p):
            print(f"找不到檔：{p}")
            return 2
    pb, dr = read(PLAYBOOK), read(DRAIN)

    fails = []
    for token, desc in ANCHORS:
        in_pb = token in pb
        in_dr = token in dr
        if in_pb and in_dr:
            continue
        if not in_pb and not in_dr:
            fails.append(f"`{token}`（{desc}）：**兩邊皆缺**——anchor 已過時？確認該規則是否仍在")
        else:
            missing = DRAIN if in_pb else PLAYBOOK
            present = PLAYBOOK if in_pb else DRAIN
            fails.append(f"`{token}`（{desc}）：在 {present} 有、**{missing} 漏**——權威/殼漂移，補同步")

    print("=== prompt parity（orchestration-playbook §5b/§6b ↔ prd-to-srs-orchestrator-drain）===")
    print(f"檢查 {len(ANCHORS)} 個迴圈不變式 anchor")
    if not fails:
        print("[parity] PASS — 迴圈不變式 anchor 權威與運行殼兩邊都在。（語意正確性仍人審）")
        return 0
    print("[parity] FAIL")
    for m in fails:
        print(f"    X {m}")
    print(f"\ncheck-prompt-parity: FAIL — {len(fails)} 個 anchor 漂移。改 playbook 迴圈規則記得同步 drain 殼（內容權威＝playbook，但運行殼必須內聯同一規則）。")
    return 1


if __name__ == "__main__":
    sys.exit(main())

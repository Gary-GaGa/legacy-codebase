#!/usr/bin/env python3
"""verify-c0 — machine-checkable guardrails for c0 mirror pages (goal-mode hard gate).

把人工 review 的「形式檢查」自動化。**只攔形式錯**（編碼 / 禁用樣式 / 命名）；
語意正確性（calc 有沒有照鏡像、checkpoint 跨頁副作用對不對、info 端點該不該寫回 DB）
仍需讀 code / 對 i0 —— 見 backend/AGENTS.md §6.6 的煞車條款。

用法：
  python scripts/verify-c0.py --git                # 檢查 git 變更（vs HEAD）的 .java
  python scripts/verify-c0.py --staged             # 檢查已 staged 的 .java
  python scripts/verify-c0.py <path> [<path> ...]  # 檢查指定檔/資料夾

退出碼：0 = 全過；非 0 = 至少一項違反（該頁不算完成，擋下）。
"""
import os
import re
import subprocess
import sys

# 禁用樣式：只在 c0（路徑含 /corporate/）的 .java 檔檢查
FORBIDDEN = [
    (re.compile(r"\bjava\.lang\.reflect\b"), "reflection import（禁止反射繞 i0）"),
    (re.compile(r"\bgetDeclaredMethod\s*\("), "getDeclaredMethod（禁止反射）"),
    (re.compile(r"\bsetAccessible\s*\("), "setAccessible（禁止反射）"),
    (re.compile(r"import\s+[\w.]*\.individual\.[\w.]*;"), "import i0 individual.*（禁止耦合 i0；需鏡像就複製進 c0）"),
    (re.compile(r"\.service\.individual\."), "引用 i0 service.individual（禁止委派 i0）"),
    (re.compile(r"\bTBCheckPoints?I[su]\b|\bTB_CHECK_POINTS?_I[SU]\b"), "i0 checkpoint 表 Is/Iu（c0 應用 Cs/Cu）"),
    (re.compile(r'epl-[A-Za-z]+-i0-'), "i0 endpoint 字串 -i0-（c0 應為 -c0-）"),
]
# mapping 標註：用來找 endpoint 路徑字串
MAPPING = re.compile(r'@(?:Post|Get|Put|Delete|Request)Mapping\s*\(\s*(?:value\s*=\s*)?"([^"]+)"')


def java_files(paths):
    out = []
    for p in paths:
        if os.path.isdir(p):
            for root, _, files in os.walk(p):
                out += [os.path.join(root, f) for f in files if f.endswith(".java")]
        elif p.endswith(".java") and os.path.isfile(p):
            out.append(p)
    return sorted(set(out))


def git_changed(staged):
    cmd = ["git", "diff", "--name-only"] + (["--cached"] if staged else [])
    try:
        names = subprocess.check_output(cmd, text=True).splitlines()
    except Exception as e:
        print(f"!! git diff 失敗：{e}")
        return []
    # 也納入未追蹤的新檔
    if not staged:
        try:
            names += subprocess.check_output(
                ["git", "ls-files", "--others", "--exclude-standard"], text=True
            ).splitlines()
        except Exception:
            pass
    return [n for n in names if n.endswith(".java") and os.path.isfile(n)]


def check(path):
    """回傳 violations 清單（字串）。"""
    v = []
    with open(path, "rb") as f:
        raw = f.read()
    # 1. BOM
    if raw[:3] == b"\xef\xbb\xbf":
        v.append("有 UTF-8 BOM（須存成 No BOM）")
        raw = raw[3:]
    # 2. strict UTF-8
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as e:
        v.append(f"非有效 UTF-8（{e}）")
        return v  # 解不開就不繼續逐行
    # 3. 禁用樣式（只在 c0 corporate 檔）
    is_c0 = "/corporate/" in path.replace(os.sep, "/")
    if is_c0:
        for i, line in enumerate(text.splitlines(), 1):
            s = line.strip()
            if s.startswith("//") or s.startswith("*"):
                continue  # 略過註解行，避免「鏡像來源 i0」之類說明誤判
            for pat, msg in FORBIDDEN:
                if pat.search(line):
                    v.append(f"L{i}: {msg}")
        # 4. mapping 命名：corporate 端點不得含 -i0-（c0/csu 不可呼叫 i0 端點）。
        #    合法慣例：主流程 -csu-、評分 -c0- 皆可 → 不對其它 epl- 命名告警。
        if "/controller/corporate/" in path.replace(os.sep, "/"):
            for m in MAPPING.finditer(text):
                route = m.group(1)
                if "-i0-" in route:
                    v.append(f"endpoint `{route}` 含 -i0-（c0/csu 不可呼叫 i0 端點）")
    return v


def main(argv):
    args = argv[1:]
    if not args:
        print(__doc__)
        return 2
    if args[0] == "--git":
        files = git_changed(staged=False)
    elif args[0] == "--staged":
        files = git_changed(staged=True)
    else:
        files = java_files(args)

    if not files:
        print("verify-c0: 沒有要檢查的 .java（git 無 java 變更？）")
        return 0

    total = 0
    for path in files:
        vs = check(path)
        if vs:
            total += len(vs)
            print(f"\nX {path}")
            for msg in vs:
                print(f"    - {msg}")
    print()
    if total:
        print(f"verify-c0: FAIL — {total} 項違反，{len(files)} 檔。修掉再算完成。")
        return 1
    print(f"verify-c0: PASS — {len(files)} 檔，無形式違反。（語意正確性仍需對 i0/人審）")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

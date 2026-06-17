#!/usr/bin/env python3
"""check-srs-bundle — machine-checkable gates for an SRS boundary bundle.

把 SRS bundle 的「形式/機械」檢查自動化，補 spec-reviewer 抓不到的 deterministic 漏洞。

**⚠️ 本檔頭＝機械閘門涵蓋範圍的 canonical 清單**（2026-06-11 總體檢裁定：
其他文件一律「見腳本檔頭」，**勿在他處複寫此清單**——多份副本必漂移）：
  gate①  openapi：YAML 解析 / $ref 解得開 / required ⊆ properties
  gate②  schema：DDL 解析、欄位重複、括號平衡、欄長 ↔ openapi maxLength 交叉
  gate⑤  covers：每個非-@PENDING `Rn` ≥1 QA covers；懸空 QA 引用；
         **分支覆蓋自承不完整**（Rn 雖 ≥1 但 qa 自承「僅…分支／未撰寫／RD 補／
         不可當已覆蓋」）=warn（破「≥1 假綠」；2026-06-16 升級，源 00800 批判 #3）
  gateⓈ Status↔安全/雙軸：(a) spec Status 含 Approved 但有未承載 Bible→PRD seam
         （BPn-PENDING）=warn——**未承載 Bible 安全/災難條件不得 Approved**；機械無法判是否
         安全條件→逼人確認（2026-06-16 批判輪1 #5）；(b) Status 含 Approved 但未分
         『規格定版 / 實作完成』兩軸=warn——破「Approved 混『規格定了』與『實作好了』」
         （2026-06-16 批判輪2）
  xfile  跨檔完整性：endpoint↔openapi、spec 表↔schema、錯誤碼↔openapi、強制點欄
  gateⒷ Bible↔PRD：covers-prd↔PRD 快照懸空=FAIL；trace 缺列 / Bible BR 點名
         本 funcId 未入 trace=advisory warn
  gateⓅ @PENDING↔pending-register 同步：spec 開著的待決未登錄 register=FAIL、
         已關的仍掛 register open 區=FAIL（spec 為來源、register 為 derived 視圖）
  gateⒺ 錯誤碼承載：PRD Error Response 表（上游權威）的每個錯誤碼，下游 spec.md（Rn
         錯誤規則）+ openapi responses 都應承載；PRD 列了但 spec/openapi 皆漏=warn
         （漏承載，B-1 類）；PRD↔openapi 同碼 HTTP status 不一致=warn（B-2 status 面）。
         皆 warn（disclaim 由人/reviewer 認）。**關鍵：解析前去 markdown 底線跳脫
         `\\_`**（否則 PRD 表格的 `MSG\\_X` 漏抓＝SR-B1 當初的根因）。
         （2026-06-16 批判輪3，源 00800 spec-review SR-B1/B2）
  [--all 附帶] doc-paths：全 repo markdown 內 backtick 引用的 root-anchored 路徑
         存在性（advisory；歷史檔 build-tasks/done/、archive/ 不掃）

編號對照：gate①②⑤＝DoD 閘門牆（`docs/assets/ai-workflow.mmd`）①②⑤ 同位項在 SRS
定稿階段的 pre-check（**同號同義、不同階段**）。gateⒷ/gateⓅ/gateⓈ/xfile/doc-paths＝**SRS
階段專屬、DoD 牆無對應格**，故用字母標（Ⓑ=Bible、Ⓟ=Pending、Ⓢ=Status/Safety）而非接續
⑥⑦——避免與牆上 ⑥Build/⑦LLM-advisory 撞號（Ⓑ=Bible、Ⓟ=Pending、Ⓢ=Status/Safety、
Ⓔ=Error碼承載）。完整對照表見 `docs/specs/srs/README.md`。

**分工**：語意正確性（規則合不合理、as-is/to-be 對不對、有沒有把 legacy 當需求、
NFR 量化）仍由 `.claude/agents/spec-reviewer.md`（人/LLM）審。兩層互補、不重疊。

對象＝`docs/specs/srs/<funcId>/`：spec.md + openapi.yaml + schema.sql + qa-cases.md。

用法：
  python scripts/check-srs-bundle.py <bundle-dir> [<bundle-dir> ...]
  python scripts/check-srs-bundle.py --all          # specs/srs/ 下所有 bundle

退出碼：0 = 全過；1 = 至少一項硬違反（🔴，定稿前必修）；2 = 用法錯/找不到檔。
標記：X=硬違反(FAIL) ／ !=建議(warn) ／ i=資訊(@PENDING 等，不擋)。

啟發式限制（誠實標示，同 verify-c0 的煞車條款）：
  - gate⑤ 規則集 = spec.md 的 `### Rn` 標題 + `**R13.x**` 子規則；不展開 `R13.1–13.5` 範圍寫法。
  - 「@PENDING 豁免」**只認**規則(或其父規則)定義行的 `@PENDING` token——裸 `RPn` 或
    「已裁/已關」字樣**不豁免**（裁定關閉後規則立即恢復覆蓋保護；2026-06-11 修正，
    原 `RPn` 比對會把已裁規則誤判為 pending、靜默放掉 covers 缺口）。
  - schema 長度交叉比對僅比 snake_case 欄名 ↔ camelCase openapi property 名重疊者。
  - gateⒷ 為 funcId 檔名 glob + `REQ-\\d{3}` token 比對；快照/trace 不存在時整段 advisory
    略過（不擋無 PRD 的鏡像 i0 bundle）。trace 行格式約定見 docs/specs/prd/trace-*.md 頭部。
  - gateⓅ 單向（spec→register）：register 的非 SRS 來源列（A-1 OQ、撥貸 group、E1/E2…）
    無機械來源可對，不在範圍；register open 區的自由文字若誤含已關 id 會 FAIL——刻意，
    逼 register 保持乾淨。
  - gateⒺ＝表格啟發式：只認 PRD 表格 cell[0] 的錯誤碼（`錯誤代碼` 欄）+ cell[1] 的 HTTP
    status；PRD 若以散文/不同欄位列碼 → 抓不到、靜默跳過（非 FAIL）。「承載」＝碼字串出現在
    spec.md/openapi（contains），**非**驗它落在對的 `Rn`/語意正確（語意仍 spec-reviewer）。
    status 一致性需 pyyaml + 碼出現在 openapi response `description`；2xx 成功碼不做 status
    比對。**解析前去 `\\_` markdown 跳脫**（PRD 表格 `MSG\\_X`，否則漏抓＝SR-B1 根因）。
  - doc-paths 只掃 root-anchored backtick 路徑（docs/、scripts/、.claude/、.github/）；
    相對路徑（`../x.md`）由 markdown link 檢查工具涵蓋、不在此掃。
"""
import glob
import os
import re
import sys

BUNDLE_ROOT = "docs/specs/srs"
RULE_RE = re.compile(r"R\d+(?:\.\d+)?")
PLACEHOLDER_RE = re.compile(r"未撰寫|待補|RD\s*補|TODO|TBD|尚未")


def read(path):
    with open(path, "rb") as f:
        raw = f.read()
    if raw[:3] == b"\xef\xbb\xbf":
        raw = raw[3:]
    return raw.decode("utf-8")


# ---------- gate ① openapi.yaml ----------------------------------------------
def _walk(node, path, fn):
    """深走 dict/list，對每個 dict 節點呼叫 fn(node, path)。"""
    if isinstance(node, dict):
        fn(node, path)
        for k, v in node.items():
            _walk(v, path + [str(k)], fn)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            _walk(v, path + [str(i)], fn)


def _resolve_ref(doc, ref):
    if not ref.startswith("#/"):
        return False  # 只驗本檔內部 ref
    cur = doc
    for part in ref[2:].split("/"):
        part = part.replace("~1", "/").replace("~0", "~")
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            return False
    return True


def gate1_openapi(bundle):
    fails, warns = [], []
    p = os.path.join(bundle, "openapi.yaml")
    if not os.path.isfile(p):
        return ["缺 openapi.yaml（gate① 無法驗）"], []
    try:
        import yaml
    except ImportError:
        return [], ["無 pyyaml，gate① 只能略過（pip install pyyaml 後可驗 $ref/required）"]
    try:
        doc = yaml.safe_load(read(p))
    except yaml.YAMLError as e:
        return [f"openapi.yaml 不是合法 YAML：{e}"], []
    if not isinstance(doc, dict):
        return ["openapi.yaml 解析後非 mapping"], []
    for key in ("openapi", "info", "paths"):
        if key not in doc:
            fails.append(f"openapi.yaml 缺頂層 `{key}`")

    # $ref 解析
    def check_ref(node, path):
        if "$ref" in node and isinstance(node["$ref"], str):
            if not _resolve_ref(doc, node["$ref"]):
                fails.append(f"$ref 解不開：`{node['$ref']}`（at {'/'.join(path)}）")
    _walk(doc, [], check_ref)

    # required 的每個名稱要存在於 properties（抓 checkPointMap.required:[applicationNo] 這類錯）
    def check_required(node, path):
        req = node.get("required")
        if not isinstance(req, list):
            return
        if not (node.get("type") == "object" or "properties" in node or "additionalProperties" in node):
            return
        props = node.get("properties") or {}
        for name in req:
            if name in props:
                continue
            where = "/".join(path) or "(root)"
            if "additionalProperties" in node and not props:
                fails.append(
                    f"required `{name}` 不在 properties，且此 schema 是開放 map(additionalProperties) "
                    f"→ 把非 map-key 當必填(at {where})；map 的 required 應列真正的 key 或移除")
            else:
                fails.append(f"required `{name}` 在 properties 中不存在(at {where})")
    _walk(doc, [], check_required)

    # 進階：若裝了 openapi-spec-validator，順手做完整 3.0.x 驗證
    try:
        from openapi_spec_validator import validate as _validate  # type: ignore
        try:
            _validate(doc)
        except Exception as e:  # noqa: BLE001
            fails.append(f"openapi-spec-validator：{str(e).splitlines()[0]}")
    except ImportError:
        warns.append("未裝 openapi-spec-validator → 只做結構檢查；pip install 後可做完整 3.0.x 驗證")
    return fails, warns


# ---------- gate ② schema.sql -------------------------------------------------
COL_RE = re.compile(
    r"^\s*([A-Z][A-Z0-9_]*)\s+(VARCHAR2|CHAR|NUMBER|DATE|TIMESTAMP|CLOB|BLOB)"
    r"(?:\s*\(\s*(\d+)\s*\))?", re.I)
CREATE_RE = re.compile(r"CREATE\s+TABLE\s+([A-Z0-9_]+)\s*\(", re.I)


def _snake_to_camel(s):
    parts = s.lower().split("_")
    return parts[0] + "".join(w.capitalize() for w in parts[1:])


def gate2_schema(bundle):
    fails, warns = [], []
    p = os.path.join(bundle, "schema.sql")
    if not os.path.isfile(p):
        return ["缺 schema.sql（gate② 無法驗）"], []
    text = read(p)
    # 去註解行只為解析欄位（保留原文供長度比對）
    code = "\n".join(ln for ln in text.splitlines() if not ln.lstrip().startswith("--"))

    # 括號平衡
    if code.count("(") != code.count(")"):
        fails.append("schema.sql 括號不平衡（CREATE TABLE 區塊可能未閉合）")

    # 解析每張 CREATE TABLE 的欄位（名,型,長度）
    cols = {}  # COLNAME -> (type, length)
    for m in CREATE_RE.finditer(code):
        start = m.end()
        depth = 1
        i = start
        while i < len(code) and depth:
            if code[i] == "(":
                depth += 1
            elif code[i] == ")":
                depth -= 1
            i += 1
        body = code[start:i - 1]
        seen = set()
        for ln in body.splitlines():
            cm = COL_RE.match(ln)
            if not cm:
                continue
            name = cm.group(1).upper()
            if name in ("CONSTRAINT", "PRIMARY", "FOREIGN", "CHECK", "UNIQUE"):
                continue
            if name in seen:
                fails.append(f"{m.group(1)}：欄位 `{name}` 重複定義")
            seen.add(name)
            length = int(cm.group(3)) if cm.group(3) else None
            cols[name] = (cm.group(2).upper(), length)

    if not cols:
        warns.append("schema.sql 未解析到任何欄位（可能全為註解 placeholder；RD 補 DDL 後再驗）")
        return fails, warns

    # 交叉比對：schema 欄長 vs openapi property maxLength（snake↔camel 重疊名）
    try:
        import yaml
        odoc = yaml.safe_load(read(os.path.join(bundle, "openapi.yaml")))
        omax = {}  # propName -> maxLength

        def grab(node, path):
            for k, v in node.items():
                if isinstance(v, dict) and "maxLength" in v and isinstance(v["maxLength"], int):
                    omax[k] = v["maxLength"]
        _walk(odoc, [], grab)
        for col, (typ, length) in cols.items():
            if length is None:
                continue
            cam = _snake_to_camel(col)
            if cam in omax and omax[cam] != length:
                fails.append(
                    f"長度不一致：schema `{col}` {typ}({length}) ↔ openapi `{cam}` maxLength {omax[cam]}")
    except Exception:  # noqa: BLE001
        pass  # openapi 不可解析時 gate① 已會報
    return fails, warns


# ---------- gate ⑤ Rn ↔ QA covers --------------------------------------------
def gate5_traceability(bundle):
    fails, warns, infos = [], [], []
    sp = os.path.join(bundle, "spec.md")
    qp = os.path.join(bundle, "qa-cases.md")
    if not (os.path.isfile(sp) and os.path.isfile(qp)):
        return ["缺 spec.md 或 qa-cases.md（gate⑤ 無法驗）"], [], []
    spec = read(sp).splitlines()
    qa = read(qp).splitlines()

    # 1) 規則集：### Rn 標題 + **R13.x** 子規則（僅認列表項定義行，
    #    避免上方 `>` 註記/表格列提及 R13.x 被誤當定義行而吃到其 @PENDING token）
    rule_line = {}  # rule_id -> def line text
    for ln in spec:
        m = re.match(r"^###\s+(R\d+)\b", ln)
        if m:
            rule_line[m.group(1)] = ln
        if ln.lstrip().startswith("-"):
            for sm in re.finditer(r"\*\*(R\d+\.\d+)", ln):
                rule_line.setdefault(sm.group(1), ln)
    rules = set(rule_line)
    containers = {r for r in rules if any(o != r and o.startswith(r + ".") for o in rules)}

    def is_pending(rid):
        # 只認 `@PENDING` token；裸 RPn／「已裁」字樣不豁免（見檔頭啟發式限制）
        line = rule_line.get(rid, "")
        if "@PENDING" in line:
            return True
        if "." in rid:  # 子規則：看父規則標題
            return "@PENDING" in rule_line.get(rid.split(".")[0], "")
        return False

    # 2) qa-cases 表格列：QA id（可能含 @PENDING）+ covers 欄
    qa_defined = set()
    covers = {}  # rule_id -> set(QA id)（僅計非 @PENDING 的 case）
    for ln in qa:
        if not ln.lstrip().startswith("| QA-"):
            continue
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) < 2:
            continue
        qid_m = re.search(r"QA-\d+", cells[0])
        if not qid_m:
            continue
        qid = qid_m.group(0)
        qa_defined.add(qid)
        case_pending = "@PENDING" in cells[0]
        for rm in RULE_RE.finditer(cells[1]):
            rid = rm.group(0)
            if not case_pending:
                covers.setdefault(rid, set()).add(qid)

    # 3a) dangling covers：QA covers 指向不存在的規則
    for rid in sorted(set(covers) - rules):
        fails.append(f"QA covers 指向不存在的規則 `{rid}`（qa-cases.md；改規則 id 或補 spec.md 定義）")

    # 3b) 未覆蓋規則：非 container、非 pending、無任何非-pending covers → FAIL；pending → INFO
    for rid in sorted(rules, key=lambda r: (int(r[1:].split(".")[0]), r)):
        if rid in containers:
            continue
        if covers.get(rid):
            continue
        if is_pending(rid):
            infos.append(f"`{rid}` 無 QA covers，但屬 @PENDING（TBD 關前不計 gate⑤）")
        else:
            fails.append(f"`{rid}` 無任何 QA covers（gate⑤：每個非-@PENDING 規則至少 1 條）")

    # 4) Traceability Matrix / 內文引用的 QA-id 未定義 → FAIL（除非任一引用處標 placeholder）
    referenced = {}  # qid -> [lines]
    for ln in spec:
        for qm in re.finditer(r"QA-\d+", ln):
            referenced.setdefault(qm.group(0), []).append(ln)
    for qid, lines in sorted(referenced.items()):
        if qid in qa_defined:
            continue
        if any(PLACEHOLDER_RE.search(l) for l in lines):
            infos.append(f"{qid} 在 spec.md 被引用但 qa-cases.md 未定義（已標 placeholder，視為待補）")
        else:
            fails.append(f"{qid} 在 spec.md 被引用，但 qa-cases.md 無此 case（懸空引用；補 case 或標 placeholder）")

    # 5) 分支覆蓋自承不完整（2026-06-16 升級，破「≥1 假綠」）：Rn 雖有非-pending case，
    #    但 qa 在該 Rn 的覆蓋描述（`Rn：…` 至下個 ｜/換行的視窗）自承「僅…分支／未撰寫／
    #    RD 補／不可當已覆蓋」→ warn（≥1 過但非全分支；補 happy/error/edge）。
    qa_text = "\n".join(qa)
    partial_re = re.compile(r"僅[^｜|\n]{0,20}分支|不可當已覆蓋|partial", re.IGNORECASE)
    partial_rids = set()
    for m in re.finditer(r"(R\d+(?:\.\d+)?)[：:]([^｜|\n]{0,80})", qa_text):
        rid, tail = m.group(1), m.group(2)
        if rid not in rules or not covers.get(rid) or is_pending(rid):
            continue
        if partial_re.search(tail) or PLACEHOLDER_RE.search(tail):
            partial_rids.add(rid)
    for rid in sorted(partial_rids, key=lambda r: (int(r[1:].split(".")[0]), r)):
        warns.append(
            f"`{rid}` 覆蓋自承不完整（分支未齊／case 未撰寫）→ gate⑤ ≥1 過但非全分支覆蓋；"
            f"補 happy/error/edge case（破假綠，見檔頭 #3）"
        )
    return fails, warns, infos


# ---------- gateⓈ Status ↔ 未承載 Bible 安全 seam（2026-06-16 升級）----------
BP_PENDING_RE = re.compile(r"BP\d+-PENDING")


def gate_status_safety(bundle):
    """gateⓈ：Status↔安全/雙軸（皆 warn）。
    (a) Status 含 Approved 但有未承載 Bible→PRD seam（BPn-PENDING）——機械無法判 BP 是否安全/災難
        → 逼人確認（未承載安全條件不得 Approved）。
    (b) Status 含 Approved 但未分『規格定版 / 實作完成』兩軸——破「Approved 混『規格定了』與
        『實作好了』」（2026-06-16 批判輪2）。"""
    sp = os.path.join(bundle, "spec.md")
    if not os.path.isfile(sp):
        return [], []
    spec = read(sp)
    # header 容忍註記（如「Status（雙軸）」）→ `[^|]*` 吃到首個 pipe，免漏抓 Status 列致假綠
    status_line = next(
        (ln for ln in spec.splitlines()
         if re.match(r"^\|\s*Status[^|]*\|", ln) and "Approved" in ln),
        None,
    )
    if status_line is None:
        return [], []
    warns = []
    # (a) Approved 帶未承載 Bible→PRD seam
    bps = sorted(set(BP_PENDING_RE.findall(spec)))
    if bps:
        warns.append(
            f"Status 含 Approved，但有未承載 Bible→PRD seam（{', '.join(bps)}）——"
            f"確認無安全/災難條件未承載方可 Approved（**未承載安全條件不得 Approved**；"
            f"機械無法判是否安全條件→人確認，見檔頭 gateⓈ(a)）"
        )
    # (b) Status 雙軸：規格定版 vs 實作完成 須分離
    if not ("規格定版" in status_line and "實作完成" in status_line):
        warns.append(
            "Status 含 Approved 但未分『規格定版 / 實作完成』兩軸——單一 `Approved(subset)` "
            "易混『規格定了』與『實作好了』；請拆兩軸（如 `規格定版: Approved(subset) ／ "
            "實作完成: D1–D5`），見檔頭 gateⓈ(b)"
        )
    return [], warns


# ---------- 跨檔完整性（endpoint↔openapi、spec 表↔schema、錯誤碼↔openapi）----------
CODE_RE = re.compile(r"\b(?:COMMON_MSG|MSG)_[A-Z0-9_]+")
TABLE_RE = re.compile(r"\bTB_[A-Z0-9_]+")


def gatex_crossfile(bundle):
    """跨檔完整性——抓「一檔有、另一檔漏」的對齊缺口（機械層）。"""
    fails, warns = [], []
    sp = os.path.join(bundle, "spec.md")
    op = os.path.join(bundle, "openapi.yaml")
    sq = os.path.join(bundle, "schema.sql")
    if not os.path.isfile(sp):
        return ["缺 spec.md（跨檔檢查無法做）"], []
    spec = read(sp)
    op_text = read(op) if os.path.isfile(op) else ""

    # 1) endpoint ↔ openapi paths：openapi 的 epl-* 路徑都要在 spec.md 提到（契約要有規則對應）
    opaths = set()
    try:
        import yaml
        odoc = yaml.safe_load(op_text) if op_text else {}
        if isinstance(odoc, dict):
            opaths = {str(p).lstrip("/") for p in (odoc.get("paths") or {})}
    except Exception:  # noqa: BLE001
        opaths = set()
    spec_epl = set(re.findall(r"epl-[a-z0-9-]+", spec))
    for p in sorted(opaths):
        if p.startswith("epl-") and p not in spec_epl:
            fails.append(f"openapi 有 endpoint `{p}`，但 spec.md 全文未提（契約無對應規則？）")
    for e in sorted(spec_epl - opaths):
        warns.append(f"spec.md 提到 `{e}`，但 openapi 無此 path（as-is/prose？確認是否該入契約）")

    # 2) spec 的 TB_ 表 ↔ schema.sql（CREATE 或註解都算「列了」）
    if os.path.isfile(sq):
        sql_tables = set(TABLE_RE.findall(read(sq)))
        for t in sorted(set(TABLE_RE.findall(spec)) - sql_tables):
            fails.append(f"spec.md 提到表 `{t}`，但 schema.sql 未列（CREATE 或註解皆無 → 補 DDL/註解）")

    # 3) 錯誤碼 ↔ openapi responses（advisory：prompt-stage 或待 RD response mapping 可接受）
    for c in sorted(set(CODE_RE.findall(spec)) - set(CODE_RE.findall(op_text))):
        warns.append(f"錯誤碼 `{c}` 在 spec.md 但 openapi 未現（prompt-stage？或待 RD 補 response mapping）")

    # 4) 強制點欄：每條 `### Rn` 頂規則應標 強制點（FE/BE/both）。warn 級（DoD/reviewer 另把關）
    for ln in spec.splitlines():
        m = re.match(r"^###\s+(R\d+)\b", ln)
        if m and "強制點" not in ln:
            warns.append(f"規則 `{m.group(1)}` 未標**強制點**（FE/BE/both）——#7：完整性驗證 BE 權威")
    return fails, warns


# ---------- gate ⑥ Bible↔PRD 對照（治 BP-7：上游漂移要有 gate）-----------------
PRD_ROOT = "docs/specs/prd"
REQ_RE = re.compile(r"REQ-\d{3}")
BR_ROW_RE = re.compile(r"^\*{0,2}BR-\d+")


def gate_bible_prd(bundle):
    """gateⒷ：covers-prd ↔ PRD 快照 ↔ Bible↔PRD trace sidecar 三方對照。

    - spec.md 引用的 REQ 不在 PRD 快照 → FAIL（懸空上游追溯，同 gate⑤ 懸空類）。
    - 快照/trace 不存在 → warn 後略過（advisory；鏡像 i0 bundle 無 PRD 屬正常）。
    - trace 表 A 的 BR 列無 REQ 對應、也無 BP-n/@PENDING 登記 → warn（漂移未登記）。
    - PRD 快照的 REQ 未入 trace → warn（上行追溯缺列）。
    """
    fails, warns, infos = [], [], []
    funcid = os.path.basename(bundle.rstrip("/"))
    sp = os.path.join(bundle, "spec.md")
    if not os.path.isfile(sp):
        return [], [], []
    spec_reqs = set(REQ_RE.findall(read(sp)))

    snaps = sorted(glob.glob(os.path.join(PRD_ROOT, f"PRD-*{funcid}*.md")))
    if not snaps:
        if spec_reqs:
            warns.append(f"無 PRD 快照（{PRD_ROOT}/PRD-*{funcid}*.md）→ covers-prd 無法對快照驗（advisory 略過）")
        return fails, warns, infos
    prd_reqs = set(REQ_RE.findall(read(snaps[-1])))
    for r in sorted(spec_reqs - prd_reqs):
        fails.append(f"spec.md 引用 `{r}`，但 PRD 快照無此 REQ（懸空上游追溯；對 covers-prd 或重新快照）")

    traces = sorted(glob.glob(os.path.join(PRD_ROOT, f"trace-*{funcid}*.md")))
    if not traces:
        warns.append(f"無 Bible↔PRD 對照表（{PRD_ROOT}/trace-*{funcid}*.md）→ Bible→PRD 漂移無登記點（BP-7 類）")
        return fails, warns, infos
    trace_reqs = set()
    for ln in read(traces[-1]).splitlines():
        s = ln.strip()
        if not s.startswith("|"):
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        if not cells:
            continue
        if BR_ROW_RE.match(cells[0]):
            row_reqs = REQ_RE.findall(ln)
            trace_reqs.update(row_reqs)
            if not row_reqs and not re.search(r"BP-\d|@PENDING", ln):
                warns.append(f"trace `{cells[0].strip('*')}` 無 PRD REQ 對應、也無 BP-n/@PENDING 登記（漂移未登記）")
        elif REQ_RE.match(cells[0].strip("*")):
            trace_reqs.update(REQ_RE.findall(cells[0]))
    for r in sorted(prd_reqs - trace_reqs):
        warns.append(f"PRD `{r}` 未入 Bible↔PRD 對照表（上行追溯缺列）")

    # Bible BR 點名本 funcId、但 trace 表 A 未列 → warn（漏列候選；治「人工通讀挑 BR」漏網）
    trace_brs = set(re.findall(r"BR-\d{3}", read(traces[-1])))
    for bf in sorted(glob.glob("docs/specs/bible/bible-*.md")):
        for ln in read(bf).splitlines():
            bm = re.match(r"^\|\s*(BR-\d{3})\b", ln.strip())
            if bm and funcid in ln and bm.group(1) not in trace_brs:
                warns.append(
                    f"Bible `{bm.group(1)}` 點名 {funcid}，但 trace 表 A 未列"
                    f"（漏列候選；{os.path.basename(bf)}）")
    infos.append(f"對照：{os.path.basename(snaps[-1])} ＋ {os.path.basename(traces[-1])}")
    return fails, warns, infos


# ---------- gateⒺ 錯誤碼承載：PRD Error Response 表 → spec.md + openapi ---------
def gate_error_carry(bundle):
    """gateⒺ：PRD（上游權威）的每個錯誤碼，下游 spec.md（Rn 錯誤規則）+ openapi
    responses 是否都承載。

    - PRD 列了、但 spec.md 與 openapi **皆無** → warn（漏承載；B-1 類）。
    - PRD↔openapi 同碼但 HTTP status 不一致 → warn（B-2 status 面）。
    皆 warn：機械不判語意嚴重度（init-query 無分頁可 disclaim 等），由人/spec-reviewer 認。
    **解析前先去 markdown 底線跳脫 `\\_`**（PRD 表格寫 `MSG\\_X`，literal `_` 比對會漏抓
    ＝SR-B1 當初的根因）。無 PRD 快照（鏡像 i0 bundle）或 PRD 無 Error 表 → 跳過。
    """
    fails, warns, infos = [], [], []
    funcid = os.path.basename(bundle.rstrip("/"))
    sp = os.path.join(bundle, "spec.md")
    if not os.path.isfile(sp):
        return fails, warns, infos
    snaps = sorted(glob.glob(os.path.join(PRD_ROOT, f"PRD-*{funcid}*.md")))
    if not snaps:
        return fails, warns, infos  # 鏡像 i0 bundle 無 PRD → 跳過
    prd = read(snaps[-1]).replace("\\_", "_")  # 關鍵：去底線跳脫（SR-B1 漏抓根因）
    prd_codes = {}  # code -> http status(str) or None；錯誤碼在表格 cell[0]、status 在 cell[1]
    for ln in prd.splitlines():
        s = ln.strip()
        if not s.startswith("|"):
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        if len(cells) < 2:
            continue
        cm = CODE_RE.match(cells[0])
        if not cm:
            continue
        st = re.search(r"\b([45]\d{2})\b", cells[1])
        prd_codes[cm.group(0)] = st.group(1) if st else None
    if not prd_codes:
        return fails, warns, infos  # PRD 無 Error Response 表（或非表格形）→ 跳過
    spec_codes = set(CODE_RE.findall(read(sp)))
    op = os.path.join(bundle, "openapi.yaml")
    op_raw = read(op) if os.path.isfile(op) else ""
    op_codes = set(CODE_RE.findall(op_raw.replace("\\_", "_")))
    # 承載：PRD 碼在 spec、openapi 皆無 → 漏承載（B-1）
    missing = [c for c in prd_codes if c not in spec_codes and c not in op_codes]
    for c in sorted(missing):
        warns.append(
            f"PRD 錯誤碼 `{c}`（{prd_codes[c] or 'status?'}）未承載進 spec.md 或 openapi——"
            f"漏承載（補 Rn 錯誤規則 + openapi response，或明文 disclaim+owner；見檔頭 gateⒺ）")
    # HTTP status 一致：PRD 碼在 openapi responses 但 status key 不符（B-2 status 面）
    try:
        import yaml
        odoc = yaml.safe_load(op_raw) if op_raw else {}
        code_status = {}  # code -> set(status)；從 paths→*→responses→<status>→description 取碼
        if isinstance(odoc, dict):
            for _p, methods in (odoc.get("paths") or {}).items():
                if not isinstance(methods, dict):
                    continue
                for _m, opv in methods.items():
                    if not isinstance(opv, dict):
                        continue
                    for status, body in (opv.get("responses") or {}).items():
                        desc = str(body.get("description") or "") if isinstance(body, dict) else ""
                        for c in CODE_RE.findall(desc.replace("\\_", "_")):
                            code_status.setdefault(c, set()).add(str(status))
        for c in sorted(code_status):
            ps = prd_codes.get(c)
            if ps and ps not in code_status[c]:
                warns.append(
                    f"錯誤碼 `{c}` HTTP status 不一致：PRD {ps} ↔ openapi {sorted(code_status[c])}"
                    f"（gateⒺ；確認 to-be 改了 status 或漏對）")
    except ImportError:
        pass  # 無 pyyaml → 只做承載(文字)檢查，status 一致性略過
    infos.append(f"PRD Error Response：{len(prd_codes)} 碼承載檢查（漏 {len(missing)}）")
    return fails, warns, infos


# ---------- gate ⑦ @PENDING ↔ pending-register 同步 ---------------------------
REGISTER_PATH = "docs/pending-register.md"
RP_CELL_RE = re.compile(r"^\*{0,2}(RP\d+)\b")
BP_CELL_RE = re.compile(r"^\*{0,2}BP(\d+)-PENDING\b")


def gate_pending_register(bundle):
    """gateⓅ：spec.md @PENDING 表 ↔ pending-register 單向同步（spec＝來源、register＝derived 視圖）。

    - spec @PENDING 表開著（非 ✅）的 RPn / BPn-PENDING → 必須出現在 register 的 open 區，
      否則 FAIL（漏登記＝有人不知道自己欠裁定）。
    - spec 已關（✅）的 id 仍出現在 register open 區 → FAIL（register 失步）。
    - register 的非 SRS 來源列不在本 gate 範圍（無機械來源可對，見檔頭）。
    """
    fails, warns, infos = [], [], []
    sp = os.path.join(bundle, "spec.md")
    if not os.path.isfile(sp):
        return [], [], []
    open_ids, closed_ids = set(), set()
    for ln in read(sp).splitlines():
        s = ln.strip()
        if not s.startswith("|"):
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        if not cells:
            continue
        m = RP_CELL_RE.match(cells[0])
        if m and len(cells) >= 2:
            (closed_ids if "✅" in cells[1] else open_ids).add(m.group(1))
            continue
        b = BP_CELL_RE.match(cells[0])
        if b:
            open_ids.add(f"BP-{b.group(1)}")
    if not (open_ids or closed_ids):
        return fails, warns, infos  # 無 @PENDING 表（鏡像 i0 bundle）→ 跳過
    if not os.path.isfile(REGISTER_PATH):
        warns.append(f"無 {REGISTER_PATH} → @PENDING 同步無法驗（advisory 略過）")
        return fails, warns, infos
    reg_open = re.split(r"^##[^\n]*已關[^\n]*$", read(REGISTER_PATH),
                        maxsplit=1, flags=re.M)[0]
    for rid in sorted(open_ids):
        if not re.search(rf"\b{re.escape(rid)}\b", reg_open):
            fails.append(f"spec @PENDING `{rid}`（開）未登錄 pending-register open 區（漏登記）")
    for rid in sorted(closed_ids):
        if re.search(rf"\b{re.escape(rid)}\b", reg_open):
            fails.append(f"spec 已關 `{rid}` 仍出現在 pending-register open 區（register 失步）")
    infos.append(f"同步：open {len(open_ids)} / closed {len(closed_ids)} ↔ {REGISTER_PATH}")
    return fails, warns, infos


# ---------- doc-paths（--all 附帶；advisory）-----------------------------------
DOC_PATH_RE = re.compile(
    r"`((?:docs|scripts|\.claude|\.github)/[A-Za-z0-9_.\-/]+"
    r"\.(?:md|py|json|toml|ya?ml|sql|mmd|svg))`")
DOC_PATH_SKIP = ("docs/build-tasks/done/", "docs/archive/")


def scan_doc_paths():
    """掃全 repo markdown 內 backtick 引用的 root-anchored 路徑是否存在。
    抓 reorg 後的舊路徑殘留（markdown link checker 只看 []() 連結、看不到 inline code）。
    歷史檔（build-tasks/done/、archive/）是當時的紀錄、不掃。advisory only。"""
    warns = []
    targets = (glob.glob("*.md") + glob.glob("docs/**/*.md", recursive=True)
               + glob.glob(".claude/**/*.md", recursive=True)
               + glob.glob(".github/**/*.md", recursive=True)
               + ["backend/AGENTS.md", "frontend/AGENTS.md"])
    for path in targets:
        if any(s in path for s in DOC_PATH_SKIP) or not os.path.isfile(path):
            continue
        for m in DOC_PATH_RE.finditer(read(path)):
            if not os.path.exists(m.group(1)):
                warns.append(f"{path}：`{m.group(1)}` 不存在（舊路徑殘留？）")
    return warns


# ---------- runner -----------------------------------------------------------
def check_bundle(bundle):
    funcid = os.path.basename(bundle.rstrip("/"))
    print(f"\n=== {funcid} ===")
    total_fail = 0
    g1f, g1w = gate1_openapi(bundle)
    g2f, g2w = gate2_schema(bundle)
    g5f, g5w, g5i = gate5_traceability(bundle)
    gxf, gxw = gatex_crossfile(bundle)
    gbf, gbw, gbi = gate_bible_prd(bundle)
    gpf, gpw, gpi = gate_pending_register(bundle)
    gsf, gsw = gate_status_safety(bundle)
    gef, gew, gei = gate_error_carry(bundle)
    sections = [
        ("gate①openapi", g1f, g1w, []),
        ("gate②schema ", g2f, g2w, []),
        ("gate⑤covers ", g5f, g5w, g5i),
        ("xfile 完整性 ", gxf, gxw, []),
        ("gateⒷbible↔prd", gbf, gbw, gbi),
        ("gateⓅpending同步", gpf, gpw, gpi),
        ("gateⓈstatus安全", gsf, gsw, []),
        ("gateⒺ錯誤碼承載", gef, gew, gei),
    ]
    for name, fails, warns, infos in sections:
        status = "FAIL" if fails else "PASS"
        print(f"[{name}] {status}")
        for m in fails:
            print(f"    X {m}")
        for m in warns:
            print(f"    ! {m}")
        for m in infos:
            print(f"    i {m}")
        total_fail += len(fails)
    return total_fail


def discover_all():
    if not os.path.isdir(BUNDLE_ROOT):
        return []
    return sorted(
        os.path.join(BUNDLE_ROOT, d)
        for d in os.listdir(BUNDLE_ROOT)
        if os.path.isdir(os.path.join(BUNDLE_ROOT, d))
        and os.path.isfile(os.path.join(BUNDLE_ROOT, d, "spec.md"))
    )


def main(argv):
    args = argv[1:]
    if not args:
        print(__doc__)
        return 2
    bundles = discover_all() if args[0] == "--all" else [a for a in args if os.path.isdir(a)]
    if not bundles:
        print("找不到 bundle（給 bundle 資料夾路徑，或 --all）")
        return 2
    total = sum(check_bundle(b) for b in bundles)
    if args[0] == "--all":
        pw = scan_doc_paths()
        print("\n[doc-paths（advisory）] " + ("PASS" if not pw else f"{len(pw)} 筆殘留"))
        for m in pw:
            print(f"    ! {m}")
    print()
    if total:
        print(f"check-srs-bundle: FAIL — {total} 項硬違反（涵蓋範圍見檔頭）。語意審查另跑 spec-reviewer。")
        return 1
    print(f"check-srs-bundle: PASS — {len(bundles)} bundle，無機械違反。（語意正確性仍需 spec-reviewer）")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

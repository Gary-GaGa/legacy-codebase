# EPROZ00100 — 母資料夾 fix-pack（typo + gate② + TBD-001）

> **用途**：owner 在**母資料夾**（含 `docs/db-schema/02_tables/` snapshot 的 superset working copy）一次套用 → 一個 atomic commit → push 回 `Gary-GaGa/legacy-codebase` `main`。
> **為什麼是這份**：spec repo（本 repo）＝規劃/規格/backlog、無原始碼，**沒有 db-schema snapshot**；真實 DB 長度與資料只在母資料夾能核對。因此 bundle 的修改集中在母資料夾一次做，spec repo 這側**不動 bundle**（避免 dir rename 撞車）。
> **落地後**：spec repo 這側 `git fetch` → 機械閘門驗證 → SSOT backfill（見 §5），單獨一個 PR。
> **脈絡**：PR #102/#103（`decisions.md` −29%、`feature-inventory.md` −11.6%）後的收尾；funcId = `EPROZ00100`（現 dir 為 typo `ERPOZ00100`）。

---

## 0. 一次套用順序（建議 atomic commit）
1. dir rename + 內文引用正名（§1）
2. gate② 解 — owner 定奪修法（§2）
3. TBD-001 套用包（§3）
4. 機械閘門 `exit 0`（§4）
5. `commit` + `push`；spec repo 這側做 §5 backfill

```bash
# 母資料夾根目錄；先抓 bundle 路徑（rename 前/後都吃）
BUNDLE=$(ls -d docs/specs/srs/E?POZ00100 2>/dev/null | head -1); echo "bundle = $BUNDLE"
```

---

## 1. Typo rename（funcId 正名）
`docs/specs/srs/ERPOZ00100/ → docs/specs/srs/EPROZ00100/`，內文引用一併改。
```bash
git mv docs/specs/srs/ERPOZ00100 docs/specs/srs/EPROZ00100
# 內文 / 其他檔對 funcId 的引用（feature-inventory、traceability、decisions…）
grep -rl "ERPOZ00100" docs/ | xargs sed -i 's/ERPOZ00100/EPROZ00100/g'
BUNDLE=docs/specs/srs/EPROZ00100
```

---

## 2. gate② — **false-positive name-collision，不是長度 bug**
`check-srs-bundle.py` 把 schema 欄位 ↔ openapi 同名欄位**逐名比長度**，但下面兩對是**跨層同名、語意不同**：

| gate② 抱怨 | openapi 那側（API 層） | schema 那側（DB 層） | 判定 |
|---|---|---|---|
| `role` 3 ↔ `ROLE` 100 | `data.role` = **3 碼 role code**（`404/405`…，`spec.md:53`/`TBD-001`） | `TB_API_AUTH.ROLE VARCHAR2(100)` = 授權分組欄 | **碰撞** |
| `borrowerName` 100 ↔ `BORROWER_NAME` 50 | CAD **顯示欄**，刻意 =100（`REF-D2` follow refactor） | `TB_RELATED_PARTY_INFO.BORROWER_NAME VARCHAR2(50)` = PK 儲存欄 | **碰撞** |

**正解 mapping**（給文件 + 任一修法依據）：openapi `role`(maxLength 3) 的真實對象是 `TB_ROLE_DEFINE.ROLE_ID VARCHAR2(3)`（**同長度、會 PASS**），不是被誤配的 `TB_API_AUTH.ROLE(100)`。→ gate② 是誤判鐵證；**對齊數字每個方向都錯**（會破 API contract 或 DB 真相）。

**修法（owner 定奪，二擇一）**
- **(A) gate 側**：讓 `check-srs-bundle.py` 不再把 API 層 code/display 欄（如 `role`/`borrowerName`）跨層強配到同名 DB 欄。屬**雙軌共用、非 LLM 機械閘門** → 改完維持 `check-dualtrack-parity.py` parity，且涵蓋範圍以**腳本檔頭 canonical 清單**為準。
- **(B) bundle 側**：在 bundle 內消歧（不改 FE 依賴的 contract 欄名前提下）。

**先核對真實 DB（母資料夾 snapshot＝SSOT）再決定**
```bash
grep -niE "\bROLE\b|VARCHAR"        docs/db-schema/02_tables/TB_API_AUTH.md
grep -niE "BORROWER_NAME|VARCHAR"   docs/db-schema/02_tables/TB_RELATED_PARTY_INFO.md
# 若 snapshot ≠ schema.sql → 真 drift：先把 schema.sql 校到 snapshot，再重判 openapi 那側
```

---

## 3. TBD-001 — **由查 DB 解掉**（role names + authorization matrix）
schema 已宣告所需表：`TB_ROLE_DEFINE(ROLE_ID(3), ROLE_NAME(50), ROLE_DESC(50))`、`TB_API_AUTH(API_ID(100), ROLE(100), REF_FUNCTION_ID)`。缺的只是 **rows**（母資料夾查）。

### 3.1 查詢（母資料夾 / real DB）
```sql
-- (a) role code → 名稱（TBD-001 的 names）
SELECT ROLE_ID, ROLE_NAME, ROLE_DESC
FROM   TB_ROLE_DEFINE
WHERE  ROLE_ID IN ('001','002','003','101','102','103',
                   '201','202','203','301','302','404','405')
ORDER  BY ROLE_ID;

-- (b) authorization matrix（TBD-001 的 matrix）；API_ID = 本頁 8 個 epl-* 端點
SELECT API_ID, ROLE, REF_FUNCTION_ID
FROM   TB_API_AUTH
WHERE  API_ID IN ('epl-comm-todolist-prompt','epl-list-todolist',
                  'epl-comm-field-options','epl-case-insert-delreason',
                  'epl-case-insert-cloreason','epl-file-todolist-download',
                  'epl-comm-todolist-setsession','epl-comm-todolist-clearsession')
ORDER  BY API_ID, ROLE;
```

### 3.2 SRS 套用包（填 ⟨⟩ 後貼進 `$BUNDLE/spec.md`）
**① `spec.md` R1 註 — 替換最後一句**
- 舊：`To-be role names/permission semantics remain @PENDING(TBD-001).`
- 新：`To-be role labels resolve from TB_ROLE_DEFINE (ROLE_ID→ROLE_NAME/ROLE_DESC), keyed by the 3-char role; the concrete code set and per-endpoint authorization are normative in Appendix A (snapshot of TB_ROLE_DEFINE/TB_API_AUTH, mirror-legacy per REF-D4).`

**② `spec.md` 授權規則（現引 `TB_API_AUTH`+`TB_ROLE_DEFINE` 那句）— 句末加**
`The to-be authorization matrix for the eight EPROZ00100 epl-* endpoints is the TB_API_AUTH snapshot in Appendix A-2; role labels resolve via TB_ROLE_DEFINE (Appendix A-1).`

**③ 新增 Appendix A（接 Traceability Matrix 後）**
```markdown
## Appendix A — Role dictionary & authorization matrix (TBD-001)
> SSOT：TB_ROLE_DEFINE（labels）+ TB_API_AUTH（authorization）。Snapshot as-of ⟨YYYY-MM-DD⟩，mirror-legacy parity 依 REF-D4。

### A-1 Role dictionary
| ROLE_ID | ROLE_NAME | ROLE_DESC |
|---|---|---|
| 001 | ⟨⟩ | ⟨⟩ |
| 002 | ⟨⟩ | ⟨⟩ |
| 003 | ⟨⟩ | ⟨⟩ |
| 101 | ⟨⟩ | ⟨⟩ |
| 102 | ⟨⟩ | ⟨⟩ |
| 103 | ⟨⟩ | ⟨⟩ |
| 201 | ⟨⟩ | ⟨⟩ |
| 202 | ⟨⟩ | ⟨⟩ |
| 203 | ⟨⟩ | ⟨⟩ |
| 301 | ⟨⟩ | ⟨⟩ |
| 302 | ⟨⟩ | ⟨⟩ |
| 404 | ⟨⟩ | ⟨⟩ |
| 405 | ⟨⟩ | ⟨⟩ |

### A-2 Endpoint authorization
| API_ID | authorized ROLE(s) | REF_FUNCTION_ID |
|---|---|---|
| epl-comm-todolist-prompt | ⟨⟩ | ⟨⟩ |
| epl-list-todolist | ⟨⟩ | ⟨⟩ |
| epl-comm-field-options | ⟨⟩ | ⟨⟩ |
| epl-case-insert-delreason | ⟨⟩ | ⟨⟩ |
| epl-case-insert-cloreason | ⟨⟩ | ⟨⟩ |
| epl-file-todolist-download | ⟨⟩ | ⟨⟩ |
| epl-comm-todolist-setsession | ⟨⟩ | ⟨⟩ |
| epl-comm-todolist-clearsession | ⟨⟩ | ⟨⟩ |

> openapi role(maxLength 3) 驗證對象＝TB_ROLE_DEFINE.ROLE_ID VARCHAR2(3)，非 TB_API_AUTH.ROLE(100)——即 §2 gate② 的正解 mapping。
```

**④ `spec.md` REF-Dn 決策表（接 `REF-D3` 後）— 新增列**
`| REF-D4 | TB_ROLE_DEFINE/TB_API_AUTH snapshot as-of ⟨date⟩；legacy role-flag 推導 EPROZ0_0100.java:74-91 | To-be role 標籤＋逐 endpoint 授權＝鏡像 legacy DB snapshot（refactor 不改政策）；grounds Appendix A、closes TBD-001。 | (b) mirror legacy parity；PM/SA 簽 |`

**⑤ `@PENDING` 表 — TBD-001 列**
- 全填好＋REF-D4 已簽：`| TBD-001 | PM/SA | Role names + authz matrix → Appendix A（TB_ROLE_DEFINE/TB_API_AUTH snapshot）。 | no | resolved |`
- 只 names 好、matrix 待簽：`status partial`、`blocking no`、註 "names done; matrix pending REF-D4"。

**⑥ `spec.md:5` Status 行**
- 新：`In Review - PRD TBD-002~008 未裁（TBD-001 resolved → Appendix A）；blocking: TBD-002 prompt redistribution/method, TBD-004 CAD docNo mapping, TBD-006 download file security.`

**⑦ QA（建議補 1 條，讓 matrix 可測）**
A-2 成 normative：happy＝某授權 ROLE 呼 `epl-case-insert-delreason`→200；error＝role `003`→403 `FORBIDDEN_ACTION`（R-delete 已有，交叉 cover）。covers→授權規則。

### 3.3 治理（別漏）
- (a) names＝純 DB 解掉；(b) matrix＝DB grounding + **REF-D4 那行 PM/SA「mirror legacy」簽**才算真關（TBD-001 owner=PM/SA、原 blocking=yes）。
- TBD-001 **不**碰 R2/R12（那是 `TBD-002` CA/CR redistribution、`TBD-008` session/route）。

---

## 4. 機械閘門驗證（套完、push 前）
```bash
python3 scripts/check-srs-bundle.py "$BUNDLE"; echo "exit=$?"   # 期望 exit=0
python3 scripts/check-dualtrack-parity.py; echo "parity=$?"     # 若動了 §2(A) gate 才需特別留意
```
④⑤⑥ 動到 `@PENDING`/Status/決策表 → `gateⓅpending同步`、`gateⓈstatus安全` 會檢，需綠。
> 涵蓋範圍**以 `check-srs-bundle.py` 檔頭 canonical 清單為準**，勿在他處複寫。

---

## 5. 落地後 backfill（spec repo 這側，後續 PR；非 owner 工作）
- `git fetch origin main` → 確認 §4 兩閘門綠（gate② 解、TBD-001 套用）。
- `spec-reviewer` N 軸抽查 Appendix A / REF-D4 一致性、無 Blocker。
- SSOT backfill：
  - `feature-inventory.md` §2E：TBD-001 closed、authz matrix 計入、dir 正名。
  - Traceability Matrix：TBD-001 → Appendix A row。
  - pending-register / `@PENDING`：TBD-001 `resolved`。
  - 進度：matrix `0/67 → 1/67`。
- 單獨一個 PR、不自動 merge。

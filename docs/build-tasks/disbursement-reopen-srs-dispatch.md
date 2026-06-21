# Build Task — 撥貸 re-open SRS dispatch overlay（0921 / 0922+T24）

> **性質**：頁別**薄殼 overlay**，疊在通用 `prd-to-srs-codex-dispatch.md` 上——只放「撥貸 re-open 三頁的頁別具體值＋ re-open override」，**通用轉換流程/鐵則/DoD/閘門＝base prompt，勿在此複寫**。
> **適用頁**：`EPROISU0922`(+T24)、`EPROISU0921`＝06-20 owner 在 **SRS 層 re-open**「照舊」者；`EPROISU0920`＝未 re-open（無照舊衝突、走通用）。
> **權威**：re-open 框架＝`decisions.md`「T24/0921 於 SRS 層 re-open」＋「撥貸 re-open 的 to-be＝走 §5b SoT 梯裁」；梯裁＝`spec-architecture §5b`／`ADR-0002`；待決＝`pending-register` 兩 re-open 列。

## 0. 開火前置（gate；缺則勿跑）
1. **PRD 定稿**：`build-tasks/prd-drafts/PRD-…-<funcId>-v0.1-DRAFT.md` 由 PM 填完 `〔PM:…〕`＋§7 TBD → 改名 `…-v1.0.md` 移 `docs/specs/prd/` → matrix ledger 該列升 `prd-ready`（orchestrator 只 pick `prd-ready`）。
2. **母資料夾備齊** `docs/refactor-spec/`＋`docs/db-diff/`（本規劃 repo 無此二夾）；**搆不到** → SRS 須顯式 disclaim「待母資料夾複核」＋列已知 delta（`check-srs-bundle` gateⓇ，非靜默留白）。
3. **as-is 來源**＝母資料夾產品碼 ＋ 舊 T24 spec（`EPROIS_0922-t24.md`）＋ parity findings（`done/t24-bgroup-legacy-parity-fix-findings.md`，commit `3d6f446`）。

## 1. 頁別具體值（填進 base prompt 的 `<funcId>`／`<PRD 路徑>`／§5 來源）

### `EPROISU0922`(+T24) — **to-be 偏新使用方式（refactor-wins）**
- **PRD**：`docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0922-v1.0.md`
- **refactor-spec 必讀**：`docs/refactor-spec/02_modules/EPROISU0922.md` ＋ `03_artifacts/{be,fe}-shared/EPROISU0922/`（T24 介面 artifact）＝**T24 新使用方式 SoT**
- **db-diff**：`docs/db-diff/`（T24 寫入表 ＋ `TB_BRANCH_PROFILE.T24_COMPANY` 物理欄〔B-1〕）
- **re-open 逐欄清單（REQ-004；各欄：as-is baseline 舊 → 比對 refactor-spec/db-diff → to-be 新/舊/`REF-Dn` → owner confirm；未 confirm＝@PENDING）**：
  `A15`/`A16`/`A31`/`A52`、B 段、`C12`/`C13`/`C20`/`C26`、D 段、`E14–E23`/`E21`、`G4`/`G7`/`G10`/`G11–G12`、`H1–H8`。
  **風險最高先**：換匯 `G4`/`G10`/`H8` ＋ KHR 來源 ＋ B-1 `T24_COMPANY`→`B8`/`C9`。
- **方向**：舊系統 T24 在重構案已調整、refactor-spec 有對應 T24 調整 → **to-be 偏新（三判 b、留 `REF-Dn`）**；**非 default 照舊、勿寫「照舊 ✅」**。

#### 逐欄 re-open worksheet（as-is 已坐實者；證據＝`done/t24-bgroup-legacy-parity-fix-findings.md` + 舊 `EPRO_IS0922.java`）
> 用法：每欄 ① as-is 舊值＝下表(已坐實、commit `3d6f446` 現碼已對齊) ② **比對母資料夾 `refactor-spec/02_modules/EPROISU0922.md` + `03_artifacts/.../EPROISU0922/`**（填「refactor 有無對應調整」）③ 三判→to-be(新/舊/`REF-Dn`) ④ owner confirm。下表「refactor 待比 / to-be」＝母資料夾跑 SRS 時填。

| 欄 | as-is 舊值（baseline，舊 `file:line`）| 現碼（`3d6f446` 後）| refactor 對應調整？（待母資料夾填）| to-be（三判→confirm，待填）|
|---|---|---|---|---|
| `A16` | `NORMAL.LAON`（`:92-96/249-254/496`）| =舊 | ☐ | ☐ |
| `C12` | 讀 `TB_COLL_VALUE_INFO.SUG_VAL`（`:660-662/729`）| =舊 | ☐ | ☐ |
| `C13` | `lonSummaryInfo.DECISION_DATE`（`:642/650/729`）| =舊 | ☐ | ☐ |
| `A15` | 空值保留 `""`（`:307/493-494`）| =舊 | ☐ | ☐ |
| `G11`/`G12` | 舊 fee remark 文案+note 號（`:1031-1049/1096`）| =舊 | ☐ | ☐ |
| `A31` | `AGREEMENT_NO` 後 16 碼（`:301-302/505`）| =舊 | ☐ | ☐ |
| `G7` | `AGREEMENT_NO` 後 16 碼（`:1072-1073/1093-1094`）| =舊 | ☐ | ☐ |
| 行尾 | CRLF `\r\n`（`:70/176/555/1052/1170`）| =舊 | ☐ | ☐ |
| `C26` | 依 `COLL_DATA_SEQ` 過濾 title deed（`:529-550/702-716/738`）| =舊 | ☐ | ☐ |
| `E21` | 非 USD/KHR→`0`（A-5 收窄 keep；舊全換匯 `:934-940`）| keep（A-5 邊界）| ☐ | ☐ |
| `G4`/`G10`/`H8` | 換匯欄幣別來源（`:1076-1085/1090-1094/1133-1138/1154-1156`）| keep（A-5 邊界、RD 跟）| ☐（**KHR 最高風險先**）| ☐ |
| `T24_COMPANY`（B-1） | `OVSLXLON01`（06-17 裁）→`B8`/`C9` 接值 | 待 RD entity 映射 | ☐ | ☐ |
> **未在上表但屬 REQ-004 清單者**（`A52`/`C20`/B 段/D 段/`E14–E23`/`G7`外 G 欄/`H1–H7`）＝parity-fix 未動/已對齊 → as-is **待母資料夾逐欄坐實** `file:line` 後比 refactor-spec，同流程。


### `EPROISU0921` — **核心還原舊版 baseline、僅 delta 才改**
- **PRD**：`docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md`
- **refactor-spec／db-diff**：同慣例（`<funcId>`＝`EPROISU0921`）
- **re-open 逐項清單**：
  - REQ-002/006（A-4 檢核）：`CO_CHECK` 判定、`mbCheck` gate、law firm `IS_SHOW` 條件、address `UPD_DATE` 來源、`DATA_SEQ` 順序、business-section。
  - REQ-003（M6 完工日）：`EST_COM_DATE`/`OTHER_EST_COM_DATE` 兩欄值來源。
- **方向**：撥貸核心 as-is baseline＝舊；**僅 `db-diff`/`refactor-spec` 命中 delta（三判 b）才改＋`REF-Dn`**，否則維持舊；owner 逐項 confirm。
- **不 re-open**：REQ-004（fee M7/M10）、REQ-005（RECEIVED_DATE M4）＝已修 regression，當約束帶入。

### `EPROISU0920` — 撥貸 Process（頁框，domain-gated；**未 re-open**）
- 無 re-open 衝突 → 走**通用** base prompt；尚無 draft skeleton（待 PM 起 PRD，或先建骨架見本卡 §3）。

## 2. override 提醒（相對 base prompt【鐵則】line 120–124）
- T24/A-4/M6「照舊」**＝06-20 re-open、非凍結約束**（已在 base prompt §C line 82 + 鐵則 line 120–124 標例外）；**勿 re-litigate 成「照舊 ✅」**。
- 每個 re-open 欄/項未 owner-confirm＝`@PENDING`（金錢/交易/檢核，ADR-0002 升級觸發）。
- **撥貸＝金錢 T1** → N 軸跑**全 A–G**（不可降軸）；機械先 `check-srs-bundle exit 0`（含 gateⓇ delta 段）。

## 3. 收尾／回填
- bundle → 規劃 repo `docs/specs/srs/<funcId>/`；回填 `feature-inventory`（§③ 撥貸）＋ matrix ledger（SRS 欄）。
- re-open 欄/項的 to-be 提案 → **batch checkpoint 一次交 owner 逐欄/逐項 confirm**（confirm 後才從 @PENDING 轉定版；confirm＝舊 則 `REF-Dn` 標 unchanged、confirm＝新 則留 delta）。
- 更新 `pending-register` 兩 re-open 列狀態。

---
> 維護：本卡＝薄殼，頁別值變才動；通用流程改 base prompt。三頁 drain 完成（SRS in-review + owner confirm）後本卡可標 ✅ 移 `done/`。

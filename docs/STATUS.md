# STATUS — 重構總彙整 Dashboard（單一入口）

> **🔄 新 session / context 中斷後從這接回**（狀態全在 repo·已併 main，非對話記憶——心法見 `verification/verification-execution.md`「真相存 doc 不存記憶」）：
> Resume order: 1 `CLAUDE.md`, 2 this STATUS, 3 `pending-register.md`, 4 `build-tasks/`, 5 `decisions.md`. 2026-06-20 RD/DBA update: `EPROZ00100`/`EPROC00118` contract closeout completed, TB_API_AUTH direct apply + SELECT-only recheck passed, both SRS bundles now dual-axis Approved; closeout card archived under `build-tasks/done/`.
> ⚠️ Codex 在母資料夾產的 findings 是 untracked → **push 上來才進 repo**（同 AUD-10/KHR）。
> 2026-06-17 更新：T24 B-group parity fix 已套用並產出 `build-tasks/done/t24-bgroup-legacy-parity-fix-findings.md`；`E21` 依 A-5 USD+KHR-only 邊界 keep、`G4`/`G10`/`H8` 換匯欄幣別**來源 06-17 owner 裁照舊**（坐實舊 `DISBURSEMENT_CURRENCY`、收窄/rounding 仍 keep）。**金錢/截斷欄 pre-push 最嚴人審已過 → code 已 commit/push（product repo，commit `3d6f446`，06-17 10:41，已在 origin/master）**；剩端到端/T24 接收驗證（Phase V/UAT）。
> **⚠️ 2026-06-20 撥貸 SRS-層 re-open（owner）**：**T24（0922）＋ A-4/M6（0921）的「照舊」在 SRS 層 re-open**——`code` baseline（還原舊版，`3d6f446`）**仍為正確 as-is、不變**；但**產 SRS 時 to-be 不沿用「照舊」為定案**，改走 §5b SoT 梯裁（as-is 舊 → 比對 `db-diff`＋`refactor-spec` → **T24 偏新使用方式（refactor-spec 有對應調整）/核心 A-4/M6 預設舊 baseline、僅 delta 才改** → owner 逐欄/逐項 confirm）。**故撥貸 owner-decision 牆下方各處「全裁照舊／全清空」＝code 層為真、SRS 層已 re-open**（KHR-G·H/B-1 屬 T24 欄、併 0922 re-open）。權威＝`decisions.md`「T24/0921 於 SRS 層 re-open」＋「撥貸 re-open to-be＝走 §5b 梯裁」、`pending-register` 兩列、`spec-architecture §5b`/`ADR-0002`。

> **定位**：一眼看「整體進度／還剩什麼／卡在誰」。**細節不在這**——逐頁狀態＝`feature-inventory.md`（SSOT）、待決＝`pending-register.md`（SSOT）、Phase V runtime＝`verification/verification-handoff.md`。本檔只彙總層、指向 SSOT，數字來源見各列。
> Last updated **2026-06-20**: `EPROZ00100` + `EPROC00118` owner-decision pending closed, RD/DBA contract closeout completed, TB_API_AUTH direct apply + SELECT-only recheck passed against `OVSLXLON02`, both `check-srs-bundle` runs PASS, SRS coverage remains **2/67** and both covered bundles are Approved.

## 一、總進度（一句話）
**Migration code is still roughly ~80% present; FE rebuild is closed; no red owner-decision blocker is on the mainline. PRD-to-SRS coverage is 2/67, and both covered bundles (`EPROZ00100`, `EPROC00118`) are Approved after 2026-06-20 RD/DBA contract closeout. Current focus: Phase V runtime verification plus SRS expansion by risk tier.**

```
程式遷移(碼在)   ████████████████░░░░  ~80%   133/166 audit 列（源 feature-inventory §1）
PRD-to-SRS specs    ██░░░░░░░░░░░░░░░░░░  ~12%   **2/67 Approved** (`EPROZ00100` + `EPROC00118`, RD/DBA contract closeout complete); next risk-tier pages pending
FE 補建          ████████████████████  100%   Phase F c0 評分 9 頁 + Phase G 企金主流程 6 頁+popup
audit 修復包      ████████████████████  100%   5/5（00660/00100/00119/00640/00300）
Phase V runtime  █████░░░░░░░░░░░░░░░░  ~25%   V-1 登入✅；RV-1/RV-2 兩類 bug 已收斂；smoke V-2~V-6 待跑（c0 需先套授權列）
撥貸核心(A-1)     ███████████████░░░░░  ~78%   ✅ A-1+conformance、✅ 批次層 AUD-10、✅ B-group parity fix(`3d6f446`；金錢欄人審過)、✅ A-5 幣別 keep(只USD/KHR)；剩端到端/T24 接收驗證〔殘 domain A-4/M6/B-1/G·H 06-17 照舊(code 層)〕；**⚠️ 06-20 T24/A-4/M6 SRS-層 re-open→產 SRS 走 §5b 梯裁(見 banner)**
owner 裁定收口    ███████████████░░░░░  ~75%   06-16 關 RP9/AUD-6/AUD-9/AUD-1/AUD-10/A-1 OQ/A-5/T24 照舊＋06-17 撥貸殘 domain 全裁照舊（code 層）；**⚠️ 06-20 撥貸 T24/A-4/M6 SRS 層 re-open**（產 SRS 走 §5b 梯裁、owner 逐欄/逐項 confirm；見頂部 banner）；餘 AUD-2/3/4/7/8/11、RP8/11、E1/E2、BP
```

## 二、各階段狀態（排程見 `feature-inventory.md §5`）
| 階段 | 內容 | 狀態 |
|---|---|---|
| Phase 0 | 坐實缺口 | ✅ |
| Phase F | c0 評分 FE（9 頁） | ✅ 收工 06-09 |
| Phase G | 企金主流程 FE 後半（6 頁+3 popup） | ✅ 收口 06-15 |
| audit 修復包 | 00660/00100/00119/00640/00300 | ✅ 5/5 |
| **Phase V** | **runtime 整合驗證** | 🔵 **進行中**（本檔 §四） |
| Phase D | 撥貸解鎖（A-1+T24+domain） | 🟠 **owner 決策全清**（A-1 conformance PASS／批次層 AUD-10／T24 照舊／A-5 keep）→ **執行中**：T24 B-group parity fix 已 commit/push（`3d6f446`；金錢欄人審過），待端到端/T24 接收驗證（Phase V/UAT）；殘小 domain A-4/M6/B-1/G·H **06-17 全裁照舊→Codex 執行**（§三）|
| Phase E | c0 收尾 + 授權列套用 | ⏳ 等 ops 套 `c0-authz-sql` |
| Phase R | 暫緩 track（R2 報表/檔案 API） | ⏸ 待拍板 |
| **spec layer (PRD-to-SRS)** | New Bible/PRD -> SRS bundle | green: 2/67 bundles Approved (`EPROZ00100`, `EPROC00118`); pipeline ready for risk-tier expansion |

## 三、撥貸收尾（owner 決策牆清空 → 執行階段；原唯一 coding 缺口 A-1 已關）
**🟢 撥貸核心（A-1 `funcGetExchangeRate`）＝已實作＋conformance PASS（`daae4c3`，06-16，mvn 綠）**：補 return＋移尾端 throw → authorize 換匯總開關打通；**Codex 唯讀碼驗 4/4 PASS**（OQ-1 `IdNo=OVSLXLON01`、OQ-3 非0000拋錯中止 authorize〔碼＝專屬 `FAILED_E304`〕、OQ-4 throw 勿回 null、兩表同 `@Transactional`）。OQ-5 G/H 欄名 bug 另已修 `581e717`。**剩撥貸端到端真完成**：① ✅ **T24 正確性全裁「照舊系統規格」**（06-16 owner）→ B-group 轉**執行階段**（卡 `t24-bgroup-legacy-parity-fix.md`：Codex 逐欄坐実舊+對齊，金錢欄最嚴審；**幣別分支＝A-5 ✅ owner 裁 keep**〔撥貸只 USD+KHR→收窄無害、non-USD-non-KHR path by-design-unreachable、非 bug〕本批照修非幣別欄）② ✅ **批次層 AUD-10 結**（6/8 FOUND + B005 銷案）→ 下游交付不缺；B008＝ops ③ 唯一復驗點＝新環境 T24 拒收 `IdNo=01` 則改 02。**撥貸剩＝① T24 batch-fix（code 執行，非 owner，`3d6f446`✅）＋殘 domain A-4 檢核/M6 完工日/B-1 `T24_COMPANY`/KHR-G·H 來源〔06-17 owner 全裁照舊（code 層）〕**。**⚠️ 06-20 SRS-層 re-open**：上述 T24/A-4/M6「照舊」**僅 code as-is baseline**，產 SRS 時 to-be 走 §5b 梯裁（T24 偏新 per refactor-spec、核心舊 baseline）+owner 逐欄/逐項 confirm（見頂部 banner、`pending-register` 兩 re-open 列）。

## 四、Phase V runtime（本機 FE+BE，06-15 起；詳 `verification-handoff §6`）
| 項 | 狀態 |
|---|---|
| 起服務 + 登入（V-1） | ✅ |
| **RV-1 Search E999** | ✅ 已修（`00600`） |
| **RV-2 TODO 空** | ✅ 已修（`bbbaa19`；筆數一致 zh_TW=en_US=91） |
| 橫向 sweep① langType 砍資料 | ✅ **5 處全修**（`bbbaa19`+`7e1f0d2`；五頁筆數一致；卡歸檔） |
| 橫向 sweep② GET-body | 🔧 #1/#2 scorecard ✅；**#3 reviseditem 解鎖**（RP9 ✅ 06-16=GET）→ 改 GET query 同 00600，可派工 |
| smoke V-2~V-6（Phase G render/save/c0/dialog/teardown） | ⏳ 待跑（c0 需先套授權列） |
| **API 自驗 harness（v1 唯讀）** | 🆕 卡備 `build-tasks/phase-v-api-selfverify-harness.md`：人起服務→自動打 `epl-*`+唯讀 SQL 比對（API↔DB 一致性，RV-2 那類）；含 langType 筆數一致回歸守門；c0/寫入/FE-render 留 v2/v3/另案 |

## 五、待 owner 裁定（卡在誰 — 不是 Claude 能裁）
> 詳 `pending-register.md`（SSOT）。Claude 角色＝審查/記帳/坐實/把每項「備到蓋章即可」，**裁定權在 owner**。

| 群 | 項 | owner |
|---|---|---|
| 🟠 撥貸（code 清／SRS re-open）| code 層✅：A-1+conformance、批次層 AUD-10、T24 B-group parity-fix（`3d6f446`）、A-5 keep；**⚠️ SRS 層 06-20 re-open**：**T24（0922）＋ A-4/M6（0921）「照舊」不沿用為 SRS 定案** → 產 SRS 走 §5b 梯裁（T24 偏新 per refactor-spec／核心舊 baseline）、owner 逐欄/逐項 confirm（KHR-G·H/B-1 屬 T24 欄、併 0922）；refactor-spec＝母資料夾-local 前置 | 撥貸 domain（逐欄/逐項 confirm）＋ Codex（母資料夾梯裁）|
| 🟡 00800（v0.9 SRS 已封存→待重產）| RP11（execute DTO）、RP8（R6/R7 判據）→ **RD 派工卡 `00800-rp8-rp11-rd-closeout.md`**；~~SR-B1/B2~~ **✅ 06-17 折進重建**（gateⒺ 安全網）〔RP9＝GET 已關；v0.9 SRS 封存 `archive/EPROZ00800-v0.9-superseded/`〕| RD／架構 |
| 🟡 企金線 | **老系統 parity 補比（reopen 06-17，18 頁＝c0 評分 9+CSU 主流程 9，卡 `c0-legacy-parity-recheck.md`，risk-tier 00118/00120/0170 先）**；E1（CU-return）、E2（crScoreCardCompleted 覆寫）→ 卡 `c0-crediteval-e1-e2-escalation.md`（與 T1 00118 合流）| 信用決策 domain |
| 🟡 audit | AUD-2（0211/0213）、AUD-3（admin）、AUD-4（demo）、AUD-7（54 表）、AUD-8（權限表）、**AUD-11（CU0160 碼驗 06-17＝UNFOUND·先不關**：無獨立 CU0160→傾向已併，但卡 ① `TB_PAGE_MENU` data ② `CsuLoanConditionServiceImpl:597` 讀 ISU0160 分流存疑 → DBA(SQL)/RD(`:597`)，**派工卡 `aud11-closeout-dba-rd.md`**〕〔AUD-1/6/9/**10** 已 06-16 關〕| PM／SA／DBA／domain／RD |
| 🧩 seam | BP-1~4（00800 顯示條件/type 軸/展期展變/下游映射）、BP-5（nit） | PM／SA |

## 六、進行中 / 待派（Codex）
- ✅ **撥貸主線 code 層全推進 → code 決策牆清空**：A-1 換匯實作（`daae4c3`）+conformance PASS（OQ-1~5/交易碼驗 4/4）、批次層 **AUD-10 結**（6/8 FOUND + B005 inline-取代銷案）、**T24 B-group parity-fix（`3d6f446`）**、**A-5 幣別 keep**、**06-17 殘 domain 全裁照舊（code 層）**（A-4/M6/B-1`→OVSLXLON01`/KHR-G·H）→ code 層剩執行+UAT。**⚠️ 06-20 SRS-層 re-open**：T24（0922）+A-4/M6（0921）產 SRS 時走 §5b 梯裁、owner 逐欄/逐項 confirm（refactor-spec 母資料夾前置；見頂部 banner）
- ✅ **PRD→SRS 轉換層硬化（批判輪2，06-16）**：00800 重審蒸餾 **4 轉換固有病** → gateⓈ(b) Status 雙軸 + DoD 4 條 + spec-reviewer 紅旗（批量 PRD→SRS 前置再強化；自身踩假綠當場抓回）
- 🔧 **待派（Codex，prompt 在各卡裡）——建議並行（彼此獨立）**：
  - **Wave 1（即可派、彼此獨立並行）**：
    - ① **get-body #3** reviseditem GET query（卡 `get-body-contract-sweep.md`；RP9 已關＝GET、00600 為樣板）——**＝harness 段② 的前置**，建議最先派
    - ② **harness v1 段①** langType 五頁筆數一致（manifest `phase-v-harness-manifest-v1.md` §2，5 列全 grounded；卡 `phase-v-api-selfverify-harness.md`；唯讀零風險）——無依賴
    - ③ **M4/M5/M7/M8 audit 重 grep**（帶 source、各跑一場 `/refactor-audit` 單模組；範圍＝`refactor-audit/drift-recheck-2026-06-17.md §4`）——無依賴；更新 audit 列→新 `diff-vs-inventory`
    - ④ **企金線老系統 parity 補比**（reopen；帶 source 比**舊企金 cs/cu**、非對個金 i0/ISU twin；卡 `c0-legacy-parity-recheck.md`；**範圍＝c0 評分 9 + CSU 主流程 9 ＝18 頁**；risk-tier 00118/00120/0170 先；與 E1/E2 合流；套 `legacy-parity-sop`）——無依賴；填 `per-page-reinventory-matrix` parity/disposition 欄
  - **Wave 2（gated）**：
    - ④ **harness v1 段②** 00800 init-query RI-1/RI-2（manifest §7）——**待 ① get-body #3 落地後**（先前 endpoint＝壞 GET-body 會 E999）
    - ⑤ **harness v2 + smoke V-4**（c0/csu 讀型/非 403）——**待 ops 套 `c0-authz-sql`**（OVSLXLON02）
  - **smoke V-2~V-6**（`verification-handoff §6`；本機 bring-up `local-phase-v-bringup.md`）：V-2 render／V-5 dialog 可隨 bring-up 跑；V-3 save／V-6 teardown＝寫入（帶 §0.1 護欄）；V-4 待 ops（見 Wave2⑤）
  - **已備卡待對應角色（非 Codex 主派）**：T24 B-group 剩 **UAT**；**AUD-11 收尾** DBA/RD（卡 `aud11-closeout-dba-rd.md`）；**RP8/RP11** RD（卡 `00800-rp8-rp11-rd-closeout.md`）
  - **owner 裁定（隨時、非阻擋）**：AUD-2/3/4/7/8、E1/E2、BP-1~5〔撥貸殘 A-4/M6/B-1/G·H 已 06-17 全裁照舊；SR-B1/B2 折進重建〕
- 📐 **重新盤點驅動（選 A，06-17；非 wholesale 重建）**：per-page 矩陣 `refactor-audit/per-page-reinventory-matrix.md`——每頁套 SOP 三判定 disposition；確定 rebuild 僅 00800、最大 parity 風險＝企金線 18 頁（Wave1 ④）；**新版 Bible/PRD → SRS**（**Bible v1.1 已入 repo 06-17**〔DB 錨點/狀態碼/角色·API auth/BR-030/SC-031〕；owner local 用 Codex 跑；**dispatch prompt 備齊＝`build-tasks/prd-to-srs-codex-dispatch.md`**；risk-tier：企金線/撥貸/00800 重產先；SRS 落 `docs/specs/srs/`）
- **ops**：`c0-authz-sql` 套 `OVSLXLON02`（解鎖 c0/csu Phase V 與 403）；**B008** log 歸檔機制確認
- ✅ 早前完成：langType 5 處（`bbbaa19`+`7e1f0d2`）、get-body #1/#2（`751f78f`）、0922 T24 typo（`581e717`）、legacy schema 全面復驗（7 校正）、owner 盤點 reconcile、Copilot 第三軌移除、docs 收納判準

## 七、SSOT 指引（細節去哪查）
| 要看 | 去 |
|---|---|
| 逐頁 FE/BE 狀態、排程 | `feature-inventory.md` ⭐ |
| 所有待決 + owner + 卡什麼 | `pending-register.md` ⭐ |
| Phase V runtime findings | `verification/verification-handoff.md §6` |
| 任務單（live/done） | `build-tasks/` |
| 盤點總量 diff | `build-tasks/refactor-audit/diff-vs-inventory.md` |
| 決策/事實流水帳 | `decisions.md` |
| **差異處置準則（舊系統為主+三判）** | `process/legacy-parity-sop.md` ⭐ |
| **per-page 重建/修/保留 disposition** | `build-tasks/refactor-audit/per-page-reinventory-matrix.md` ⭐ |
| SRS 產出佇列（決策頁＋各頁輸入需求） | `srs-production-queue-2026-06-20.md`（matrix ledger 的輸入註解視圖）|

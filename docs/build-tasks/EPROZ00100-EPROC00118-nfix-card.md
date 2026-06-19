# 母資料夾 修正派工卡 — EPROZ00100 + EPROC00118（跨模型 N 軸 Blocker/Should-fix）

> **來源**：2026-06-18 重產 pilot 的 **4 跨模型 N 軸 agent**（opus+sonnet, A–G）驗收（見 `decisions` 重產 pilot 驗收列）。機械閘門兩頁 PASS、但跨模型複驗抓到單一 pass 漏的真 Blocker。
> **用途**：owner 在**母資料夾**（能讀產品碼 + `docs/db-diff/` + `docs/refactor-spec/`）逐條改 → 重產/重驗 → 乾淨後 Approved + 放大。**修好前先別放大到 67 頁。**
> **行號**：取自 N 軸 agent 對 `main` 上 bundle 的讀；母資料夾同版，動手前以實檔核對。
> **改完**：`check-srs-bundle docs/specs/srs/<funcId>` exit 0 → **跨模型 N 軸再審一輪**（採納修正可能引入新錯）→ 乾淨 → 回 repo backfill ledger `in-review→approved`（人裁 TBD 後）。

---

## 1. EPROZ00100（TO DO LIST）

### 🔴 Blocker
| # | 位置 | 問題 | 修法 |
|---|---|---|---|
| Z-B1 | `spec.md:75`（R4）＋`qa-cases.md:21`-`25`（QA-016~019A）| R4 把 **legacy page-id**（`EPROIS_0171/0910/0920`）寫成 to-be「Response page is exactly…」可驗收契約，**違 Bible:793-794**（refactor route 一律 `EPROISU/EPROCSU`、legacy 僅 source scope）。§5b 升級觸發#1（Bible invariant 衝突）未升級、自決鏡像 legacy。| R4 改以 **`EPROISU/EPROCSU` 頁族**表述 to-be route（legacy id 僅作 trace 標籤）；**或**開一條 C 類 `@PENDING`(owner PM/SA) 標 legacy→refactor route 映射待裁。QA-017~019A 的 Then 一併對齊（QA-016 已含「/ refactor equivalent」措辭可參照）。|

### 🟡 Should-fix（Approved 前）
| # | 位置 | 問題 | 修法 |
|---|---|---|---|
| Z-S1 | `spec.md PENDING-Z001` | role **顯示名稱＝DB-resolvable fact**（`TB_ROLE_DEFINE`＋Bible:796），卻與 action-permission **policy** 合併 Pending → 違 §5b Rule 1「fact 不留人工 Pending」。| 把 role-name fact 拆出**直接填入 SRS**；`PENDING-Z001` 只留 policy（哪些 role 可 delete/close）。|
| Z-S2 | `spec.md:82`（R5）/`:142`（PENDING-Z002）/QA-021 | `CASE_PROGRESS=D1` 當已定 fact，但 Bible:797 狀態字典**未含 D1**（`C1` 已確認可放行）。| R5/QA-021 對 `D1` 加註「語意受 `PENDING-Z002` 控制（legacy as-is 證據、非已核准 to-be）」，與 `C1` 區隔。|
| Z-S3 | `spec.md:57`（R2）/`qa-cases.md:11`（QA-007）/PRD REQ-002-05 | `showRelated` 引用 `IS_Y`，但 `schema.sql TB_RELATED_PARTY_INFO` 只有 `IS_CUB_RELATED`/`IS_CUBC_RELATED`（三處欄名不一致）。| 母資料夾查實際欄名：若 `IS_CUB_RELATED` → spec/qa/PRD 三處統一改；若確有 `IS_Y` → `schema.sql` 補欄 + `DB-Dn`。|
| Z-S4 | `openapi.yaml:113`（`TB_API_AUTH` schema）| PK 僅 `API_ID` 單欄，但 R9 授權＝`API_ID+ROLE+REF_FUNCTION_ID`；一 API 多 ROLE 時 QA-040 情境（role 201 無列、001 有）在 DB 層無法並存。| 確認複合 PK `(API_ID, ROLE)` 並 `schema.sql` 更正；或 `DB-D5` 說明「一 API 限一 ROLE」業務理由。|
| Z-S5 | `qa-cases.md:29,40`（QA-022A/032A）| `otherReason` 超長拒絕 acceptance 含糊（「`E102` or mapped」未定哪個為準）。| 擇一明確；或標「錯誤碼 envelope 受 `REF-D3`（E102 待 RD map）控制」＝刻意 pending。|
| Z-S6 | `qa-cases.md:36`（QA-029）vs R6 | 唯一覆蓋 `reasonList` 格式的 case 用裸碼 `E102`，與 R6 業務碼（`MISSING_REASON`）邊界未界定。| QA-029 界定 `E102`(結構/格式) vs `MISSING_REASON`(語意缺漏) 觸發分界，或拆兩 case。|
| Z-S7 | `spec.md:106`-`113`（R8）/QA | R8 要求「auth 拒絕 set/clear 時 session 不變」，但 DELETE(clear) 路徑無 auth-fail negative case。| 補一條（標 `PENDING-Z008`）error case：DELETE/SET 遭 `ACCESS_DENIED` 時驗 session 未建立/清除。|

> 🟢 Nit：`PENDING-Z001`~`Z010` repo `pending-register` 已以「spec §@PENDING 為單一出處」處理（gateⓅ PASS）；定版後可選擇回登。db-diff 引用「dangling」＝母資料夾-local 設計、**非缺陷**（在母資料夾可核行號）。

---

## 2. EPROC00118（Corporate Scorecard, c0 評分 T1）

### 🔴 Blocker
| # | 位置 | 問題 | 修法 |
|---|---|---|---|
| C-B1（F 軸·最高風險）| `openapi.yaml` `CalcCodeMap.curRatio`(`368`-`371`)/`ScorecardRoleMap.curRatio`(`481`-`484`)；`spec.md:111`(R8) | `CUR_RATIO`→`NUMBER(3,2)`，但 pattern `^\d{1,3}$` 未定**是否允許小數**；輸入 `80.5` 無法存 NUMBER(3,2)→**靜默截斷風險**。| R8 precision policy 加「`CUR_RATIO` 百分比**限整數**（無小數）」＋**QA 斷言**：輸入含小數（如 `80.5`）被 BE validation reject、不靜默截斷。|
| C-B2（F 軸）| `openapi.yaml` `ScorecardRoleMap.debtRatio`(`509`-`513`)＋`CalcCodeMap.debtRatio`(`400`) | `maxLength:22` ⊥ `NUMBER(6,2)`（`-9999.99` 最長 8 char）；契約與型別不一致、誤導 review/consumer。| `debtRatio` `maxLength` **22→8**（兩處同步）。|
| C-B3（F 軸）| `spec.md:111`-`115`(R8)＋`qa-cases.md`(QA-033) | item-level `_SCR NUMBER(3,0)` **無具體 QA 斷言**（QA-033 只泛化）；openapi 又不暴露 `_SCR`/`totalScore`。| QA-033 補具體斷言：某 `_SCR` 超 `999`（NUMBER(3,0)上限）→ BE reject/log；`totalScore` 超 `NUMBER(7,2)` 同樣 reject。|
| C-B4（D 軸）| `spec.md:88`(R5)/`:125`(AUTH-D1)/`PENDING-012` | `TB_API_AUTH` C0 target rows **尚未存在** → 任何認證用戶可呼 `epl-save-c0-corporateScorecard`、端點**實質未保護**；`PENDING-012` 目前非 pre-deploy 級。| `PENDING-012` Blocking 升「**Yes before any testing deployment**」；NFR Security 加一行「`epl-save-c0-corporateScorecard` 的 `TB_API_AUTH` seed 須在 QA regression 前到位；缺 seed＝未保護端點」。|

### 🟡 Should-fix（Approved 前）
| # | 位置 | 問題 | 修法 |
|---|---|---|---|
| C-S1 | `PENDING-001` | 只談「兩碼語意跨 scorecard」（E2 整欄覆寫），漏 **E1（CU-return 只清 CS 的分流缺失）**。| `PENDING-001`（或新增一條）把 E1 的 CU 分流正確性也列待裁；R7/QA 補 E1 待測點。|
| C-S2 | `openapi.yaml` `/epl-calc-…` 400 desc | `COMMON_MSG_ERROR_LON`/`COMMON_UI_PLEASE_SELECT`/module message 觸發條件並列、未分流。| 三類觸發條件**分行**描述（applicationNo blank / 必填 code 未選 / funcGetRate 業務錯）。|
| C-S3 | `openapi.yaml` `/epl-save-…` 500 desc | `COMMON_MSG_RATE_FAIL`(Default date lookup fail) 與 `COMMON_MSG_SAVE_FAIL` 並列、語意混。| 補：`RATE_FAIL` 僅 Default flag=Y 且 date lookup 失敗時；`SAVE_FAIL` 用於 transaction/DB write 失敗。|
| C-S4 | `spec.md` R1/R2/AUTH-D1 | **讀取端點**（`info`/`sele-list`）authZ 行為未指定（是否需獨立 `TB_API_AUTH` 列）。| 補：讀取端點是否共用 query-role 列或獨立；若不在 `TB_API_AUTH`，說明誰確保 session-only auth。|
| C-S5 | `spec.md` Sources 表 | 缺 **Bible BR/SC 逐條 carried/disclaimed 表**（只有零散引用）。| Sources 表加「Bible BR/SC coverage」欄/段，逐條 carried/disclaimed。|
| C-S6 | `schema.sql`（`TB_SCORE_CARD_PARAM_DETAIL.SCORE`）/R3:66 | `SCORE` 是 `VARCHAR2(10)`（字串存分數），但 R3 用它做數值加總、未說型別轉換。| R3/schema hint 補「BE 以 `TO_NUMBER` 轉換後加總；非數字 SCORE→`MSG_QUERY_FAIL`+log」。|
| C-S7 | `openapi.yaml CalcResponse.scoreDatetime`(`289`-`299`)/QA-010 | `maxLength:19` 無 `pattern`、無時區。| 加 `pattern: '^\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}$'` + 時區(UTC+8)；QA-010 驗格式。|
| C-S8 | `spec.md:108`-`109`(R8) | `AO_SCORE/CR_SCORE NUMBER(7,2)` **totalScore 上界未說明**。| R8 補「totalScore 上界由 `TB_SCORE_CARD_PARAM_DETAIL` seed 決定；BE 確認不超 NUMBER(7,2)，否則 `COMMON_MSG_RATE_FAIL`」。|
| C-S9 | `openapi.yaml CalcCodeMap.totalAsset/totalLoanAmt`(`387`-`395`) | `maxLength:22` vs NUMBER(19,2)（最長 21 char）。| `maxLength` **22→21**。|

> 🟢 Nit：`schema.sql` excerpt 註可更明確（`-- excerpt: only SRS-relevant columns shown`）。
> **誤報排除（不用改）**：三端點 xfile advisory＝refactor 檔名路徑、非契約（contract camelCase `corporateScorecard` 已對齊 openapi）。

---

## 3. 改完收尾
1. 每頁 `python3 scripts/check-srs-bundle.py docs/specs/srs/<funcId>` exit 0。
2. **跨模型 N 軸 A–G 再審一輪**（採納修正可能引入新錯；00118＝T1 全 A–G、特別 F 軸）→ 無 Blocker。
3. push 回 main → 我 backfill：ledger 維持/升級、覆蓋數、`decisions` 補「Blocker 已修+複審」列。
4. **乾淨 + TBD 人裁 → Approved**；確認 pilot 守得住後再依佇列 risk-tier **放大其餘 funcId**。

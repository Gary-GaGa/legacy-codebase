# EPROZ00100 / EPROC00118 — contract-軸 closeout 派工卡（RD/DBA）

> **目的**：兩頁 owner-decision @PENDING 已**全關**（2026-06-20），bundle 內無 open @PENDING、機械閘門兩頁 PASS、spec-reviewer 複審無 Blocker。**唯一擋 Approved＝contract 軸：FE/BE 實作（DTO/status/`TB_API_AUTH` seed/save guard…）未追上 to-be SRS**。本卡把缺口整併成逐項 deliverable＋acceptance＋recheck，RD/DBA 照單做、QA 照單驗。
>
> **來源證據（單一出處，勿複寫）**：`pilot-srs-pending-verification.md`（逐 pending closure＋DB SELECT-only 證據）＋`pilot-srs-pending-verification.sql`＋`c0-authz-sql-findings.md`（c0 00110–00120 seed precheck）＋各頁 `spec.md`/`openapi.yaml`/`schema.sql`/`qa-cases.md`。
> **原則**：**不得改回現況掩蓋 SRS**（owner 明示）——to-be 規格正確、是實作要追上規格。
> **完成定義（升 Approved）**：所有 deliverable 實作＋測試證據 → contract 軸（N 軸 axis G／as-is→to-be parity）轉 PASS → 兩頁 `Status: Draft→Approved` → 回填 SSOT。
> **owner**：RD（實作）＋DBA（seed apply 證據）；🟡 標註項需 SA 先裁再落 RD。

---

## A. EPROC00118（Corporate Scorecard）

### A1. `TB_API_AUTH` 四端點 seed — **部署最硬閘（`PENDING-012` 第一層，before ANY testing deployment）**
四 c0 端點目前 DB row 缺（06-19 SELECT-only：`TARGET_COUNT=0 / SOURCE_COUNT=4`）。需 insert（單欄 PK `API_ID`、分號 `ROLE`、`REF_FUNCTION_ID=EPROC00118`）：

| `API_ID` | `ROLE` |
|---|---|
| `epl-sele-c0-corporateScorecard-list` | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` |
| `epl-info-c0-corporateScorecard` | `001;002;003;101;102;103;201;202;203;301;302;401;402;403;404;405` |
| `epl-calc-c0-corporateScorecard` | `001;002;102;103` |
| `epl-save-c0-corporateScorecard` | `001;002;102;103` |

- seed 來源＋idempotency（by `API_ID`）＋recheck SQL＝`c0-authz-sql-findings.md` §「EPROC00118 Security Close Verification List」（已附 SELECT-only recheck）。
- **acceptance**：四 row 存在且 `ROLE`/`REF_FUNCTION_ID` 對；apply **只能對 schema `OVSLXLON02`**（先確認 current schema、勿打 `OVSLXLON01`）。

### A2. save service-level guard — **`PENDING-012` 第二層（DB seed 不足以單獨收尾）**
- 現行 `CsuCorporateScorecardServiceImpl.java:229` **無** `!isAO && !isCR` 顯式 reject → 非授權角色落入 CR 分支。
- **deliverable**：save 對非 AO／非 CR 角色顯式 reject（platform access-denied，現行 filter 行為 401），scorecard/summary/checkpoint **不動**。
- **side-scoped（`spec.md:119`）**：BE 依 authenticated session role 推可寫側；AO 只寫 AO 側、CR 只寫 CR 側＋CR comment；client 提供的非可寫側 map **非權威**、視為 tampering 拒絕。
- **acceptance**：QA-021A（cross-side tampering→401、無 DB change）＋ 非 AO/CR save→reject regression。
- 〔**spec-reviewer 🟡3 連帶**〕`ScorecardRoleMap.riskLevel/actionDate/score` 即使在**可寫側**也是 **BE-derived**（R4/R6：Default→`-1`/`Default`/rating date；非 Default→`totalScore`）；client 提供值須忽略/重算。RD 落實＋QA 補**同側** tamper case（現 QA-021A 只蓋 cross-side）。

### A3. `epl-info` 初始化 payload（`PENDING-013`）
- 現行 info DTO 缺 `mainBorrowerName` ＋ checkpoint 欄。
- **deliverable**：`epl-info-c0-corporateScorecard` 回 `mainBorrowerName`（`TB_MAIN_BORROWER_INFO_CORP`）＋ `checkpointStatus`（`TB_CHECK_POINTS_CS/CU.EPROC00118`），對齊 openapi `InfoResponse`。
- **acceptance**：QA-001/QA-002（response 含 `mainBorrowerName`/`checkpointStatus`）。

### A4. `parseScore` fail-fast（`PENDING-016`）
- 現行 `FunctionServiceImpl.parseScore` 吞 `NumberFormatException`→回 `0`（靜默）。
- **deliverable**：非數值 `TB_SCORE_CARD_PARAM_DETAIL.SCORE` seed → **fail-fast `MSG_QUERY_FAIL`**，不得 coerce `0`。
- **acceptance**：負向 seed 測試（非數值 SCORE → 查詢失敗碼、非 `0`）。

### A5. `scoreDatetime` 時區（`PENDING-017`）
- 現行 `getScoreDatetime()` 用 `LocalDateTime.now()` 無 `ZoneId`。
- **deliverable**：明確 **Asia/Taipei / UTC+8** 產生 `scoreDatetime`（`dd/MM/yyyy HH:mm:ss`），不依部署預設時區。
- **acceptance**：QA-010（`scoreDatetime` 來自顯式 UTC+8 clock）。

### A6. numeric/precision 一致（`PENDING-014`）
- initial load 與 Default-Y→N reset 用**同一** SRS/openapi/DB precision；`CUR_RATIO` integer-only（不靜默截斷）。
- **acceptance**：bundle 內邊界 QA。

> 〔**spec-reviewer 🟡1 待 SA 先裁、非 RD 純實作**〕`openapi CalcCodeMap.required`（22 欄全必填）vs R4 Default short-circuit（Default=Y 時評分欄清空/不必填）潛在矛盾，且 calc 無 `loanDefDayFlag` 欄。**SA 擇一**：① 文件聲明 calc 在 Default flow 不被呼叫（並於 `CalcRequest`/R3 敘明）；② 放寬 `required`＋加 Default discriminator＋補「Default 下 calc request shape」QA。裁定後再落 RD。

---

## B. EPROZ00100（To Do List）

| # | deliverable | 來源 pending | acceptance 重點 |
|---|---|---|---|
| B1 | `TB_API_AUTH` 八 `epl-*` 為最終 seed baseline；**mutation row 移除 `403`**（least-privilege，403 排除所有 user-facing EPROZ00100 API）；補缺 row（init/proposal download/session bridge/delete-reason select/close-reason select）。單欄 `API_ID`、`REF_FUNCTION_ID=EPROZ00100`。 | `Z001`/`Z009` | delete/close row 無 `403`；缺 row 補齊；只對 `OVSLXLON02` apply。 |
| B2 | `epl-init-z0-todolist` 為 POST mutation：`TB_API_AUTH`＋transaction＋history insert＋rollback（自動 CA/CR redistribution）。 | `Z003` | init 端點存在、有 auth row、失敗 rollback。 |
| B3 | proposal download：一次性短時效 `downloadToken`＋`expiresAt`，**不得**可重用本地檔案路徑；補端點＋auth row。 | `Z006` | token 一次性/短時效；無本地路徑外洩。 |
| B4 | `epl-session-z0-current-application` 為 migration-only POST/DELETE bridge；補 auth row；待 `EPROISU`/`EPROCSU` 不再讀 server-session application context 時退役。 | `Z008` | bridge 端點＋auth row 存在。 |
| B5 | delete/close reason：request DTO 從單一 `reasonCode` → `reasonList[]`；`D99`/`C99` 要求 `otherReason`。 | `Z007` | `reasonList[]` 契約；`D99/C99` 無 `otherReason`→reject。 |
| B6 | CAD decision-date range：BE 強制 ≤ 6 calendar months（`endDecisionDate ≤ startDecisionDate + 6M`）。 | `Z005` | 超 6 月 range→reject（現行 BE 無此 guard）。 |
| B7 | response `docNo1` = `V_MAIN_BORROWER_INFO.DOC_NO_REGISTER_NO`；corporate `REGISTER_NO` 正確性。 | `Z004` | corporate case QA 證 `DOC_NO_REGISTER_NO` 回 `REGISTER_NO`。 |

> `Z002`（status code baseline）/`Z010`（proxy actor 用 `PROCESS_EMP_*`、不加 `PROCESS_AGENT_*`）＝DB baseline 已坐實、無額外 RD 實作，僅 QA 斷言照 baseline。

---

## C. 升 Approved 流程（兩頁共用）
1. RD 實作 A/B 各項 ＋ DBA seed apply 證據（A1/B1）；QA 跑各 acceptance（regression/負向）。
2. contract 軸（N 軸 axis G／as-is→to-be parity）重驗轉 **PASS**。
3. 兩頁 `spec.md` `Status: Draft → Approved`；機械閘門維持 exit 0。
4. 回填 SSOT（`STATUS`/`feature-inventory`/`pending-register`/`decisions`/`per-page-reinventory-matrix`）＋ trace sidecar 狀態欄（去殘留 `PENDING-*` 活錨——見 spec-reviewer 🟢7）。

## D. recheck SQL（SELECT-only, schema `OVSLXLON02`）
- 00118 四端點：`c0-authz-sql-findings.md` §「EPROC00118 Security Close Verification List」已附 SELECT-only recheck SQL。
- 00100 role/status/reason seed：`pilot-srs-pending-verification.sql`（schema `OVSLXLON02`、SELECT-only）。
- **不在 repo 跑 INSERT**；apply 由 ops 對 `OVSLXLON02`（先確認 current schema）。

---

## E. spec-reviewer post-fix 複審結果（2026-06-20, opus 跨模型獨立）＋定稿前 spec-side 收尾
**兩頁複審 verdict＝無 Blocker、無 fix-induced regression，可進人審/Approved-gating。** 以下 Should-fix／Nit ＝**spec-doc 收尾，由母資料夾 pipeline／SA 處理（非 RD 實作）**；皆不擋 Approved gate，但定稿前宜收：

- ✅ **已由我方收（本卡同批）**：兩頁 trace sidecar 殘留 `@PENDING` 活錨 → 改「已裁→殘實作」（00118 🟢／00100 🟡2）。
- 🟡 **EPROZ00100 `TB_API_AUTH` 欄位集三處不一致**（`schema.sql:108-115` 4 欄／`spec.md:147` 3 欄／`c0-authz-sql-findings.md:17` 5 欄）→ 擇一口徑對齊（功能契約 PK+三欄+ROLE allow-list 本身一致，僅欄位集 audit 欄漂移）。
- 🟡 **EPROC00118 `CalcCodeMap.required`（22 欄全必填）vs R4 Default short-circuit**（calc 無 `loanDefDayFlag`）→ **SA 先裁**：聲明 calc 不在 Default flow 呼叫／或放寬 required＋加 discriminator＋補 QA（已併入 §A6 註）。
- 🟡 **EPROC00118 `ScorecardRoleMap.riskLevel/actionDate/score` 在可寫側仍 client-writable** → 註明 BE-derived、client 值忽略/重算（已併入 §A2 註，含 QA 補同側 tamper case）。
- 🟢 其餘 nit：00118「23 items＝17 select+5 numeric+1 Default」分解註、percent 上界、datetime 格式跨端點不一；00100 `V_MAIN_BORROWER_INFO` 列入 schema external-source 註、PRD REQ-005-05 措辭（SRS 已正確 disclaim、無需改）。

> 機械註記：兩頁複審皆確認 bundle 內**無 open `@PENDING`**；contract 軸 FE/BE 實作 gap 為**已知刻意** RD/DBA implementation（即本卡 §A/§B），複審依指示不計為 spec Blocker。

---
> 本卡＝RD/DBA 工單（dispatch），**非 SSOT**；狀態權威仍在各頁 `spec.md`＋`pending-register.md`。完成後本卡歸檔 `done/`。

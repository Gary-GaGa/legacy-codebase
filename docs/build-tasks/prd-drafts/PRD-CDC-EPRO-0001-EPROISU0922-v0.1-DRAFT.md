# PRD — EPROISU0922 撥貸彙總/授權/T24（Disbursement Summary）

> 🟠 **DRAFT SKELETON（v0.1）— 由規劃 repo 從撥貸 triage/escalations 反推的骨架，非 PM 定稿**。
> **用途**：給 PM/owner 當起點填業務內容（acceptance 細節、新業務規則、TBD 裁示）。**定稿後**改名 `PRD-CDC-EPRO-0001-EPROISU0922-v1.0.md`、移到 `docs/specs/prd/`、再把 matrix ledger 該列升 `prd-ready`。**在本資料夾（`build-tasks/prd-drafts/`）期間 orchestrator 不會 pick**（reconcile 只掃 `docs/specs/prd/`）。
> **來源證據**：`docs/disbursement/disbursement-triage.md`、`docs/disbursement/disbursement-domain-escalations.md`、`docs/build-tasks/done/a1-funcGetExchangeRate-spec.md`、`docs/build-tasks/done/t24-bgroup-legacy-parity-fix-findings.md`。brownfield＝以舊系統行為為基準（`legacy-parity-sop` 三判）。
> **⚠️ PM 待補/確認**＝全文 `〔PM:…〕` 標記處 + §7 TBD。

---

## Metadata
| 欄 | 值 |
|---|---|
| funcId | `EPROISU0922` |
| doc id | `CDC-EPRO-0001` |
| 名稱 | 撥貸彙總 / 授權 / T24 組檔 / 提交覆核（Disbursement Summary） |
| Status | **DRAFT（規格定版：DRAFT／實作完成：partial）** |
| Owner | PM（業務）＋撥貸 domain（裁示）＋ RD（接值） |
| 版本 | v0.1-DRAFT |
| 上游 | Bible v1.1（撥貸個金 only，Q-002 企金待確認）；舊頁 `EPROIS_0922` / `EPROIS_0922-t24` |
| as-is 來源 | 撥貸 triage/escalations（本機 `legacy-extract/*-compare.md` gitignore）|

## 1. 背景 / 目的
撥貸流程末端：承辦在 0921 輸入撥貸資料後，於本頁 **彙總檢視 → 授權（authorize，含換匯）→ 產生 T24 介面檔 → 提交覆核者（checker）**。金錢核心、與 T24 外部系統整合。〔PM: 補業務目標一句話、北極星對應〕

## 2. 範圍 / Non-Goals
- **In**：Summary 載入、authorize（換匯＋寫撥貸日期/匯率）、T24 檔組裝（段 A–H）、submit（通知 checker、寫 history）。
- **Non-Goal**：0921 資料輸入（屬 `EPROISU0921`）；T24 **接收端**行為（外部系統）；報表/列印（R2 track）；企金撥貸（Bible Q-002 待確認，本頁個金）。

## 3. 角色
〔PM: 對 Bible `TB_ROLE_DEFINE` 確認〕承辦（AO，authorize/submit）、覆核者（checker，收 submit 通知）。

## 4. 功能需求（REQ；brownfield 以舊行為為基準，差異標三判）

### REQ-001 撥貸彙總載入
顯示該案撥貸彙總（借款人、撥貸金額、幣別、費用、撥貸日…）。
- **as-is**：✅ 既有（`EPROIS_0922`）。**強制點**：BE 提供彙總 DTO。
- **acceptance**：〔PM: 列必顯欄位〕。

### REQ-002 授權前換匯（A-1，已實作）
authorize 時呼叫 `funcGetExchangeRate` 取匯率；**非 `0000` 回應→中止 authorize、回錯**（不回 null）。
- **as-is**：✅ 已實作（product `daae4c3`；OQ-1~5 碼驗 4/4）。匯率源 `IdNo=OVSLXLON01`（A-2 照舊）。
- **三判**：(a) 原 throw-stub＝regression → 已補 return 修齊。
- **強制點**：**BE 權威**（金錢，client 不得送匯率值）。
- **acceptance**：匯率 0000→繼續；非 0000→中止＋錯誤碼 `FAILED_E304`（見 §5）。

### REQ-003 授權撥貸（寫撥貸日期＋匯率，單一交易）
authorize 成功＝寫 `TB_DISBUR_DATE` ＋ `TB_EXCHANGE_RATE`，**同一 `@Transactional`**（任一失敗整筆回滾）。
- **as-is**：✅（A-1 conformance 確認兩表同交易）。
- **強制點**：BE。**acceptance**：兩表同交易；失敗不留半筆。〔PM: 確認 authorize 後狀態流轉/CASE_PROGRESS〕

### REQ-004 組 T24 介面檔（段 A–H，照舊 parity）
產出 T24 檔，段 A–H 欄位/順序/格式 **一律對齊舊系統**（owner 06-16「T24 都照舊系統規格」）。
- **as-is**：✅ B-group parity-fix 已 commit/push（`3d6f446`）；逐欄坐實見 `t24-bgroup-legacy-parity-fix-findings.md`。
- **已照舊修齊（三判 a，regression→修回）**：`A16`=`NORMAL.LAON`（非 `LOAN`）、`A31`/`G7` `AGREEMENT_NO` 取後 16 碼、`C12` `SUG_VAL` 讀對表、`C13` 來源 `DECISION_DATE`、`C20` `INS_EXPIRY_DATE`、`A52` `DISTRICT_NAME`、`G11–G12` fee remark、`A15` 空值→`N/A`、行尾 CRLF、`C26` 依 `COLL_DATA_SEQ` 過濾、H 段 append+定位+「FEE 非 null 且非 0」才出。
- **強制點**：BE。**acceptance**：〔PM/RD: T24 端到端接收驗證（UAT）〕。

### REQ-005 提交覆核（submit）
authorize 後提交：**通知選定 checker**（mail）、寫處理 history。
- **as-is**：✅ mail 補 checker 已修（M3 `49ebcb1`）。**待確認**：history 序號 `25` vs `24`（A-6）→ §7 TBD。
- **強制點**：BE。**acceptance**：checker 收到通知；history 正確序號（待裁）。

### REQ-006 幣別處理（USD/KHR only）
撥貸有效幣別＝**USD + KHR only**（柬埔寨）；KHR rounding `DOWN`；G/H 換匯欄幣別來源＝舊 `DISBURSEMENT_CURRENCY`。
- **as-is**：✅ A-5 owner 裁收窄 keep（非該幣別業務不發生→ fee→null/`E21`→0＝by-design-unreachable、非 bug）。
- **三判**：(b) 刻意收窄＝keep 新＋本 PRD 載明為業務邊界。
- **強制點**：BE。**acceptance**：USD/KHR 正常；其他幣別 by-design 不可達。

### REQ-007 撥貸公司碼 T24_COMPANY（B8/C9）
T24 `B8`/`C9` 取 `TB_BRANCH_PROFILE.T24_COMPANY`（schema＝`OVSLXLON01`）。
- **as-is**：🟡 **待 RD 接值**（B-1：entity 補欄位映射；06-17 裁取 `OVSLXLON01`）。
- **強制點**：BE。**acceptance**：B8/C9 輸出非空、值＝該分行 T24_COMPANY。→ §7 TBD（實作 gap）。

## 5. 錯誤回應（Error Responses）
> ⚠️ as-is 碼為**裸名/專屬碼**；機械 gateⒺ 只認 `MSG_*`/`COMMON_MSG_*` 前綴 → 〔PM: 若要 gateⒺ 守承載，改 `MSG_*` 命名；否則靠 spec-reviewer 語意審〕。
| 情境 | as-is 碼 | HTTP | 備註 |
|---|---|---|---|
| 換匯非 0000（取匯率失敗）| `FAILED_E304`（映射 `EPROIS0921_UI_RAET_FIND_ERROR`）| 〔PM: 400 業務錯〕| 中止 authorize（REQ-002）|
| 空 `APPLICATION_NO` | 〔as-is：新 controller 擋、舊 throw 未明〕| | C-2，待確認 |
| contract-source 缺值 | 〔可能 NPE〕| 500 | C-2，待 RD 防護 |

## 6. DB 影響矩陣（餵 db-diff by table_name + refactor-spec by module_code）
| 表 `TB_*` | 動作 | REQ | 備註 |
|---|---|---|---|
| `TB_DISBUR_DATE` | write | 003 | 撥貸日期；與匯率同交易 |
| `TB_EXCHANGE_RATE` | write | 002/003 | 換匯寫入（new：write-only，AUD-10 B005 inline 取代每日批次）|
| `TB_BRANCH_PROFILE` | read | 007 | `T24_COMPANY`（schema OVSLXLON01）|
| `TB_DISTRICT` | read | 004 | A52 `DISTRICT_NAME`（UPD_DATE 慣例查）|
| `TB_LOAN_CONDITION_FEE` | read | 004 | fee remark/金額（G 段）|
| `TB_LON_SUMMARY_INFO` | read/upd | 001/003 | 〔PM/RD: 確認狀態欄 CASE_PROGRESS〕|
> module_code/端點：〔RD: 補真實 `epl-*`（authorize/submit/buildT24）；mutate=POST〕。

## 7. TBD（不自裁；每條附 owner）
| TBD | 內容 | owner |
|---|---|---|
| TBD-001 | submit history 序號 `25` vs `24`（A-6）| 撥貸 domain |
| TBD-002 | `T24_COMPANY` entity 映射＋B8/C9 接值（B-1，已裁取 OVSLXLON01、待 RD 實作）| RD |
| TBD-003 | `t24DealResult` 非 `0000`/無 done flag 是否更新 summary 狀態（C-2）| 撥貸 domain |
| TBD-004 | `IS_CONTRACT`/`IS_CONTR` persist 目標、contract-source NPE 防護、空 `APPLICATION_NO` 行為（C-2）| RD |
| TBD-005 | authorize 後 CASE_PROGRESS/狀態流轉（Bible `TB_PROCESS_CODE` 對照）| PM/domain |

## 8. maxlength / 必要（能給就給，餵 openapi↔schema 交叉比對）
〔PM/RD: 由 refactor-spec API Header 欄位表（`04_rules/field_rule.md`）抽；T24 欄寬以舊 spec 為準（`AGREEMENT_NO` 後 16 碼）〕。

## 9. as-is findings 路徑（讓 SRS 的 as-is 欄實）
- `docs/disbursement/disbursement-triage.md`（P0–P3 + §7 allowlist M1–M10）
- `docs/disbursement/disbursement-domain-escalations.md`（A/B/C/D 組）
- `docs/build-tasks/done/a1-funcGetExchangeRate-spec.md`（換匯 OQ-1~5）
- `docs/build-tasks/done/t24-bgroup-legacy-parity-fix-findings.md`（T24 逐欄坐實）
- `docs/build-tasks/done/khr-currency-handling-recon-findings.md`（幣別收窄）

---
> **下一步（PM）**：填 `〔PM:…〕` + §7 裁示方向 → 定稿改名 v1.0 移 `docs/specs/prd/` → ledger 升 `prd-ready` → drain。
> **0920/0921 同型**：可照本骨架複製（0921＝資料輸入+檢核 A-4 照舊；0920＝頁框 domain-gated）。

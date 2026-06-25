# SRS - EPROISU0921 Data Input

# ───────────────── Contract（做什麼；to-be only、可純掃開發）─────────────────

## Metadata
| Field | Value |
|---|---|
| funcId | `EPROISU0921` |
| Page | Individual Disbursement - Data Input |
| Status | 規格定版: Approved (2026-06-23, owner — mechanical PASS + N-axis A–G PASS + cross-model spec-reviewer recheck 0 Blocker / 0 Should-fix); 實作完成: Conformant — D-axis backend closeout verified 2026-06-23 (mother-folder build/test PASS; N-axis A–G PASS) (QA 暫拔除) |
| Risk tier | T1 money/checkpoint/auth |
| Owner | SA / disbursement domain / RD |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md` |
| Bundle | `docs/specs/srs/EPROISU0921/` |
| Source baseline | PRD + Bible + db-diff + refactor-spec + bounded source read |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`, `README.md`（人類 digest，見 `digest-template.md`）（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |
| N-axis review | Per-page owner re-open decisions are closed; owner sign-off granted 2026-06-23 after mechanical PASS + N-axis A–G PASS + cross-model spec-reviewer recheck (0 Blocker / 0 Should-fix). Promoted to Approved. **2026-06-24 兩半轉換**：改 canonical Contract/Appendix 結構、Traceability Matrix 段已移除（追溯靠 covers-prd、gateⒷ 驗）、各 Rn 加 `[ev→Rn]`、段名正規化；只重排不改語意。N-axis A–G PASS 摘要見 Appendix `N-axis Verification Status`。 |

## Scope
- In scope: 本 bundle 定義 `EPROISU0921` Data Input 的 to-be 契約：select/init data、query、main borrower 與 co-borrower 的 T24/CIF 檢核、save/finish、return、page authorization，以及透過完成旗標讓 EPROISU0920 Summary 進行的 gating。
- Out of scope（Non-Goals）:
  - EPROISU0922 T24 authorize / file generation。
  - 變更實體 DB 表名或欄名（含 legacy typo 欄 `EPORIS_0921`、`DRAWDOWN_ACCOINT`）。
  - 重開 fee M7/M10 或 `RECEIVED_DATE` M4；這些以 regression-fixed 約束承載、不重議。

## Assumptions / Dependencies / Constraints
- 依賴 current page-column authorization model（`epl-auth-page-column` 依賴）決定可見按鈕/可編欄。
- 依賴外部 T24/CIF/SSI source service 做 borrower/co-borrower 比對。
- 依賴 `TB_API_AUTH` route auth 與 service-level role/state guard（route 列必要但不充分）。
- 撥貸幣別限 USD/KHR（A-5/domain 決策）；其他幣別於本流程 by-design 不可達。
- 實體 DB 名稱（含 legacy typo）保持不變，API 以 epl-* 契約名對外。

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `/epl-sele-isu-data-input` | POST | 回傳渲染前所需的 select/init 選項與 address date | R1 |
| `/epl-info-isu-data-input` | POST | 查詢 Data Input 頁狀態與完成旗標 | R2, R5, R12 |
| `/epl-case-isu-data-input-check-mb` | POST | 主借款人 T24/CIF/SSI 檢核 | R4 |
| `/epl-case-isu-data-input-check-co` | POST | 共同借款人 T24/CIF 檢核 | R5, R8 |
| `/epl-save-isu-data-input` | POST | 存草稿 / Finished 交易 | R6, R7, R8, R10 |
| `/epl-retu-isu-data-input` | POST | Return 案件、清理暫存 | R9 |
| `funcIsuDataInputCheckBorInfo` | internal function only | 內部比對 helper（非公開 endpoint） | R4, R5, R8 |

## Rules
> 每條只寫 **to-be 契約**（系統最終應如何）；佐證/出處/as-is/決策 → 下半 `Rule Evidence`，用 `[ev→Rn]` 指過去。

### R1 Select/init options and address date - 強制點: BE
covers-prd: FR-INIT-001, FR-INIT-002, FR-INIT-005, AC-001, AC-002

`/epl-sele-isu-data-input` 必須回傳渲染前所需的所有 Data Input 選項：common field options、可見 law firms、`updDate`、province list，以及 Data Input、collateral、purchased-property 區域的靜態值清單。Law firm 選項只暴露 `IS_SHOW='Y'` 的 `TB_LAW_FIRM` 列；`updDate` 必須為與舊系統一致的 application-date-derived address-version，common address endpoints 必須用此值查 province/district/commune/village。

此 endpoint 為 mutating POST（`CASE_PROGRESS=24` 初始化會更新 `TB_LON_SUMMARY_INFO.DISBURSING_DATE` 為保留副作用），mutation 必須明確、可稽核、交易安全；回傳的 `updDate` 仍維持 application-date-derived。缺 case summary 或前置 loan-condition 資料時回 `MSG_DATA_NOT_FOUND` + 404；查詢或系統失敗回 `MSG_QUERY_FAIL` + 500；兩者皆不得透過 unchecked list access 失敗。 [ev→R1]

### R2 Query Data Input page state - 強制點: BE
covers-prd: FR-INIT-001, FR-INIT-002, FR-INIT-003, FR-INIT-004, FR-UI-004, AC-001, AC-002

`/epl-info-isu-data-input` 必須以 `APPLICATION_NO` 查詢並回傳 summary header、`TB_DISBUR_DATE`、collateral list、purchased-property list、co-borrower list、T24 borrower check state、account candidates、`mbCheck`、`coCheck` 與 `eprois0921`。若無 `TB_DISBUR_DATE`，回應須由 approved loan-condition/source data 預填撥貸幣別/金額與 borrower T24 number，但不得標記完成。

回應欄位 `eprois0921` 為 API-facing 完成旗標，對應 DB 欄 `TB_DISBUR_DATE.EPORIS_0921`。EPROISU0920 Summary 僅在此值為 `Y` 時可進行；空白或 `N` 阻擋 Summary 並將使用者帶回 Data Input。 [ev→R2]

### R3 Role/page authorization and editability - 強制點: BE
covers-prd: FR-UI-001, FR-UI-002

頁面必須用 current page-column authorization model（`epl-auth-page-column` 依賴）決定可見按鈕與可編欄。CAD Maker role `404` 於 `CASE_PROGRESS=24` 可見 Back、Return、Save、Finished、main borrower Check、co-borrower Check。查詢-only 或不可編狀態不得呼叫 mutating endpoints。

後端仍須對 `/epl-save-isu-data-input`、`/epl-retu-isu-data-input`、`/epl-case-isu-data-input-check-mb`、`/epl-case-isu-data-input-check-co` 強制 role/state。`TB_API_AUTH` route 列必要但不充分；service-level guard 必須在使用者無權處理該案時拒絕直呼。 [ev→R3]

### R4 Main borrower T24/CIF/SSI check - 強制點: BE
covers-prd: FR-INIT-003, FR-UI-003, AC-003, AC-004

`/epl-case-isu-data-input-check-mb` 必須驗證 `applicationNo` 與 `borrowerT24No`，呼叫 borrower/CIF/SSI source，比對姓名、出生日、性別、Sector/Industry 與 `BUSINESS_SEC_CODE`，再寫入 `TB_T24_MAIN_BORROWER_INFO` 與 `TB_MAIN_BORROWER_ACC`。案件 product code 來源為 `TB_LON_SUMMARY_INFO.PRODUCT_CODE`；Sector/Industry mapping 為權威封閉集：product `01` 或 `02` 需 Sector `1001`/Industry `1001`；product `03` 需 Sector `1002`/Industry `1001`；任何未列 product code 或未列 Sector/Industry 組合必須讓 main-borrower check 失敗，不得 by default 通過。`MB_CHECK=Y` 需比對成功且 `CHECK_DATE` 為今日；mismatch、缺帳號或日期過期回 HTTP 200 + `MB_CHECK=N` 與結果訊息，不得部分信任先前的 pass state。Upstream timeout、服務不可用或系統例外必須回 non-2xx error envelope，不得偽裝成 `MB_CHECK=N`。

當 Borrower CIF No. 於成功檢核後在 T24 變更時，FE 必須將本地 `mbCheck` reset 為 `N`；BE 必須將已存 pass state 視為 stale，除非其符合當前 request/case state。 [ev→R4]

### R5 Co-borrower T24/CIF check and A-4 baseline - 強制點: BE
covers-prd: FR-INIT-004, FR-UI-003, AC-005, AC-008

`/epl-case-isu-data-input-check-co` 必須以 `DATA_SEQ` 驗證每筆 co-borrower CIF 輸入，呼叫 T24/CIF source，比對姓名、出生日、性別與 `BUSINESS_SEC_CODE`，並以 `APPLICATION_NO`、`RECID`、`DATA_SEQ` 為鍵寫入 `TB_T24_CO_BORROWER_INFO` 列。回傳的 `coCheck` 僅在每筆既存 co-borrower 列皆通過時為 `Y`。

`coCheck=N` 保留給業務 mismatch、check date 過期、缺列、缺必要 CIF 輸入或列級驗證失敗。Upstream timeout、T24/CIF 服務不可用或系統例外必須回 non-2xx error envelope，不得偽裝成 `coCheck=N`。

初始化與 Finished gating 採 old baseline：若案件無 co-borrower，co-borrower check 視為通過且不得阻擋 Finished；若有 co-borrower，`CO_CHECK=Y` 需列數一致、無失敗列、`CHECK_DATE` 為今日，且 `DATA_SEQ` mapping 正確。 [ev→R5]

### R6 Save draft and Finished transaction - 強制點: BE
covers-prd: Save / Finished, validation table, AC-006, AC-007, AC-008

`/epl-save-isu-data-input` 必須支援 draft（`isFinish=N`）與 Finished（`isFinish=Y`）兩模式。Draft 持久化所提供的 Data Input、collateral、purchased-property 與 co-borrower 暫存列，但不設 `EPORIS_0921=Y`。Finished 必須在 mutation 前執行所有必填、address、money、law-firm、T24-check 與 role/state 驗證，再原子寫入 `TB_DISBUR_DATE`、`TB_DISBUR_COLL`、`TB_DISBUR_OTHER_COLL` 與任何 T24 temp rebuild 列。

Finished 成功時設 `TB_DISBUR_DATE.EPORIS_0921='Y'` 並依已固定的 M4 regression 更新 `TB_LON_SUMMARY_INFO.RECEIVED_DATE`。失敗的 Finished 不得留下部分完成狀態。Client 提供的 `coCheck` 非權威；BE 必須在完成前以當前已存 T24 check state 重算或驗證。

Finished 非可重試的金額 mutation。任何 `isFinish=Y` mutation 前，BE 必須查詢當前 `TB_DISBUR_DATE.EPORIS_0921`；若已為 `Y`，請求必須以具名驗證碼 `EPROISU0921_ALREADY_FINISHED` 拒絕並 no-op 所有可變效果（含 `RECEIVED_DATE`、`FACILITY_FEE`、`REFINANCING_FEE`、collateral 列、purchased-property 列、T24 暫存列）。Draft save 在案件維持可編 Maker 狀態時仍可更新可編 draft 資料，但不得重開或覆蓋已完成的 Finished 事件。 [ev→R6]

### R7 M6 completion dates - 強制點: BE
covers-prd: M6 completion dates, `collateralList`, `addpurchasedList`

`collList[].estCom` 對應 `TB_DISBUR_COLL.EST_COM_DATE`；`purPropList[].otrEstCom` 對應 `TB_DISBUR_OTHER_COLL.OTHER_EST_COM_DATE`。public API wire format 為 `MM/YYYY`，非 legacy `dd/MM/yyyy`、亦非 ISO `date`。Query 必須以 `MM/YYYY` 回傳已存月年值；save 必須解析並將所提供月年值持久化至實體 DATE 欄。僅在欄位未提供或業務欄不適用時允許 null。 [ev→R7]

### R8 Sequence identity and business-section consistency - 強制點: BE
covers-prd: co-borrower check, collateralList, addpurchasedList, AC-005

`COLL_DATA_SEQ`、`OTHER_COLL_DATA_SEQ` 與 co-borrower `DATA_SEQ` 為穩定的排序/識別鍵。Save 不得以破壞 T24 比對或下游 collateral 參照的方式重新編號既存列。`TB_T24_CO_BORROWER_INFO.DATA_SEQ` 必須映回對應 co-borrower 列，任何 `BUSINESS_SEC_CODE` mismatch 必須讓相關 borrower check 失敗。 [ev→R8]

### R9 Return Data Input case - 強制點: BE
covers-prd: TBD-007, AC-010

`/epl-retu-isu-data-input` 必須驗證 role/state 並將案件退回前一 workflow 狀態。原子單位包含：將 case summary 更新回前一狀態、於 `TB_APP_HISTORY` 插入 return audit/history 列、設 `TB_CONTR_DATA.CONTR_STATUS='R'`，並刪除 Data Input/T24/contract-generation 暫存 DB 物件：`TB_T24_MAIN_BORROWER_INFO`、`TB_T24_CO_BORROWER_INFO`、`TB_MAIN_BORROWER_ACC`、`TB_DISBUR_COLL`、`TB_DISBUR_OTHER_COLL`、`TB_DISBUR_DATE`、`TB_CONTR_AUTO_FILE_PTH`、`TB_LOAN_CONDITION_FEE`（`CON_TYPE='FN'`）與 `TB_LOAN_CONDITION_DETAIL`（`CON_TYPE='FN'`）。

清理邊界僅限 DB metadata/data。刪除實體已產出 contract 檔案不在本 SRS 範圍，除非另有 owner 決策加入。交易必須原子：若 history、workflow update、contract status update 或 cleanup 失敗，workflow 狀態不得部分退回。 [ev→R9]

### R10 Money, address, and law-firm validations - 強制點: BE
covers-prd: validation table, AC-007, AC-009, fee M7/M10 non-reopened constraint

Money 與 fee 欄位須遵循 DB 精度 `NUMBER(17,2)`（適用處）。撥貸金額不得超過核准 loan amount；無效金額依頁規則 restore 或 reject。Designated repayment day 必須為 1–31。`LAW_FIRM_AMOUNT_90` 與 `LAW_FIRM_90_OTHER_REMARK` 成對：任一提供則兩者必填；remark 最大長度 16。

`FACILITY_FEE` 與 `REFINANCING_FEE` 為 Finished 時 BE 計算值，非 client 權威 request 值。Facility fee 來源為案件當前 `FIN_CON_TYPE` 的核准 loan-condition amount `TB_LOAN_CONDITION_DETAIL.LOAN_AMOUNT` × `TB_LOAN_CONDITION_FEE.FEE_1 / 100`。Refinancing fee 來源為所提交 `TB_DISBUR_DATE.DISBURSEMENT_AMOUNT` × `TB_LOAN_CONDITION_FEE.FEE_5 / 100`。缺 fee source 欄則持久化 null 而非合成值；non-numeric、overflow 或不支援幣別的 fee 計算須在 Finished mutation 前以具名碼 `EPROISU0921_FEE_SOURCE_INVALID` 失敗。Rounding 遵循 old-system parity（除非後續 owner 決策明確核准 delta）：USD 須以 legacy `String.format("%.2f", value)` 行為格式化為 2 位小數、不得以 `RoundingMode.DOWN` 截斷；KHR 維持已核准的 A-5/domain 決策（scale 0、`RoundingMode.DOWN`）；任何其他撥貸幣別在 USD/KHR-only 決策下 by-design 不可達、不得靜默產生支援的 fee 值。

Collateral 與 purchased-property 的 address front/back text 每列合計不得超過 65 字元。FE 可即時驗證，但 BE 為 Finished 與 mutating save 的權威。

CBC Member Reference 與 Add Purchased Property 使用同一 `collproSize` 上限值 5，但兩者計數獨立：CBC Member 至多 5 筆、Add Purchased Property 至多 5 列，兩計數不得合併成單一總額。FE 可提早阻擋 add，但 BE 為 `/epl-save-isu-data-input` Save/Finished 的權威，必須 reject 超限 payload 而非靜默截斷。 [ev→R10]

### R11 Authorization, privacy, and audit guards - 強制點: BE
covers-prd: security and transaction expectations

所有 endpoint 必須要求已驗證 user context 與 application 的 service-level authorization。Error 回應不得暴露 credentials、hostnames、stack traces、production URLs、T24 raw payloads，或超過 UI 已預期的最小 field-level result message 的個資。Mutating endpoint 必須與 workflow 一致地寫入既有 audit/history 記錄。

`funcIsuDataInputCheckBorInfo` 為內部比對 helper，非公開 OpenAPI endpoint。若實作為 reuse 將其置於 controller 後，必須保護為 internal-only，且不得回傳超過 caller 所需欄位的 raw 比對來源列。

`TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE` 作為個金撥貸流程的 server-read routing 與 audit context 承載。EPROISU0921 不在 Data Input 內建立獨立 S/U 分支：上游 tab/page eligibility 與 collateral-page availability 在本頁之前由 ISU shell/EPROISU0920 routing 決定。BE 不得信任 client 提供的 secure attribute，且不得用其繞過 Data Input 驗證；未來 S/U 行為拆分需新 PRD/SRS delta。 [ev→R11]

### R12 Traceability and completion interoperability - 強制點: both
covers-prd: FR-UI-004, AC-001, AC-007, AC-008

API 契約刻意暴露 `eprois0921`，同時保留實體 DB 欄 `EPORIS_0921`。舊 legacy 路徑 `/EPROIS_0921/query`、`/EPROIS_0921/save_dataInput`、`/EPROIS_0921/CheckMainBorr`、`/EPROIS_0921/CheckCoBorr` 僅為 provenance；to-be 公開契約為本 bundle 的 epl-* endpoint 集。EPROISU0920 Summary gating 必須用 to-be `eprois0921` 值，不得從部分 Data Input 列推斷完成。 [ev→R12]

## NFR
- Transactionality: Finished 與 Return 必須跨 summary、disbursement、collateral、T24 temp 與 history 更新原子。
- Observability: 失敗的 T24/CIF check 回結構化 result message，不洩漏敏感服務細節。
- Compatibility: 保留實體 DB 名稱與 legacy 完成旗標語意，同時對外用 epl-* API 契約名。
- Testability: 規則以可 seed 的 API-level 形式可測；所有 T1 money/checkpoint/security 規則須 BE 驗證。

## Hard Boundaries
- 可先修（與 @PENDING 無關、皆已 closed）：R1–R12 全條目，所有 per-item owner checkpoint 已於 2026-06-22 關閉、TBD-0921-001..005 closed。
- 待 TBD（涉 @PENDING）：無；本包 @PENDING 全 closed。
- 不可動：實體 DB 表/欄名（含 typo `EPORIS_0921`、`DRAWDOWN_ACCOINT`）；fee M7/M10 與 `RECEIVED_DATE` M4 以 regression-fixed 約束承載、不重開。
- 摘要：RD 可全面實作 R1–R12，重點守住 already-finished 冪等、BE 權威檢核、USD/KHR rounding parity、collproSize 雙計數獨立上限。

# ───────────────── Appendix — Evidence & Decisions（為什麼/出處/風險）─────────────────

## Appendix — Evidence & Decisions
> 本半＝稽核/審查讀者用；契約推導的所有佐證。實作者開發時可後讀。

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PM PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md:40`-`46`, `68`-`72`, `82`-`86`, `96`-`99`, `113`-`120`, `126`-`147`, `167`-`176` | Scope、PRD functional requirements、validation、API legacy mapping、DB touchpoints、acceptance criteria。Carried by R1-R12。 |
| Dispatch | `docs/build-tasks/disbursement-reopen-srs-dispatch.md:43`-`76` | 0921 re-open 方向：old baseline、僅 intentional `refactor-spec`/`db-diff` delta 改 to-be、per-item owner confirm。 |
| Source precedence | `docs/spec-architecture.md:80`-`117` | PRD/refactor/db-diff/legacy 衝突的 SoT ladder 與升級規則。 |
| N-axis playbook | `docs/process/orchestration-playbook.md:40`-`50`, `81`-`83` | T1 須跑 A-G；per-page checkpoint；不得自宣 Approved。 |
| Legacy | `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0921_mod.java` | A-4、M6、address `UPD_DATE`、`DATA_SEQ`、business-section、law firm filter 的 old baseline。as-is。 |
| Legacy FE | `legacy-epro/WebContent/html/cathaybk/system/epro/is/EPROIS_0900/EPROIS0921_JS.jsp` | 舊 finish gate、Summary tab gate、payload 欄名、address 與 sequence 處理。as-is。 |
| Refactor-spec | `docs/refactor-spec/02_modules/EPROISU0921.md:22`-`29`、`docs/refactor-spec/03_artifacts/fe-individual/EPROISU0921/eproisu0921-data-input.md:28`-`34`, `80`-`84`, `134`, `178`-`220` | 最新 epl-* 契約 map、page auth、Summary gate、check buttons、`coCheck` request carriage。 |
| DB diff | `docs/db-diff/02_tables/*.md` | `schema.sql` 與 DB reconcile 的實體 table/column 真值（schema 權威）。 |
| Current backend | `backend/src/main/java/khd/svc/epro/controller/individual/DataInputController.java:43`-`114` | 已實作 epl-* route 名與方法。現行實作 grounding。 |

## Trade-offs
- 保留 legacy typo 實體欄名（`EPORIS_0921`、`DRAWDOWN_ACCOINT`）而用 epl-* / camelCase 對外：兼顧不破 DB 與契約現代化，代價是 API↔DB 名稱不對稱（以 R12/schema 文件化）。
- `coCheck` 承載於 save request 但 BE 不採信、改以已存 T24 state 重算：保 refactor-spec 相容性，代價是契約上需明示 client 值非權威（R6/REF-D2）。
- USD fee rounding 維持 legacy `String.format("%.2f", value)` parity 而非與 KHR 統一 `RoundingMode.DOWN`：守住 old-system 金額一致性，代價是兩幣別 rounding 行為分歧（R10/REG-D6）。

## DB Reconcile / Delta
| Delta | 三判 | SRS action | Source |
|---|---|---|---|
| DB-D1 `TB_DISBUR_DATE` 為 active，存 Data Input 主資料含 money 欄、law firm 欄與實體完成旗標 `EPORIS_0921`。 | carried | R2/R6/R10/R12 將 `eprois0921` 對映實體 `EPORIS_0921`；無 DB rename。 | `docs/db-diff/02_tables/TB_DISBUR_DATE.md:45`-`61`, PRD `:132`, `:142` |
| DB-D2 `TB_DISBUR_COLL.EST_COM_DATE` 與 `TB_DISBUR_OTHER_COLL.OTHER_EST_COM_DATE` 存在為 `DATE`。 | physical carried + owner-confirmed `REF-D4` wire delta | R7 要求 save/query 月年 round-trip；current null persistence 非 to-be。 | `docs/db-diff/02_tables/TB_DISBUR_COLL.md:55`; `docs/db-diff/02_tables/TB_DISBUR_OTHER_COLL.md:47`; current `DataInputServiceImpl.java:1025`, `1095` |
| DB-D3 T24 check 表保留 `CHECK_DATE`、`CHECK_SUCCESS`、`DATA_SEQ`、`BUSINESS_SEC_CODE`。 | carried | R4/R5/R8 要求當日 pass 與 business-section 比對。 | `docs/db-diff/02_tables/TB_T24_MAIN_BORROWER_INFO.md:40`, `46`-`47`; `docs/db-diff/02_tables/TB_T24_CO_BORROWER_INFO.md:32`, `40`-`48` |
| DB-D4 Address 表以 `UPD_DATE` 為鍵。 | confirmed old baseline | Owner 2026-06-22 確認：R1 要求單一 application-date-derived `updDate` 供 province/district/commune/village。 | `docs/db-diff/02_tables/TB_PROVINCE.md:32`, `41`; `docs/db-diff/02_tables/TB_DISTRICT.md:32`, `42`; `docs/db-diff/02_tables/TB_COMMUNE.md:32`, `42`; `docs/db-diff/02_tables/TB_VILLAGE.md:32`, `42` |
| DB-D5 `TB_LAW_FIRM.IS_SHOW` 維持實體 filter 欄。 | physical carried + confirmed `REF-D3` behavior delta | R1/R10 僅暴露 active law firm 並 reject inactive 直接 save，取代舊 non-`02.21` all-law-firm 分支（owner 2026-06-22）。 | `docs/db-diff/02_tables/TB_LAW_FIRM.md:42`; legacy `EPROIS_0921_mod.java:300`-`311`; current `TBLawFirmRepository.java:16`-`18` |
| DB-D6 `TB_API_AUTH` 為 active/exact 並支援 epl endpoint seed 列。 | carried with security guard | R3/R11 要求 route auth 加 service-level role/state guard。 | `docs/db-diff/02_tables/TB_API_AUTH.md:38`-`40`; playbook D-axis requirement |
| DB-D7 `TB_DISBUR_DATE.DISBURSEMENT_BY` 實體長度為 25。 | DB-resolvable fact | OpenAPI 用 `maxLength: 25`；refactor save artifact 的 `String 5` 訊號不覆蓋 db-diff 實體寬度，因該欄存 account/payment text。 | `docs/db-diff/02_tables/TB_DISBUR_DATE.md:47`; `docs/refactor-spec/03_artifacts/be-individual/EPROISU0921/epl-save-isu-data-input.md:117`; `openapi.yaml` `disbursementBy` |
| DB-D8 `TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE` 為 active case-routing 屬性。 | carried + page-level disclaim | R11 將其承載為 server-read routing/audit context 並明確 disclaim 任何 intra-0921 S/U split。 | Bible `docs/specs/bible/bible-eproposal.md:230`, `326`; `schema.sql` `TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE` |
| DB-D9 `TB_DISBUR_DATE.DRAWDOWN_ACCOINT` 保留實體 typo 但存 account text。 | DB-resolvable correction | `schema.sql` 用 `VARCHAR2(25)`、OpenAPI 暴露 `drawdownAccount` 為 string max 25；此修正 SRS schema 型別並保留實體欄名。 | Current entity `TBDisburDateEntity.java:60`-`61`; refactor save artifact `epl-save-isu-data-input.md:116`; legacy UI `EPROIS0921_JS.jsp:173`, `181` |
| DB-D10 `TB_DISBUR_DATE.FACILITY_FEE` 與 `REFINANCING_FEE` 為 `NUMBER(17,2)` 計算欄。 | carried with BE-authoritative calculation | R10 定義 Finished-time 公式、來源表、null/失敗政策與 rounding；OpenAPI 回 `facilityFee`/`refinancingFee` 為 server-calculated。USD rounding 遵 legacy `String.format("%.2f", value)` parity；KHR `RoundingMode.DOWN` 限 A-5/domain-approved KHR 分支。 | PRD AC-007 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md:173`; legacy `EPROIS_0921_mod.java:451`-`459`, `470`-`477`; current backend `DataInputServiceImpl.java:882`-`905`, `1149`-`1155`; `docs/disbursement/disbursement-domain-escalations.md:13` |
| REF-D1 Refactor 最新將 legacy actions 拆為 epl-* endpoints 並加 page-column authorization。 | intentional contract modernization | Endpoints 表與 openapi 用 epl-* routes；legacy 路徑僅 provenance。 | `docs/refactor-spec/02_modules/EPROISU0921.md:22`-`29`; `eproisu0921-data-input.md:167`-`181` |
| REF-D2 Refactor 於 save request 承載 `coCheck` 但不使其 backend-authoritative。 | carried with confirmed BE authority constraint | R6 僅為相容接受 `coCheck`；owner 2026-06-22 確認 BE 於 Finished 前驗當前已存 check state。 | `eproisu0921-data-input.md:134`; legacy save request `EPROIS0921_JS.jsp:1058`-`1059`; legacy save read `EPROIS_0921_mod.java:386`-`387` |
| REF-D3 Refactor 移除舊 `SYSTEM_VER` law-firm 分支、一律以 `IS_SHOW='Y'` filter 可見 law firm。 | confirmed intentional contract modernization | Owner 2026-06-22 採納 `REF-D3`；R1/R10 以 `IS_SHOW='Y'` 為 to-be select 與 save validation 規則。 | legacy `EPROIS_0921_mod.java:300`-`311`; refactor `epl-sele-isu-data-input.md:210`; current `TBLawFirmRepository.java:16`-`18` |
| REF-D4 Refactor 將 M6 completion date wire format 由 legacy `dd/MM/yyyy` 改為 `MM/YYYY`。 | intentional contract modernization + owner-confirmed 2026-06-22 | R7 與 openapi 對 `estCom`/`otrEstCom` 用 `MM/YYYY`；實體 DB 仍 DATE 並須 round-trip 月年。 | legacy `EPROIS_0921_mod.java:168`, `416`, `422`; refactor `epl-info-isu-data-input.md:127`-`128`; current DTO `SaveCollList.java:90`-`92`, `SavePurPropList.java:55`-`57` |
| REG-D1 Current backend 在無 co-borrower T24 列時回 blank `coCheck`。 | regression against confirmed old baseline | Owner 2026-06-22 確認：no co-borrower = `CO_CHECK=Y`；Finished 不得因缺 co-borrower 被阻擋。 | legacy `EPROIS_0921_mod.java:232`-`242`; current `DataInputServiceImpl.java:479`-`485` |
| REG-D2 Current backend 於 save 時將 M6 date 欄設 null。 | regression | R7 要求恢復舊 date round-trip。 | legacy `EPROIS_0921_mod.java:416`, `422`; current `DataInputServiceImpl.java:1025`, `1095` |
| REG-D3 Current backend Sector/Industry 條件可 by default 通過未列 product 或 Sector/Industry 組合。 | regression risk against confirmed product mapping | R4 要求封閉 mapping：`01`/`02` -> `1001`/`1001`；`03` -> `1002`/`1001`；其他失敗。 | legacy `EPROIS_0921_mod.java:698`-`713`; current `DataInputServiceImpl.java:1426`-`1430` |
| REG-D4 Current backend 於持久化前未明顯 reject 超限 CBC Member 或 Add Purchased Property payload。 | regression risk against owner-confirmed limit rule | R10 要求當 `cbcMemberList` > 5 或 `purPropList` > 5 列時 BE reject；FE-only 限制對 T1 Save/Finished 不足。 | legacy `EPROIS0921_JS.jsp:1118`-`1121`, `1143`-`1147`; refactor `EPROISU0921_Data_Input_前端系統規格書_v1.8_20251125--4c5f2248.md:372`, `582`; current `DataInputServiceImpl.java:968`-`984`, `1083`-`1088` |
| REG-D5 重複 `isFinish=Y` 提交在無防護下可重複 money/completion 副作用。 | Bible disaster-scenario blocker | R6 要求 already-finished 拒絕/no-op，以 `EPROISU0921_ALREADY_FINISHED` 在更新 `RECEIVED_DATE`、fees、collateral、purchased-property、T24 temp 列前攔下。 | Bible duplicate-disbursement risk `docs/specs/bible/bible-eproposal.md:246`, `463`; PRD idempotency row `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md:185` |
| REG-D6 Current backend 以 `RoundingMode.DOWN` 截斷 USD facility/refinancing fee。 | regression risk against old-system USD fee parity | R10 要求 USD 遵 legacy 兩位小數 `String.format("%.2f", value)`。未發現核准 USD 截斷 delta 的 owner 證據；A-5 下僅核准 KHR `DOWN` 與 USD/KHR 幣別收斂。 | legacy `EPROIS_0921_mod.java:451`-`459`, `470`-`477`; current `DataInputServiceImpl.java:897`-`905`, `1149`-`1155`; `docs/build-tasks/done/khr-currency-handling-recon-findings.md:161`-`167`; `docs/disbursement/disbursement-domain-escalations.md:13` |

## @PENDING
> 本包 @PENDING 全 closed（owner 2026-06-22）。下表為 PRD TBD disposition 與已關 register 的整合視圖。

### PRD TBD Disposition
| PRD TBD | SRS disposition | Status |
|---|---|---|
| TBD-001 legacy naming noise (`EPROIS_0911` / Collateral Information) | R12 保留 to-be 名 `EPROISU0921` / Data Input，legacy 命名僅 provenance。 | closed in SRS |
| TBD-002 physical completion flag typo `EPORIS_0921` | R2/R12 將 public `eprois0921` 對映實體 `EPORIS_0921`；本 SRS 無 DB rename。 | closed in SRS |
| TBD-003 physical account typo `DRAWDOWN_ACCOINT` | R12 與 `schema.sql` 保留實體 typo，API 用 `drawdownAccount`。 | closed in SRS |
| TBD-004 legacy `.get(0)` 前置資料假設 | R1/R2 要求缺前置資料回 `MSG_DATA_NOT_FOUND`/404，並禁止 unchecked-list 失敗。 | closed in SRS |
| TBD-005 `CASE_PROGRESS=24` 初始化更新 `DISBURSING_DATE` | R1 明確文件化保留副作用並要求 audit/transaction 安全，address `updDate` 維持舊 `APPLICATION_DATE`-derived baseline（owner 2026-06-22）。 | closed in SRS |
| TBD-006 Product Code 對 Sector/Industry mapping | Owner 2026-06-22：以 PRD mapping 為 main-borrower check 權威（`01`/`02` -> `1001`/`1001`；`03` -> `1002`/`1001`）；未列 product code 不得 by default 通過。 | closed `TBD-0921-003` |
| TBD-007 Return cleanup scope | Owner 2026-06-22：遵舊/refactor SQL1-SQL12 DB cleanup scope，保留/寫 audit history，不要求實體檔刪除（除非另定）。 | closed `TBD-0921-004` |
| TBD-008 shared `collproSize` limit | Owner 2026-06-22：CBC Member 與 Add Purchased Property 用同上限值 5，但各自獨立計數；BE 須在 Save/Finished 強制上限。 | closed `TBD-0921-005` |

### @PENDING Register (all closed)
| ID | Status | Decision | Owner | Source |
|---|---|---|---|---|
| TBD-0921-001 | closed | A-4 owner 2026-06-22 確認：no-co-borrower pass = `CO_CHECK=Y`；co-borrower `CO_CHECK=Y` 需 count parity、every row success、today's `CHECK_DATE`、`DATA_SEQ` mapping；Finished `mbCheck`/`coCheck` 需 BE 權威；law firm 用 `REF-D3` `IS_SHOW='Y'`；address `UPD_DATE` 為 `APPLICATION_DATE`-derived 並有獨立 `DISBURSING_DATE` 初始化副作用；business-section 比對為必要。 | PM/SA/RD | 本 spec R1/R4/R5/R6/R8/R10；dispatch `docs/build-tasks/disbursement-reopen-srs-dispatch.md:46`-`49`, `55`-`63` |
| TBD-0921-002 | closed | Owner 2026-06-22：API wire format 為 `MM/YYYY`（`REF-D4`），`EST_COM_DATE`/`OTHER_EST_COM_DATE` 提供時須被 query/accept/persist；current save-to-null 為 regression 待修。 | PM/SA/RD | 本 spec R7；dispatch `docs/build-tasks/disbursement-reopen-srs-dispatch.md:48`, `61`-`63` |
| TBD-0921-003 | closed | Owner 2026-06-22：PRD mapping 為本 SRS 完整權威（`01`/`02` -> `1001`/`1001`；`03` -> `1002`/`1001`）；未列 product code 或 Sector/Industry 組合須讓 main-borrower check 失敗。 | PM/SA | PRD `TBD-006`；本 spec R4 |
| TBD-0921-004 | closed | Owner 2026-06-22：Return 遵舊/refactor SQL1-SQL12 DB cleanup 集，保留/寫 `TB_APP_HISTORY`、設 `TB_CONTR_DATA.CONTR_STATUS='R'`、刪 T24 temp 列、Data Input collateral/date 列、`TB_CONTR_AUTO_FILE_PTH` 與 FN loan-condition fee/detail 列；實體檔刪除非必要除非另定。 | PM/SA/QA | PRD `TBD-007`；本 spec R9 |
| TBD-0921-005 | closed | Owner 2026-06-22：CBC Member 與 Add Purchased Property 共用上限值 5，但各自獨立計數；BE 須 reject 超限 Save/Finished payload、不得靜默截斷。 | PM/SA | PRD `TBD-008`；本 spec R10 |

## N-axis Verification Status
| Gate | Result |
|---|---|
| Mechanical `check-srs-bundle` | PASS 2026-06-22（`python scripts/check-srs-bundle.py docs/specs/srs/EPROISU0921`）；warnings 僅 advisory（`epl-auth-page-column`/`epl-contract` prose、缺 Bible-PRD trace file）。 |
| N-axis A Comprehensive/spec-review | PASS（最新 read-only spec-reviewer recheck 無 SRS completeness blocker，status 維持 In Review 期、未自宣 Approved）。 |
| N-axis B as-is parity | PASS（最新 regression recheck；SRS 現保留 `DRAWDOWN_ACCOINT` 為 account text、記錄 duplicate Finished 為 blocker 需求、視 current USD fee 截斷為 REG-D6 而非目標行為）。 |
| N-axis C error-code carriage | PASS（`EPROISU0921_COLL_OVER_LIMIT`、`EPROISU0921_ALREADY_FINISHED`、`EPROISU0921_FEE_SOURCE_INVALID` 承載於 OpenAPI/QA/spec）。 |
| N-axis D security/auth | PASS（2026-06-23 本機實作證據；status 維持 In Review 期、未自宣 Approved）。Backend 在 `isFinish=Y` 前鎖 case summary 列、reject already-finished `EPORIS_0921='Y'`、於 money/completion mutation 前驗當前已存 T24 main/co-borrower check，outbound request/response logging 遮罩 URI 與非 JSON body。 |
| N-axis E DB/refactor reconcile | PASS（`DRAWDOWN_ACCOINT` 保留實體 typo 為 `VARCHAR2(25)`、fee DB delta 明確）。 |
| N-axis F money/precision/truncation | PASS（USD fee rounding 遵 legacy `String.format("%.2f", value)`、KHR `DOWN` 限 A-5/domain-approved 分支、current backend USD `DOWN` 記為 REG-D6）。 |
| N-axis G testability/trace | PASS（QA-033 至 QA-036 涵蓋 blocker 修正）。 |

## Rule Evidence
> 每條 Rn 的 as-is（現況/legacy；含疑似 bug）、to-be delta / 決策 ID、provenance（`file:line`/`@SHA`）；鍵到 Rn，與上半 `[ev→Rn]` 1:1。

| Rn | as-is（現況/legacy；含疑似 bug） | to-be delta / 決策 ID | provenance |
|---|---|---|---|
| R1 | 舊 select 有 `SYSTEM_VER` law-firm 分支（非 `02.21` 回全部）。`CASE_PROGRESS=24` 流程先更新 `DISBURSING_DATE` 再呼 `getdisDate(APPLICATION_NO)`，而 `getdisDate` 實際由 `APPLICATION_DATE` 解析查 address `UPD_DATE`；current backend 在此分支由本地 `disbursingDate` 推 `updDate`。 | `REF-D3`（law firm `IS_SHOW='Y'`，owner 2026-06-22）；address `updDate` 照舊 `APPLICATION_DATE`-derived（owner 2026-06-22），`DISBURSING_DATE` 初始化副作用保留但非 address `UPD_DATE` 來源（TBD-0921-001、TBD-005）。 | legacy `EPROIS_0921_mod.java:173`-`177`, `300`-`311`, `994`-`1002`；`EPRO_IS0110.java:230`-`242`, `347`-`381`；refactor `eproisu0921-data-input.md:210`、前端規格書 `:1152`-`1153`, `1194`-`1195`, `1236`-`1237`；current `DataInputServiceImpl.java:293`-`325` |
| R2 | 舊 query 含完成旗標讀寫；公開契約欄需對映實體 typo 欄。 | API 暴露 `eprois0921` → 實體 `EPORIS_0921`（TBD-002）；無 `TB_DISBUR_DATE` 時預填但不標完成；Summary gating 用此值。 | PRD `:132`, `:142`；legacy UI `EPROIS0921_JS.jsp`；DB-D1 |
| R4 | 舊 code 以 `DATA_SEQ` 鍵 co-borrower 比對、存 T24 `BUSINESS_SEC_CODE`、比 CIF income sector 對 stored business-section。Current backend Sector/Industry 條件可 by default 通過未列組合（REG-D3）。 | 封閉 product→Sector/Industry mapping（`01`/`02`->`1001`/`1001`；`03`->`1002`/`1001`；其他失敗）（TBD-0921-003）；upstream 失敗回 non-2xx 不偽裝 `MB_CHECK=N`。 | legacy `EPROIS_0921_mod.java:72`-`75`, `698`-`713`, `858`-`870`, `890`-`903`, `922`-`934`；current `DataInputServiceImpl.java:1426`-`1430`；DB-D3、REG-D3 |
| R5 | 舊 baseline：no-co-borrower 初始化為 `CO_CHECK=Y`；有 co-borrower 時需 count 與 T24 列一致、無失敗列、今日 `CHECK_DATE`。Current backend 無 T24 co-borrower 列時回 blank（REG-D1）。 | 照舊 baseline（owner 2026-06-22）：no co-borrower = pass、不阻 Finished；有 co-borrower 需 count parity、無失敗列、今日 `CHECK_DATE`、`DATA_SEQ` mapping（TBD-0921-001）。無 intentional refactor delta。 | legacy `EPROIS_0921_mod.java:232`-`242`；current `DataInputServiceImpl.java:479`-`485`；DB-D3、REG-D1 |
| R6 | 舊 FE 在 `MB_CHECK=Y` 且 `CO_CHECK=Y` 才允 Finished，borrower T24 變更後 reset `MB_CHECK`。重複 `isFinish=Y` 在無防護下可重複金額/完成副作用（REG-D5，Bible disaster blocker）。 | BE authority（owner 2026-06-22）：`isFinish=Y` 須獨立強制當日 `mbCheck`/`coCheck` pass 才 mutate；already-finished 以 `EPROISU0921_ALREADY_FINISHED` 拒絕/no-op（REG-D5）；client `coCheck` 非權威（REF-D2）。M4 `RECEIVED_DATE` 為 regression-fixed 約束。 | legacy `EPROIS0921_JS.jsp:1100`-`1103`, `1288`-`1295`；Bible `docs/specs/bible/bible-eproposal.md:246`, `463`；PRD `:185`；REF-D2、REG-D5 |
| R7 | 舊 query/save 用 `dd/MM/yyyy`。Current backend save 將兩欄寫 null（REG-D2）。 | `REF-D4`（owner 2026-06-22）：API wire format `MM/YYYY`；BE 須將月年 round-trip 至 DATE 欄、提供有效值時不得寫 null。 | legacy `EPROIS_0921_mod.java:168`, `261`-`262`, `284`-`285`, `416`, `422`；current `DataInputServiceImpl.java:1025`, `1095`；DB-D2、REF-D4、REG-D2 |
| R8 | 舊 code 以 `DATA_SEQ` 鍵 co-borrower 比對並比 stored business-section。 | `DATA_SEQ` mapping 與 business-section mismatch 必須讓相關 borrower check 失敗（owner 2026-06-22，TBD-0921-001）；save 不得 renumber 破壞 T24 比對/下游參照。 | legacy `EPROIS_0921_mod.java:72`-`75`, `858`-`870`, `890`-`903`, `922`-`934`；DB-D3 |
| R9 | 舊/refactor 以 SQL1-SQL12 做 DB cleanup。 | 照舊/refactor cleanup 集（owner 2026-06-22，TBD-0921-004）：更新 summary、寫 `TB_APP_HISTORY`、設 `TB_CONTR_DATA.CONTR_STATUS='R'`、刪指定暫存物件；實體檔刪除非本 SRS 範圍；交易原子。 | PRD `TBD-007`；dispatch `docs/build-tasks/disbursement-reopen-srs-dispatch.md` |
| R10 | 舊系統 USD fee 用兩位小數格式化；KHR scale 0 `DOWN`。Current backend 以 `RoundingMode.DOWN` 截斷 USD（REG-D6），且未明顯 reject 超限 collproSize payload（REG-D4）。 | USD 遵 legacy `String.format("%.2f", value)` parity（無 owner 核准截斷 delta）；KHR `DOWN` 限 A-5；fee BE 計算、來源/失敗政策見規則；`collproSize` 上限 5 但雙計數獨立、BE reject 超限（TBD-0921-005）；fee 失敗碼 `EPROISU0921_FEE_SOURCE_INVALID`。M7/M10 fee 為 regression-fixed 不重開。 | legacy `EPROIS_0921_mod.java:451`-`459`, `470`-`477`；current `DataInputServiceImpl.java:897`-`905`, `968`-`984`, `1083`-`1088`, `1149`-`1155`；`docs/build-tasks/done/khr-currency-handling-recon-findings.md:161`-`167`；`docs/disbursement/disbursement-domain-escalations.md:13`；DB-D10、REG-D4、REG-D6 |
| R11 | `funcIsuDataInputCheckBorInfo` 為內部 helper；`SECURE_ATTRIBUTE` 為 active case-routing 屬性。 | helper 維持 internal-only、不回多餘 raw 列；`SECURE_ATTRIBUTE` 承載為 server-read routing/audit、明確 disclaim intra-0921 S/U split、BE 不信 client 值（DB-D8）。 | Bible `docs/specs/bible/bible-eproposal.md:230`, `326`；`schema.sql` `TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE`；DB-D8 |
| R12 | 舊 legacy 路徑 `/EPROIS_0921/query` 等為 provenance；實體欄含 typo。 | API 暴露 `eprois0921` 同時保留實體 `EPORIS_0921`（TBD-001/002）；legacy 路徑僅 provenance；Summary gating 用 to-be 值。 | DB-D1；legacy UI `EPROIS0921_JS.jsp`；REF-D1 |

> 註：R3 為 to-be authorization 契約（page-column model + service-level guard），佐證見 DB-D6 與 N-axis D。

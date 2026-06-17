# 撥貸（Disbursement）整體 Triage — 0921 + 0922 + T24

> **舊系統比對（Step A/A2/B）完成後的綜合裁決**（2026-06-05）。逐項證據表（含 T24 段位、舊業務規則、`file:line`）存本機 `legacy-extract/*-compare.md`（gitignore）；本檔只到**主題 / 嚴重度 / owner / 信心**。
> 配 `verification-handoff.md` §2.1/§2.2/§2.3。
> ⚠️ **重大裁定更新（2026-06-16）**：① **A-1 換匯 stub 已實作＋conformance PASS**（`daae4c3`，P0-1 結）② **批次層 AUD-10 結**（6/8 FOUND + B005 inline-取代銷案）③ **owner「T24 都照舊系統規格」** → §2/§3 所有 T24 欄值/來源/格式/截斷 **全收編＝照舊 parity、轉執行**（卡 `build-tasks/t24-bgroup-legacy-parity-fix.md`；邊界＝KHR 無舊 spec→維持新）。**下文 §6「需真 T24 spec/domain」對 T24 欄部分已被此裁定 supersede**；殘 domain＝A-4 檢核嚴格度、M6 完工日 DTO。

## 0. 總結論（里程碑更正）
**新撥貸後端（`0921 DataInput` + `0922 Summary` + T24 組檔）＝結構搭好、但功能未完成且與舊系統實質分歧。**
- **目前無法端到端授權**：`funcGetExchangeRate` 是 throw-stub。
- **即使補完 stub，T24 檔仍會錯**：段位錯位、多/漏欄、漏段、來源欄錯 → 產出**無效或錯誤的 T24 檔**。
- → **「`0920` 認列既有＝30% 結構到位」正式更正為「撥貸需實作 + 修正 + T24 格式符合性驗證」**，是 work-in-progress，非完成。
- **信心分層**：🔴 結構類（stub、漏段、多欄、位移）＝**高信心**（新碼確定行為）；來源欄類＝中高（倚賴舊 spec）；「是否刻意」類＝需 domain。

## 1. P0 — Blockers（撥貸根本不能動）
| # | 項目 | 來源 | owner |
|---|---|---|---|
| ~~P0-1~~ ✅ | `funcGetExchangeRate` throw-stub → authorize 全斷 | **已實作＋conformance PASS（product `daae4c3`，06-16，mvn 綠；OQ-1~5 碼驗 4/4，錯誤碼 `FAILED_E304`）** | 撥貸開發 |
| P0-2 | T24 結構壞：**H 段建了未 append**（不會輸出）、`E14–E23`+`E24-25` 位移、`H1–H8` 順序錯、`B9/C27/D8/G13` 各多尾端 `\n` 空欄 | 0922-t24 | 撥貸開發 + T24 整合 |
| P0-3 | `T24_COMPANY` 死路：`B8`/`C9` 仍讀新 schema 已移除的欄 → 空值，**無替代來源** | 0922-t24（D8）| T24 整合 owner（需決定值來源）|

## 2. P1 — 正確性 bug（資料錯 / 金錢 / 資料遺失；較高信心）
- **0921**：collateral 完工日寫 `null`（資料遺失）；`dataReturn` fee cleanup `deleteByIdApplicationNo` 過度刪；fee 公式 alias 不符 → facility fee 可能 `null`；`RECEIVED_DATE` 在 Save 即寫。
- **0922-main**：`EXCHANGE_RATE` 來源 ID `OVSLXLON01→02`（**✅ 06-16 owner 裁定：先對齊舊 parity→改回 `01`**；同 A-1 OQ-1、escalations A-2）；`submit` mail 送空清單（checker 沒收到）；`submit` history `25→24`。
- **0922-t24 來源欄**：`A52` 漏（`DISTRICT_NAME`）；`C12` `SUG_VAL` 讀錯表；`C13` `DECISION_DATE`→`CHECK_DATE`；`C20` 來源欄名錯（`INS_END_DATE` vs 同名直映 `INS_EXPIRY_DATE`）；`G4` currency 來源；`G10`/`H8` 換匯欄；`A31`/`G7` `AGREEMENT_NO` 截斷（舊取後 16 碼）；`E21` 非 USD 非 KHR 輸出 `0`（舊全換匯）；`G11–G12` fee remark mapping；`A15` 空值補 `N/A`；`A16` `NORMAL.LAON`→`LOAN`（⚠️ 舊可能是 T24 期望的 key、勿當錯字修）。**2026-06-17 B-group batch-fix**：`C12`/`C13`/`A31`/`G7`/`G11–G12`/`A15`/`A16` 已照舊修正；`E21`、`G4`/`G10`/`H8` 依 A-5 USD+KHR-only 邊界 keep，不在本批。

## 3. P2 — 需 domain / T24-spec 裁示（intended vs regression）
- **0921 檢核對等**：`CheckMainBorr`/`CheckCoBorr` 身分/sector/account/`DATA_SEQ` 順序/business-section；`info CO_CHECK` `='Y'` vs 舊 `!='N'`；Finished gate 未驗 `mbCheck`；law firm `IS_SHOW` 版本條件；address `UPD_DATE` 來源。
- **0922-main 架構**：`t24DealResult`→批次 `EPROZ0B006`（async）；mail 改 scheduler 後送；`IS_AUTODIS=YC`。
- **0922-t24**：行尾 `\r\n` vs `\n`（T24 可能敏感）；`C26` title-deed 全 join 到每筆 C row。**2026-06-17 B-group batch-fix**：已改 CRLF record join，`C26` 依當前 `COLL_DATA_SEQ` 過濾 title deed；仍待 T24 接收/端到端驗證。
- ~~🟢 疑刻意演進~~ → **A-5 結（06-16 owner）＝幣別「收窄」keep**：**補規格＝撥貸有效幣別 USD+KHR only（柬埔寨）**；舊 non-USD 通吃、新只 USD/KHR（其他 fee→null/E21→0）＝**by-design-unreachable、非 bug**（非該幣別業務不發生），不對等修。坐実＝`khr-currency-handling-recon-findings.md`。

## 4. P3 — UNSURE / 舊 DDL 核對（**06-12 起舊庫可連（Oracle），DDL 自查即可、不必等 DBA**）
- ~~金額 **precision**~~ ✅ 已關（06-12 DDL 實查：舊＝新，全金額 `(17,2)`、匯率表 `(17,4)`，無落差）。
- `t24DealResult` 非 `0000`/無 done flag 是否更新 summary 狀態。
- `IS_CONTRACT`/`IS_CONTR` persist 目標；contract-source 可能 NPE；空 `APPLICATION_NO`（新 controller 擋、舊 throw 未明）。

## 5. 工作量級別（誠實）
**非「修幾個 bug」**：＝ 補 1 個 stub ＋ **重做 T24 組檔**（結構 + ~12 處來源欄）＋ 修 ~7 個 0921/0922-main bug ＋ ~10 項 domain 裁示 ＋ 1 輪 DDL/DBA 精度。金錢核心、且**從未端到端跑過**。

## 6. 建議路徑（為什麼不讓 Codex 無腦「改回舊版」）
- T24 格式符合性、`T24_COMPANY` 值來源、檢核嚴格度、架構變更、精度——**都需要真 T24 spec / domain 決策**，非 Codex 可單方裁定；且部分分歧是刻意演進（KHR），改回舊版會破壞。
- Codex 可協助的是**機械、無歧義**的修正（append H、移除多餘 `\n` 欄、改正來源欄名），但須 gated review，且只限「舊行為明確正確且非移除依賴」者。
- → **決策點（見對話）**：撥貸返工怎麼驅動。

## 7. 機械修正 allowlist（Codex 授權執行；`backend/AGENTS.md` §6.7）
> 裁決（2026-06-05）：**Codex 先修機械、無歧義項**；判斷題升級。**只准動下列；每項引舊 spec `file:line`、逐項 commit、先回報 diff 供人審才推產品 repo**（§6.7）。

**Tier 1 — 純結構/明確 bug、彼此孤立（最安全，先做）**
| # | 修正 | 舊正確行為 | 風險 |
|---|---|---|---|
| M2 | 移除 `B9`/`C27`/`D8`/`G13` **多餘尾端欄**（重複 append 的欄）使欄數回舊定義（B=8/C=27/D=7/G=12）。**不動行尾 `\r\n` 政策（升級項）** | 舊段欄數固定；新各多一欄 | 低（逐段核對欄數）|
| M3 | `0922 submit` mail **把 checker 加進 `MailList` 再送** | 舊通知選定 checker；新送空清單 | 低 |
| M4 | `0921 RECEIVED_DATE` **加 `isFinish` guard、只在 Finished 寫** | 舊僅 Finished 寫 | 低 |

**Tier 2 — 結構對齊/來源欄（須逐位置對舊 spec；非單純平移即轉升級）**
| # | 修正 | 舊正確行為 | 確認點 |
|---|---|---|---|
| M1 | T24 **`H` 段整修＝append + `H1–H8` 位置對齊 + 輸出條件改「FEE 非 null 且非 0」三者同修** | 舊 H（`FT.LOAN.EIR`）有段、欄序固定、`FEE_1/FEE_5` 非 null 且非 0 才出 | ⚠️ **只 append 不修順序/條件會出錯位 H row** → 三者必須一起 |
| M8 | T24 `E14–E23` **位置對齊舊段位**（`MR_RATE_IDX`/`RATE_MRG` 放回原位） | 舊段位順序為 T24 格式 | 逐位置對 `EPROIS_0922-t24.md`；非單純平移即升級 |
| M5 | T24 `C20` 來源欄 `INS_END_DATE`→`INS_EXPIRY_DATE` | schema-map 標同名直映 | entity 有 `INS_EXPIRY_DATE` |
| M6 | `0921` collateral 完工日寫 `EST_COM_DATE`/`OTHER_EST_COM_DATE`（非 null） | 舊保存兩欄 | request/entity 有值可寫 |
| M7 | `0921` fee 公式 loan-amount alias 修正（facility fee 不為 null） | 舊 `loan amount × FEE_1` | alias/讀 key 對齊後值正確 |
| M9 | T24 `A52` 補輸出 `DISTRICT_NAME` | 舊輸出 A52 | 新流程讀得到 `TB_DISTRICT` |

**Tier 3 — 金錢刪除（機械但高風險，單獨 commit + 加強審查）**
| # | 修正 | 舊正確行為 | 風險 |
|---|---|---|---|
| M10 | `0921 dataReturn` fee cleanup **只刪 `CON_TYPE=FN`**（非 `deleteByIdApplicationNo`） | 舊只刪 FN | 刪錯範圍 = 資料遺失，務必精準 |

**🚫 不在 allowlist（一律 §6.6 升級，Codex 不得順手改）**
- P0-1 `funcGetExchangeRate` **stub 實作**（金錢核心）、P0-3 `T24_COMPANY` B8/C9 **值來源**。
- `EXCHANGE_RATE` 來源 ID `OVSLXLON01/02`（金錢、疑刻意）、`E21` 非 USD 非 KHR、`A15` N/A、`A16` `NORMAL.LAON/LOAN`（疑 T24 key）、`G11–G12` fee remark、`C12` SUG_VAL 換表、`C13` 來源、`G4`/`G10`/`H8` 換匯欄、`AGREEMENT_NO` 截斷（confirm T24 欄寬）。
- 全部 P2（檢核嚴格度、批次化、async mail、行尾 `\r\n`、KHR）、全部 P3（精度、`IS_CONTR`…）、`0922 submit` history `25/24`（confirm 後再定）。

**逐項閘門（每筆機械修正）**：① 屬上表某項 ② 引舊 spec `file:line` 證「舊明確正確且非移除依賴」 ③ 只動該 method、不外擴 ④ `mvn package` 綠 ⑤ 回報 diff + 依據供人審 → 過了才推產品 repo。

**2026-06-17 B-group owner-fix 補記**：本批是依 06-16 owner「T24 都照舊系統規格」另行授權，非擴張一般 allowlist。證據與修正清單見 `build-tasks/t24-bgroup-legacy-parity-fix-findings.md`；金錢/截斷欄 pre-push 最嚴人審**已過 → code 已 commit/push（product repo，06-17）**；剩端到端/T24 接收驗證。

### 7.1 進度
| 項 | 狀態 | 證據 |
|---|---|---|
| **M2** trim T24 尾欄（B/C/D/G） | ✅ diff 經審、對齊舊 spec（欄數 8/27/7/12）、行尾策略未動、scope 乾淨 → **待推產品 repo** | commit `2417cfe`；引 `EPROIS_0922-t24.md:143/152/168/196/215/223/295/308` |
| **M3** submit mail enqueue | ✅ diff 經審、只補空清單 bug、async 架構未動 → **待推** | commit `49ebcb1`；引 `EPROIS_0922.md:139` |
| **M4** RECEIVED_DATE Finished-guard | ✅ diff 經審、另案「dataReturn 多寫 history」未動 → **待推** | commit `1d39e1d`；引 `EPROIS_0921.md:122/:145` |
> 三筆各自獨立 commit、`package` exit 0。**落地（2026-06-06，更正）**：三筆**已在 `origin/master`**（push 先於分支決策、繞過了原定 PR gate）。裁決＝**接受在 master、不開 PR、不 revert**——diff 已對舊 spec 人審（規劃 repo commit `91ecd0c`）、且 stub 未修前 authorize 不會真的跑（修正暫時 inert），churn 不值得。**前向約定**：下一批落地方式**開工前先定**（避免又「已在 master 才發現」）；尤其 **Tier 3 M10（金錢刪除）建議走 feature branch + PR**，過產品 repo CI/審。下一批 = Tier 2（M1 H 段整修、M8 E 段、M5/M6/M7/M9，逐位置對、審更細）。
>
> ⚠️ **build 環境發現（非本次修正引入）**：後端 Logback 測試設定硬編碼 `D:\temp\saveFile\log`，非 Windows/無 `D:` 環境會擋 build；Codex 以 `-Dlogging.api.path`/`-Dlogging.batch.path` 覆寫繞過。屬可攜性 smell，建議外部化該路徑（獨立 ops 項，不阻擋本批）。
> 處置記錄：本 triage 為撥貸驗證的綜合產出。修正/實作屬**獨立返工階段**，不在「程式補完」里程碑（該里程碑就撥貸部分已更正為未完成）。

**Tier 2 派工（2026-06-06，🔄 進行中）**：落地＝**master-direct，但順序＝報 diff → 人審 → 才 push**（修正上批「先 push 才審」）。執行順序＝**易/孤立先、結構後**。**審查 round 1（2026-06-06，Codex 交 4 筆 commit、未 push；M6/M9 依停手規則未改）**：
| 序 | 項 | 狀態 | 審查結論 |
|---|---|---|---|
| 1 | **M5** C20 `INS_END_DATE`→`INS_EXPIRY_DATE`（commit `85783d5`） | ✅ 審過、待 push | key 為 raw 欄名（Oracle 原樣大寫）、entity 有 `insExpiryDate`、scope 乾淨。整合測時確認 C20 有值即可。 |
| 2 | **M7** 0921 fee alias `getLoanAmount`→`loanAmount`（commit `7856e66`，金錢） | 🟡 **push 前阻擋**：方向對（舊 key 是亂填的 getter 名），但**新 key 大小寫存疑**——Oracle 把未加引號的 `AS loanAmount` 折成 **`LOANAMOUNT`**，`.get("loanAmount")` 恐仍 null＝沒真的修好。需以**同查詢的鄰欄 working read** 證實實際 runtime key。 |
| 3 | **M8** E14–E23 位置對齊（commit `f31a19d`） | 🟡 **push 前確認**：layout 自洽（E16–E20=5×drawdown、E21=CHRG_AMOUNT、E22/E23=rates），但 Codex 另「補 E20 drawdown」超出「只搬 MR_RATE_IDX/RATE_MRG」——需確認 spec :254-263 確列 E16–E20 為 5 筆（非新增資料）。 |
| 4 | **M1** H 段三合一（commit `03831cc`） | 🟡 **push 前阻擋**：append✓、條件 `!=null && !=0`✓、H1–H7 定位✓；但 **H8 換匯欄屬 §7 升級項（line 71）**——須確認 Codex 對 H8 **只做定位、未新作 `EX_RATE_BUY`/non-USD 換匯值邏輯**；若改了值邏輯則 H8 拆出升級。 |
| — | **M6** 0921 完工日 | ⛔ Codex 停手 → **升級 domain**：request DTO 只有 `estCom`/`otrEstCom` 型別欄、**無日期值來源**，現況仍 `setEstComDate(null)`。非平移＝舊行為的日期從何而來需 owner 裁（FE 欄位漏接？別處衍生？）。 |
| — | **M9** A52 `DISTRICT_NAME` | ⛔ Codex 停手 → **升級 scope**：`SummaryServiceImpl` 未注入 `TBDistrictRepository`，正確補 A52 需新增依賴、超 method-only。為界定清楚的小擴充，確認 join key 後可單獨授權。 |
> M10（Tier 3 金錢刪除）不在本批。每筆仍守 §7 逐項閘門①–⑤。

**審查 round 2（2026-06-06，裁決後）**：四筆 M5/M7/M8/M1 經查證**已全在遠端 master `a353d10`**（先審後推 gate 第 3 次未守住——本批連帶把未授權 H8 換匯邏輯 + 疑無效 M7 一起推上）。逐項結：
> - **M5 / M8** ✅ 確認 OK（M8：spec `:256-260` 證 E16–E20 為 5 筆 drawdown，E20 是 spec 要求、非新增）。
> - **M1** ⚠️→✅：H8 `EX_RATE_BUY`/non-USD 是 Codex 新作（踩升級項），已用本地 `4089978` 拆掉、還原既有值邏輯（`mainBorrowerAcc.CURRENCY` 判 USD、非 USD 讀 `disburDate.EXCHANGR_RATE`），append/H1–H7/條件保留 → 待 push。H8 **值來源**維持升級項、不在本批修。
> - **M7** 🔴→ **往前修成 `get("LOANAMOUNT")`**：Oracle 未引號 `AS loanAmount` → JDBC label 折大寫，現行 `get("loanAmount")` 多半回 null（沒真修）；比照 native-query 既有大寫先例 `individual/FunctionServiceImpl:1781`。整合測時確認 facility fee 真有值。**附帶 smell**：codebase map-key 大小寫混用（`loanAmount`@807 vs `LOANAMOUNT`@1781）→ 列**獨立 sweep 項**。
> - **M6** ⛔ 升級 domain（request DTO 無日期值來源）。
> - **M9** 🟢 **授權（界定擴充）**：inject `TBDistrictRepository`，用主借人 `RESIDENT_PROVINCE_CODE`+`RESIDENT_DISTRICT_CODE` 查 `DISTRICT_NAME` 輸出 A52。⚠️ repo 鍵含 **`UPD_DATE`**（時間維度）→ 須比照既有 TBDistrict 名稱查法選「對的那筆」；無既定選法則停手升級。
> - **落地紀律最終定案**：**master-direct 全程（含 M10）+ 前向修模式**。⚠️ **M10 金錢刪除無平台 gate → pre-push 人審用最嚴標準 + 確認只刪 `CON_TYPE=FN`**（master-direct 下唯一防線）。

**Tier 2 收工（2026-06-06，round 3）**：master `446bdfb`。
> - **M7** ✅ `d5ca37f`：key 改 `LOANAMOUNT`，同 method 無其他同 map 欄位需動。
> - **M9** ✅ `446bdfb`：注入 `TBDistrictRepository`、A52 補 `DISTRICT_NAME`；`UPD_DATE` **沿用既有地址查法** `findMaxUpdDateWithDISBURSING_DATEByApplicationNo`（未猜 latest）；A52 接手 A51 尾端 newline。
> - **整合測確認點（繼承既有行為、非本批引入）**：M7 facility fee 實際有值；M9 該 UPD_DATE 慣例能 join 到非空 `DISTRICT_NAME`。
> - **Tier 2 全 6 項結案**：M5/M7/M8/M1/M9 已上 master 並審過；**M6 升級 domain**（DTO 無日期值來源，待 owner）。
> - **撥貸機械 allowlist 僅剩 `M10`**（Tier 3 金錢刪除）。其餘皆 §6.6 升級項（P0 stub、`T24_COMPANY`、匯率源 ID…）歸 domain。

**M10 結案（2026-06-06，最嚴閘門通過）→ 機械 allowlist 全清**：`06f39df`（待/已 ff push）。
> - fee delete 由 unscoped `deleteByIdApplicationNo` 改為 `deleteByApplicationNo(applicationNo, "FN")`，沿用既有 `TBLoanConditionFeeRepository:29` 的 `@Modifying @Query` native delete（`APPLICATION_NO=:applicationNo AND CON_TYPE=:conType`，具名參數綁定確認、非 derived）。
> - **detail delete 本就 FN-scoped**（`TBLoanConditionDetailRepository:200`，`CON_TYPE='FN'` 寫死）→ 無需改;fee/detail 皆對齊舊 spec `EPROIS_0921.md:197`。
> - 刪後**無重插** → 無非-FN 重複風險。
> - ✅ **撥貸 §7 機械 allowlist（M1–M10）全數結案**。剩下全是 §6.6 domain 判斷題 + M6（DTO 缺日期來源）→ 見 `disbursement-domain-escalations.md`。

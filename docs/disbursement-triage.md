# 撥貸（Disbursement）整體 Triage — 0921 + 0922 + T24

> **舊系統比對（Step A/A2/B）完成後的綜合裁決**（2026-06-05）。逐項證據表（含 T24 段位、舊業務規則、`file:line`）存本機 `legacy-extract/*-compare.md`（gitignore）；本檔只到**主題 / 嚴重度 / owner / 信心**。
> 配 `verification-handoff.md` §2.1/§2.2/§2.3。

## 0. 總結論（里程碑更正）
**新撥貸後端（`0921 DataInput` + `0922 Summary` + T24 組檔）＝結構搭好、但功能未完成且與舊系統實質分歧。**
- **目前無法端到端授權**：`funcGetExchangeRate` 是 throw-stub。
- **即使補完 stub，T24 檔仍會錯**：段位錯位、多/漏欄、漏段、來源欄錯 → 產出**無效或錯誤的 T24 檔**。
- → **「`0920` 認列既有＝30% 結構到位」正式更正為「撥貸需實作 + 修正 + T24 格式符合性驗證」**，是 work-in-progress，非完成。
- **信心分層**：🔴 結構類（stub、漏段、多欄、位移）＝**高信心**（新碼確定行為）；來源欄類＝中高（倚賴舊 spec）；「是否刻意」類＝需 domain。

## 1. P0 — Blockers（撥貸根本不能動）
| # | 項目 | 來源 | owner |
|---|---|---|---|
| P0-1 | `funcGetExchangeRate` throw-stub（寫資料後無條件丟、無 return）→ authorize 全斷 | 0922-main `FunctionServiceImpl:1221` | 撥貸開發 |
| P0-2 | T24 結構壞：**H 段建了未 append**（不會輸出）、`E14–E23`+`E24-25` 位移、`H1–H8` 順序錯、`B9/C27/D8/G13` 各多尾端 `\n` 空欄 | 0922-t24 | 撥貸開發 + T24 整合 |
| P0-3 | `T24_COMPANY` 死路：`B8`/`C9` 仍讀新 schema 已移除的欄 → 空值，**無替代來源** | 0922-t24（D8）| T24 整合 owner（需決定值來源）|

## 2. P1 — 正確性 bug（資料錯 / 金錢 / 資料遺失；較高信心）
- **0921**：collateral 完工日寫 `null`（資料遺失）；`dataReturn` fee cleanup `deleteByIdApplicationNo` 過度刪；fee 公式 alias 不符 → facility fee 可能 `null`；`RECEIVED_DATE` 在 Save 即寫。
- **0922-main**：`EXCHANGE_RATE` 來源 ID `OVSLXLON01→02`（換錯匯率源）；`submit` mail 送空清單（checker 沒收到）；`submit` history `25→24`。
- **0922-t24 來源欄**：`A52` 漏（`DISTRICT_NAME`）；`C12` `SUG_VAL` 讀錯表；`C13` `DECISION_DATE`→`CHECK_DATE`；`C20` 來源欄名錯（`INS_END_DATE` vs 同名直映 `INS_EXPIRY_DATE`）；`G4` currency 來源；`G10`/`H8` 換匯欄；`A31`/`G7` `AGREEMENT_NO` 截斷（舊取後 16 碼）；`E21` 非 USD 非 KHR 輸出 `0`（舊全換匯）；`G11–G12` fee remark mapping；`A15` 空值補 `N/A`；`A16` `NORMAL.LAON`→`LOAN`（⚠️ 舊可能是 T24 期望的 key、勿當錯字修）。

## 3. P2 — 需 domain / T24-spec 裁示（intended vs regression）
- **0921 檢核對等**：`CheckMainBorr`/`CheckCoBorr` 身分/sector/account/`DATA_SEQ` 順序/business-section；`info CO_CHECK` `='Y'` vs 舊 `!='N'`；Finished gate 未驗 `mbCheck`；law firm `IS_SHOW` 版本條件；address `UPD_DATE` 來源。
- **0922-main 架構**：`t24DealResult`→批次 `EPROZ0B006`（async）；mail 改 scheduler 後送；`IS_AUTODIS=YC`。
- **0922-t24**：行尾 `\r\n` vs `\n`（T24 可能敏感）；`C26` title-deed 全 join 到每筆 C row。
- 🟢 **疑刻意演進（勿改回）**：`KHR` 換匯 + 在地化（舊僅 USD）。

## 4. P3 — UNSURE / 需舊 DB2 DDL 或 DBA
- 金額 **precision** 全面（新 `NUMBER(17,2)` vs 舊 DB2 scale UNKNOWN）→ 需舊 DDL/DBA。
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

### 7.1 進度
| 項 | 狀態 | 證據 |
|---|---|---|
| **M2** trim T24 尾欄（B/C/D/G） | ✅ diff 經審、對齊舊 spec（欄數 8/27/7/12）、行尾策略未動、scope 乾淨 → **待推產品 repo** | commit `2417cfe`；引 `EPROIS_0922-t24.md:143/152/168/196/215/223/295/308` |
| **M3** submit mail enqueue | ✅ diff 經審、只補空清單 bug、async 架構未動 → **待推** | commit `49ebcb1`；引 `EPROIS_0922.md:139` |
| **M4** RECEIVED_DATE Finished-guard | ✅ diff 經審、另案「dataReturn 多寫 history」未動 → **待推** | commit `1d39e1d`；引 `EPROIS_0921.md:122/:145` |
> 三筆各自獨立 commit、`package` exit 0、**未 push**（待產品 repo 分支決策）。下一批 = Tier 2（M1 H 段整修、M8 E 段、M5/M6/M7/M9，逐位置對、審更細）。
>
> ⚠️ **build 環境發現（非本次修正引入）**：後端 Logback 測試設定硬編碼 `D:\temp\saveFile\log`，非 Windows/無 `D:` 環境會擋 build；Codex 以 `-Dlogging.api.path`/`-Dlogging.batch.path` 覆寫繞過。屬可攜性 smell，建議外部化該路徑（獨立 ops 項，不阻擋本批）。
> 處置記錄：本 triage 為撥貸驗證的綜合產出。修正/實作屬**獨立返工階段**，不在「程式補完」里程碑（該里程碑就撥貸部分已更正為未完成）。

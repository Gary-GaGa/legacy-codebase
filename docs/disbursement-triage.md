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

---
> 處置記錄：本 triage 為撥貸驗證的綜合產出。修正/實作屬**獨立返工階段**，不在「程式補完」里程碑（該里程碑就撥貸部分已更正為未完成）。

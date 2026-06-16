# Build Task — 撥貸 T24 G/H 段匯率欄名 typo 修（OQ-5 坐實 bug）

> 載具：Codex（後端；明確 typo 修，附舊系統+DB 鐵證）**或**交撥貸 domain。**獨立可做**——不依賴 A-1 換匯 stub（雖同在撥貸 authorize 鏈）。
> **來源**：`a1-oq-legacy-recon-findings.md` OQ-5（2026-06-16 審過）。

## 坐實的 bug
- 新 `funcIsuT24Authorize` 的 **T24 G/H 段讀 `disburDate["EXCHANGR_RATE"]`**（`SummaryServiceImpl:2221`、`:2285`）——**此欄在舊/新 schema、entity、DB psv 實查全部不存在**（拼字錯：少 E、`EXCHANGR`）→ 恆取空值。
- 舊系統 T24 G/H（`EPRO_IS0922:1063/1128`）讀 **`EX_RATE_BUY`**；新 entity 也只映射 `EX_RATE_BUY/EX_RATE_SELL`（`TBDisburDateEntity:66`）。
- 新 **E 段已正確**讀 `EX_RATE_BUY/EX_RATE_SELL`（`SummaryServiceImpl:2146`）——只有 G/H 打錯。

## 目標
T24 G/H 段改讀 **`EX_RATE_BUY`**（對等舊系統），讓非 USD 牌告匯率欄不再恆空。

## 鐵則
1. **只改 G/H 段的欄名** `EXCHANGR_RATE`→`EX_RATE_BUY`（`SummaryServiceImpl:2221`、`:2285` 一帶）；grep 確認無其他 `EXCHANGR_RATE` 殘留。
2. **E 段不動**（已對）；**A-1 換匯 stub 不碰**（另案）；其他 T24 段不誤動。
3. `mvn` build 綠；一 commit。
4. ⚠️ **撥貸 authorize 端到端仍待 A-1 stub 修**——本卡只修 G/H typo（即使修了,authorize 仍被 A-1 throw-stub 擋,需 A-1 一起才端到端通）。

## 回報
- diff（G/H 欄名）+ grep「無 `EXCHANGR_RATE` 殘留」證據 + `mvn` build 結果 + commit hash。

> 過了：T24 G/H 牌告匯率欄正確；回填 `a1-oq-legacy-recon-findings.md` OQ-5 標已修、`pending-register`/handoff §2.3 撥貸 T24 註記；併入撥貸 Phase D 端到端驗證（待 A-1）。

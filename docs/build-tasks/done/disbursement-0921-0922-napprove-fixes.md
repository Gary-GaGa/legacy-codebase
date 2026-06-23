# Build Task — 0921/0922 N 軸 Blocker 修正（Approved 前必修，2026-06-22）

> **來源**：2026-06-22 最終 Approved-gate N 軸驗證（多 model：opus A/B/F + sonnet C/D/E/G，per-page T1 全 A–G）。**兩頁皆 NOT Approvable**。在母資料夾修一輪 + 重跑 N 軸才能升 Approved。
> **載具**：母資料夾 Codex（改 SRS bundle `docs/specs/srs/EPROISU0921|0922/`；部分含 schema.sql 型別、openapi 錯誤碼）。**T1 金錢頁 → per-page checkpoint**：修完重跑 §4b 全 A–G、跨 model，不自升 approved。
> **權威**：`spec-architecture §5b`、`legacy-parity-sop`、Bible `bible-eproposal.md`。

## 信心分層（跨 run / 跨 model 對照，務必先看）
> 0921 C/D/E/G 跑了**兩次不同 run**,**結論有分歧**——修前先按信心處理,別把 disputed 當定案。

**高信心(多來源一致 / repo 內可直接驗,先修)**：
- **0921 facility/refinancing fee 計算缺**(opus F-1;PRD AC-007 要、SRS 無 Rn/欄/QA)。
- **SECURE_ATTRIBUTE 未 carry/disclaim**(0921+0922 兩頁、多 run 一致;severity 🟡~🔴)。
- **冪等 / 重複撥貸**(Bible 災難情境;0921 Finished 冪等、0922 four-eyes;多 run 一致)。
- **0922 Maker-Checker 四眼控制**(sonnet D-BLK-1;Bible 明令,單 run 但屬硬性安全控制)。
- **0921 stale CHECK_DATE 的 Finished 拒絕 QA 缺**(rerun G-13;與既有 R4/R6 一致)。

**Disputed(兩 run 不一致 → 先查證、別當 Blocker)**：
- **`DRAWDOWN_ACCOINT` 型別**：run-1 判「DATE 型別錯、應 VARCHAR2(25)」🔴;run-2 判「**legacy typo 刻意保留**,schema.sql:260-263 有 reconcile 註」🟢。→ **先查 DB 實際型別**再定(可能根本不是 bug)。
- **collproSize 超限具名錯誤碼**：run-1 判缺碼 🔴;run-2 判「一般 400 path 已蓋、PRD 未要求具名碼」🟢。→ 看是否要具名碼,非硬 Blocker。

**結論**：兩頁仍 **NOT Approvable**(高信心項足以擋 Approved),但 0921 的 DRAWDOWN/collproSize **先查證、不要照單全改**。

## ⚠️ 跨頁系統性（兩頁一起修）
1. **`SECURE_ATTRIBUTE` 未 carry/disclaim**（D 軸；0921+0922）：Bible（`bible-eproposal.md:230,326`）列為有擔/無擔授權判據。每頁須在 Rn 或 DB delta **明確 carry（怎麼用/驗）或 disclaim（為何 0921/0922 不分流，附理由）**，不可只在 schema 靜默帶欄。
2. **重複撥貸 / 冪等**（Bible 災難情境 `bible-eproposal.md:463`「TLOD Maker/Checker 控制失效、重複撥貸」）：兩頁都缺金錢 mutation 的冪等/重送防護。

## EPROISU0922（撥貸 Summary/authorize/T24）— 2 Blocker（A/B/F 已綠）
1. 🔴 **Maker-Checker 四眼控制**：`epl-case-isu-summary-auth` 須 BE 強制「授權的 Checker ≠ submit 的 Maker」（`caller.empId == TB_LON_SUMMARY_INFO.CURRENT_USER_ID`〔submit 當下〕→ reject + named 錯誤碼）。加 Rn（R5/R8 子規則）+ QA（自送自核被擋）。據 `bible-eproposal.md:79,306,463`。
2. 🔴 **SECURE_ATTRIBUTE**（見系統性 #1）：加 DB-D13 或擴 DB-D1，carry 或 disclaim。
- 🟡 advisory：T24 result 500 具名錯誤碼（`openapi.yaml:114`）；authorize state=25 前置明寫進 R5；`TB_API_AUTH` seed rows 列舉；`TB_T24_MAIN/CO_BORROWER_INFO`、`TB_LOAN_CONDITION_DETAIL` 補 DB-Dn 列；R4/R11 補 edge QA。

## EPROISU0921（撥貸 Data Input）— 4 Blocker
1. 🔴 **facility/refinancing fee 計算缺**：PRD AC-007「facility fee = loan amount × FEE_1」。補 Rn（計算來源/FEE_1 provenance/rounding mode/BE 權威）+ openapi 欄（`facilityFee`/`refinancingFee`）+ QA（值/精度/rounding）。schema 已有 `FACILITY_FEE`/`REFINANCING_FEE NUMBER(17,2)`（`schema.sql:44-45`）。
2. 🔴 **`DRAWDOWN_ACCOINT` 型別錯**：`schema.sql:39` 宣告 `DATE`,應 `VARCHAR2(25)`（存帳號文字,對齊 DB-D7/openapi `drawdownAccount` string 25）。**兩 agent 都抓到＝高信心**。
3. 🔴 **collproSize 超限錯誤碼缺**：R10/QA-025 有「>5 拒絕」規則,但 `openapi.yaml:252-299` enum/`SaveValidationError` 無對應碼。補 named 碼（如 `EPROISU0921_COLL_OVER_LIMIT`,HTTP 400）。
4. 🔴 **Finished 冪等**（見系統性 #2）：`isFinish=Y` 重送（雙擊/重試）須 BE 偵測 already-finished（`EPORIS_0921=Y`）並拒絕/no-op,防重複 RECEIVED_DATE/金錢 mutation。加 Rn + QA。
- 🟡 advisory：SECURE_ATTRIBUTE/LON_ATTRIBUTE disclaim（個金-only guard）；`EPROIS0923_*` 錯誤碼用在 0921 端點（命名/provenance）；`TB_DISBUR_DATE` schema 補 `LAW_FIRM_AMOUNT_01/02/03/90`；money 欄非負驗證；QA-025 拆三情境；CIF-changed staleness QA。

## 修正 prompt（貼母資料夾 Codex）
```
任務：修 EPROISU0921 + EPROISU0922 SRS bundle 的 N 軸 Blocker（見本卡），改完重跑 §4b 全 A–G N 軸（跨 model、per-page checkpoint），不自升 approved。
逐項：
- 系統性：兩頁 SECURE_ATTRIBUTE carry-or-disclaim；重複撥貸/冪等防護（0922 四眼控制、0921 Finished 冪等）。
- 0922：①authorize 四眼控制 Rn+QA（Checker≠Maker，據 bible:79/306/463）②SECURE_ATTRIBUTE DB-Dn。
- 0921：①facility/refinancing fee 計算 Rn+openapi 欄+QA（loan×FEE_1，附 rounding/BE 權威）②schema DRAWDOWN_ACCOINT DATE→VARCHAR2(25)③collproSize 超限 named 錯誤碼④Finished 冪等 Rn+QA。
每項附 file:line + 三判；金錢/授權欄 BE 權威。修完：check-srs-bundle 兩頁 exit 0；§4b 全 A–G 無 Blocker；回填 pending-register/decisions。
回報：逐 Blocker 修法 + gate/N 軸結果。
```

## Done 條件
- 兩頁 N 軸（全 A–G、跨 model）無 Blocker；`check-srs-bundle` exit 0；owner stamp → Approved（覆蓋 2→4/67）。本卡移 `done/`。

# QA cases — EPROC00118 c0 Corporate Scorecard（QA → RD 邊界，DoD 閘門 4 + 5）

> 每條 case = **可跑驗收測試**（產品專案落成 API-層 integration test）。
> 每條標 `covers: Rn`（對 `spec.md`）→ **覆蓋率＝閘門 5**：spec 每個 `Rn` 至少一條 case，否則 FAIL。
> `@PENDING` = 未決 / escalation（顯性紅燈，不埋 doc）。
> ⚠️ 具體資料為示意；實作時用 i0 真實案例校準預期值。

## 覆蓋率對表（閘門 5）
| 規則 | cases |
|---|---|
| R1 calc=funcGetRate | QA1 |
| R2 save 寫 TB_CORP_SCRCARD | QA7 |
| R3 checkpoint Cs/Cu | QA3, QA4, QA5 |
| R4 crScoreCardCompleted 第2碼 | QA6 |
| R5 loanDefDayFlag=Y | QA2 |
| R6 sele 清單 | QA9 |
| R7 info AO/CR map | QA8 |
| R8-PENDING CU return | QA10 `@PENDING` |
| R9-PENDING crScoreCardCompleted 整欄覆寫 | QA11 `@PENDING` |
→ R1–R7 全綠才放行；R8/R9 為已知 PENDING（不阻擋本頁，但必須顯性存在，待 CreditEval owner）。

---

```gherkin
# covers: R1
Scenario: QA1 calc 走 funcGetRate 算出 riskLevel
  Given 一個 applicationNo 有完整 22 個評分欄位（B_V1..B_V22）
  When POST /epl-calc-c0-corporateScorecard
  Then data.riskLevel 等於 funcGetRate 對該 totalScore 用 COR_RISK_LV 查得的值
  And data.scoreDatetime 非空
  # 反作弊：c0 不得自算；應與 i0 calc 同輸入同輸出（用同一筆比對）

# covers: R5
Scenario: QA2 loanDefDayFlag=Y 走 Default / -1 score
  Given applicationNo 的 loanDefDayFlag = "Y"
  When POST /epl-calc-c0-corporateScorecard
  Then 計分走 Default、score = -1，且仍呼叫 funcGetRate（行為照 i0，不裁剪）

# covers: R3
Scenario: QA3 save CS 案件 isFinish=true → checkpoint 'N'
  Given lonAttribute+secureAttribute 判定為 CS
  When POST /epl-save-c0-corporateScorecard，isFinish=true
  Then TB_CHECK_POINTS_CS.EPROC00118 = 'N'
  And TB_CHECK_POINTS_CU 未被寫

# covers: R3
Scenario: QA4 save CS 案件 isFinish=false → checkpoint 'Y'
  Given 判定為 CS
  When POST /epl-save-c0-corporateScorecard，isFinish=false
  Then TB_CHECK_POINTS_CS.EPROC00118 = 'Y'

# covers: R3
Scenario: QA5 save CU 案件 → 寫 CU 表（非 CS）
  Given lonAttribute+secureAttribute 判定為 CU
  When POST /epl-save-c0-corporateScorecard，isFinish=true
  Then TB_CHECK_POINTS_CU.EPROC00118 = 'N'
  And TB_CHECK_POINTS_CS 未被寫
  # 反 i0 單條件：不可用 secureAttribute=="S" 判斷

# covers: R4
Scenario: QA6 save 只改 crScoreCardCompleted 第 2 碼
  Given TB_CORP_SCRCARD.CR_SCORE_CARD_COMPLETED 既有值第 1 碼為 X
  When POST /epl-save-c0-corporateScorecard（isFinish 決定第 2 碼 Y/N）
  Then 第 1 碼仍為 X（00114 管），只有第 2 碼被更新

# covers: R2
Scenario: QA7 save 寫回 TB_CORP_SCRCARD（AO/CR + Default 特例）
  When POST /epl-save-c0-corporateScorecard
  Then TB_CORP_SCRCARD 對應欄位被寫入，Default 特例與 i0 一致

# covers: R7
Scenario: QA8 info 回填 AO/CR map
  Given applicationNo 已有評分資料
  When POST /epl-info-c0-corporateScorecard
  Then data 含 AO map 與 CR map，欄位與 i0 一致

# covers: R6
Scenario: QA9 sele 回評分參數 / 下拉清單
  When POST /epl-sele-c0-corporateScorecard-list
  Then data.items 為該 applicationDate 的評分參數清單

# covers: R8-PENDING  @PENDING
Scenario: QA10 CU 案件 return(98) 後 checkpoint 應正確
  Given 一個 CU 案件已完成 00118 評分
  When 既有 CsuCreditEvalAndCreditDecisionServiceImpl 走 Return(98)
  Then TB_CHECK_POINTS_CU.EPROC00118 應被重設為 'Y'
  # 目前既有碼硬編碼只清 CS（:2985）→ 此 case 預期 FAIL，標 @PENDING；
  # 待確認 CU 是否真走到 00118，再決定是否授權改既有 service（見 page-mapping §2B escalation）。

# covers: R9-PENDING  @PENDING
Scenario: QA11 crScoreCardCompleted 兩碼契約不被整欄覆寫
  Given 00114 已設第1碼、00118 已設第2碼（crScoreCardCompleted 應為兩碼各自值）
  When 既有 CsuCreditEvalAndCreditDecisionServiceImpl 走信用決策步驟（:2890）
  Then crScoreCardCompleted 兩碼應各自保留
  # 既有碼會整欄覆寫成 "NN"（:2890）→ 此 case 預期 FAIL，標 @PENDING；
  # 00118 本身鏡像 i0 正確（只動第2碼）；待 CreditEval owner 確認覆寫 intended/bug + Y/N 語意（見 page-mapping §2B escalation）。
```

# Build Task — Phase G:企金主流程 FE 後半段補建（EPROCSU0150–0173 + 3 popup）

> 載具：Codex（前端）。**依據＝audit F-1/DIFF-001**（`refactor-audit/diff-vs-inventory.md`；逐列證據＝`refactor-audit/M4-cs.md`/`M5-cu.md`）：六頁＋3 popup FE 全缺、**BE `Csu*Controller` 全在**——本卡只補 FE。
> 鏡像來源＝individual 對應頁（Phase F 同型工法）；舊畫面結構＝`docs/legacy/module-cs-cu-shell.md`＋舊 cs/cu JSP。
> **落地**：一頁一 commit、`ng build` 綠、報 diff 等審（Phase F 慣例）。

## 範圍內（IN）— 逐頁
| # | 新頁 | 鏡像來源（individual）| 對接 BE（endpoint 名以 audit 列／新碼 controller 為準）|
|---|---|---|---|
| G1（pilot）| `EPROCSU0160` Loan Condition＋`0261` approved-case popup | `loan-condition`＋approved-case | `epl-info/save-csu-loan-condition`＋approved-case APIs（`CsuLoanConditionController`）|
| G2 | `EPROCSU0150` Collateral——**企金特有內層 3 tab（Info/Valuation/Site Visit）**，照舊 JSP 結構（`module-cs-cu-shell.md`）非照 isu 單層 | `collateral` | `epl-info-csu-coll`、`epl-save-csu-coll`（`CsuCollateralController`）|
| G3 | `EPROCSU0170` Credit Eval & Decision＋`0174` return／`0175` cancel popup | `credit-evaluation-and-credit-decision` | `epl-info/save-csu-cr-dec`（＋`-retu`/`-cancel`/`-del-retu`）（`CsuCreditEvalAndCreditDecisionController`）|
| G4 | `EPROCSU0171` Loan Committee Conclusion | `loan-committee` | `epl-info/save-csu-loan-committee` |
| G5 | `EPROCSU0172` Approved Loan Condition | `approved-loan-condition` | `epl-info-csu-app-loan-cond` |
| G6 | `EPROCSU0173` Credit Evaluation Old | `credit-evaluation-old` | `epl-info-csu-cr-eval-old` |

每頁固定動作：① `page-code.model.ts` 補 `EPROCSU01xx` enum＋corporate routing 註冊 ② component/service 照 isu 鏡像、改 csu endpoint＋corporate DTO（**DTO 形狀以 `Csu*Controller` request/response 為準，勿沿用 isu DTO 假設**）③ shell pageMap 可見性核對。

## 範圍外（OUT）
- c0 評分頁（Phase F 已收）、`collateral-provider-info`（已在）、`EPROCSU0110/0120/0130`（已在）。
- 檔案上傳 API（⏸ 暫緩 track）：0150 上傳區**鏡像 isu 現狀**（同樣 ⏸），不自行設計。
- R2 列印/報表（0172 列印 ⏸）。

## 鐵則
1. **return/cancel dialog 是共用元件且現只接 ISU endpoint**（audit M4 列證據）：改造方式＝**參數化（caseType→endpoint 組）或建 csu 變體**，二擇一；**isu 既有行為一個都不准變**（改完 isu 路徑回歸自測）。
2. endpoint/DTO 一律以新碼 controller 為準；與本卡表不符→以碼為準並回報差異。
3. 一頁一 commit（pilot G1 先行、等審 OK 再放大）；每 commit `ng build` 綠＋guard scan。
4. 產品 repo 後端**一行不改**。

## Tasks（checklist——session 中斷在此記斷點續跑，勿靠 compact 記憶）
- [x] G1 `EPROCSU0160`＋`0261` popup（✅ 審過 06-12，product `809d25d`；CSU popup 變體、ISU 零修改）
- [x] G2 `EPROCSU0150`（三 tab）（✅ 審過 06-12，product `14b254e`；Info/Valuation/Site Visit 三 mat-tab、上傳區守 ⏸ 現狀、BE 零改）
- [x] G3 `EPROCSU0170`＋`0174`/`0175` popup（✅ 06-12：return dialog endpointConfig 參數化、cancel popup CSU 變體；actual controller routes 含 sele/upload/del-file/submit/info/save/retu/cancel/del-retu）
- [ ] G4 `EPROCSU0171`
- [ ] G5 `EPROCSU0172`
- [ ] G6 `EPROCSU0173`
- 斷點：續跑 G4 `EPROCSU0171`。Phase V 待測：G1 載入/save/finish、approved-case popup view/save/update、total amount 更新、ISU loan-condition popup 回歸；G3 載入/dropdown/save/submit/upload/delete-file/return/cancel/delete-return、suggested additional conditions confirm 後保存、LC/LLC/Reject action-specific validation、ISU return dialog 回歸、CSU LLC 檔案下載（controller 目前無 CSU download route，勿猜 endpoint）、CSU Credit Proposal report 下載（目前沿用既有 `epl-ppdf-isu-credit-proposal-report` 共用 report endpoint）、`cgccGuarantee` 條件顯示回歸。

## 回報
- 每頁 commit hash＋落點；dialog 改造方式一句＋「isu 行為未變」聲明;G2 三 tab 結構截點;**更新上方 Tasks 勾選/斷點**。
- `ng build` 結果;Phase V 待測清單（整合驗證歸 Phase V）。

> 過了：企金案件可走完 collateral→loan condition→credit eval→LC→approved→old eval 全流程;回填 `feature-inventory.md` §2B＋§4①b;本卡進 `done/`。

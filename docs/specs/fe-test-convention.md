# FE 測試約定（Playwright e2e；QA flow 第三層）

> **問題**：QA flow 要測 DB+BE+FE,但 FE 層**原本零自動化**（`phase-v-api-selfverify-harness.md:10` 標「Playwright 類＝另案」）。這份定 **qa-case → FE e2e** 的對映,補上第三層。
> ⚠️ **真測試碼在外部產品 repo**（前端 Angular）;本檔是約定,落在 `qa-codex-dispatch` + 產品 repo。
> 關聯：`qa-to-test.md`（DB/BE 層對映)、`qa-report-format.md`（結果回報)、`frontend/AGENTS.md`（FE 實作鐵則)。

## 1. 工具：Playwright（推薦)
- **為何 Playwright 非 Cypress**：多瀏覽器、原生平行、trace viewer、API+UI 混合測（可在 e2e 內直打 BE 驗 DB）、對 Angular 友善。
- 一個 funcId 一個 spec 檔 `<funcId>.spec.ts`；case 逐一成 `test('qa_<nnn>_<slug>', ...)`，標 `covers Rn`（雙向追溯延伸到 e2e）。
- 跑法：`npx playwright test`（CI 可 headless + trace on-failure)；前置＝`start-local` 起 FE+BE（`local-phase-v-bringup.md`)。

## 2. 哪些 case 走 FE 層（依強制點）
| case 性質 | 測哪層 |
|---|---|
| 強制點 **FE** / **both** 的**畫面行為**（form 驗證提示、dialog 彈出、按鈕顯隱、i18n 語系切換、角色顯示分支） | **FE（Playwright）** |
| 強制點 **BE** 的完整性/安全 | 不在 FE 測（BE 層測 + 繞 FE negative）;FE 只測「UX 有擋」非「安全靠 FE」 |
| 純資料落庫 / 計算 | DB+BE 層,FE 不重複 |
- **強制點 FE-block 的雙驗**：FE 測「UI 擋住」(Playwright) **+** BE 測「繞過 FE 直打端點仍被擋」(BE 層)。**FE 綠 ≠ 安全**——安全永遠 BE 權威（`spec-architecture §5.5`)。

## 3. 對映（一條 FE case = 一個 e2e test）
| qa-case 欄位 | → Playwright 結構 |
|---|---|
| QA-nnn + 描述 | `test('qa_<nnn>_<slug>')` + comment `covers Rn` |
| Given（前置） | **arrange**：登入拿 JWT（test 帳號)、導到該頁、必要時經 API 預置案件資料（seed) |
| When（動作） | **act**：Playwright 操作（fill/click/select/切語系) |
| Then（預期） | **assert**：`expect(locator)` 對畫面狀態（可見/文字/disabled/dialog) + 必要時 API/DB 後置驗 |
| DB 驗證點 | 若該 case 也要驗落庫 → e2e 內呼叫 BE 或交 DB 層測（避免 FE 測重做 DB 斷言) |

## 4. selector / 長相權威 = Adobe XD 設計規格
- **selector 來源＝設計規格 + 既有 component**（`data-testid` 優先;無則語意 role/label)。**AI 不臆測像素/座標**（`frontend/AGENTS.md`)。
- i18n：用 key 對照表斷言文字(zh_TW / en_US),不寫死中文字串比對(避免語系切換漏測)。
- RWD/視覺像素級回歸＝**人審 + XD 對照**,非本層（Playwright 測行為,不替代視覺審）。

## 5. 讓 case「FE-test-ready」（回 SRS/qa-cases 寫法）
- **When 對得到 UI 操作**：寫到「點哪個鈕/填哪欄/切哪語系」,非只「使用者操作」。
- **Then 有可斷言畫面狀態**：「dialog 出現且含 X 訊息」「Finished 鈕 disabled」,非只「正確顯示」。
- 強制點 FE/both 的 case 才需 FE oracle;純後端 case 不硬塞 FE 測。

## 6. 結果回報
- 每 e2e → `qa-report-format.md` 逐案表的 `層=FE` 列;PASS/FAIL/SKIP + 證據（`spec.ts:line` + screenshot/trace ref)。
- FAIL 分類同 QA flow：impl-gap（畫面沒做到)→回 RD;oracle-spec（case/設計錯)→回 SRS。

## 7. 現況（誠實）
- **FE 自動測＝本次 QA flow 新增層**,零基礎起步 → 首跑 pilot＝**00118**（先驗 form 驗證/dialog/i18n 三類最小集)。
- 撥貸 T24 等外部整合、R2 報表 PDF 畫面 → 本機/e2e 測不到,標 deferred 納 UAT（同 `local-phase-v-bringup` 限制矩陣)。
- 成熟前,FE 層在報告標「Playwright 覆蓋中」,未覆蓋的 FE 行為列剩餘風險,不假裝全測。

---
> 關聯：`docs/specs/qa-to-test.md`（三層全貌)、`docs/build-tasks/qa-codex-dispatch.md`（產測試 prompt)、`docs/build-tasks/local-phase-v-bringup.md`（起服務 + 護欄)。

# QA dispatch prompt（給 Codex；code(rd-done) → 三層測試 + 報告）

> **用法**：母資料夾（產品碼 + 規劃 repo 可讀 + 可跑 Testcontainers/Playwright + dev/uat DB 可達）開 Codex。下方 prompt＝**單頁測試單元**（填 `<funcId>`）；接 `qa-cases.md` → 產三層測試 → 跑 → 出測試報告清單 → 回填 ledger。
> **批量＝drain**：規模化由 QA orchestrator（`orchestration-playbook §5d/§6d`）驅動，序列逐頁，drain 到所有 `qa-ready`→`qa-passed`。
> **權威**：迴圈＝`§5d`；QA 軸＝`§4d`；case→測試對映＝`docs/specs/qa-to-test.md`；FE e2e＝`docs/specs/fe-test-convention.md`；報告格式＝`docs/specs/qa-report-format.md`；harness 範式＝`build-tasks/done/B-boundary-gate-plumbing.md`、`phase-v-*`。
> **在哪跑**：母資料夾 Codex（本 planning repo 無源碼/DB、跑不了）。

## 入口閘（不過不收）
- 該 funcId ledger status=`qa-ready`（前置＝`rd-done`、build 綠）。build 紅 → 拒收、回報。

## 測試輸入
| 來源 | 用途 |
|---|---|
| `srs/<funcId>/qa-cases.md` | 逐條 case（Given/When/Then + DB 驗證點 + covers Rn）＝測試清單 |
| `srs/<funcId>/schema.sql` | Testcontainers 建表來源（DB 層） |
| `srs/<funcId>/openapi.yaml` | endpoint/method/DTO（BE 層 act + assert） |
| `srs/<funcId>/spec.md` | 強制點 FE/BE/both（決定哪層測、要不要繞 FE negative） |
| Adobe XD 設計規格 | FE selector/長相權威（FE 層；AI 不臆測像素） |

---

## ⬇️ 複製以下給 Codex（一次一頁）

```
任務：把 funcId <funcId> 的 qa-cases 變三層可跑測試並執行，出測試報告清單（QA-Agent，gate④）。
對映規則＝docs/specs/qa-to-test.md；FE＝docs/specs/fe-test-convention.md；報告＝docs/specs/qa-report-format.md。

【入口閘】確認 ledger 該頁 status=qa-ready（rd-done + build 綠）。否則停、回報。

【產三層測試（每條非-@PENDING case → 測試；@PENDING case → @Disabled("待 TBD-xxx") skeleton）】
依該 case 的「When 對到的 endpoint」與「強制點」決定測哪層（可多層）：
- DB 層：Testcontainers gvenzl/oracle-xe → 用 bundle schema.sql 建 TB_* → 依 Given seed 列
  （含該 endpoint 授權檢查要的列，測試自備、不依賴 ops 套 OVSLXLON02）→ act → assert「DB 驗證點」
  （表/欄/期望值逐項）。整合類（rollback 等）標 tag。
- BE 層：呼叫真 epl-* endpoint（method 依 openapi）→ assert response code/message/data 對 openapi
  + DB 後置斷言。強制點 BE/both 的 case → 必含「繞過 FE 直打端點」的 negative（驗 BE 權威擋）。
- FE 層（Playwright，依 fe-test-convention.md）：強制點 FE/both 的行為 → e2e 測 form 驗證 / dialog /
  i18n 語系切換 / 角色顯示分支；selector 來源＝Adobe XD 設計規格，不臆測像素。
測試名 qa_<nnn>_<slug>、@DisplayName/註記標 covers Rn（雙向追溯）。happy/error/edge 各測到 Rn 精神。

【跑 + 機械閘門（blocking）】
- 跑三層測試套件。④ QA 驗收＝三層測試綠；⑤ 覆蓋率＝python scripts/check-srs-bundle.py
  docs/specs/srs/<funcId> 的 gate⑤（每非-pending Rn ≥1 case）exit 0。
- 不得把假綠當完成：有紅如實列、不跳過、不改 oracle 遷就實作（spec/qa 是權威）。

【QA 軸（§4d Q1–Q5；跨模型、各 read-only）】
Q1 覆蓋完整性／Q2 oracle 真確（紅燈分 impl-gap vs oracle-spec 錯）／Q3 三層齊備／
Q4 環境隔離／Q5 報告忠實。各回 PASS/Blocker → 採納修正後再審一輪。
每軸 {提出/真/誤報} 回填 docs/process/n-axis-findings-ledger.md（stage 標 QA）。

【產測試報告清單（docs/specs/qa-report-format.md）】
- 逐案表：QA-id | covers Rn | 層(DB/BE/FE) | 型(happy/error/edge) | 結果(PASS/FAIL/SKIP-deferred) | 證據(file:line / SELECT 結果 / screenshot ref)。
- Rollup：Rn 覆蓋率% / 三層各覆蓋數 / PASS·FAIL·SKIP 計數 / @PENDING-disabled 數 / 剩餘風險 / FAIL 分類(impl-gap vs oracle-spec)。
- 報告本體存產品 repo 測試輸出；摘要回填 planning repo ledger。

【紅燈分類處置（不自決 spec）】
- impl-gap（實作沒做到 spec）→ 標明、該頁回 RD（ledger status=rd-ready 重排），不自己改 code 邏輯硬過。
- oracle/spec 錯（測試/規格本身錯）→ 標明、回 SRS（不自改 spec.md/qa-cases.md，等人裁）。
- 測試環境問題（容器/DB/帳號）→ blocked，不算 FAIL。

【回填 + 停】
- 達標（④⑤ 綠 + QA 軸無 Blocker + 報告產出）→ ledger status=qa-passed、填 report 路徑。
- 不自宣 Done：終點＝qa-passed；最終 done 由 owner 審報告後蓋章。
- T1 頁 → 停此交 owner 審報告，不自動接下一頁。
- context 衛生：每 sub-task 獨立 session，主控只收 PASS/FAIL/路徑。

【回報格式】
- funcId + 報告路徑 + 三層測試檔路徑。
- ④⑤ 機械閘門：exit code / 綠。
- QA 軸：每軸一行（PASS / Blocker+file:line）+ 採納修正。
- Rollup 數據一行（PASS/FAIL/SKIP、覆蓋率、三層覆蓋）。
- FAIL 清單 + 分類（impl-gap / oracle-spec / env）。
- 一句：qa-passed 是否守住（不假綠/不改 oracle 遷就實作/三層齊/不自宣 Done）。
```

---

## 備註
- **三層按強制點施測**：強制點 BE/both → DB+BE（含繞 FE negative）；FE/both → 加 Playwright；純 FE 行為（顯示/驗證 UX）→ Playwright。一層都不該漏該測的（QA 軸 Q3）。
- **Testcontainers 自 seed → 不卡 ops**：c0 endpoint 共享 DB 未套授權會 403，但 Testcontainers 自建 DB+自 seed 授權列繞過（`phase-v` 共享 DB 路線另計）。
- **FE 是新增層**：Playwright 約定見 `fe-test-convention.md`；首跑 pilot＝00118。
- **terminal＝qa-passed**，交 DoD 閘門牆 + owner；最終 Done owner 蓋章。
- 卡歸檔 `done/`：本批 drain 跑完、回填完成後移。

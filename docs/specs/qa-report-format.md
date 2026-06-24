# 測試報告清單格式（QA flow 產物；gate④ 的可見輸出）

> **問題**：QA flow 跑完三層測試後要「提交測試報告清單，列出完成的數據」。這份定**報告的標準格式**，讓 owner 一眼看完成度+剩餘風險，並回填 ledger。
> ⚠️ **報告本體產在產品 repo**（測試輸出旁）；**摘要回填 planning repo**（ledger + feature-inventory）。本檔是格式約定。
> 關聯：產出規則＝`qa-codex-dispatch.md`／`orchestration-playbook §5d`；對映＝`qa-to-test.md`；FE＝`fe-test-convention.md`。

## 1. 一頁一份；兩部分（逐案表 + Rollup）

報告檔名 `qa-report-<funcId>.md`（+ 機器可讀 `qa-report-<funcId>.json` 供 dashboard/CI）。

### 1.1 逐案表（一條 case = 一列）
| QA-id | covers Rn | 層 | 型 | 結果 | 證據 |
|---|---|---|---|---|---|
| QA-001 | R1 | BE | happy | PASS | `CorpScorecardApiTest.java:42`；resp 200 + `TB_CORP_SCRCARD` 1 列 |
| QA-031A | R8 | BE | error | PASS | 拒 decimal `curRatio`、DB 無寫入 |
| QA-026 | R7 | DB | happy | PASS | `TB_CHECK_POINTS_CS.EPROC00118` 更新、parent 未誤標 done |
| QA-040 | R5 | FE | edge | FAIL | dialog 未出現；`scorecard.spec.ts:88`；分類=impl-gap |
| QA-012 | R9 | DB | edge | SKIP-deferred | rollback 整合測、納 Phase V |
| QA-P02 | R12 | — | — | SKIP-@PENDING | `@Disabled("待 TBD-...")` |

- **層**＝DB / BE / FE（一條 case 可拆多列，若多層驗）。
- **型**＝happy / error / edge。
- **結果**＝`PASS` / `FAIL` / `SKIP-deferred`（整合測待 Phase V）/ `SKIP-@PENDING`（TBD 未關）。
- **證據**＝測試 `file:line` + 關鍵斷言（resp code / SELECT 結果 / screenshot ref）；不貼大段 log。

### 1.2 Rollup（願景「列出完成的數據」）
```
funcId: EPROC00118    report-date: <stamp>    against-commit: <hash>
規則覆蓋：Rn 總數 N，有 ≥1 PASS test 的 Rn = M（覆蓋率 M/N = __%）
三層覆蓋：DB __ 條 / BE __ 條 / FE __ 條
結果計數：PASS __ / FAIL __ / SKIP-deferred __ / SKIP-@PENDING __
FAIL 分類：impl-gap __（回 RD）｜oracle-spec __（回 SRS）｜env __（blocked）
剩餘風險：<逐條，含 deferred 整合測、未覆蓋分支、@PENDING 對應未測>
```

## 2. 判定（QA flow 何時算 qa-passed）
- `qa-passed` 條件：**無 `FAIL`**（impl-gap/oracle-spec 都算未過）＋ 機械 ④三層綠 ⑤覆蓋率 exit 0 ＋ QA 軸（§4d）無 Blocker。
- `SKIP-deferred`/`SKIP-@PENDING` **不擋 qa-passed**，但**必須列進剩餘風險**（不可灌水成「全過」）。
- 有 `FAIL` → 不 qa-passed：按分類回流（impl-gap→RD／oracle-spec→SRS／env→blocked）。

## 3. 回填（traceability 回路收尾）
- ledger（`per-page-reinventory-matrix`）：該頁 `status=qa-passed`、`report` 欄填報告路徑。
- `feature-inventory`：覆蓋計數 / 測試通過數由報告 Rollup 衍生（勿手算另記）。
- 雙向追溯：報告每列 QA-id ↔ qa-cases.md ↔ 測試碼 `qa_<nnn>` ↔ covers Rn ↔ spec。

## 4. 誠實鐵則（防假綠）
- `SKIP` 一律標明原因（deferred / @PENDING），**不可當 PASS 計入覆蓋率**。
- `FAIL` 不得改 oracle/spec 遷就實作來「轉綠」（那是竄改權威）；FAIL 就是 FAIL，分類回流。
- Rollup 數據必須與逐案表一致（QA 軸 Q5 報告忠實會查）。
- against-commit 必填（報告綁定當時 code 版本，重測要更新）。

---
> 與 `docs/process/n-axis-findings-ledger.md` 區別：那記「審查（SRS N 軸 / QA 軸）品質度量」；本報告記「測試執行結果」。兩者都餵後續決策、不互相取代。

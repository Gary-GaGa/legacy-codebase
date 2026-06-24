# QA cases → 可跑測試（gate ④ 橋接約定）

> **問題**：`qa-cases.md` 是 Given/When/Then **散文**，但 flow gate ④ 要「**跑** QA cases」。這份定**散文→可跑測試**的對映，讓 ④ 從北極星變成可操作。
> ⚠️ **真測試碼在外部產品 repo**（本規劃 repo 只放 spec/約定）；本檔是「RD 把 case 變測試」的規則，落在 build-tasks 任務單 + 產品 repo。

## 1. 對映（一條 case = 一個測試）
| qa-case 欄位 | → 測試結構 |
|---|---|
| `QA-nnn` + 短描述 | 測試名 `qa_<nnn>_<slug>`（可追溯回 case） |
| `covers: Rn` | 測試註記 `@DisplayName`/comment 標 `covers Rn`（雙向追溯延伸到測試） |
| **Given**（前置） | **arrange**：用 `schema.sql` 建表 + seed 該 case 的列；設 request/auth 狀態 |
| **When**（動作） | **act**：呼叫該頁的真實 `epl-*` endpoint（method 依 openapi） |
| **Then**（預期） | **assert**：response（code/message/data 對 openapi）+ **DB 驗證點**逐項斷言 |
| `DB 驗證點` 欄 | assert 的資料層斷言來源（哪張表、哪些列/欄應變成什麼） |

## 1b. 三層測試（DB / BE / FE；依強制點分派）
> QA flow 願景＝測 DB+BE+FE。一條 case 依其 endpoint 與**強制點 FE/BE/both** 決定測哪層（可多層）：

| 層 | 測什麼 | harness | 對映/約定 |
|---|---|---|---|
| **DB** | seed→act→DB 驗證點逐項斷言（副作用、落庫正確） | Testcontainers `gvenzl/oracle-xe`（自 seed 含授權列、不卡 ops） | 本檔 §1/§2 |
| **BE** | 真 `epl-*` endpoint(method 依 openapi)→ response + DB 後置;**強制點 BE/both → 繞 FE 直打 negative**(驗 BE 權威擋) | Phase V API 自驗 harness 形狀（`phase-v-api-selfverify-harness.md`） | 本檔 §1/§2 |
| **FE** | form 驗證/dialog/i18n/角色顯示分支;強制點 FE-block 的 UI 擋(配 BE negative 雙驗) | **Playwright e2e**(新層) | `docs/specs/fe-test-convention.md` |

- **強制點是分派鍵**：完整性/安全＝BE 權威必測(+繞 FE negative);畫面行為＝FE 測;落庫＝DB 測。一層都不漏該測的(QA 軸 §4d Q3)。
- 三層結果統一進**測試報告清單**（`docs/specs/qa-report-format.md`：逐案 PASS/FAIL/SKIP + Rollup 數據）。

## 2. 測試 harness（產品 repo）
- **Testcontainers `gvenzl/oracle-xe`**（跑得動 `@Query(nativeQuery=true)`；見 `build-tasks/done/B-boundary-gate-plumbing.md`）。
- **建表來源＝該 bundle 的 `schema.sql`**（Flyway / 啟動 script 建 `TB_*`）→ schema 與 SRS 同源、gate② 已驗型別長度。
- 一個 funcId 一個測試類，case 逐一成測試方法。

## 3. 生成規則（RD / build-task）
- **每條非-@PENDING case** → 生一個測試（gate⑤ 已保證每個非-pending `Rn` ≥1 case）。
- **`@PENDING` case** → 產 `@Disabled("待 TBD-xxx")` skeleton（TBD 關閉即啟用，呼應 escalation＝pending test）。
- **deferred-to-DB**（需真 DB 的整合測，如 rollback `QA-012`）→ 標 tag，納 **Phase V** 跑，不擋單元層 build。
- 測試**斷言對 `Rn` 的精神**（非只 happy path）：happy/error/edge 各有測（DoD 已要求）。

## 4. 讓 case「test-ready」（回到 SRS 寫法）
寫 `qa-cases.md` 時每條就要可生測試（已寫進 `prd-to-srs` skill）：
- **Given 明確到可 seed**：哪張表、哪幾列、關鍵欄值（別只寫「案件有資料」）。
- **When 對得到 endpoint**：對到 openapi 的某 `epl-*` + method。
- **Then 有機器可斷言的 DB 驗證點**：表/欄/期望值（別只寫「正確」）。

## 5. 現況（誠實）
- **目前 ④ ＝半自動**：controller test + static scan 覆蓋部分（如 00800 `QA-013/014/016/017`），整合類 `QA-012` deferred-to-DB。
- **目標**：上述對映成為 build-task 標準產出（「為每條非-@PENDING case 生測試」），gate④ 才真正 deterministic。
- 在那之前，gate④ 在圖上標 **advisory→deterministic 過渡**；`feature-inventory` 的 Phase V 收整合測。
- **編排化（QA flow）**：上述「為每條 case 生三層測試 + 跑 + 出報告」由 **QA Agent Flow** 驅動（`orchestration-playbook §5d/§6d`、運行殼 `qa-orchestrator-drain.md`、單頁 `qa-codex-dispatch.md`）→ gate④ 對該頁變 deterministic。**FE 層**（Playwright）為本輪新增（`fe-test-convention.md`）。首跑 pilot＝00118。

---
> 關聯：`spec-architecture.md`（行為 vs 長相、強制點）；`assets/ai-workflow.mmd` gate④；`prd-to-srs` skill（qa-cases test-ready 寫法）；**QA flow**：`qa-codex-dispatch.md`／`qa-orchestrator-drain.md`／`fe-test-convention.md`／`qa-report-format.md`。

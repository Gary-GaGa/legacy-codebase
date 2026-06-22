# Build Task — 0921/0922 D 軸 backend 落地（Approved 前最後一哩，2026-06-22）

> **狀態**：0921/0922 **SRS spec 已完成**——`check-srs-bundle` 兩頁 exit 0；N 軸 **A/B/C/E/F/G PASS**；**D 軸 FAIL ＝ backend 尚未落地** spec 已規範的 3 個 guard。spec 已寫對(to-be 在),差 code 對齊(implementation conformance)。**這是 Approved 前唯一阻擋**（同 00100/00118 慣例：Approved 需 contract/impl conformance）。
> **載具**：母資料夾 **產品碼 backend**（RD）；改 controller/service。改完**重跑 D 軸（+ 相關 contract QA）**→ PASS → owner stamp → 覆蓋 2→4/67。
> **不自升 Approved、卡不移 done/**，直到 D 軸 PASS + 人裁。

## 3 個 backend guard（逐項落地）

### ① 0921 — Finished 冪等 / 重複撥貸 guard
- **行為**：mutation（Save `isFinish=Y` / Finished）前先檢查 `EPORIS_0921='Y'`；已 Finished → 拒絕、回 `EPROISU0921_ALREADY_FINISHED`，**不重複寫 RECEIVED_DATE / 不重複金錢 mutation**（防雙擊/重送重複撥貸）。
- **spec 權威**：`docs/specs/srs/EPROISU0921/spec.md:117,156`；錯誤碼 `openapi.yaml`；QA-033~036。
- **acceptance**：已 Finished 案再送 `isFinish=Y` → 400 `EPROISU0921_ALREADY_FINISHED`、狀態/金錢欄不變。

### ② 0922 — authorize 四眼控制 guard
- **行為**：`epl-case-isu-summary-auth` 在 **T24 檔產生 / SFTP 上傳前**強制：(a) `CASE_PROGRESS=25` (b) caller = 該案 assigned checker (c) **Maker ≠ Checker**（caller.empId ≠ submit 當下的 `CURRENT_USER_ID`/Maker）。自送自核 → 拒絕、回 `EPROIS0922_SELF_APPROVAL`。
- **spec 權威**：`docs/specs/srs/EPROISU0922/spec.md:54,84`（Maker identity preserve + state 25 + four-eyes）；QA-029/030。
- **acceptance**：同一員工 submit 後自行 authorize → reject `EPROIS0922_SELF_APPROVAL`，不進 T24/SFTP；非 25 狀態或非 assigned checker 亦 reject。

### ③ 0921+0922 — controller logging masking
- **行為**：兩頁 controller 不得記完整 request/response;遮蔽敏感（credentials、PII、T24 raw payload、帳號/金額等）。對齊 spec 的 log 安全規則（client-facing 訊息不得洩 host/credential/path/stack/customer data）。
- **spec 權威**：0922 `spec.md` R11/NFR log 安全;0921 R11。
- **acceptance**：撥貸/授權路徑 log 不含完整 payload / 敏感欄;sample log 檢視通過。

## 收尾（→ Approved）
1. RD 在 backend 落地 ①②③ + 單元/整合測試。
2. **重跑 D 軸 sub-agent**（read-only、跨模型）+ 相關 contract QA（QA-029/030/033~036）→ 無 Blocker。
3. D 軸 PASS → 兩頁 N 軸全 A–G PASS → owner stamp Approved（規格定版＋實作完成雙軸）→ 覆蓋 2→4/67。
4. 回填 `pending-register` 0921/0922 列、`decisions`、`STATUS`;本卡移 `done/`。

> 相關：`disbursement-0921-0922-napprove-fixes.md`（SRS 修正 agenda，已完成的部分）;`decisions.md:95`、`pending-register.md:83`（06-22 N 軸結果回填）。

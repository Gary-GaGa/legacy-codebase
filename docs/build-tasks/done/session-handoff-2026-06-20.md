# Session Handoff — 2026-06-20（給下個 session / context 接回）

> 用途：本 session（spec 軌收尾＋多輪驗證）的接回點。**狀態權威仍在** `../STATUS.md`／`../feature-inventory.md`／`../pending-register.md`；本檔只記「這輪做了什麼＋下一步卡在誰」，讀完即可接手。

## 1. 本 session 做了什麼（6 PR，全 merged main）
| PR | 內容 |
|---|---|
| #113 | SSOT backfill（00100/00118 Blocker 修正＋跨模型複審 PASS 後回填 STATUS/inventory/matrix/decisions/pending）|
| #114 | 補 00100/00118 Bible↔PRD trace sidecar（清 gateⒷ advisory）|
| #115 | 00100 DB-D4 `IS_Y` attribution nit |
| #116 | repo 健檢修正批（gate 漏改舊夾名 `db-schema/refactor`→`db-diff/refactor-spec`；README/狀態 drift；3-agent 廣掃後真修 6 項）|
| #117 | refactor-audit drift re-check 2026-06-19（denominator 親手重推＝77 工作單位/166 列、**零 drift**）|
| #118 | 00100/00118 待裁決 digest（owner decision aid，非 SSOT）|

## 2. repo 現況（已三向驗證乾淨）
- **SRS bundle 2/67**（`EPROZ00100` + `EPROC00118`），**In Review（Draft）、未 Approved**；機械閘門全 PASS（`python scripts/check-srs-bundle.py --all` exit 0、`check-dualtrack-parity.py` exit 0）。
- 跨模型 N 軸 Blocker 已修（06-19 owner + opus×2 複審 PASS）。
- migration 口徑：**77 工作單位**（67 頁＋`EPROZ00670`＋8 批次＋1 共用 API）／166 audit 列，零 drift。
- SSOT 五檔自洽（#116 健檢確認）。

## 3. 下一步（都不在 Claude 這側）
> **⚠️ 06-20 PM 更新（A 已過時）**：owner 已把兩頁所有 owner-decision @PENDING 全裁/全關（00100 `Z001~Z010`＋00118 `001~018`，push `d056803`，bundle 無 open pending、機械閘門兩頁 PASS）。**A 不再適用**——殘 Approved-blocker 改為 **contract 軸 RD/DBA 實作 gap**（DTO/status/`TB_API_AUTH` seed/save guard 未追上 to-be SRS）。詳見 `decisions.md` 06-20 列＋`pending-register.md` 該列＋證據 `pilot-srs-pending-verification.md`。下一步＝**RD/DBA 補 implementation/seed/測試證據 → contract 軸 PASS → Approved**；或走 §3-B 掛 source 放大。以下 A 段保留為史實。

**A. ~~owner 裁定 → 推 00100/00118 → Approved~~（✅ 06-20 已裁完，見上方更新）**
- 工具＝`EPROZ00100-EPROC00118-pending-decision-brief.md`。
- **先裁這 2 條**（28 條裡唯一擋 Approved 的）：`00100 PENDING-Z001`（逐角色 action 權限，PM/SA）＋ `00118 PENDING-001`（`CR_SCORE_CARD_COMPLETED` 兩碼語意＋E1/E2，PM/SA/風控）。
- 其餘 26 條擋後續 signoff/部署，照 digest §6 順序逐關清；**部署最硬閘＝`00118 PENDING-012`**（`TB_API_AUTH`＋非授權角色拒絕，"before ANY testing deployment"）。
- 裁定逐條回填各 `spec.md §@PENDING` ＋ `decisions.md`；digest 裁完歸檔 `done/`。

**B. 掛母資料夾 source → 交 Codex**
- carried-status 重 grep（M4/M5/M7/M8＋CU0160）：清單＝`refactor-audit/drift-recheck-2026-06-19.md §4`。
- 新 SRS 產出（剩 65/67）：risk-tier 企金線/撥貸/00800 先。

## 4. T24 規格歸屬（本 session 釐清，durable 記這）
**問：哪份 SRS 該有 T24 規格？→ `EPROISU0922`（撥貸 Disbursement Summary）。**
- 證據：`legacy/page-mapping.md:34`（`EPROISU0922 = IS_0922 = Summary`）；碼＝新 `SummaryServiceImpl.funcIsuT24Authorize`／舊 `EPRO_IS0922.createTransferA–H`。
- 撥貸＝**個金有擔（IS）線**；企金（CSU）無 09xx 撥貸頁 → **T24 頁只此一份、無企金對應份**。
- 橫跨三處：欄級 outbound 組檔/換匯＝`EPROISU0922`（頁 SRS）；T24 檔 SFTP 交付＝批次 `B007`；T24 回傳結果檔處理＝批次 `B006`（換匯每日匯入 `B005` 已銷案＝inline 取代）。
- **`EPROISU0922` SRS 尚未產**（剩 65/67 之一）；產時 T24 欄級行為**已坐實**＝`done/t24-bgroup-legacy-parity-fix-findings.md`（逐欄 legacy `file:line`＋commit `3d6f446`）＝現成 reconcile 輸入，省掉重追舊碼。

## 5. 限制備忘（為何某些事 Claude 這側做不到）
- **本 repo 無產品 source**（規劃 repo；`*.jsp/*.java/*.ts` glob=0）；legacy/新碼/`db-diff/`/`refactor-spec/` 皆**母資料夾-local** → 碼證據類（carried-status 重 grep、DB-resolvable pending 取值）須 Codex/DBA 帶 source。
- 裁定權在 owner（PM/SA/RD/DBA/Security/風控）；Claude 角色＝審查/記帳/坐實/「**備到蓋章即可**」（`STATUS.md §五`）。

---
> **接手**：讀 `STATUS.md`（憲法接回序）→ 本檔 §3 挑 A 或 B → 動工。本檔屬一次性接回卡，里程碑推進後可歸檔 `done/`。

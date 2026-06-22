# 撥貸 SRS 派工狀態 + prompts（2026-06-22）

> **用途**：撥貸 0921/0922 SRS 的「派工 hub + 接回點」。記在途狀態、owner 裁定點、兩支可貼 prompt。權威狀態仍以 `pending-register` / `STATUS` / 各 `spec.md` 為準；本卡＝操作便利。
> **在哪跑 SRS/code**：母資料夾 Codex（產品碼 + 規劃 repo 可寫 + local `docs/refactor-spec/`+`docs/db-diff/`）。本 remote planning repo 跑不了。

## 在途狀態（2026-06-22）
| 項 | 狀態 | 卡在誰 |
|---|---|---|
| `EPROISU0922` 主體 T24 re-open | ✅ 折回 `TBD-0922-001`/REF-D3；A15+B/D/H1-7 closed（REF-D8/TBD-008）| — |
| **`TBD-0922-007`**（`T24_COMPANY`→T24 B8/C9）| 🔄 **RD 派工在跑**（entity/schema-model 對齊）| Codex → 再 owner signoff |
| **`EPROISU0921`**（A-4/M6 re-open）| ▶️ **PM PRD 已放開發機、可開跑**（從零產 SRS）| 待跑 + owner 逐項 confirm |
| `EPROZ00800` | 🟡 in-review；R7 `TB_PAGE_COLUMN_AUTH_DETAIL.reason.item` backfill | DBA/RD |

## owner 裁定點（只有你能拍，共 3）
1. **0921 逐項 confirm**：A-4（CO_CHECK/mbCheck gate/law firm IS_SHOW/address UPD_DATE/DATA_SEQ/business-section）+ M6（EST_COM_DATE/OTHER_EST_COM_DATE）。
2. **0922 `T24_COMPANY` contract signoff**：確認「無另設 T24 contract override」→ B8/C9 都取 `TB_BRANCH_PROFILE.T24_COMPANY`。拍了才關 `TBD-0922-007`。
3. 兩者 **pre-push 金錢/識別欄人審**。

## 操作步驟
**軌 A（0921，可開跑）**：① 自查 PRD 命名/ledger prd-ready/預檢 → ② 貼 §A prompt → ③ per-page checkpoint 逐項 confirm → ④ gate 綠 + N 軸 → 同步回 main → 叫 Claude review。
**軌 B（0922 RD 返回時）**：⑤ 檢視 Codex 回報 → ⑥ owner signoff → ⑦ pre-push 人審 → push → 同步回 main → 叫 Claude 關 TBD-0922-007。
> 順序：0922 RD 在跑時先開軌 A；**別同時跑兩個 N 軸 batch**（T1 per-page、一次一頁、保 context 衛生）。

---

## §A — 0921 SRS 派工 prompt（PRD 放好後貼母資料夾 Codex）
```
任務：產 EPROISU0921（撥貸 Data Input）SRS bundle。母資料夾跑。T1 金錢/檢核頁 → per-page checkpoint：產完停交人審，不自宣 approved。

【前置】PM PRD 須在 docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md（無則回報「待 PM PRD」並停）。
【權威工作流】單頁轉換＝docs/build-tasks/prd-to-srs-codex-dispatch.md（填 funcId=EPROISU0921 / PRD 路徑）；re-open 逐項底稿＝docs/build-tasks/disbursement-reopen-srs-dispatch.md 的 EPROISU0921 段；梯裁＝docs/spec-architecture.md §5b；N 軸＝orchestration-playbook §4b（T1 全 A–G、F/D 不可省）。
【方向（與 T24 不同）】撥貸核心 as-is baseline=還原舊版。各 re-open 項：①坐實舊判據/來源 file:line（A-4=TBD-001、M6=TBD-002 本回坐實）②比對 db-diff+refactor-spec ③僅 refactor-spec 命中刻意 delta(三判 b)才改=偏新+REF-Dn；否則維持舊 baseline ④無從裁=@PENDING+owner confirm。勿預設偏新。
【逐項】REQ-002/006（A-4）：CO_CHECK 判定（新 ='Y' vs 舊 !='N'）、mbCheck gate、law firm IS_SHOW、address UPD_DATE、DATA_SEQ、business-section。REQ-003（M6）：EST_COM_DATE/OTHER_EST_COM_DATE 值來源（現 setEstComDate(null) 遺失 → 舊來源接回非 null）。不 re-open（當約束）：REQ-004 fee（M7/M10 已修）、REQ-005 RECEIVED_DATE（M4 已修）。
【輸出】docs/specs/srs/EPROISU0921/（spec/openapi/schema/qa；金錢/檢核 Rn 強制點 BE 權威）。
【驗證+收尾】check-srs-bundle docs/specs/srs/EPROISU0921 exit 0（含 gateⓇ delta 段）；N 軸 T1 全 A–G 跨模型 per-page checkpoint→停交人審+逐項 owner confirm；搆不到 refactor-spec/db-diff→顯式 disclaim「待母資料夾複核」+列已知 delta；回填 pending-register/ledger/decisions。
【回報】各 re-open 項 as-is 坐實+to-be（照舊/偏新 REF-Dn/@PENDING）、gate+N 軸結果、待 owner 逐項 confirm 清單。
```

## §B — TBD-0922-007 收尾 prompt（可直接派）
```
任務：收尾 EPROISU0922 的 TBD-0922-007（T24_COMPANY 餵 T24 B8/C9 的 entity/schema-model 對齊）。母資料夾跑。T1 金錢/識別欄 → per-page checkpoint：做完停交人審，不自做 owner contract signoff。

【先讀】spec.md TBD-0922-007（open）/REF-D8/Historical note；pending-register 第 14 列；schema-diff-findings.md:246-249；db-diff TB_BRANCH_PROFILE.md:47-50。
【已坐實（沿用）】DB 有 TB_BRANCH_PROFILE.T24_COMPANY；findByDepCode 跑 native SELECT *、funcIsuT24Authorize 呼叫、B8/C9 以 MapUtils.getString(...,"T24_COMPANY") 取值；TBBranchProfileEntity 只映 T24_BRANCH_CODE/T24_DEPT_CODE、未映 T24_COMPANY。
【做】① 確認 entity/repo 是否需補 T24_COMPANY 屬性以對齊 DB+native-map 用法。② 若需要：補 entity 映射（+必要 getter/repo），不破壞 native SELECT * 路徑。③ 確認 to-be：B8/C9 皆由撥貸部門 TB_BRANCH_PROFILE.T24_COMPANY 取、不靜默 fallback 空白；附 legacy（EPRO_IS0922.java:590-601/645-652/726-727）+現後端（SummaryServiceImpl.java:906-907/1862-1865/1903-1905）對照。④ ⛔ 不自做 owner「無另設 T24 contract override」signoff → 整理成一句待確認問題回報。
【驗證+收尾】mvn clean package 綠 + diff 供人審（金錢/識別欄最嚴）；check-srs-bundle docs/specs/srs/EPROISU0922 exit 0；spec.md 把已對齊部分寫實、TBD-0922-007 縮成「僅待 owner signoff」、REF-D8 同步；回填 pending-register/decisions；N 軸 T1 全 A–G per-page checkpoint→停交人審+等 owner signoff，不自升 approved。
【回報】entity 是否補/怎麼補（file:line）、B8/C9 to-be 定案、mvn+check-srs-bundle 結果、待 owner signoff 的問題。
```

---
> 跑完回填後本卡可標 ✅ 移 `done/`。0921/0922 都到 in-review + owner confirm/signoff 完成即收。相關：`disbursement-reopen-srs-dispatch.md`（總 overlay + worksheet）。

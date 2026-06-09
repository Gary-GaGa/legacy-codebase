# 重構 → 開發 Pipeline 願景（AI-native SDLC）

> 把白板雛形正式化。**這是「補完 30%」之上的下一步**：從現在的「RD agent 自走補完」往上長成
> `Bible → PRD → SRS → QA → RD-Agent` 一條**往上可追溯、往下可驗證**的鏈。
> 本檔定**模型與原則**；第一個 worked example = [`specs/srs/EPROZ00800/`](specs/srs/EPROZ00800/)（規格分層 bible→prd→srs 見 [`specs/README.md`](specs/README.md)）。
>
> 🖼 **一圖總覽（來源）**：[`assets/ai-workflow.mmd`](assets/ai-workflow.mmd)（GitHub / Mermaid 直接 render；**＝AI Flow 權威來源**）。[`assets/ai-workflow.svg`](assets/ai-workflow.svg) 為快取 render，**2026-06-09 .mmd 加 brownfield 機制後未重出 → 以 .mmd 為準、需要時重 render**。

## 1. 終極目標
- 從 legacy 系統**反推出 Bible**：真實世界的 user story、業務**北極星**、**黃金旅程** → 讓團隊**不分角色一致理解業務**（這是「前傳」，講清楚原系統為何長這樣）。
- 再由角色接力，**每一棒都是機器可驗證的交接**：
  - PM/PO → **PRD**（what）
  - SA → **SRS**（how：OpenAPI + spec + DB schema）
  - QA → **QA case**（驗收邊界 1~∞）
  - RD-**Agent** → 開發 + 測試，**並可證明通過 SA/QA 邊界**；bug → issue → 回歸 case

## 2. 角色鏈 ↔ 現有 repo artifacts（我們其實是「由下往上」長的）
| 層 | 角色 | 產物 | 現有對應 | 成熟度 |
|---|---|---|---|---|
| 業務 | （EPRO Expert）| **Bible**：user story / 北極星 / 黃金旅程 | —（技術事實有，業務敘事缺）| 🔴 缺 |
| 產品 | PM/PO | **PRD**（what）| 散在 `build-tasks/` `page-mapping.md` | 🟡 |
| 規格 | SA | **SRS**：OpenAPI + spec + DB schema | `module-*.md` `db-schema-catalog.md` `AGENTS.md` | 🟡（OpenAPI 未落地）|
| 測試 | QA | **QA case** + bug case | `待整合驗證清單`（散文、延後）| 🔴 缺可跑測試 |
| 實作 | RD-Agent | code → CICD → issue | `AGENTS.md` + `verify-c0` + `runbook-30pct` | ✅ 最成熟 |

## 3. 核心原則：往上可追溯、往下可驗證
- **AI 在每一層都會 confabulate** → 每個交接點（邊界）必須是**機器可驗證的契約**，不是純文字，否則 AI 只是自己給自己打分。
- 30% 補完已用血換到：**deterministic gate（`verify-c0`）可信、LLM gate（`codex review`）只能輔助**。把這條**往上推**到 PM/SA/QA，就是整個 pipeline 的支點。
- **Bible 是特例**（敘事，無法 schema 化）→ 它的「驗證」= **證據接地**：每條業務北極星 / user story 都要**引用 legacy 證據（code/DB/JSP `file:line`）**，同我們逼 reviewer「引用 i0:line ↔ c0:line、不准猜 PASS」。Bible 一旦幻覺，整條鏈繼承幻覺且無人察覺。

## 4. RD ↔ SA/QA 的 DoD = deterministic 閘門「合取」
RD agent「通過邊界」要可**被證明**，DoD 就是下面**全綠**（由強到弱）：

```
SA 邊界 ┌ 1. Contract 一致   impl ↔ OpenAPI（欄位/型別/required/enum/狀態碼）
        │ 2. Schema 一致     entity/SQL ↔ DB schema（Hibernate validate / migration）
        │ 3. 結構閘門         verify-c0（命名/禁用樣式/只新增/編碼）★已有
QA 邊界 ┤ 4. 驗收測試         每條 QA case = 可跑測試，紅綠分明；bug → 新 case（回歸 1~∞）
        │ 5. 覆蓋率           每條 spec/PRD 項都有 ≥1 QA case（靠追溯 ID 對表）
        └ 6. Build 綠
─────────── 以上「機器說了算」（deterministic）───────────
        7. [輔助] LLM 語意審查  只補 1–6 抓不到的（mirror 保真度…）。永遠 advisory，不當 gate
```

## 5. 每頁一個「邊界包」（boundary bundle）＋追溯 ID 骨幹
每個 story/page 配一束 artifacts，**全靠同一個 ID（`EPROC00118`）串起來** → 這裡「可驗證邊界」與「追溯 ID」合流：

```
EPROC00118/
├─ openapi.yaml   ← SA：endpoint request/response 契約         → 閘門 1
├─ schema.sql     ← SA：touched 表/欄位/約束                    → 閘門 2
├─ spec.md        ← SA：業務規則（每條給 rule-id：R1/R2…）
└─ qa-cases.md    ← QA：每條 case 標 covers: Rn（可跑測試）      → 閘門 4 + 5
```
- **覆蓋率（閘門 5）= 對表**：spec 的每個 `Rn` 都要有 ≥1 個 `covers: Rn` 的 QA case，否則 FAIL。
- **escalation / 未決 = `PENDING` case**（顯性紅燈，不埋 doc）。例：00118 的「CU return checkpoint 衝突」就是一條 PENDING case。

## 6. 設計決策
- **OpenAPI source of truth**：先 **code-first + snapshot**（springdoc 從既有 hand-written controller 生 OpenAPI → snapshot 鎖住，改契約得有意改 snapshot；門檻低）。**contract-first（從 OpenAPI 生 DTO、契約零 drift）為北極星**。
- **QA case = 可跑驗收測試**（Gherkin / API integration），非散文；bug → 新回歸 case。
- **覆蓋率靠追溯 ID**（`Rn` ↔ `covers: Rn`）。

## 7. 現況差距（誠實）
- ✅ 已有：閘門 3（`verify-c0`）、閘門 7（`codex review`/`reviewer-c0`）。
- 🟡 半套：閘門 1（只有人工讀 DTO 對齊，**OpenAPI 未落地**——`decisions.md` B3）、閘門 2（有 schema 文件、無自動 validate）。
- 🔴 缺：閘門 4（`待整合驗證清單`是散文 + 延後 dev/uat；build 還 `-Dmaven.test.skip=true`）、閘門 5（無 ID 覆蓋對表）。
- **不舒服但要講**：vision 的支點（可執行邊界）**正是目前 30% 專案刻意 punt 掉的**（靠「build 綠 + 之後人工整合」，而 runbook 自己寫「build 綠 ≠ 正確」）。往 vision 走 = 把 1/2/4/5 從「文件 + 延後」升級成「迴圈內可跑」。

## 8. 漸進落地（別一次到位）
> 具體 plumbing 做法（含真正的前置摩擦：壞 baseline 測試 / Oracle native SQL / JWT / Nexus image）見
> [`build-tasks/done/B-boundary-gate-plumbing.md`](build-tasks/done/B-boundary-gate-plumbing.md)。
1. **先接閘門 1**：springdoc 生 OpenAPI + snapshot test（配既有 controller）。
2. **再補閘門 4/5**：挑一頁把 `待整合驗證清單` 改寫成可跑 QA case + ID 覆蓋對表。
3. **一頁 end-to-end 跑通**（建議 `EPROC00118`，邊界包範本已備）→ 再放大到其它頁。
4. **上層（Bible/PRD）可並行萃取**，但守證據接地紀律；先有一頁邊界包跑通再往上長。

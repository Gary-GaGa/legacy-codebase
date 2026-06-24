# Flow 速度極限檢視 — 用黃仁勳思考方式看 AI Flow（proposal）

> **這是什麼**：用 Jensen Huang 的招牌心智模型（speed of light / attack the bottleneck / zero-billion-dollar market / ride the cost curve）重看本專案的 AI Flow（`assets/ai-workflow.mmd`、敘事版 `ai-flow-guide.md`），找出「紀律已足、野心不足」之處，並把可執行的改動列成 backlog。
> **狀態**：**Proposal — 待 owner 裁定**（刻意遵守本 flow 自身鐵律「判斷題不自裁」：下列重定向會改變 flow 的預設野心與指標，屬 C 類決策，不自行採納）。
> **一句話結論**：這 flow 是一台**世界級的 regression 防護機**（幾乎不會讓你變糟），但缺「變得不可思議」的機制——把 legacy 從**天花板**改成**地板**。

---

## 1. 已經很「黃仁勳」的部分（keep，別動）

| 老黃原則 | flow 內對應 |
|---|---|
| Intellectual honesty / 面對殘酷事實 | `結構在≠行為對等`、`舊系統≠絕對正確`、`AI progress bias 假 Approved`、`採納修正後再審一輪`——把會自我欺騙的點全部制度化成 gate |
| 失敗 → 寫進系統（fix the system, not the person） | [`spec-architecture.md §9`](../spec-architecture.md) 教訓→控制點表 |
| Information flows freely / 單一真相 | SSOT 紀律（`feature-inventory`/`pending-register`/不複寫連回原檔）+ `funcId` 共用座標系 |
| One architecture, bet for a decade（CUDA） | `funcId` 縱貫追溯鏈＝貫穿全棧、愈跑愈複利的賭注 |
| Full-stack co-design | 層界契約（FE—openapi—BE—schema—DB）+ oracle-first（QA 在 RD 前） |

## 2. 老黃會拍桌的三點

### 2.1 你 benchmark 的是 legacy，不是 speed of light
flow 錨點＝**as-is parity**（regression vs 演進、異於舊版預設當 regression）＝**增量思維**。老黃會先問「這頁的理論最佳版長怎樣」，再往回推差距。現行「刻意演進」是**例外**（要舉證放行），不是**預設野心**。

### 2.2 你沒在攻唯一的瓶頸
flow 吞吐天花板白紙黑字＝`終點是等人審`、`orchestration 省派工不省審查裁定`。**瓶頸＝人類裁定（@PENDING/owner）+ review**。老黃不接受「這是天花板」，他會盯「每頁產生幾個 judgment call，這數字有沒有每季下降」。
> 你**已在做**對的事——[`spec-architecture.md §5b Rule 1`](../spec-architecture.md)（DB-resolvable fact 不留人工 Pending）就是把人類待裁降級成自動解；但它是**規則**，老黃會把它當**KPI**。

### 2.3 這是「移植 flow」，不是「創造 flow」
設計重心全在「不弄壞舊的」，對「發明 10x 新東西」幾無機制。Bible 由 **legacy 反推**得來，不是前瞻畫出。老黃：「真正價值不在 port，在 port 完之後變得可能的事。」

## 3. 可執行 backlog（待 owner 採納後才動 flow）

| ID | 改動 | 動到哪 | owner | 採納後連動 |
|---|---|---|---|---|
| **SOL-1** | SRS/每頁加 `speed-of-light target` 欄：與 as-is 並列「若無 legacy 包袱的理想版 + 差距」。讓 parity 變**起點**不是終點。 | `prd-to-srs` skill DoD、SRS 範本、`ai-flow-guide.md ③` | PM/SA | 更新 `spec-architecture.md`（規格類型多一欄）、`ai-workflow.mmd`（SRS 節點） |
| **SOL-2** | 把 **C→A 降級率** 變 dashboard 指標：每里程碑記「本期多少『曾需人裁』變成『模型可自解』」＝riding 模型進步曲線（Huang's law）的儀表板。 | `STATUS.md`、`feature-inventory.md`、`§5b Rule 1` 回路 | SA/owner | `orchestration-playbook` 完成定義加指標 |
| **SOL-3** | 平行化壓到極限、只在 correlated-blindness 處踩剎車：審視 `drain 序列一次一頁` 是物理約束還是安全拐杖；把「非序列不可」縮到「跨頁共享決策」這類，其餘放平行。 | [`orchestration-playbook §5b/§6b`](orchestration-playbook.md) | SA/RD | drain 迴圈規則修訂 + circuit-breaker 邊界重定義 |
| **SOL-4**（選配） | 上游加**前瞻 north-star**：不從 legacy 反推、而從「2026 該有的授信體驗」正推，與反推 Bible 並列、衝突時正推贏。 | `legacy-to-bible` 之外新增上游、`ai-workflow.mmd` | PM/PO/domain | 改 flow 上游拓樸（重大，需 ADR） |

> SOL-4 屬「改 flow 上游拓樸」的重大取捨，若採納應升格為 `docs/adr/ADR-NNNN`。

## 4. 老黃版總結

> 「你造了一台世界級的 regression 防護機——它幾乎不會讓你變糟。但我不投資『不會變糟』，我投資『變得不可思議』。把 legacy 從你的天花板改成你的地板，然後告訴我光速在哪。」

---
> 維護：本檔＝**proposal**，非已採納方法論。owner 採納任一 SOL 項後，依「採納後連動」欄回填對應權威檔，並把本檔對應項標 ✅ adopted / 連到落地 commit。未採納者保留為待議。

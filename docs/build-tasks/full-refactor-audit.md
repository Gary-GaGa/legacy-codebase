# Build Task — 全量重構盤點（zero-based audit）：Bible＋舊系統＋畫面清單 → 重推總量 → 對照新碼進度

> 載具：Codex（母資料夾），**唯讀**（產品 repo 新/舊碼一個檔都不改）；產出只寫 `docs/build-tasks/refactor-audit/`。
> **動機**：`feature-inventory.md` 是增量維護的狀態表，可能有 stale/漏列。本卡**不信任它**、從三個上游重推「重構翻寫總量」：① Bible（`docs/specs/bible/bible-eproposal.md`）② 舊 EPRO source ③ 畫面合併清單（`docs/legacy/page-mapping.md`＋`legacy/module-*.md`）。推完才對 inventory 做 **diff（只報不改）**，人審後由規劃 repo 主流程回填。
> ⚠️ **多 session 分段執行**——嚴守 §0 context 衛生（依據 `docs/verification/verification-execution.md` §1：context 拋棄式、真相存 doc）。

## 0. 不變式（每個 session 都遵守；違反任一條＝該 session 結果作廢）
1. **唯讀**：不改碼、不跑 build；只搜只讀。
2. **一模組（或半模組）＝一個 session**，照 §3 切分；**禁止一個 session 吃兩節**。
3. 每 session 開頭**只讀**：本卡 §0＋§2＋自己那節、`refactor-audit/master.md`、`page-mapping.md` 該模組節。**禁止整檔載入** `feature-inventory.md`/Bible/大型 doc（留給 S-final）。
4. 每個結論附證據：舊＝JSP 檔名＋action `file:line`；新＝controller route／FE component 路徑。**找不到＝❓UNFOUND，不准猜、不准拿文件當證據**。
5. **context 用到約七成就收尾**：把已完成列寫進模組檔、在 `master.md` 記斷點（做到哪個 funcId），回報後結束。**嚴禁 compact 之後憑記憶續寫表格**——壓縮必失真；新 session 從斷點重查。
6. 真相在檔案、不在記憶：session 之間不口頭傳遞結論；下個 session 一律重讀模組檔。

## 1. 產出結構（S0 建骨架）
```
docs/build-tasks/refactor-audit/
├── master.md            # 進度板：§3 的 session × 狀態(未開/進行/斷點funcId/完成) + 各模組小計
├── M1-zz.md … M9-common.md（M2/M6/M7 各拆 a/b 兩檔或同檔兩節）
└── diff-vs-inventory.md # S-final 產出：總量表 + 對 feature-inventory 的差異清單
```

## 2. 列 schema（全模組統一；一畫面/一獨立 action＝一列）
| 舊 funcId/JSP | 功能（畫面/action）| Bible 錨點 | 新對應（FE 路由 / BE `epl-*`）| FE | BE | 證據 | 缺口/備註 |

- 狀態字彙（FE/BE 各自標）：✅ 碼在｜🟡 碼在疑未完（stub/空回/TODO/throw）｜🔴 無對應｜🚫 確認不遷（**必附裁決出處**，如 CS 0240）｜❓ UNFOUND
- Bible 錨點：該畫面被 Bible BR/SC 點名才填（id），否則 `—`（Bible 完備性留 S-final 抽查）。
- 每模組檔尾**小計一行**：`總列數 / ✅ / 🟡 / 🔴 / 🚫 / ❓`。

## 3. Session 切分（S1–S9 可亂序/並行；S0 先行、S-final 最後）
| S | 範圍 | 舊源錨點 | 新碼錨點提示 |
|---|---|---|---|
| **S0** | 建 `refactor-audit/` 骨架：master.md（本表抄成進度板）＋各模組空檔含表頭 | `page-mapping.md` §1 模組×JSP 數 | — |
| S1 | M1 `zz`（登入/首頁）＋ M9 common/demo（版型/error；同質頁可彙列） | 舊 `zz`/common 資料夾 | `main-layout`、Spring Security/JWT |
| S2 | M2a `is` 申請流程（0110–0290） | 舊 `is` JSP＋dispatcher 註冊 | FE `EPROISU*`、BE 對應 controller |
| S3 | M2b `is` 契約＋撥貸（0910–0913、0920–0922）＋ M3 `iu` 全部（IS/IU 已合併，對照同一組新頁；iu 獨有差異逐列標） | 舊 `is` 09xx＋`iu` | 同上＋`DataInput/SummaryController` |
| S4 | M4 `cs`＋M5 `cu`（CS/CU 合併，同 S3 處理法） | 舊 `cs`/`cu` | FE `EPROCSU*` |
| S5 | M6a `i0`（00110–00115） | 舊 `i0` | FE `individual/credit-investigation/*`、BE `controller/individual/*` |
| S6 | M6b `i0`（00116–00120＋其餘 i0 JSP 全數列盡） | 同上 | 同上＋`FinancialStaffController` |
| S7 | M7a `c0`（00110–00115 對應段） | 舊 `c0` | FE `corporate/*`、BE `controller/corporate/*` |
| S8 | M7b `c0`（00116–00120 對應段＋其餘 c0 JSP 列盡） | 同上 | 同上 |
| S9 | M8 `z0`（00100–00800 全 18 頁） | 舊 `z0` | `EPROZ00*` 各 controller |
| **S-final** | 彙總＋diff（見 §5） | — | — |

**每模組盤法（S1–S9 固定四步）**：① 從**舊源檔案系統＋dispatcher/web.xml 註冊**列出該模組全部畫面與獨立 action（以舊碼為準、非文件）→ ② 逐列找新對應：先用 `page-mapping.md` 該節當提示、**再以新碼 grep 驗證（以碼為準，文件不符就照碼寫並標註）** → ③ 判 FE/BE 狀態＋貼證據 → ④ 寫模組檔＋小計，回 `master.md` 更新狀態/斷點。

## 4. 舊源不在 workspace 的降級規則
舊 EPRO source 若不可讀：該模組總量改以 `page-mapping.md`＋`legacy/module-*.md` 為次佳來源，模組檔頭標 **`SOURCE=docs-only`（信度降級）**；**不得拿新碼反推總量**（循環論證——新碼缺的頁會直接從總量消失）。

## 5. S-final：彙總＋diff（此時才讀 feature-inventory 與 Bible）
1. 讀 9 個模組檔的**小計列**（不重讀明細）→ 全系統總量表：`總畫面數 × ✅/🟡/🔴/🚫/❓`，按模組分組。
2. 對 `feature-inventory.md` 逐模組 diff，只列**差異**：(a) inventory ✅ 但 audit 🟡/🔴/❓ (b) inventory 漏列的舊畫面 (c) audit 🚫 但 inventory 仍當待辦 (d) 兩邊狀態矛盾。每條附模組檔行號。
3. Bible 完備性抽查：Bible 黃金旅程/BR 點名的頁，各自在 audit 表有承載列嗎？沒有→列 `BIBLE-GAP-n`（只標，不裁）。
4. 寫 `diff-vs-inventory.md`：總量表＋差異清單＋BIBLE-GAP＋「建議回填項」清單。**不改 `feature-inventory.md`**。

## 6. 回報（每 session 固定格式）
- 本 session 範圍、模組檔路徑、小計一行；斷點（若有，含下個 session 從哪個 funcId 續）。
- 產品 repo `git status --short`（應乾淨）；異常（舊源不在/docs-only 降級）一句。

> 過了：人審 `diff-vs-inventory.md` → 差異逐條裁定 → 回填 `feature-inventory.md`（含新發現缺口開卡）。本卡＋`refactor-audit/` 整夾進 `done/`。

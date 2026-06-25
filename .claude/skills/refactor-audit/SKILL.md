---
name: refactor-audit
description: Zero-based, code-evidence-only audit of refactor progress — re-derive the migration total from upstream (Bible + legacy source + page list) and diff against feature-inventory.md (report only, never edit). Use to re-baseline progress when the inventory may have drifted (e.g. after a milestone lands, or before a planning checkpoint), or to verify a module's real completeness. Trust nothing; missing code = UNFOUND, never inferred. Triggers: "重新盤點", "zero-based audit", "盤點進度", "audit <module>", "重構盤點".
---

# Refactor Audit（zero-based 重構盤點）

唯讀、**只信碼不信文件**地重推「重構翻寫總量」，再對 `docs/feature-inventory.md` 做 diff（**只報不改**）。
動機：`feature-inventory.md` 是**增量維護**的狀態表，會 stale/漏列——本 skill 不信任它、從三個上游重推。
位置見 `docs/assets/ai-workflow.mmd`（這是 inventory 的**定期校正回路**，不是 flow 主線的一站）。

> **為什麼是 skill 不是一次性卡**：drift 會反覆發生（里程碑落地、增量回填後）。把方法論常設化＝下次盤點直接跑、不重新發明四錨點/窮盡聲明/QC 口徑。首跑實例＝`docs/build-tasks/refactor-audit/`（166 列，F-1 翻案抓到 inventory 標 ✅ 但 FE 不存在）。

## ⚠️ 最重要的鐵則：trust nothing，找不到＝UNFOUND
盤點的價值全在「不拿文件當證據」。**每個結論附碼證據**：舊＝JSP 檔名＋action `file:line`；新＝controller route／FE component 路徑。**推不出對應的標 `❓UNFOUND`，不准猜、不准拿 `feature-inventory`/`page-mapping` 當證據**（那正是被審對象）。寧缺勿假——假陽性（標綠其實沒做）比 UNFOUND 危險得多。

## 不變式（每個 session 都遵守；違反任一條＝該 session 結果作廢）
1. **唯讀**：不改碼、不跑 build；只搜只讀。產出只寫盤點資料夾，**不碰** `feature-inventory.md`。
2. **一模組（或半模組）＝一個 session**；**禁止一個 session 吃兩節**（context 必失真）。
3. session 開頭**只讀**：本 skill＋進度板＋自己那節＋`page-mapping.md` 該模組節。**禁止整檔載入** `feature-inventory.md`/Bible/大型 doc（留給 S-final）。
4. **context 用到約七成就收尾**：已完成列寫進模組檔、在進度板記斷點（做到哪個 funcId），回報後結束。**嚴禁 compact 後憑記憶續寫表格**——新 session 從斷點重查。
5. **真相在檔案、不在記憶**：session 之間不口頭傳遞結論；下個 session 一律重讀模組檔。

## 列 schema（全模組統一；一畫面/一獨立 action＝一列）
| 舊 funcId/JSP | 功能（畫面/action）| Bible 錨點 | 新對應（FE 路由 / BE `epl-*`）| FE | BE | 證據 | 缺口/備註 |

- 狀態字彙（FE/BE 各自標）：`✅ 碼在`｜`🟡 碼在疑未完`（stub/空回/TODO/throw）｜`🔴 無對應`｜`🚫 確認不遷`（**必附裁決出處**）｜`❓ UNFOUND`。
- **列彙總口徑**：任一端 UNFOUND → 整列計 UNFOUND。
- Bible 錨點：該畫面被 Bible BR/SC 點名才填 id，否則 `—`（完備性留 S-final 抽查）。
- 每模組檔尾**小計一行**：`總列數 / ✅ / 🟡 / 🔴 / 🚫 / ❓`。

## FE 判定標配＝四錨點（S4b 教訓內化，**不可省**）
只做精確字串搜尋**不得**標 UNFOUND——legacy→新的命名常不對稱（合併頁、動態拼接）。FE 列判 UNFOUND 前必查四錨點，全空才算缺：
1. **目錄樹**：對應 feature 的 component 資料夾在不在。
2. **page-code 註冊**：`page-code.model.ts`（或等價）有無該 funcId enum/路由。
3. **service 動態拼接**：endpoint 是否由變數組裝（grep 不到字面）。
4. **共用元件分支**：是否藏在共用 dialog/shell 的 caseType 分支裡。

## Session 切分（S1–S9 可亂序/並行；S0 先行、S-final 最後）
進度板 `<audit-dir>/master.md` 抄 session×狀態(未開/進行/斷點funcId/完成)＋各模組小計。模組切分照 repo 的 M1–M9（或當次盤點域）。
**每模組四步**：① 從**舊源檔案系統＋dispatcher/web.xml 註冊**列出全部畫面＋獨立 action（以舊碼為準）→ ② 逐列找新對應（`page-mapping` 當提示、**再以新碼 grep 驗證**，文件不符照碼寫並標註）→ ③ 判 FE/BE＋貼證據（FE 走四錨點）→ ④ 寫模組檔＋小計＋更新進度板斷點。
**窮盡聲明**：每模組收尾記一句「無剩餘非-partial JSP/action」——逼盤點者明示「列盡了」，否則漏列無痕。

## 舊源不在 workspace 的降級規則
舊 source 不可讀：該模組改以 `page-mapping.md`＋`legacy/module-*.md` 為次佳來源，模組檔頭標 **`SOURCE=docs-only`（信度降級）**；**不得拿新碼反推總量**（循環論證——新碼缺的頁會從總量直接消失）。

## S-final：彙總＋diff（此時才讀 feature-inventory 與 Bible）
1. 讀各模組檔**小計列**（不重讀明細）→ 全系統總量表：`總列數 × ✅/🟡/🔴/🚫/❓`，按模組分組；統計時 `✅ 碼在`≡`碼在`、`❓`≡`UNFOUND`；action 級粒度模組（如殼/common）另列「頁級換算」欄並註記。
2. 對 `feature-inventory.md` 逐模組 diff，只列**差異**四類：(a) inventory ✅ 但 audit 非綠 (b) inventory 漏列 (c) audit 🚫 但 inventory 仍列 (d) 狀態矛盾。每條附模組檔行號。
3. **Bible 完備性抽查**：Bible 黃金旅程/BR 點名的頁，各自在 audit 表有承載列嗎？沒有→列 `BIBLE-GAP-n`（只標不裁）。
4. 寫 `diff-vs-inventory.md`：總量表＋差異清單＋BIBLE-GAP＋「建議回填項」清單（逐條 inventory 哪列改成什麼＋依據，供人審打勾）。**不改 `feature-inventory.md`**。

## QC 日誌（逐場留痕，單一出處）
每場 QC 後在 `<audit-dir>/refactor-audit-qc.md` 加一列：`S / commit / 🟢🟡 判定 / 摘要`，並累計發現 `F-n`（證據位置＋建議動作，**裁定全留人審**）。口徑備忘（同義字、列粒度、四錨點標配）固化進該檔，S-final 統計時遵守。

## DoD（盤點完成）
- 各模組檔小計齊＋窮盡聲明記；進度板全標完成。
- `diff-vs-inventory.md` 四節齊；QC 日誌 F-list 與 diff 逐條對得上。
- 產品 repo `git status --short` 乾淨（唯讀證明）。
- **回填**：人審 diff 逐條裁 → 主流程改 `feature-inventory.md`（含新缺口開卡）＋更新該模組「audit 驗證」欄（日期＋本次 audit ref）→ 盤點資料夾進 `done/`。

> 過了：inventory 從「增量維護的可能謊言」校正回「碼證據對齊」；staleness 欄記下校正日，下次知道何時該再跑。

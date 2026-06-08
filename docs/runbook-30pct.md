# Runbook — 自走補完剩餘 30%（goal mode）

> 給 Codex 自走（goal mode）完成剩餘 backlog 的控制文件。**硬規則見 `backend/AGENTS.md` §6**；本檔定**順序、閘門、煞車、停止點**。
> 原則：**build 綠 ≠ 正確**（本專案已多次「綠但有 bug」：reflection / 亂碼 / BOM / checkpoint）→ 閘門 = **驗證腳本 + build 綠 + 對 i0 語意自檢**，且判斷題一律**停下回報**。

## 0. 已完成（**勿重做**）
- 前端：🟡 **大致完成，惟 c0 評分前端整組缺**（⚠️ 2026-06-06 翻案：corporate 缺評分容器+8 子頁、Phase F 鏡像 i0 補建中，見 `feature-inventory.md` §2D；**勿因本行誤以為 c0 評分 FE 已做**）。其餘（`00610`/`00620–00650`/`00660`/`00700`=`deputy`/`EPROCSU0130`）✅。
- 後端 c0 評分：`00115`✅ `00116`✅ `00117`✅ `00118`✅ `00119`✅ `00120`✅（**全數結清**；`00117` 既有模組 audit 確認已滿足、`00118` 本期新建+語意審查 9 PASS 帶 2 條既有-service escalation）。
- 後端撥貸：`0920`(頁框)/`0921 DataInput`/`0922 Summary` 的 controller+service **已存在**（2026-06-05 盤點；服務 FE 9 端點）→ **非 build 缺口、勿重做**。
- 詳見 `page-mapping.md` §2A/§2B 狀態欄。

## 1. 剩餘 backlog（依序；標明可否自走）
| 順序 | 項目 | 鏡像/來源 | 自走？ |
|---|---|---|---|
| ~~1~~ | ~~`EPROC00117` c0 FinEval GI~~ | i0 `FinancialStaffController` | ✅ **既有模組已滿足規格（2026-06-05 audit：缺無、錯無）**，非從零、無需重建。只取 00117 分支、info 寫回 GI 保留、checkpoint `Cs/Cu.EPROC00117`；sele 用 `commonFunctionService.funcIsStaffLoan`（`service.common`，允許）|
| ~~2~~ | ~~`EPROC00118` c0 Corporate Scorecard~~ | i0 `CorporateScorecardController`；calc 注入 `FunctionService.funcGetRate` | ✅ **完成（2026-06-05）**：build 綠 + verify-c0 + 語意審查 9 PASS；2 條既有-service escalation（CU-return、crScoreCardCompleted 整欄覆寫）留待 owner。詳見 `page-mapping §2B` |
| ~~3~~ | ~~`EPROISU0920` Disbursement~~ | 無 i0；基準＝既有 `0921`/`0922` + FE 契約 | ✅ **盤點完成（2026-06-05）：後端已存在**（`DataInputController`/`SummaryController` 服務 FE 9 端點），**非 build 缺口**。舊源不在 workspace → 撥貸正確性走 **domain + 整合驗證**（§6.6：不臆測、不重寫、不改既有 service）|
| ~~4~~ | ~~`EPROCSU0130` 企金保證人（前端）~~ | 照個金 twin `EPROISU0130` | ✅ **完成（2026-06-05，ng build 綠）**：3 檔小修（端點 bug、error/loading 收斂、popup 去耦），oracle＝twin 非 deputy |

## 2. 每頁自走迴圈
1. **plan**：先盤 i0 來源（端點集合 / entity / checkpoint / 跨頁副作用），列計畫。判斷題 → 停（§6.6）。
2. **implement**：自足鏡像（§6.1–6.4），純新增、不動 i0/`Csu*`。
3. **gate（硬閘門，全過才算完成）**：**a 必先**（便宜、deterministic）；**b/c 皆須通過，兩者順序可換**（語意審查讀原始碼、不需編譯；build 不需審查）。
   - **a. 形式**：`python scripts/verify-c0.py --git` → **PASS**。現在同時擋：strict-UTF-8 / No BOM、禁用樣式、`-c0-` 命名、**且「修改到既有 i0/Csu* 檔」（§6.1 只新增）**；`FunctionService` 共用計分引擎為核准例外（allowlist）。⚠️ 可接 Codex `Stop`/`PostToolUse` hook（`docs/env/codex/hooks.json`），但 **hook 不保證真 block**（exit≠0 需 wrapper 轉 block JSON、schema 待官方確認）→ 當作**每頁必跑的手動/CI 閘門**，別只靠 hook。
   - **b. 語意（獨立審查）**：跑原生 **`codex review --uncommitted "<審查指示>"`**（非互動、唯讀、自動含未追蹤新檔、獨立 context）。指示＝對照本頁 i0 鏡像來源（page-mapping §2B / 頁卡）+ 依 `backend/AGENTS.md §6`、`docs/review-c0-prompt.md` 逐項 **PASS/FAIL/UNSURE + 引用 i0:line↔c0:line、不准猜 PASS**。求更獨立加 `-c model="<與實作不同的模型>"`。**全 PASS 才往下；任何 FAIL/UNSURE → 回實作修，重跑 a→b**。（備案：`docs/env/codex/reviewer-c0.toml` 唯讀 custom agent。）仍是 LLM、非萬無一失。
   - **c. 編譯**：`mvn clean package "-Dmaven.test.skip=true"` → **綠**（獨立終端機，勿自跑長 build 卡住）
4. **backfill**：更新 `page-mapping.md` §2B 該列為「✅實作（待整合驗證）」+ 補待整合驗證清單（新 endpoint `TB_API_AUTH` 授權列、export 模板沿用 i0 路徑等）。
5. **commit**（實際產品專案，非本規劃 repo）：訊息描述頁碼 + 鏡像來源。

## 3. 🛑 停止點（停下回報、不准猜）
- 算法/計分無法 1:1 鏡像（`00118` calc 已定案＝注入 `FunctionService`，見頁卡；此條指**新出現、未定案**的算法分歧）。
- 無 i0 可鏡像（`0920`）→ 只能先盤點+計畫。
- 需改既有 i0/`Csu*`、跨頁 checkpoint 副作用不確定、DTO 契約要變。
- `verify-c0` / 審查 agent / build **連續兩輪**修不過 → 停下回報卡點，別硬湊。
- 審查 agent 與實作 agent **反覆對同一點 FAIL↔改** 兩輪仍喬不攏 → 停下，把雙方說法一起回報人審。

## 4. 並行（multi-agent）注意
- 這些頁**彼此有耦合**（`00119↔00120`、G 對 `00116/00117`、scorecard 散在共用 service）→ 並行 agent 改同一 backend 易撞。
- 安全做法：**預設序列**；要並行只挑**真正獨立**的（如後端 `00117` 與前端 `CSU0130` 可平行，因不同專案/不同檔）。

## 5. 完成定義（整個 30%）
- **30% 進度（2026-06-05 更正；2026-06-06 再修）**：c0 評分 `00115–00120` **後端** ✅；前端（主流程/i0/契約/z0/`CSU0130`）✅，**但 c0 評分前端整組缺、Phase F 補建中**（見 `feature-inventory.md` §2D）。⚠️ **撥貸 `0921/0922` 端點在、但核心未完成**——舊系統比對（Step A/A2/B）發現 `0922 authorize` 換匯 `funcGetExchangeRate` 是 throw-stub（執行核心未跑過）+ `0921` 7P/15F/5U + `0922-main` 真 bug。**先前「撥貸結構到位」更正為「需實作 + 修正」**，詳 [`verification-handoff.md`](verification-handoff.md) §2.1/§2.2，撥貸整體 triage 進行中。其餘殘留＝整合測試（真資料/授權列）+ 2 條 CreditEval escalation。
- `page-mapping.md` §2 backlog 全部 ✅；待整合驗證清單交付給 dev/uat 整合測試（含 `TB_API_AUTH` 授權列、export 模板、CR/報表呈現）。
- **整合驗證**（真資料、授權列、模板）為**獨立後續階段**，非 build 階段；本 runbook 只負責「程式補完 + build 綠 + 形式驗證」。

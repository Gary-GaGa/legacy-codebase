# Build Task（DRAFT）— Phase V L3：FE Playwright（瀏覽器層 render/dialog/強制點-FE）

> Status: **DRAFT**（待 v2 過後或並行派）。性質＝gate ⑧ runtime conformance 的 **FE 畫面層**（瀏覽器測 render/互動/顯示條件；抓靜態+API 層看不到的 FE runtime bug，如 langType 砍資料畫面、render 斷料、dialog 回歸）。
> 依據：`phase-v-automation-plan.md §L3` + `process/local-env-manager.md`（FE 起停）+ 各頁 SRS 的「強制點 FE/both」Rn。

## 範圍
- **c0 評分容器 + 8 子頁** render/載入、dropdown、顯示條件（強制點 FE/both 的 UX 規則）。
- 原 smoke **V-2**（新頁 render：0150/0160/0170…）、**V-5**（共用 return dialog 回歸：CSU return→CSU endpoint，切 ISU→預設 endpoint）。
- 抓 **RV-1/RV-2 類 FE runtime bug**（langType 切換砍資料、GET-body、render 斷料）。
- **不含寫入**（save 互動落庫＝v3 領域）；L3＝render/display/dialog（讀型 + UI 行為）。

## ⚠️ Windows 安裝兩坑（動工前先解，找 ops；automation-plan 已記）
1. **Node 版本**：前端 Node **16.20.2**，Playwright v1.41+ 要 Node 18+ → **釘 `@playwright/test@1.40.5`**（最後支援 Node 16）**或** E2E 另開 Node 18+（與 app build 互不綁，推薦）。
2. **內網禁外網下載 browser binary**：`npx playwright install` 抓 CDN 會被內網擋 → **首選用系統已裝 Chrome**（config `use:{channel:'chrome'}`、免下載 binary）；或 `PLAYWRIGHT_DOWNLOAD_HOST` 指內網 mirror；或離線複製到 `%USERPROFILE%\AppData\Local\ms-playwright`。
3. 安裝走 **Nexus npm-all**：`yarn add -D @playwright/test@1.40.5`；config `channel:'chrome'`；`npx playwright test`（Windows 不需 `install-deps`）。
- **決策點（動工前確認）**：browser binary 走「系統 Chrome」還是「內網 mirror」。

## 形狀
- env：`tools/local-env.ps1 -Action up`（FE ready）→ Playwright `baseURL = descriptor.services.fe.url`（不自起 FE，消費 env manager）。
- page-object：c0 容器 + 8 子頁；測 render（200+關鍵元素在）、`mat-dialog`（0174/0175 類 + return dialog）、輸入驗證/顯示條件（強制點 FE）。
- 斷言對象＝各頁 SRS Contract 半的 `強制點: FE/both` Rn + 原 smoke V-2~V-6 清單。
- 失敗三分類（類比 gate ⑧）：FE render/行為≠spec FE 強制點 → assertion（開 RD 卡）；env/FE 起不來 → infra；登入/權限 → auth。

## 可貼 Codex 啟動（L3；母資料夾）
```
任務：Phase V L3 FE Playwright——c0 容器+8 子頁 render/dialog/強制點-FE smoke。依據
docs/build-tasks/phase-v-l3-fe-playwright.md + automation-plan §L3。不寫 DB（render/display/dialog only）。
0. 安裝前置（找 ops 確認）：Node 16→釘 @playwright/test@1.40.5（或另開 Node18）；browser=系統 Chrome
   channel:'chrome'（內網不下載 binary）；走 Nexus npm-all。
1. env：tools/local-env.ps1 -Action up → 讀 descriptor services.fe.url 當 Playwright baseURL（不自起 FE）。
2. page-object：c0 容器 + 8 子頁；testcase＝各頁 SRS「強制點 FE/both」Rn + smoke V-2(新頁 render)/V-5(return dialog 回歸)。
3. 測：render 200+關鍵元素、mat-dialog（含 CSU return→CSU endpoint、切 ISU→預設 endpoint 回歸）、
   輸入驗證/顯示條件、langType 切換不砍畫面資料（RV-2 類 FE 對應）。
4. 三分類：FE 行為≠spec FE 強制點→assertion（開 RD 卡，不自改）；FE 起不來→infra；登入/權限→auth。
5. finally：local-env down。
回報：PASS/FAIL（per 頁×情境，三分類）+ browser 採系統Chrome/mirror + 截點證據（去敏）+ down 確認。
   回填 verification-handoff §6。
鐵則：不寫 DB；JWT/帳密走 env 不進 repo；截圖/dump 去敏不進版控；finally 必 down；斷言失敗只報不自改產品碼。
```

## 關聯
- 架構＝`phase-v-automation-plan.md §L3`；env＝`process/local-env-manager.md`；強制點來源＝各頁 SRS（母資料夾）。

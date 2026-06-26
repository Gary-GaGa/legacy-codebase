# Phase V 自動化 plan — 全自動 runtime 驗證（bring-up script + API harness + FE Playwright）

> **決定**：owner 定 **Phase V 全自動、取代人工 smoke**（含 FE 畫面層）。屬**段③**（執行順序：① 9 包 RD → ② SRS 兩半轉換 → ③ 本段；見 `STATUS.md` 執行順序）。
> **在哪跑**：母資料夾/本機（規劃 repo 的 remote agent 打不到本機 localhost）→ **AI 產 runnable，執行在你那**。
> **時機**：架構現定（本卡）；runnable 在**段③**建（c0/FE 依 110–120 RD 定型）。**L2 v1（i0/z0 唯讀）內容正交、本可預建，但 owner 定「等 9 包 RD 批次跑完再做」**（守不交錯、Codex 專注 RD）。
> **誰建**：L2 全部 runnable（含 v1）由 **Codex 在母資料夾 materialize+跑**（需 product native SQL + localhost）；規劃 repo 只留 manifest 約定（已 grounded）。RD 批次後由規劃側產 **L2 v1 materialize 派工卡**給 Codex。

## 三層架構
### L1 Bring-up（v1 唯讀 self-driving）
> **元件化（owner 定）**：L1 起停服務＝**通用可選工具** local-env manager（權威 `docs/process/local-env-manager.md`、`tools/local-env.ps1` up/down/status；不綁 Phase V），**與 L2 harness/L3 Playwright 解耦**——三層共用同一 descriptor（base URL）、不各自起停。Phase V 消費見 `phase-v-env-manager.md`。
- **Codex 自啟動全跑**（v1 唯讀）：背景 detached 起 BE（`spring-boot:run`）+ FE（`ng serve`）、記 pid（**不前景阻塞 turn**）→ 輪詢 health 至 ready → 帳密（env、不進 repo）login 拿 JWT → 跑 harness → **teardown kill pid（不留殭屍）**。詳見 `local-phase-v-bringup.md`「可貼 Codex 自啟動殼」。
- 原「人觸發起服務」是避**前景長程序卡死 session**，已用**背景程序**解。**fallback**：帳密不可放 env → JWT 人貼一次、其餘自動。
- **v3 寫入**：teardown SQL/DML 仍人審（打正式新庫 OVSLXLON02），非全自動；v1 唯讀零寫入故可全自動。

### L2 API/DB harness（materialize 既有卡）
> **定位升級（owner 定）**：L2 API↔DB conformance ＝**DoD gate ⑧ runtime conformance**，**併入 RD per-page 迴圈**（有 harness manifest 的頁 rd-done 前 blocking；`orchestration-playbook §4c`）——不再只是 RD 後的段③。**段③殘留＝跨頁整合 + L3 FE Playwright**（無法 per-page 者）。harness＝第四種驗證（非 QA）。
- 來源＝`phase-v-api-selfverify-harness.md` + `phase-v-harness-manifest-v1.md`（manifest 已 grounded）。endpoint/method/params 以 openapi 為準；唯讀帳號 SELECT 比對。
- **v1**：i0/z0 唯讀「API↔DB 一致性」（read/list/init-query 比筆數/關鍵欄；含 **langType 五頁回歸守門**）。內容穩定、不依賴 110–120 RD，但**時機＝RD 批次後**（守不交錯）。
- **v2**：納 c0/csu（110–120）——需先套 `c0-authz-sql` 授權列（否則 403）+ 110–120 **rd-done**（契約定型）。
- **v3**：寫入（save/submit）——帶 `local-phase-v-bringup §0.1` 護欄 + teardown SQL + 測試案件號段。

### L3 FE 畫面 Playwright（全新建置）
- 瀏覽器層自動測：render/載入、dialog（`mat-dialog` 0174/0175 類）、輸入驗證/顯示條件（**強制點 FE/both 的 UX 規則**）。
- spec 來源＝各頁 SRS Contract 半的 `強制點: FE/both` Rn + 原 smoke 清單（V-2~V-6）。
- 抓 build+靜態驗**漏的 runtime FE bug**（RV-1/RV-2 類：langType 砍資料、GET-body、render 斷料）。
- 工具＝**Playwright（新依賴）**；page-object 對 c0 容器 + 8 子頁。110–120 段③建（FE 在 RD 對位後定型）；i0/z0/csu 既有頁可先建基線。
- **⚠️ Windows 安裝兩個會卡的坑（段③前先解，找 ops）**：
  1. **Node 版本**：前端是 Node **16.20.2**，但 Playwright **v1.41+ 要 Node 18+** → 釘 `@playwright/test@1.40.5`（最後支援 Node 16），或 **E2E 另開 Node 18+**（與 app build 互不綁，推薦）。
  2. **內網禁外網下載 browser binary**：`npx playwright install` 預設抓 playwright CDN、內網八成擋 → **首選用系統已裝 Chrome**（config `use: { channel: 'chrome' }`、**免下載 binary**）；或設 `PLAYWRIGHT_DOWNLOAD_HOST` 指內網 mirror；或離線複製到 `%USERPROFILE%\AppData\Local\ms-playwright`。
  - 安裝：`yarn add -D @playwright/test@1.40.5`（走內網 Nexus npm-all）→ config 設 `channel: 'chrome'` → `npx playwright test`（Windows **不需** `install-deps`，那是 Linux apt）。
  - **決策點（段③前確認）**：browser binary 走「系統 Chrome」還是「內網 mirror」。

## 原 smoke（V-1~V-6）→ 自動化對應
| smoke | 內容 | 自動化落點 |
|---|---|---|
| V-1 | 登入 + 唯讀載入 | L1 + L2（已人工過 → 轉自動）|
| V-2 | 新頁 render（0150/0160/0170…）| **L3 Playwright** |
| V-3 | save 落庫正確 | L2 **v3**（寫入 + teardown）|
| V-4 | c0/csu 非 403（授權列已套）| L2 **v2** |
| V-5 | 共用 return dialog 回歸 | **L3 Playwright** |
| V-6 | teardown SQL | L2 v3 teardown |

## 建置時機（守三段序列、不交錯）
- **架構＝現在**（本卡）。
- **L2 v1（i0/z0 唯讀）**：內容與 110–120 RD 正交（打 i0/z0 穩定面），**但 owner 定等 9 包 RD 批次跑完再做**（不在段①並行；守 Codex 單一專注）。RD 批次後規劃側產 materialize 派工卡 → Codex 母資料夾建。
- **L2 v2/v3 + L3（110–120）**：**段③建**（依 110–120 rd-done + SRS 兩半轉換 + `c0-authz-sql` 授權列套用）。
- 不在 RD/轉換中插隊跑 Phase V（含 L2 v1——owner 撤回「可預建」、改 RD 批次後）。

## 鐵則
- runnable 由 AI 產、執行在母資料夾/本機；JWT/帳密走環境變數**不進 repo**；local profile 不 commit 正式。
- 唯讀層零寫入；寫入層帶護欄 + teardown；可重複 idempotent。
- 自動化 PASS ＝證據，**不取代 owner 最終 Done**（DoD 閘門牆 + owner 蓋）。

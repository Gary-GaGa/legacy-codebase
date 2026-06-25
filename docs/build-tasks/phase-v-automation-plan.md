# Phase V 自動化 plan — 全自動 runtime 驗證（bring-up script + API harness + FE Playwright）

> **決定**：owner 2026-06-25 定 **Phase V 全自動、取代人工 smoke**（含 FE 畫面層）。屬**段③**（執行順序：① 9 包 RD → ② SRS 兩半轉換 → ③ 本段；見 `STATUS.md` 執行順序）。
> **在哪跑**：母資料夾/本機（規劃 repo 的 remote agent 打不到本機 localhost）→ **AI 產 runnable，執行在你那**。
> **時機**：架構現定（本卡）；runnable 在**段③**建（c0/FE 依 110–120 RD 定型）；唯 **L2 v1（i0/z0 唯讀）穩定、可預建**。

## 三層架構
### L1 Bring-up（起服務腳本化）
- 由 `local-phase-v-bringup.md` → 腳本：起 BE（`spring-boot:run`）+ FE（`ng serve`）+ 真 dev 帳號登入拿 JWT（環境變數、不進 repo）。
- 人觸發、腳本執行；長程序人/腳本持有，驗證層只短命呼叫。

### L2 API/DB harness（materialize 既有卡）
- 來源＝`phase-v-api-selfverify-harness.md` + `phase-v-harness-manifest-v1.md`（manifest 已 grounded）。endpoint/method/params 以 openapi 為準；唯讀帳號 SELECT 比對。
- **v1**：i0/z0 唯讀「API↔DB 一致性」（read/list/init-query 比筆數/關鍵欄；含 **langType 五頁回歸守門**）。**穩定、可預建**（不依賴 110–120 RD）。
- **v2**：納 c0/csu（110–120）——需先套 `c0-authz-sql` 授權列（否則 403）+ 110–120 **rd-done**（契約定型）。
- **v3**：寫入（save/submit）——帶 `local-phase-v-bringup §0.1` 護欄 + teardown SQL + 測試案件號段。

### L3 FE 畫面 Playwright（全新建置）
- 瀏覽器層自動測：render/載入、dialog（`mat-dialog` 0174/0175 類）、輸入驗證/顯示條件（**強制點 FE/both 的 UX 規則**）。
- spec 來源＝各頁 SRS Contract 半的 `強制點: FE/both` Rn + 原 smoke 清單（V-2~V-6）。
- 抓 build+靜態驗**漏的 runtime FE bug**（RV-1/RV-2 類：langType 砍資料、GET-body、render 斷料）。
- 工具＝**Playwright（新依賴）**；page-object 對 c0 容器 + 8 子頁。110–120 段③建（FE 在 RD 對位後定型）；i0/z0/csu 既有頁可先建基線。

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
- **L2 v1（i0/z0 唯讀）**：與 110–120 RD 正交 → **可預建/段①期間並行**（要的話我先 materialize manifest 成 runnable）。
- **L2 v2/v3 + L3（110–120）**：**段③建**（依 110–120 rd-done + SRS 兩半轉換 + `c0-authz-sql` 授權列套用）。
- 不在 RD/轉換中插隊跑 Phase V（L2 v1 foundation 例外＝正交可預建）。

## 鐵則
- runnable 由 AI 產、執行在母資料夾/本機；JWT/帳密走環境變數**不進 repo**；local profile 不 commit 正式。
- 唯讀層零寫入；寫入層帶護欄 + teardown；可重複 idempotent。
- 自動化 PASS ＝證據，**不取代 owner 最終 Done**（DoD 閘門牆 + owner 蓋）。

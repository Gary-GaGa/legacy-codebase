# Build Task — `EPROZ00700` Assign Substitute（前端唯一）

> 🟢 **已完成（2026-06-04 Codex 盤點）**：本頁**不需新建**。前端早已實作為既有 feature **`frontend/src/app/pages/deputy`**（清單 `app-table-search` + 查詢 `app-search-item` + 新增彈窗 `popup-add-deputy` + 刪除；四個 `epl-case-deputy-*` 全串好；role 驅動、部門/人員/代理人 options 動態載入；route `/deputy`、breadcrumb `E_DEPUTY`、選單來自後端 `epl-auth-menutree`）。
> 下面的建置步驟**保留作參考**；實際只剩可選的「**deputy ↔ 00700 規格 gap-check**」（欄位/role/流程差異、route 命名是否要對齊 funcId）。**勿重建新 feature**。

> 載具：**Codex CLI**（在前端專案內執行；自動讀 `AGENTS.md`）。
> ⚠️ **後端已完成** = `DeputyController`（endpoints `epl-case-deputy-options`/`epl-case-query-deputy`/`epl-case-insert-deputy`/`epl-case-delete-deputy`）→ **不要重做後端、也不要用 spec 裡的 `/api/emp-proxy` REST**。本頁只缺**前端**。
> 規格參考 `../../archive/phase1-eproz0_0700-spec.md`（DTO/欄位/狀態/級聯/驗證；但 **API 改打上述 `epl-*`**）。

## 前置（後端契約）
後端已是 `DeputyController`。在**母資料夾**啟動 Codex（同時看得到後端），於前端任務裡直接叫它讀（免手動抓）：
> 先讀後端 `DeputyController` 的 4 個 endpoint（`epl-case-deputy-options` / `-query-deputy` / `-insert-deputy` / `-delete-deputy`）的 request/response DTO，前端欄位對齊。

## 前端任務（在「前端專案」跑 Codex CLI）

```
實作 Assign Substitute（EPROZ00700）頁面。遵循本專案 AGENTS.md：照既有 z0 查詢/管理頁
複製改名；config-driven（app-table-search + *-config.ts）；元件 app-* → cub-* → mat-*；
視覺用既有元件 + 主題變數、勿寫死色碼、勿 override 元件樣式；每個狀態都要
（空/載入/錯誤/disabled）；API service 經 HTTP interceptor 附 JWT。

後端已就緒（DeputyController，RPC 式 endpoint）→ 直接接：
- epl-case-deputy-options  ：載入下拉/初始（部門、可代理人、角色/scope）
- epl-case-query-deputy    ：查詢現有代理設定（結果表格）
- epl-case-insert-deputy   ：新增/更新代理設定
- epl-case-delete-deputy   ：刪除
（以上 request/response 以後端 DeputyController 實際 DTO 為準。）

路由：新增 lazy route，命名比照既有 z0 頁（如 /assign-substitute）。
版面：
- 查詢/表單：部門 → 申請人 → 代理人 級聯下拉（options endpoint 提供）；代理起日、迄日。
- 結果表格：代理日期、代理人、Del（刪除）。
- Self / Others：第一版只做 Self；Others 先標 TODO。
驗證：起日必填、迄日 >= 起日、起日 >= 今天。
```

## 驗收
- `yarn install --frozen-lockfile` + `ng build` 離線可 build。
- 端到端：進頁(JWT)→ query 顯示現有 → insert 新增 → 表格出現 → delete 消失。
- 狀態（空/載入/錯誤/驗證失敗）正確。
- 完成 → 回填 `page-mapping.md` §2A。

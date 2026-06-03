# Build Tasks（B 批）— z0 報表/狀態 前端 6 頁

> 載具：**Codex CLI**（前端專案，讀 `AGENTS.md`）。**後端皆已就緒**（打既有 `epl-*`）。
> 原型一致：**查詢表單（篩選）→ 結果清單（+報表的 export/download）**。**做法：鏡像一個已完成的 z0 查詢/清單頁**（如 `EPROZ00600` Search / `EPROZ00400` Case Distribution），config-driven（`app-table-search` + `search-item-config`），元件 `app-*`→`cub-*`→`mat-*`，狀態 空/載入/錯誤，API 經 JWT interceptor。
> ⚠️ **篩選欄位與表格欄位以後端 controller 的 query DTO 為準**（Codex 在後端專案可讀；或前端比照舊頁），**勿臆造**。

## 共用提示（每張任務前綴）
```
遵循本專案 AGENTS.md。照既有已完成的 z0 查詢/清單頁（如 search / case-distribution）複製改名。
config-driven：用 search-item-config 宣告篩選列（交給 app-table-search 渲染）+ 結果表格。
篩選/欄位以後端對應 controller 的 query request/response DTO 為準，不要自己編。
元件 app-* → cub-* → mat-*；視覺用既有元件 + 主題變數、勿寫死色碼；
狀態涵蓋 空/載入/錯誤；API service 經 HTTP interceptor 附 JWT。新增 lazy route。
```

---

### 1) `EPROZ00610` Credit Reviewer On Hand Status（狀態清單）
```
（接共用提示）頁面：Credit Reviewer On Hand Status。route 例：/credit-reviewer-onhand-status。
查詢清單 → epl-case-credit-reviewer-onhandstatus-query-list。
純查詢+表格，無 export。篩選/欄位依該 controller DTO。
```

### 2) `EPROZ00660` CAD On Hand Status（狀態清單）
```
（接共用提示）頁面：CAD On Hand Status。route 例：/cad-onhand-status。
查詢清單 → epl-case-CAD-onhandstatus-query-list。純查詢+表格，無 export。
```

### 3) `EPROZ00620` Application Delete Report（報表）
```
（接共用提示）頁面：Application Delete Report。route 例：/application-delete-report。
搜尋 → epl-case-application-delete-report-btn-search；查詢清單 → epl-case-application-delete-report-query-list。
查詢表單 + 結果表格。
```

### 4) `EPROZ00630` Deviation Case Report（報表 + 下載）
```
（接共用提示）頁面：Deviation Case Report。route 例：/deviation-case-report。
部門/貸放類型下拉 → epl-sele-dept-loantype-deviation；查詢清單 → epl-list-deviation；
檔案下載 → epl-file-download-deviation（下載沿用既有檔案下載元件/模式）。
```

### 5) `EPROZ00640` Scorecard Report（報表 + PDF/Excel 匯出）
```
（接共用提示）頁面：Scorecard Report（MIS）。route 例：/scorecard-report。
查詢清單 → epl-case-mis-report-scorecard-query-list；
匯出 PDF → epl-case-mis-report-scorecard-export-pdf；
匯出 Excel → epl-case-mis-report-scorecard-export-excel。
表格上方/旁加「匯出 PDF / 匯出 Excel」按鈕，觸發對應 endpoint 下載。
```

### 6) `EPROZ00650` Application Cancel Report（報表）
```
（接共用提示）頁面：Application Cancel Report。route 例：/application-cancel-report。
部門/貸放類型下拉 → epl-sele-dept-loantype-canreason；查詢清單 → epl-list-cancelreport。
查詢表單 + 結果表格。
```

## 驗收（每頁）
- `yarn install --frozen-lockfile` + `ng build` 離線可 build。
- 篩選 → 查詢 → 表格顯示；報表頁 export/download 可觸發。
- 狀態 空/載入/錯誤 正確。
- 完成 → 回填 `page-mapping.md` §2A。

## 備註
- 6 頁共用原型，建議**先做 1 頁（如 00610 最單純）跑通**，再套用到其餘 5 頁。
- 報表 export 後端已存在（**R2 對這幾頁不阻塞**）；R2「新報表服務」屬底層產製決策，與此前端接線無關。

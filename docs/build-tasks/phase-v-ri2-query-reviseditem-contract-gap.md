# RD 契約缺口卡 — `epl-case-query-reviseditem` 空案件漏必填 `revisedType`（Phase V RI-2）

> 來源：Phase V harness v1.1 自驗 RI-2（assertion FAIL）。**planning 側補建**（dev v1.1 報告稱已建此卡，實際未進 repo → 補上，免真 bug 遺失）。性質＝**產品契約缺口、走 RD flow 修**（非 harness 範圍）。
> Status：Open，待 SA/owner 裁權威方向 → RD 修。

## 發現（去敏）
- endpoint：`epl-case-query-reviseditem`（GET，EPROZ00800 revised-item init-query）。
- fixture：**有 case、但無 `TB_REVISED_ITEM` 列**的有效案號（去敏＝fixture-B；真案號留本機證據）。
- 實際 response：**HTTP 200 / `code=0000` / Success**（success data envelope），`data` 有 `lonTypeCode`/`secureAttribute`、`item1`–`item14` 與 `reasonMemo` 皆 blank，**但缺 `data.revisedType` 與 `data.revisedTypeSize`**。
- 對照契約：現行 `docs/specs/srs/EPROZ00800/openapi.yaml` 的 `QueryRevisedItemResponse` 將 **`revisedType`/`revisedTypeSize` 列為 `required`**（`:216`-`:217`、`:236`/`:241`）。
- 原始完整 dump＝本機證據（gitignore，含真案號，不進 repo）；上述去敏摘錄足供 RD 判讀。

## 為何是真缺口（非 harness/fixture 問題，已消歧）
- 回的是 **success envelope（code 0000）非 `MSG_DATA_NOT_FOUND`** → fixture 確為「有效 case、僅無 revised-item 列」，非「無 case」。
- `revisedType` 是**選項字典（下拉來源）**，源自 `TB_COMMON_FIELD_OPTIONS`/`TB_MULTI_LANG`（spec DB-D5），**與案件有無 revised-item 列無關**——空案件仍需渲染下拉。
- spec R2（`spec.md:42`）：「case 存在但無 revised item 列時回 **blank items**」＝仍是 data envelope；契約要求該 envelope 含 required `revisedType`。
- 已排除：path 取錯（harness 取 `data.revisedType`、與 openapi envelope 一致）；BOM/授權（RI-1 同 endpoint 同 role PASS）。

## 裁決方向（SA/owner 定權威；別自動斷定哪邊錯）
契約 vs 實作不一致，兩種收法：
1. **（建議）改 API**：空 revised-item 案件的 success envelope **仍回 `revisedType`/`revisedTypeSize`** 選項字典（理由：選項是表單渲染資料、非案件資料，空案件也要；DB-D5 來源獨立於 revised-item 列）。→ RD 改 BE query service。
2. **（替代）改 spec**：若業務確認空案件可省選項，則 openapi 將二欄改非 required（須業務依據）。→ SA 改 openapi + 註 delta。
> 預設傾向 1（多數 FE 表單需要選項字典渲染），但**由 SA/owner 拍板**，不在此自決。

## 範圍 / 落點
- 修點＝**產品 BE**（母資料夾 `RevisedItemController`/`RevisedItemServiceImpl` 的 query 組裝），走 **RD flow**；非 Phase V harness。
- harness 端：RI-2 斷言**正確**（忠實抓到契約缺口）；待方向 1 修後 RI-2 應轉 PASS（或方向 2 則同步改斷言）。

## 關聯
- 契約＝`docs/specs/srs/EPROZ00800/openapi.yaml` `QueryRevisedItemResponse`；行為＝`spec.md` R2/R5/R6、DB-D5（選項來源）。
- 偵測＝`phase-v-api-selfverify-runtime-bugs.md`（RB-4→本卡）、`verification/verification-handoff.md §6.3` RI-2 列。

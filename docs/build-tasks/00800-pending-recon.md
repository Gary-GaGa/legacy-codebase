# Build Task — `EPROZ00800` 待決取證（RP6/RP4/RP10，唯讀 recon）

> 載具：Codex（母資料夾，**需可讀舊 EPRO source**；舊 source 不在就逐項標 `UNFOUND`，**不准猜**）。
> **性質＝唯讀取證**：產品 repo（新/舊）**一個檔都不改**；唯一產出＝findings 報告寫回規劃 repo。
> **背景**：`00800` 仍開的待決中，RP6/RP4/RP10 缺的是**證據**而非裁定意見——取證到位後 SA/RD 即可關（內容詳 `docs/specs/srs/EPROZ00800/spec.md` §@PENDING；視圖 `docs/pending-register.md`）。

## 目標
對舊 EPRO source（`z0` 模組 `EPROZ0_0800` 及 is/iu/cs/cu 的 `_0260`）取證三題，逐項附 `file:line`，寫進本資料夾新檔 `00800-pending-recon-findings.md`（產出後才存在）。

## 取證項
| # | 為哪個待決 | 取什麼證 | 去哪找 |
|---|---|---|---|
| **E1 / RP6** | ITEM1~14 正式名稱（SA 取數）| 舊 `EPROZ0_0800` 畫面上 ITEM1~14 each 的**顯示 label**（中/英），逐 ITEM 一列：`ITEMn ↔ label ↔ 出處 file:line`；順帶列新 FE `revised-item` 現顯示字串對照 | 舊 JSP + resource bundle（`*.properties`/messages）|
| **E2 / RP4** | ITEM1 與 ITEM10 皆 TENOR＝設計 or 缺陷 | 舊系統兩者的 label/欄位/側效是否**確實相同**：勾選後各觸發什麼（程式路徑 file:line）；若舊系統有區分（label 不同、側效不同、僅其一有 RI-MAT），逐點列出 | 舊 JSP + 舊 action/service |
| **E3 / RP10** | checkpoint `_0260` 確切 key 清單 | 舊系統 `EPRO{IS,IU,CS,CU}_0260` 重處理時 checkpoint/pageCheckMap **實際寫入的 key 值**（四模組各列）；對照新碼現寫的 key（as-is 證據＝`00800-verification-findings.md` S7）標同/異 | 舊 checkpoint 寫點（搜 `_0260`/pageCheckMap）|

## 鐵則
1. **唯讀**：不改新碼、不改舊碼、不跑 build；只搜只讀。
2. **每個結論附 `file:line`**；找不到＝該項標 `UNFOUND`（含搜過哪些路徑/關鍵字），**禁止以新碼或常理回填**。
3. 只報證據與傾向（一句），**裁定留給 SA/RD**——本卡不關任何 RP。
4. 一題一節，報告依上表編號（E1/E2/E3）。

## 回報
- `00800-pending-recon-findings.md` 三節齊（或標 UNFOUND）；產品 repo `git status --short` 乾淨（零修改）。

> 過了：SA 拿 E1 裁 RP6（順帶 E2→RP4）、RD 拿 E3 裁 RP10 → 回填 spec §@PENDING + `pending-register.md`（gate⑦ 會驗同步）→ 解鎖 R13.4/13.5 與 R14 key 重映射的後續修復卡。

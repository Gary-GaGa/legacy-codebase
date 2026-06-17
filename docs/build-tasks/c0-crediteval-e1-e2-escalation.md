# Build Task — c0 評分既有服務 2 條 escalation（E1/E2；信用決策 domain 裁定 + 唯讀碼驗前置）

> **性質**：兩條皆**既有 `CsuCreditEvalAndCreditDecisionServiceImpl` 行為**（grandfathered、`backend/AGENTS.md §6.1` 禁改）→ **非 00118 本體缺陷、須信用決策 domain 裁**。每條結構＝**①唯讀碼驗**（Codex/RD 追碼路徑，餵裁定）→ **②domain 裁定**（intended vs bug）。
> **怎麼來的**：00118（企金 corporate scorecard）建置 code review 抓到既有服務兩個可疑行為；§6.1 禁改 `Csu*` → 不在 00118 修、升級。
> **背景全文**：`verification/verification-handoff.md §1`、`decisions.md`（00118 calc 兩決策 / gate-b 裁決兩列）、`page-mapping.md §2B`（escalation 登記）、`pending-register` E1/E2。
>
> 命名：c0＝企金評分線（00114-00120）；CS＝企金有擔、CU＝企金無擔；`crScoreCardCompleted` 雙位元＝第1碼 00114／第2碼 00118。

---

## 任務 A — E1：CU-return checkpoint 只清 CS、無 CU 分流

**證據**：`CsuCreditEvalAndCreditDecisionServiceImpl:2985`——退回（Return, status `98`）時硬編碼只清 `TB_CHECK_POINTS_CS`，**無 CU 分流**。

### A-1 唯讀碼驗（Codex/RD，餵裁定）
追：**CU（無擔企金）案件會不會真的走到這段 00118 checkpoint Return 流程？**
- 由容器 `businessType`/`secureAttribute` routing 進這個 service 的 Return(98) 路徑時，CU 是否可達？（對照其他 c0/csu 頁的 CS/CU 分流慣例）
- 若可達，CU 退回時應清哪個 checkpoint 表（`TB_CHECK_POINTS_CU`）？現碼是否完全沒處理？
- 附 `file:line`；推不出＝UNFOUND、不猜。

### A-2 domain 裁定（信用決策 domain）
| 碼驗結果 | → 裁定 |
|---|---|
| CU **會**走到 | 🔴 缺 CU 分流＝bug → 加 CU 分流（**改既有 `Csu*` 破 §6.1 → 需核可例外**，比照 00118 calc 引擎 `ALLOW_SHARED_FUNC` precedent；單獨 commit、先報 diff）|
| CU **不會**走到 | ✅ 非 bug → 結案（記錄「CU 不達此路徑」的證據）|

---

## 任務 B — E2：`crScoreCardCompleted` 整欄覆寫成 `"NN"`

**證據**：`CsuCreditEvalAndCreditDecisionServiceImpl:2890`——把 `crScoreCardCompleted` 整個 2 字元欄覆寫成 `"NN"`；該欄雙位元契約（第1碼=00114、第2碼=00118）→ 整欄覆寫把兩碼都歸 N。

### B-1 唯讀碼驗（Codex/RD，餵裁定）
追：
- **時序**：`:2890` 覆寫發生在 00118 save **之前還是之後**？（決定它是否會蓋掉剛寫的值）
- **踩界**：整欄 `"NN"` 是否清掉 00114 擁有的**第 1 碼**（而非只動第 2 碼）？
- **下游**：submit gate 是否讀 `crScoreCardCompleted`？讀第幾碼？`"NN"` 會不會讓 00114/00118 的 submit 期望值失準？
- 附 `file:line`。

### B-2 domain 裁定（信用決策 domain）
| 碼驗結果 | → 裁定 |
|---|---|
| intended（決策重置，合理地把兩碼都清、時序/下游無害）| ✅ 文件化原因、結案 |
| latent bug（蓋掉 00114 第1碼／蓋掉剛 save 的值／submit gate 失準）| 🔴 修（**改既有 `Csu*` 破 §6.1 → 需核可例外**；只動該動的碼、單獨 commit、先報 diff）|

---

## 鐵則
1. **§6.1：禁改既有 `Csu*`**——唯讀碼驗階段只讀不改；任何修正須**先核可 §6.1 例外**（比照 00118 `ALLOW_SHARED_FUNC` precedent、記 `AGENTS.md §6.1`）才動，且單獨 commit、先報 diff 供人審。
2. 每結論附 `file:line`；推不出＝UNFOUND，不臆測既有碼意圖。
3. 「intended vs bug」是 domain 決策題——碼驗只給證據，**裁定權在信用決策 domain**。
4. 教訓（decisions.md 00118 gate-b）：review 放行條件**勿把「既有碼行為」寫成新頁的契約**。

## 回報落點
唯讀碼驗 findings → 新 `done/c0-crediteval-e1-e2-findings.md`；domain 裁定 → 回填 `verification-handoff §1`、`pending-register` E1/E2、`feature-inventory §⑤`、`decisions.md`（若改既有碼則記 §6.1 例外）。

> 過了：c0 評分線兩條既有服務 escalation 收斂（intended 結案 or §6.1 例外修），00118 corporate 決策生命週期正確性坐實。

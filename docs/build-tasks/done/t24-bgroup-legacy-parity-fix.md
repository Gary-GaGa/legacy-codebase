# Build Task — T24 B-group 照舊系統規格 batch-fix（owner 裁定 2026-06-16）

> **⚠️ 2026-06-20 SRS-層 re-open**：本卡＝**code 層 parity-fix（已完成、`3d6f446`），其結果＝SRS 的 as-is baseline 證據、非 SRS to-be 定案**。產 T24 SRS（`EPROISU0922`）時 to-be 走 §5b 梯裁（refactor-spec 有對應 T24 調整→偏新使用方式）+owner confirm，**勿把本卡當「T24 最終規格」**。見 `decisions.md`「T24 於 SRS 層 re-open」、`pending-register`「T24 SRS re-open」。
> **owner 裁定（2026-06-16）：「T24 都照舊系統規格」** → 撥貸 T24 組檔的 outbound 欄值/格式/來源/截斷**一律對齊舊系統**（延伸 A-1/A-2 已立的 parity 原則到整個 T24 檔）。
> 載具：Codex（母資料夾，新後端 + legacy 唯讀對照 → 改新後端）。**性質＝逐欄坐実舊行為 → 改新碼對齊**（同 get-body/langtype sweep 模式，但**含金錢欄 → pre-push 最嚴人審**）。
> 範圍清單＝`disbursement/disbursement-domain-escalations.md` §B（B-2~B-5）＋§A A-3；逐欄主題見該檔。

## ⚠️ 裁定邊界（必讀，勿誤改）
- **「照舊規格」適用於舊系統有 spec 之處**（欄位位置/來源/格式/截斷）。
- **✅ 幣別分支＝A-5 已裁 keep（06-16 owner）**：坐実結果為「收窄」（舊 non-USD 通吃→新 USD/KHR only、其他 null/0），但 **owner 裁撥貸有效幣別＝USD+KHR only（柬埔寨）→ 收窄無害、keep**（non-USD-non-KHR path＝by-design-unreachable、非 bug、**不做對等修**）。
- **處置**：E21/G4/G10/H8、fee rounding 幣別分支 **維持新（keep）、不照舊不對等修**；**補規格**＝撥貸有效幣別＝USD+KHR（見 triage）。殘小（非阻擋）：KHR rounding `DOWN`（keep）、G/H 幣別來源（USD/KHR 內 disbursement vs account 幣別差異→資料約束待 RD）。其餘 T24 欄（非幣別分支）照舊照修。

## 逐欄（照舊；先坐実舊 `file:line` 再改新）
| 欄 | 項 | 照舊＝ | 坐実 + 改 |
|---|---|---|---|
| `A16` | B-2 `NORMAL.LAON`/`LOAN` | 舊送 T24 的字面值 | 坐実舊 A16 值 → 新對齊（若舊＝`LAON` 則保留 `LAON`）|
| `C12` | B-3 `SUG_VAL` 讀錯表 | 舊讀的來源表 | 坐実舊讀哪表 → 新改回 |
| `C13` | B-3 日期來源 | 舊來源欄（疑 `DECISION_DATE`）| 坐実 → 新改回 |
| `A15` | B-3 空值補 `N/A` | 舊空值行為 | 坐実 → 對齊 |
| `G11–G12` | B-3 fee remark mapping | 舊 mapping | 坐実 → 對齊 |
| `A31`/`G7` | B-4 `AGREEMENT_NO` 截斷 | 舊取後 16 碼 | 照舊取後 16（T24 欄寬同 A-1「先固定 parity、新環境拒收再調」）|
| 行尾 / `C26` | B-5 `\r\n` vs `\n`、title-deed join | 舊行尾政策、舊 join 行為 | 坐実舊 → 對齊 |
| `E21` | A-3 非 USD 非 KHR 輸出 | **舊全換匯**（非輸出 0）| 照舊全換匯；**KHR 分支先不動**（待坐実，見邊界）|
| `G4`/`G10`/`H8` | B-3 換匯欄 | 舊欄位來源/格式 | **欄位位置/來源/格式照舊**；**KHR 幣別分支先不動**（待坐実）|

## 鐵則
1. **逐欄先坐実舊 `file:line`**（legacy T24 組檔 `EPRO_IS0922` 等）→ 再改新（`SummaryServiceImpl` T24 段）對齊；附新舊對照。
2. **金錢欄（換匯/fee/截斷）逐項 commit + pre-push 最嚴人審**（同 M10 標準）；非金錢欄可批量。
3. **KHR 幣別分支：先不動**（不 revert、不假設保留）→ 待另案 Codex 坐実新舊差異 + domain 確認；本批只動非幣別分支的 T24 欄。
4. 同段其他欄不誤動；`mvn package` 綠；FE 無涉（純後端組檔）。
5. 不確定舊行為＝`UNFOUND`、停手回報，不猜。

## 回報
逐欄表：`欄 ↔ 舊行為 file:line ↔ 新現況 ↔ 改法 ↔ commit`；findings 寫 `t24-bgroup-legacy-parity-fix-findings.md`；**金錢欄先報 diff 人審才推**。

> 過了：撥貸 T24 檔對齊舊規格（+KHR 邊界）→ 撥貸端到端最後大塊收；回填 triage §2/§3、escalations §B、feature-inventory、STATUS。

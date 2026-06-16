# Build Task — T24 B-group 照舊系統規格 batch-fix（owner 裁定 2026-06-16）

> **owner 裁定（2026-06-16）：「T24 都照舊系統規格」** → 撥貸 T24 組檔的 outbound 欄值/格式/來源/截斷**一律對齊舊系統**（延伸 A-1/A-2 已立的 parity 原則到整個 T24 檔）。
> 載具：Codex（母資料夾，新後端 + legacy 唯讀對照 → 改新後端）。**性質＝逐欄坐実舊行為 → 改新碼對齊**（同 get-body/langtype sweep 模式，但**含金錢欄 → pre-push 最嚴人審**）。
> 範圍清單＝`disbursement/disbursement-domain-escalations.md` §B（B-2~B-5）＋§A A-3；逐欄主題見該檔。

## ⚠️ 裁定邊界（必讀，勿誤改）
- **「照舊規格」適用於舊系統有 spec 之處**（欄位位置/來源/格式/截斷）。
- **⚠️ KHR 幣別分支＝未確認、先不動（勿假設保留、也勿自動 revert）**：
  - 證據（坐実）：新系統 fee rounding 有 `KHR`+`RoundingMode.DOWN` 分支、E21 有 KHR 處理（`verification-handoff §2.1:54`、`§2.3:85`，Step-B 老↔新比對）。
  - **但「刻意在地化」係推斷未確認**（A-5「🟢 **疑似**」、handoff「**多半**」）。
  - **「舊僅 USD」只對 fee rounding 分支成立**：舊 `getExchangeRate` **仍以 `CcyCode=KHR` 查匯率**（`done/a1-oq-legacy-recon-findings.md:8`）→ 非「舊全無 KHR」。
- **處置**：本 batch-fix **先不碰 KHR 換匯/fee 幣別分支**；**另派 Codex 坐実新舊幣別處理差異 + domain 確認**後再定該分支去留。其餘 T24 欄（非幣別分支）照舊照修。

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

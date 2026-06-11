# 全量重構盤點 — QC 日誌（Claude 側,逐場審核紀錄）

> 配 `full-refactor-audit.md`（卡）與 `refactor-audit/master.md`（Codex 側進度板）。本檔＝**QC 判定與累計發現的單一出處**,每場 QC 後更新;S-final 與人審以此對照。
> QC 方法:讀 `sync-task` 分支該場 diff——schema/小計/master 三同步、證據完整性（file:line）、UNFOUND 的搜尋紀錄是否足以排除假陰性。

## 逐場 QC 判定
| S | commit | QC | 摘要 |
|---|---|---|---|
| S0 | `1d48eec` | 🟢 | 骨架齊;唯 10 個模組檔為 0-byte 空殼（陸續清理中）。 |
| S1 | `1d48eec` | 🟢 | M1 4 列全綠;M9 11 列中 10 列 UNFOUND（見發現 F-2/F-3）。SOURCE=old-source 確立（`legacy-epro/` 在母資料夾）。 |
| S2 | `d6ae795` | 🟢 | M2a 26 列;計數口徑定版（一頁/一 popup 一列,AJAX 收證據欄）。發現 F-4。 |
| S3 | `4169498` | 🟢 | M2b 8 列+M3 20 列;0922 BE 🟡（A-1 stub,正確標法）;M2 空殼已刪。發現 F-5。 |
| S4 | `33c32d3` | 🟡→S4b | M4 20+M5 17 列;22 列 FE=UNFOUND 僅憑精確字串搜尋,QC 退回復核。 |
| S4b | `e4da52d` | 🟢 | 四錨點復核,22 列全維持 UNFOUND → **F-1 翻案實錘**。四錨點法自此為 FE 判定標配。 |
| S5 | `9d3aa76` | 🟢 | M6 §A 12 列全綠;主動附四錨點證據（教訓內化）。M6a/M6b 空殼待 S6 清。 |

## 累計發現（S-final diff 報告的預載;裁定全部留給人審）
| # | 發現 | 證據位置 | 影響/建議動作 |
|---|---|---|---|
| **F-1** 🔴頭條 | **企金主流程 FE 後半段整段缺**:`EPROCSU0150/0160/0170/0171/0172/0173` 六新頁+3 popup（0174/0175/0261）FE 不存在;BE `Csu*Controller` 六支全在。corporate/ 目錄僅 4 資料夾;page-code 未註冊;共用 dialog 只接 ISU endpoint | `M4-cs.md` §S4b、`M5-cu.md` §S4b | inventory §2B FE ✅＝70% 時代殘留謊言（同翻案#1 根因）。補建型態=照 isu 鏡像（Phase F 同型,可估）;S-final 後改寫 §2B+開卡（暫名 Phase G） |
| F-2 | M9:`SysNews` 公告 CRUD、`BatchManager`、`cacheMonitor` 新碼 FE/BE 全無對應 | `M9-common.md` | 遷/不遷待裁;若不遷補 🚫 裁決出處 |
| F-3 | M9:demo 頁 4 列 UNFOUND | `M9-common.md` | 大概率 🚫,等正式裁定 |
| F-4 | Property Info 家族:`EPROIS_0240`/`EPROIU_0140`/`EPROIU_0240` UNFOUND——drop 裁決明文只點名 `EPROIS_0140` | `M2-is.md`、`M3-iu.md` | 一條裁決可關三列 |
| F-5 | 404/error 頁 BE 端 UNFOUND（FE error route 在） | `M9-common.md` | 低風險;確認新架構是否本就 FE 承載 |

## 口徑備忘（S-final 統計時遵守）
- 狀態字彙同義:`✅ 碼在`≡`碼在`、`❓`≡`UNFOUND`（各場用字略飄,master 彙總表已正規化）。
- 列粒度:S2 起=一頁/一 popup 一列;**M1（4 列）/M9（11 列）是 action 級粒度**,S-final 總量表需註記或重整（M1≈2 頁、M9 demo 4 列≈1 頁+1 popup）。
- 列彙總:任一端 UNFOUND → 整列計 UNFOUND（M4 檔頭口徑,全模組沿用）。
- FE 判定標配=四錨點（S4b 起):目錄樹/page-code 註冊/service 動態拼接/共用元件分支;只做精確字串搜尋不得標 UNFOUND。

> 維護:每場 QC 後加一列;S-final 出 `diff-vs-inventory.md` 後,本檔發現區與其對齊,人審逐條裁定 → 回填 `feature-inventory.md`。

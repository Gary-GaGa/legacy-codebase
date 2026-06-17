# Bible↔PRD 對照表（trace sidecar）— `CDC-EPRO-0001` × `EPROZ00800`

> **為什麼是 sidecar**：PRD 快照 verbatim 不可編（[`README.md`](README.md) 放置規則），追溯標記故放本表。
> **誰讀**：`scripts/check-srs-bundle.py` **gateⒷ**（機械、advisory）+ `spec-reviewer`（語意）。
> **行格式（機械約定）**：表 A 每列第 1 欄 `BR-nnn`——無 `REQ-nnn` 對應時**必須**含 `BP-n` 或 `@PENDING`（否則 gateⒷ warn=漂移未登記）；表 B 每列第 1 欄 `REQ-nnn`，PRD 快照的每個 REQ 都要在本表出現。
> 來源：Bible [`../bible/bible-eproposal.md`](../bible/bible-eproposal.md)（BR 表）、PRD 快照 [`PRD-CDC-EPRO-0001-v1.1-EPROZ00800.md`](PRD-CDC-EPRO-0001-v1.1-EPROZ00800.md)、缺口登記 [`../../pending-register.md`](../../pending-register.md) §Bible→PRD seam。

## A. Bible → PRD（下行：業務邊界有沒有被 PRD 承載）
| Bible 錨點 | PRD 承載 | 狀態 | 備註 |
|---|---|---|---|
| BR-014（僅展期/展變適用）| —（無 REQ；§1.3 案件類型欄空白）| **GAP → BP-1** | Bible 災難情境點名「不該顯示卻顯示」要測；SC-002 |
| BR-015（展期/展變＝不同案件類型，起案案件類型欄位確認）| —（無 REQ）| **GAP → BP-2** | 兩 type 軸（案件類型 vs `LON_TYPE_CODE`）關係未定義；SC-001 |
| BR-016（展期/展變共用同一套驗證規則）| §5.3 隱含（檢核未分案件類型）即 REQ-003 之隱含前提，未明示 | **PARTIAL → BP-3** | 是否分流未決；SC-005 |
| BR-017（影響 `EPROISU0150`、顯示於 `EPROISU0173`）| §5.5 承載資料面（loan condition，REQ-005）；0173 全無 | **PARTIAL → BP-4** | §5.6 re-process 清單不含 0150/0173；SC-003/004 |
| 情境02 業務閉環（案件類型→啟用→記錄→影響 0150→顯示 0173）| §1.1/§3.1 承載中段（記錄/儲存）；頭（gating）尾（0173）落空 | PARTIAL（頭=BP-1、尾=BP-4）| 旅程級錨點 |

## B. PRD → Bible（上行：REQ 的業務出處）
| PRD REQ | Bible 錨點 | 備註 |
|---|---|---|
| REQ-001（開啟頁面）| 情境02（隱含：進入頁籤）| |
| REQ-002（查詢選項/既有資料）| 情境02（隱含：記錄修訂資料）| |
| REQ-003（檢核）| BR-016（共用驗證規則）| 檢核細則（ITEM/REASON）為 code-derived |
| REQ-004（儲存）| 情境02 業務閉環 | |
| REQ-005（清除/還原 RI-MAT）| **Bible 無**（code-derived；最近錨點 SC-003）| Bible 回填候選——RI-MAT 是否業務意圖待 TBD-006/RP1 |
| REQ-006（checkpoint/page-menu）| **Bible 無**（code-derived；閉環「影響 0150」間接相關）| Bible 回填候選 |
| REQ-007（錯誤處理）| **Bible 無**（災難情境僅旅程級「可追蹤可阻擋」）| 錯誤碼層 code-derived |

> **讀法**：A 表抓「Bible 有、PRD 漏」（→BP 登記）；B 表抓「PRD 有、Bible 無」（→Bible 回填候選 or legacy-当-需求嫌疑，後者由 spec-reviewer 維度 3 把關）。
> **維護**：外部 PRD 改版重新快照時，本表同步重對；BP-n 關閉時更新狀態欄。

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
| S6 | `bc3f2ca` | 🟢 | M6 §B 10 列全綠 → **M6 合計 22/22,i0 模組收口、inventory §2C 獲 zero-based 驗證**;空殼已清;窮盡聲明（無剩餘非 partial i0 JSP）已記。 |
| S7 | `8c7ea52` | 🟢 | M7a 10 列:6 綠+2🟡(0114/0214→F-7)+2 UNFOUND(0211/0213→F-6);四錨點完整;「page-mapping 待確認≠不遷裁決」判斷正確。 |
| S8 | `859044a` | 🟢 | M7b 10 列:8 綠+2🟡(0119/0219→F-8) → **M7 c0 收口（20 列=14綠/4🟡/2UNFOUND）**;00117/00120 staff 不接判讀正確（合決策 B）;00118 oldCase pageMap 對等性獲驗;窮盡聲明已記。 |
| S9 | `9c9aa81` | 🟢 | M8 z0 18 列:12 綠+6🟡 → **模組場全收（S1–S9 完成）**;新增 F-9~F-12;00800 init-query 🟡=已知 RP9（審計獨立重發現=方法交叉驗證通過）;窮盡聲明已記。 |
| S-final | `a5f96bd` | 🟢 | `diff-vs-inventory.md`:總量 166 列（116綠/11🟡/2🚫/37UNFOUND）、DIFF-001~016、BIBLE-GAP-1~5、回填清單 23 項。**QC-INPUT-UNFOUND**:工作目錄未 merge main 致讀不到本檔——正確地不猜;F↔DIFF 映射由 QC 側補做（見下表）,gate 視為已關。 |

## F↔DIFF 映射（QC 側補做,關 QC-INPUT-UNFOUND;2026-06-11）
| F | DIFF 對應 | 備註 |
|---|---|---|
| F-1 | DIFF-001 | 頭條一致 |
| F-2/F-3 | DIFF-016 | M9 整組（SysNews/BatchManager/cacheMonitor/demo）收斂在 M9 總列 |
| F-4 | DIFF-002+DIFF-003 | Property Info 家族拆 IS/IU 兩條 |
| F-5 | DIFF-016 | error/404 BE UNFOUND 併入 M9 |
| F-6 | DIFF-007 | 0211/0213 |
| F-7 | DIFF-006 | ⚠️ DIFF 建議「FE 改 🟡」;F-7 補充:先驗 Calc 鈕是否真隱（inventory §2D 設計）——隱=可降綠 |
| F-8 | DIFF-008 | 00119 空 options |
| F-9/F-10 | DIFF-010 | ToDo+兩 popup |
| F-11 | DIFF-013 | 00640 PDF 註解 |
| F-12 | DIFF-014 | 00660 endpoint 404 |
| RP9（已知） | DIFF-015 | 交叉驗證通過 |
| —（新增追蹤） | **BIBLE-GAP-1~5 驗證** | 待查舊源是否真有 `EPROZ00670`/`EPROIS_0180/0182/0183/0184` JSP/action:有=S2/S3 窮盡有漏需補列;無=Bible 錨點收斂到 0181/0922 |

## 累計發現（S-final diff 報告的預載;裁定全部留給人審）
| # | 發現 | 證據位置 | 影響/建議動作 |
|---|---|---|---|
| **F-1** 🔴頭條 | **企金主流程 FE 後半段整段缺**:`EPROCSU0150/0160/0170/0171/0172/0173` 六新頁+3 popup（0174/0175/0261）FE 不存在;BE `Csu*Controller` 六支全在。corporate/ 目錄僅 4 資料夾;page-code 未註冊;共用 dialog 只接 ISU endpoint | `M4-cs.md` §S4b、`M5-cu.md` §S4b | inventory §2B FE ✅＝70% 時代殘留謊言（同翻案#1 根因）。補建型態=照 isu 鏡像（Phase F 同型,可估）;S-final 後改寫 §2B+開卡（暫名 Phase G） |
| F-2 | M9:`SysNews` 公告 CRUD、`BatchManager`、`cacheMonitor` 新碼 FE/BE 全無對應 | `M9-common.md` | 遷/不遷待裁;若不遷補 🚫 裁決出處 |
| F-3 | M9:demo 頁 4 列 UNFOUND | `M9-common.md` | 大概率 🚫,等正式裁定 |
| F-4 | Property Info 家族:`EPROIS_0240`/`EPROIU_0140`/`EPROIU_0240` UNFOUND——drop 裁決明文只點名 `EPROIS_0140` | `M2-is.md`、`M3-iu.md` | 一條裁決可關三列 |
| F-5 | 404/error 頁 BE 端 UNFOUND（FE error route 在） | `M9-common.md` | 低風險;確認新架構是否本就 FE 承載 |
| F-6 | `EPROC0_0211/0213`（展期限定 FinEvalTable/Scorecard）舊源有完整碼,新 FE/BE 全無;舊系統本身不對稱（0100 系列無 0111/0113） | `M7a-c0-00110-00115.md` | page-mapping「待確認」≠裁決——需正式裁定遷/不遷（c0 展期案的這兩功能是否由 00116-00120 涵蓋） |
| F-7 | `EPROC0_0114/0214` FE calc handler 空 return、無 calc 路由（舊有 getRate） | `M7a-c0-00110-00115.md` | 疑為 inventory §2D 已知設計（無 c0 calc→隱鈕、BE save 算,`62ec62f`）;驗 template 鈕是否真隱——隱=降綠,未隱=真 UI bug |
| F-8 🟡真缺陷候選 | `EPROC0_0119/0219`（FinStmt FI）FE `getMenu()` 回空 `currencyList`/`currencyUnitList`/`typeOfYearList`,但必填 select 欄位有消費——疑誤套 00120 的「不接 options」模式（00120 頁不消費,00119 有消費） | `M7b-c0-00116-00120-rest.md` | runtime-silent 類;查 options 是否由 info 回應另路供給;否則開修復卡（一行接回 menu 端點級別） |
| F-9 | `EPROZ00100` ToDo:呈報書下載走 `goPath()` 非報表服務、upload handler 留 console stub（inventory 標 ✅） | `M8-z0.md` | 部分屬 R2 報表軌;upload stub 需修復卡 |
| F-10 🟡真缺陷候選 | `EPROZ00101/00102` 刪/結案 popup:測試用 `setReasonList()` 硬編碼 D01–D99 覆蓋 API 回的 reason list——測試碼殘留正式路徑 | `M8-z0.md` | 小修復卡（刪覆蓋呼叫即可）;Phase V 驗 reason 正確性 |
| F-11 | `EPROZ00640` BE PDF export:writer/document 輸出被註解、回 `ResponseEntity<String>`,FE 期待 blob（Excel 正常） | `M8-z0.md` | 比 sweep① method 對齊更深;PDF 呈現屬 R2 軌,但「註解掉的殘碼」需裁:接 R2 或先修 |
| F-12 🟡真缺陷候選・頭等 | `EPROZ00660` FE 打 `epl-case-TLOD-onhandstatus-query-list`,BE 只有 `epl-case-CAD-...`——endpoint 名不符,查詢必 404;inventory 卻標「✅ CR 範本」 | `M8-z0.md` | 一行修復（FE 端點名改 CAD 或 BE 加 alias）;翻案素材（✅→實際跑不動） |
| —（已知） | `EPROZ00800` FE POST vs BE GET（init-query）＝RP9,SRS §@PENDING 在案 | `M8-z0.md` | 不開新 id;審計獨立重發現=方法交叉驗證通過 |

## 口徑備忘（S-final 統計時遵守）
- 狀態字彙同義:`✅ 碼在`≡`碼在`、`❓`≡`UNFOUND`（各場用字略飄,master 彙總表已正規化）。
- 列粒度:S2 起=一頁/一 popup 一列;**M1（4 列）/M9（11 列）是 action 級粒度**,S-final 總量表需註記或重整（M1≈2 頁、M9 demo 4 列≈1 頁+1 popup）。
- 列彙總:任一端 UNFOUND → 整列計 UNFOUND（M4 檔頭口徑,全模組沿用）。
- FE 判定標配=四錨點（S4b 起):目錄樹/page-code 註冊/service 動態拼接/共用元件分支;只做精確字串搜尋不得標 UNFOUND。

> 維護:每場 QC 後加一列;S-final 出 `diff-vs-inventory.md` 後,本檔發現區與其對齊,人審逐條裁定 → 回填 `feature-inventory.md`。
>
> ✅ **回填已執行（2026-06-11,使用者裁示「都做」）**:inventory 已套用 DIFF 回填;開卡=`phase-g-csu-mainflow-fe.md`+修復×4（00660/00100/00119/00640）+`bible-gap-recon.md`;AUD-1~5 入 `pending-register.md`;F-7 入 Phase V。**`refactor-audit/` 歸檔（進 done/）待 AUD-1~5 與 BIBLE-GAP 收口後執行**。

## 修復審查紀錄（人審=Claude QC,2026-06-11）
| 卡 | product commit | 審查 | 備註 |
|---|---|---|---|
| `00660-endpoint-fix` | `5a47038` | ✅ PASS | 一行修、TLOD 殘留 grep 清零、報表家族未誤動 |
| `00100-todo-fix` | `2599752` | ✅ PASS | F-10 只刪覆蓋、無發明行為;F-9 兩處 @PENDING 標註(R2/檔案 API);發現 E_CREDIT_PROPOSAL 實導 `directToCaseEdition`→R2 track 素材 |
| `00119-options-fix` | `6919da5` | ✅ PASS | 查證正確(info 不供 options→GI sele 同型);**Phase V 必驗**:下拉有值+save 帶值+GI-sele 對 businessType F 無分支影響(推前快檢未回報,以 Phase V 涵蓋) |
| `phase-g` G1 pilot | `809d25d` | ✅ PASS（條件式放大）| CSU popup 變體、ISU 零修改、BE 未動、自抓 payload 缺口;**G2 前置**=`epl-comm-isu-update-total-amount` ISU 限定性快檢 |
| G1 前置快檢 | —（唯讀）| ✅ PASS → **G2–G6 綠燈** | total amount 計算無 DB 寫入、case-type 無關;LDTC 標準化副作用 ISU 限定但被 `LON_ATTRIBUTE='I'`+四條件 gate 擋死（corporate='C' 走不到）;無 checkpoint 寫入;命名 tech-debt（isu 字樣）入 inventory §4⑨ |
| `phase-g` G2 | `14b254e` | ✅ PASS | 三 tab 照舊 cs 結構（非 isu 單層）;DTO 以 BE 為準（checkFile→checkFileList 等轉換）;上傳區守 ⏸ 現狀;diff-tree 證 BE 零改;individual 未動 |
| `schema-diff-recon` | —（唯讀,findings 待推）| ✅ PASS | spool/分批/只報不裁全守。**頭條:old01≡new01、02=新 app schema**（01=舊/02=新——A-1 OQ-1 近自答、A-2 降風險）;checkpoint 實表=`TB_CHECK_POINTS_*`（**SRS R14 表名要修,併 RP10**）;新增 AUD-6（🔴財評精度縮減）/AUD-7（54 舊表去留）/AUD-8（新權限表×2）;column-order drift 349 欄/17 表→Phase V `SELECT *`/map-key 警示;MARIAL→MARITAL typo 改名家族→資料遷移對映點 |

## S-final 派工 prompt（定稿;S1–S9 在 master 全標完成後才跑）
> 讀 `docs/build-tasks/full-refactor-audit.md` §5、`refactor-audit/master.md`、**`docs/build-tasks/refactor-audit-qc.md`（口徑備忘+累計發現必讀）**,以及各模組檔的小計列（不重讀明細,證據需要時才回查單列）。此時才允許讀 `docs/feature-inventory.md` 與 Bible 的 BR/SC 清單。產出 `refactor-audit/diff-vs-inventory.md`,含四節:
> ① **總量表**:全系統 總列數×（碼在/🟡/🔴/🚫/UNFOUND）,按模組分組;統計時 `✅ 碼在`≡`碼在`、`❓`≡`UNFOUND`;M1/M9 為 action 級粒度,另列「頁級換算」欄並註記。
> ② **差異清單**:對 feature-inventory 逐模組,只列差異四類（inventory ✅ 但 audit 非綠／inventory 漏列／audit 🚫 但 inventory 仍列／狀態矛盾）,每條附模組檔行號;**QC 日誌 F-1~F-5 必須逐條對上**（F-1 企金 FE 缺口=頭條）。
> ③ **Bible 完備性抽查**:Bible 黃金旅程/BR 點名的頁在 audit 表有無承載列;缺=列 `BIBLE-GAP-n`,只標不裁。
> ④ **建議回填項**:逐條「inventory 哪一列改成什麼+依據」,供人審打勾;**不改 feature-inventory 本體**。
> 鐵則:唯讀產品 repo;結論全部要能回指模組檔行號;寫完 commit+push,master 標 S-final 完成。

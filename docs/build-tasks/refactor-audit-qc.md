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
| checkpoint 欄枚舉→RP10 關閉輪（SRS v0.8）| `d8c148c`+採納修正 | ✅ 兩層過 | 機械 gate PASS（含 gateⓅ open9/closed6）;spec-reviewer:無 Blocker、舊新欄重排映射經 page-mapping 驗證正確;採納 🟡（openapi 描述 RP10 殘留）後微審 PASS;Nit 留檔（R14 可拆 a/b、版號張力）|
| rimat 修復包 F1–F9 | product `5580eb7` | ✅ PASS | getIsNotSame 零命中、F8 對齊 v0.8 集合（含移除 0160 多寫）、F9 各自對欄＋**加修 seqNo 括號跨案件還原 bug**;OUT guard 驗未越界;focused 12/0/0（QA-023 skip 正確）;隨 push 確認項=F6 ≠03 分支、audit userId（Phase V）|
| `c0-authz-sql`＋DB precheck | `203c375` | ✅ PASS | INSERT…SELECT 由 i0 列複製角色（零硬編）;precheck 回本：**c0 已有 15/29（盲套會撞）**、預期 insert 13、ROLE_TASK 8/8 已存在;NOT EXISTS 冪等化;**翻案待裁：00117 ROLE_TASK 有但 3 個 API auth 列缺**（「既有」premise 被 DB 推翻——補產 or 留 ops）;gap：`epl-pxls-c0-financial-statement-comments` 連 i0 source 無列（UNSURE 交裁）|
| `schema-diff-recon` | —（唯讀,findings 待推）| ✅ PASS | spool/分批/只報不裁全守。**頭條:old01≡new01、02=新 app schema**（01=舊/02=新——A-1 OQ-1 近自答、A-2 降風險）;checkpoint 實表=`TB_CHECK_POINTS_*`（**SRS R14 表名要修,併 RP10**）;新增 AUD-6（🔴財評精度縮減）/AUD-7（54 舊表去留）/AUD-8（新權限表×2）;column-order drift 349 欄/17 表→Phase V `SELECT *`/map-key 警示;MARIAL→MARITAL typo 改名家族→資料遷移對映點 |
| `c0-authz` 00117 翻案補產 | `78f0b51` | ✅ PASS | 使用者裁「補」;3 列照既有模式（i0-copy `API_ID`+`REF_FUNCTION_ID`、NOT EXISTS on `API_ID`=PK 語意一致、`C0AUTHZ`/SYSDATE 同主塊）;controller file:line 證據齊（Csu:29/36/43↔i0:52/65/78）;算術核過:**32 mappings=15 既有+16 insert+1 pxls gap**、i0 source 30/32;findings 三處同步更新（flip 節/Apply Impact/Ops Checklist）;卡＋schema-diff-recon 卡雙歸檔 done/ |
| `phase-g` G3 | product `646e178` | ✅ PASS | 鐵則 1 兩款手法各用對地方:**return dialog `endpointConfig` 參數化（ISU default 保留、individual 頁零 diff）＋cancel popup CSU 變體**;ng build 綠（`fdd5a63f`，僅既有 budget warning）;BE 零改（`git diff --name-only -- backend` 空）;3 sub-agent 複核（routing/dialog/DTO）無阻斷＋**自抓修 sugLoan popup save 舊值覆蓋**（依已改 category 從 LDTC refresh、save/submit 前等待）;Phase V 清單詳實且自報兩缺口（CSU download route 無——勿猜、CSU 報表沿用 `epl-ppdf-isu-credit-proposal-report`）;〔06-12 初審條件 PASS→三樣補齊升正式〕另全卡加 Phase V 共通項=G1–G6 對 XD 設計走查 |
| `phase-g` G4–G6（**Phase G 收口**）| product `8badefc`/`0ff2140`/`4429551` | ✅ PASS | 三頁直線鏡像（無 dialog 改造）:0171 loan-committee（接 `epl-sele/info/save-csu-loan-committee`＋CSU save mapper，sele 以碼為準＝鐵則 2）/0172 approved-loan-cond（列印·下載鏡像 ISU 現狀＝符 OUT「0172 列印 ⏸」）/0173 cr-eval-old;一頁一 commit、ng build 三 hash 齊（`61c3638`/`33988267`/`82bae26`）、backend 零改、git status 乾淨;page-code/routing/nav/pageMap 全註冊;檔案 upload/download 無 CSU route→標 Phase V 現狀（勿猜，同 G3）;3 sub-agent PASS（Franklin FAIL 僅唯讀看不到 terminal build→被 build hash 補足，不扣分）。**Phase G 6/6 全收口**→卡歸檔 done/、M4/M5 升 ✅、企金 FE 缺口閉合 |
| `bible-gap-recon`（AUD-5）| —（唯讀,findings 已推）| ✅ PASS | 五項全收斂、審計總量不變;每項三方 file:line 互引（舊 JSP/trx/module/jrxml＋新 FE/BE endpoint＋審計承載列）:00670 舊源全無（JSP/Java/XML/SQL/JS/JRXML）→收斂 0181/TLOD;0180→z0 ToDo(00100)/Search(00600) `downloadFile` dispatch 承載;0182/0183/0184→Summary(0922) `downloadFile`/`downloadTransResult`/`downloadMsgCodeRecord` 承載;`diff-vs-inventory` BIBLE-GAP 改 recon-closed＋建議回填項打勾。AUD-5 銷案 |
| `00300-return-recon`（→翻案開修復卡）| —（唯讀,findings 已推）| ✅ PASS | 三節齊、file:line 密、UNFOUND 誠實標（SQL text/branch-vs-dept/權限/error parity 皆標未證）;**翻案**:原「return 空回疑未完成」→坐實**後端 side effects 舊有新無（summary 更新＋computed APP_HISTORY 都在）＝非缺陷**;真缺口＝**FE `goPreviousPage()` no-op**（舊 return 後 submit back `EPROZ0_0100/prompt`）;裁定 🔴 範圍精準（FE 導回，非後端）→開 `00300-return-fix.md`;次要待裁列清楚（APP_HISTORY=98/dept-vs-branch/權限/錯誤訊息） |
| `00640-pdf-export-fix`（F-11）| product `c1bda77` | ✅ PASS | 依賴查證對:被註解段依 iText7,repo 既有可用＝openhtmltopdf+Thymeleaf+`FileService.downloadPDF`（同 TLOD `epl-ppdf-*` 模式）→修通不掛 R2;`ResponseEntity<byte[]>`、新模板、測試改驗 blob;`mvn clean package` PASS（490/0/0）;Excel 路徑未動、FE 未動;3 sub-agent 同意修通＋no blocking;殘風險＝GET-with-body 需 Phase V 實測 PDF |
| `00300-return-fix`（DIFF-011）| product `40d931c` | ✅ PASS（1 caveat）| 單檔 `shared.service.ts:149`、backend 零改（`git diff -- backend` 空）、ng build 綠;導回鏡像既有慣例（`addContentOnly('/to-do-list')`+navigate，file:line 撐）;**審查重點＝共用 `goPreviousPage()` 由 no-op→一律回 ToDo**：影響面擴及 Document Checklist×3＋Related Party＋Revised Item（原皆 no-op→淨改善，Comparison Table 自導不受影響）→判 PASS;**caveat（記 Phase V）**：其他呼叫端「回 ToDo vs 回 case 內上一頁」語意 repo 未坐實，日後要回原入口需加 `originPage` 分流（sub-agent 已自報）;5 sub-agent PASS |
| `00600-search-options-fix`（RV-1，Phase V）| product hash 未明示（pre-fix `97096be`）| ✅ PASS | 根因坐實＝**GET+`@RequestBody` 矛盾**（sweep① `48e687f` 只改 method 一半、body/binding 沒對齊）;舊 `EPROZ0_0600/doInitQuery` 只用 locale 取下拉→確認 search-options 無需 body→方向 GET query 對（依舊系統定向）;BE `@RequestBody`→`@ModelAttribute`、FE `apiGetRequestWithBody`→`?langType=`、主查詢 `/epl-list-search` POST 不波及、grep 無其他 caller;test 改測 GET query;mvn/ng build 綠（timeout/EPERM 是環境非 code）。⚠️ **揭示橫向**：`apiGetRequestWithBody` + GET`@RequestBody` 殘留恐不只此頁→建議橫向 grep sweep |
| **langType sweep 盤點**（findings `8a06253`）| —（唯讀盤點）| ✅ PASS | 5 候選逐一 SQL file:line＋舊 module 對照（named SQL UNFOUND 誠實標＋參數注入推斷不含 LANG_TYPE）＋分類＋修向;**分類精準**：(a) 純過濾移除×2（todolist/casedistribution）、(b) 多語系 join 誤放 outer WHERE→join ON+fallback×3（caseapplication/deviation/cancelreport）;**附反向清單**（已正確 `LEFT JOIN ON LANG_TYPE` 的 translation/label/字典/固定語系報表不算候選）＝證明分辨「砍父行 vs 選顯示文字」。可進修 |
| **GET-body sweep 盤點**（findings `8a06253`）| —（唯讀盤點）| ✅ PASS（1 caveat）| 3 候選＋舊對照（`EPROZ0_0640` export `requestToMap`、`EPROZ0_0800` request param）＋00600 樣板對照;FE 無直接 `apiGetRequestWithBody` 但抓到 2 處 `apiGetRequestForBlob`（GET-body 等價）;#1/#2 scorecard export→POST body（乾淨）;**⚠️ 我補 caveat：#3 `epl-case-query-reviseditem`=00800 init-query→碰 SRS `@PENDING`（按 SRS 不動），不可逕改、先對 SRS 裁定**（findings 未點出此關聯）|
| **langType sweep 修（5 處）**| product `bbbaa19`+`7e1f0d2` | ✅ PASS | (a) 移除 outer WHERE×2、(b) join ON+fallback en_US×3;**筆數一致鐵證 `zh_TW`=`en_US` 五頁全通**（todolist 91/91…）＝langType 不再砍資料、RV-2 收口;3 sub-agent（Dirac/Parfit/Plato）PASS;Parfit 提示「DB 同 LANG_KEY+LANG_TYPE 重複列仍可能重複」＝非本次新增、留意 |
| **get-body #1/#2 修（scorecard export）**| product `751f78f` | ✅ PASS | pdf/excel 改 POST、FE `apiPostRequestForBlob`、`@RequestBody` 保留、query-list 未誤動、export filter body 仍傳;mvn+ng build 綠;3 sub-agent PASS;**#3 reviseditem 正確未納入**（等 RP9）|
| **A-1 OQ legacy recon**（findings `fe3f129`）| —（唯讀 recon）| ✅ PASS | 4 OQ 全坐實舊系統做法＋對等建議＋UNFOUND 誠實標:OQ-1（舊固定 `OVSLXLON01`×4 證據、新 02 留 T24）/OQ-3（舊 throw `EPROIS0921_UI_RAET_FIND_ERROR`、勿用泛用 FAILED_E303）/OQ-4（舊不吞錯往外拋、新 stub catch 回 null→NPE，建議明確 throw）/**OQ-5 鐵證**（`EXCHANGR_RATE` 舊/新 schema/entity/DB psv 全無＝typo、G/H 應讀 `EX_RATE_BUY`）;3 sub-agent PASS;**連帶坐實撥貸 T24 G/H 現存 bug**（`SummaryServiceImpl:2221/2285` 讀不存在欄）|
| **🤖 orchestration pilot（首試）**｜Task1 method recon＋Task2 0922 typo（`581e717`）| ✅ **雙層 PASS** | **task 層**：T1 method 統計扎實（280/282 POST、query-like 132/133 POST；**2 GET=reviseditem 自己+剛立 00600**→審查補脈絡：扣掉即 100% POST，RP9 翻成雙向證據齊）、T2 typo 乾淨（2 處、E段/A-1 未動、grep 無殘留、mvn 綠、三軸 PASS）。**orchestration 層四條全守**：①停等審 ②**沒碰 C 類（RP9 證據指向某向仍忍住沒裁）** ③三軸真獨立（regression 跨廠 model 失敗→主動 fallback 不同模型/指示）④完成定義守住。**暴露 config 問題**：`verifier-regression` 綁跨廠 `claude-opus` 在 Codex 帳號失敗→範本 model 改同廠 `gpt-5.4`＋註記。**小瑕疵**：findings 自承沒跑 `git pull`（不影響本 task，批量需確保讀最新 docs）。**結論：四條全守→orchestration 可信，可放大批量 PRD→SRS（pilot-first 通過）** |
| **legacy-schema-db-reverify**（findings 已推）| —（A 類唯讀 recon）| ✅ PASS | 96 表斷言查證、93 證實、**7 🔴 推翻+2 ⚠️ 未涵蓋**,每項 DB spool file:line（`*_columns.tsv`/`*_pk.tsv`）。7 推翻：71→142 表／`TB_COLL_CROSS_CHARGE_DETAIL`→`TB_CROSS_CHARGE_DETAIL`／SCORE_CARD `_MAIN/_SUB` 舊有新無／**`TB_EMP_PROXY` 複合 PK `EMP_ID+STR_TIME`**（推翻單鍵）／`T24_BRANCH_CODE`(5→20)／`FUNCTION_AUTH.FUNCTION_ID`(20→50)／`TB_FUNCTION_INFO` 不存在;2 未涵蓋誠實標（PAGE_MENU logical key/APPLICATION_NO workflow PK，DB 不證 logical 不誤判）。**已回填 legacy 內文 7 處**;連動：EMP_PROXY→AUD-9 開 `00700-deputy-pk-reverify`（已完成頁潛在 bug）、SCORE_CARD→AUD-7。**價值：把 DB 未通時代資料事實誤判一次掃乾淨,下游 PRD→SRS 不再繼承錯 schema** |
| **00700-deputy-pk-reverify**（AUD-9 連動）| —（後端唯讀 recon）| ✅ PASS（無 bug）| EMP_PROXY 複合 PK 推翻單鍵後驗已完成 deputy 頁:4 問全 ✅ aligned、file:line 齊——`@EmbeddedId`(EMP_ID+STR_TIME)、save 組複合 key（同人不同 STR_TIME 共存、不按 EMP_ID 覆蓋）、delete 帶複合 key 單筆、query list/date-range oriented。**結論：碼照 DB 寫對、早期「單鍵」係文件假設錯**＝AUD-9 關、inventory 0700 回填。誠實附帶：EMP_ID 顯示 5 vs DB 10（非 PK gap、留日後）。**意義：已完成頁的潛在 bug 疑慮排除——複合 PK 假設驚而無險** |

## S-final 派工 prompt（定稿;S1–S9 在 master 全標完成後才跑）
> 讀 `docs/build-tasks/full-refactor-audit.md` §5、`refactor-audit/master.md`、**`docs/build-tasks/refactor-audit-qc.md`（口徑備忘+累計發現必讀）**,以及各模組檔的小計列（不重讀明細,證據需要時才回查單列）。此時才允許讀 `docs/feature-inventory.md` 與 Bible 的 BR/SC 清單。產出 `refactor-audit/diff-vs-inventory.md`,含四節:
> ① **總量表**:全系統 總列數×（碼在/🟡/🔴/🚫/UNFOUND）,按模組分組;統計時 `✅ 碼在`≡`碼在`、`❓`≡`UNFOUND`;M1/M9 為 action 級粒度,另列「頁級換算」欄並註記。
> ② **差異清單**:對 feature-inventory 逐模組,只列差異四類（inventory ✅ 但 audit 非綠／inventory 漏列／audit 🚫 但 inventory 仍列／狀態矛盾）,每條附模組檔行號;**QC 日誌 F-1~F-5 必須逐條對上**（F-1 企金 FE 缺口=頭條）。
> ③ **Bible 完備性抽查**:Bible 黃金旅程/BR 點名的頁在 audit 表有無承載列;缺=列 `BIBLE-GAP-n`,只標不裁。
> ④ **建議回填項**:逐條「inventory 哪一列改成什麼+依據」,供人審打勾;**不改 feature-inventory 本體**。
> 鐵則:唯讀產品 repo;結論全部要能回指模組檔行號;寫完 commit+push,master 標 S-final 完成。

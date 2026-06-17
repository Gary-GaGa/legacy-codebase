# 撥貸 — Domain 升級清單（給 owner 裁示）

> §7 機械 allowlist（M1–M10）已全數結案上 master。**本檔＝剩下所有「非 Codex 能單方修、需 domain / T24-spec / DBA 裁決」的項**，從 `disbursement-triage.md` §1–4 + §7 非-allowlist（line 71）+ M6 彙整、按 owner 分組。每項給：**主題 / 需要的決策 / 影響·信心 / triage 出處**。
> **✅ A-1 stub 已實作（product `daae4c3`，06-16，mvn 綠）→ authorize 換匯總開關打通**。撥貸真完成仍需：本清單 T24/domain group ＋ **批次層 B001–B008**（F-OWN-1，新查出未追蹤、待碼驗）＋ A-1 spec-conformance 確認（OQ-1/3/4/交易）。清掉前撥貸不算可上線。

## A. 撥貸 domain 開發（金錢核心 / 行為語意）
| # | 主題 | 需要的決策 | 影響·信心 | 出處 |
|---|---|---|---|---|
| ~~**A-1**~~ ✅ 已實作＋conformance PASS（`daae4c3` 06-16）| `funcGetExchangeRate` 尾端 throw-stub | **依 a1-spec OQ-1~5 補 return＋移尾端 throw、mvn 綠；Codex 唯讀碼驗 4/4 PASS**（OQ-1 `IdNo=01` `:1181`、OQ-3 非0000拋錯中止 authorize、OQ-4 throw 勿回 null、兩表同 `@Transactional`；錯誤碼＝專屬 `FAILED_E304` 非泛用 E303）。詳 `done/a1-funcGetExchangeRate-spec.md` 標頭 | ✅ 全結 | §1 P0-1 |
| ~~**A-2**~~ ✅（06-16 owner）| `EXCHANGE_RATE` 來源 ID `OVSLXLON01`→`02` | **裁定＝先對齊舊 parity→`OVSLXLON01`**（與 OQ-1 係同一分歧，同步取舊值）。⚠️ schema-diff 證據偏「02=新庫刻意」，故為「先固定」，唯一復驗點＝新環境 T24 拒收 `01` | 換錯匯率源·已裁 | §2 / §7 line71 |
| ~~**A-3**~~ ✅（隨 A-5）| `E21` 非 USD 非 KHR 輸出 `0` | A-5 裁 keep（只 USD/KHR、非此幣別業務不發生）→ E21 輸出 0＝by-design-unreachable、非 bug | 已裁 | A-5 |
| **A-4** | `0921` 檢核對等：`CheckMainBorr`/`CheckCoBorr`（身分/sector/account/`DATA_SEQ`/business-section）、`info CO_CHECK ='Y'` vs 舊 `!='N'`、Finished gate 未驗 `mbCheck`、law firm `IS_SHOW` 版本條件、address `UPD_DATE` 來源 | 逐項裁「嚴格度差異是 intended 還是 regression」 | 檢核漏放/誤擋·中 | §3 P2 |
| ~~**A-5**~~ ✅（06-16 owner）| 幣別「收窄」（舊 non-USD 通吃→新 USD/KHR only、其他 null/0）| **owner 裁：撥貸有效幣別＝USD+KHR only（柬埔寨）→ 收窄無害、keep + 補規格**（non-USD-non-KHR 的 fee→null/E21→0 path＝**by-design-unreachable、非 bug**，不做對等修）。殘小：KHR rounding `DOWN`（keep）、G/H 幣別來源（USD/KHR 內若 disbursement≠account 幣別才有差→資料約束待 RD）| 已裁·keep | 坐実 `khr-currency-handling-recon-findings.md` |
| **A-6** | `0922 submit` history `25`→`24` | confirm 正確序號後再定 | 狀態序·低 | §7 line72 |

## B. T24 整合 owner / T24 spec
> ✅ **owner 裁定（2026-06-16）：「T24 都照舊系統規格」** → **B-2/B-3/B-4/B-5 + A-3 全收編＝照舊 parity**，轉**執行階段**（卡 `build-tasks/t24-bgroup-legacy-parity-fix.md`：Codex 逐欄坐実舊行為+對齊，金錢欄最嚴人審）。**邊界**：KHR 幣別分支＝**疑刻意在地化但未確認**（A-5「🟢 疑似」；新 fee rounding/E21 有 KHR 碼〔handoff §2.1:54/§2.3:85 坐実〕，惟「舊僅 USD」只指 fee rounding 分支——舊 `getExchangeRate` 仍查 `CcyCode=KHR`）→ batch-fix **先不動 KHR 分支、另派坐実+domain 確認**（不假設保留、不自動 revert）。換匯欄位置/來源/格式照舊。下表 B-2~B-5 主題保留作執行清單；裁定已定（照舊），不再逐項 owner。
> 2026-06-17 執行回填：`build-tasks/t24-bgroup-legacy-parity-fix-findings.md` 已逐欄坐實舊 `file:line`，B-2、B-3 非幣別欄、B-4、B-5 修正已套用；`E21`、`G4`/`G10`/`H8` 依 A-5 owner keep，不做對等修。**金錢/截斷欄 pre-push 最嚴人審已過 → code 已 commit/push（product repo，06-17）**；剩端到端/T24 接收驗證（findings 註：`mvn package` 75 surefire 全過、repackage 失敗＝本機 jar-lock 環境問題、非碼問題）。
| # | 主題 | 需要的決策（✅ 06-16 全裁＝照舊）| 影響·信心 | 出處 |
|---|---|---|---|---|
| **B-1** 🟡 降級（06-12 前提推翻）| ~~`T24_COMPANY` 死路：讀已移除欄~~ → **新庫 `TB_BRANCH_PROFILE.T24_COMPANY` 實存**（`OVSLXLON01`/`OVSLXLON02` 兩 schema 皆有，06-12 DDL 實查）——「舊有新無」係 schema-Excel/entity 盤點漏列 | **轉 RD 動作**：確認 app 連用 schema → entity 補欄位映射 → `B8`/`C9` 接值；殘留小裁定＝兩 schema 選哪個（連動 A-1 OQ-1）| T24 缺值·高→**可解** | §1 P0-3 |
| **B-2** ✅ 已 commit（06-17，人審過） | `A16` `NORMAL.LAON`→`LOAN` | 坐實舊 T24 key 為 `NORMAL.LAON`，新碼已改回；金錢/截斷欄人審過、code 已 commit/push | 改錯會破 T24·中 | findings |
| **B-3** 🟡 部分修正已套用（06-17） | `C12` `SUG_VAL` 讀錯表、`C13` `DECISION_DATE`→`CHECK_DATE` 來源、`G4`/`G10`/`H8` 換匯欄、`G11–G12` fee remark mapping、`A15` 空值補 `N/A` | `C12`/`C13`/`G11–G12`/`A15` 已照舊；`G4`/`G10`/`H8` 幣別分支依 A-5 keep，不在本批 | T24 值/格式·中 | findings + A-5 |
| **B-4** ✅ 已 commit（06-17，人審過） | `AGREEMENT_NO` 截斷（`A31`/`G7`，舊取後 16 碼） | `A31`/`G7` 已照舊取後 16 碼；金錢/截斷欄人審過、code 已 commit/push | T24 欄寬·中 | findings |
| **B-5** ✅ 修正已套用（06-17） | 行尾 `\r\n` vs `\n`（T24 可能敏感）、`C26` title-deed 全 join 到每筆 C row | 已改 CRLF record join；`C26` 依當前 `COLL_DATA_SEQ` 過濾 title deed | 格式符合性·中 | findings |
| **B-6** 🟢 大致解 | 架構：`t24DealResult`→批次 `EPROZ0B006`(async)、mail scheduler、`IS_AUTODIS=YC` | **AUD-10 已坐実新系統採 async 批次架構**（B006 結果處理器、B007 結案皆 active scheduled）→「是否採新批次/async 架構」＝**是、已建**；殘＝mail scheduler timing／`IS_AUTODIS=YC` 語意（小，domain 確認）| 架構選擇·已答 | §3 P2＋AUD-10 |

### B-group parity-first 預分類（2026-06-16；依 owner parity 裁定〔A-1/A-2 已立〕＋ AUD-10）
> owner 已立原則「**撥貸 outbound 參數先對齊舊系統 parity**」（A-1 OQ-1/A-2 落地）。把 B-group 同型（T24 outbound 欄值新/舊分歧）依此預分三類，**收斂 owner 裁定量**：
>
> **① parity-default（鏡像舊、建議 owner 一次裁「T24 outbound 欄一律先對齊舊 parity」→ 之後 Codex 逐欄坐実舊行為即可批量修）**
> - **B-2** `A16` `LAON`：parity → **保留舊值 `LAON`**（勿改 `LOAN`；本就疑 T24 期望 key）。
> - **B-3/C12** `SUG_VAL` 讀錯表 → 還原舊讀的表；**C13** 日期來源 → 還原舊 `DECISION_DATE`；**G11–G12** fee remark → 舊 mapping；**A15** 空值 → 舊行為。
> - 動作：owner 蓋「parity 適用」一次 → 派 Codex 逐欄坐実舊 T24 組檔行為（`file:line`）→ 批量修（同 get-body/langtype sweep 模式）。
>
> **② 需 T24-spec（parity 給預設、外部確認）**：**B-4** `AGREEMENT_NO` 截斷（parity=舊取後16碼；**T24 欄寬**待確認，同 A-1「先固定 parity、新環境拒收再調」）、**B-5** 行尾 `\r\n`／`C26` 重複（T24 格式容忍度）。
>
> **③ 需 domain（刻意演進、parity 會錯）**：**B-3/G4·G10·H8** 換匯欄（與 KHR 在地化纏一起，非-USD/KHR 幣別出法）、**B-6** mail timing／`IS_AUTODIS`（架構已建、殘語意）。
>
> → **collapse 效果**：B-group 從「逐欄對 T24 spec」降為「owner 蓋 ① parity 一次 + ②兩項 T24-spec + ③兩項 domain」。①是大宗、可批量。

## C. DBA / 舊 DDL（**06-12：舊庫可連（Oracle），DDL 可自查**）
| # | 主題 | 需要的決策 | 影響·信心 | 出處 |
|---|---|---|---|---|
| ~~**C-1**~~ ✅ 已關（06-12 DDL 實查）| 金額 precision：舊庫全金額欄＝`NUMBER(17,2)`、`TB_EXCHANGE_RATE.EX_RATE_*`＝`(17,4)`——**與新庫完全一致，無精度落差** | —（銷案；證據另見 `a1-funcGetExchangeRate-spec.md` §5）| 已解·確認 | §4 P3 |
| **C-2** | `t24DealResult` 非 `0000`/無 done flag 是否更新 summary 狀態；`IS_CONTRACT`/`IS_CONTR` persist 目標；contract-source 可能 NPE；空 `APPLICATION_NO`（新 controller 擋、舊 throw 未明） | 對舊行為/DDL 確認後定 | 狀態/NPE·UNSURE | §4 P3 |

## D. 前端 / DTO 契約（M6 落這裡）
| # | 主題 | 需要的決策 | 影響·信心 | 出處 |
|---|---|---|---|---|
| **D-1** | **M6** `0921` collateral 完工日寫不出非 null：request DTO 只有 `estCom`/`otrEstCom` 型別欄、**無日期值來源**（現 `setEstComDate(null)`/`setOtherEstComDate(null)`） | 舊系統那兩個完工日**從哪來**？FE 漏接欄位 / 別處衍生 / 該補 DTO 欄 | 資料遺失·中 | §2 P1（Codex 停手升級） |

---
## 附：非-domain 的待辦（眼睛盯著、別漏）
- **整合驗證確認點**（繼承既有行為、非新引入，整合測時跑）：**M7** facility fee 改 `LOANAMOUNT` 後實際有值；**M9** A52 該 `UPD_DATE` 慣例能 join 到非空 `DISTRICT_NAME`。
- **Tech-debt sweep**（工程、非 domain）：codebase native-query map-key **大小寫混用**（`loanAmount` vs `LOANAMOUNT`）→ 可能藏同類靜默回 null 的 bug，排一次全面 sweep。
- **Ops smell**：後端 Logback 測試設定硬編碼 `D:\temp\saveFile\log`，非 Windows/無 `D:` 環境擋 build（現以 `-Dlogging.*.path` 覆寫繞過）→ 外部化該路徑。
- **Ops 追蹤（AUD-10 B008）**：legacy `EPROZ0_B008` DB/security log 歸檔（搬 `securityLog/yyyy`）新後端 UNFOUND → 確認是否改由 logrotate／平台／job scheduler 歸檔；非 app 碼缺、不擋撥貸。
- **Tech-debt（AUD-10 附帶）**：`TB_EXCHANGE_RATE` 在新系統 **write-only**（inline `funcGetExchangeRate` 寫、無人讀）→ 鏡像舊行為、無害，惟可列日後 cleanup 候選。

> 維護：本檔只列**待 owner 裁**項；裁決後回填對應 `triage`/`verification-handoff`，並把已決項從本檔移除或標 ✅。

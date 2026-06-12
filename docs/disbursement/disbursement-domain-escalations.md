# 撥貸 — Domain 升級清單（給 owner 裁示）

> §7 機械 allowlist（M1–M10）已全數結案上 master。**本檔＝剩下所有「非 Codex 能單方修、需 domain / T24-spec / DBA 裁決」的項**，從 `disbursement-triage.md` §1–4 + §7 非-allowlist（line 71）+ M6 彙整、按 owner 分組。每項給：**主題 / 需要的決策 / 影響·信心 / triage 出處**。
> 撥貸目前**仍無法端到端授權**（被下方 A-1 stub 擋）；本清單清掉前，撥貸不算可上線。

## A. 撥貸 domain 開發（金錢核心 / 行為語意）
| # | 主題 | 需要的決策 | 影響·信心 | 出處 |
|---|---|---|---|---|
| **A-1** 🔴 | `funcGetExchangeRate` **尾端 throw-stub**（`common/impl/FunctionServiceImpl:1156`；**已有** API key 讀取/T24 呼叫/`TB_DISBUR_DATE`+`TB_EXCHANGE_RATE` 寫入，只是尾端無條件 throw、無 return） | **實作規格已備 → 見 [`build-tasks/a1-funcGetExchangeRate-spec.md`](../build-tasks/a1-funcGetExchangeRate-spec.md)**。修＝補 return + 移尾端 throw + 兩表交易一致 + 解 OQ-1/3/4/5；⚠️ **鏡像舊 0922 換匯、勿鏡像 `funcGetRate`（那是 scorecard 計分、非匯率）**。**最高優先** | 阻斷全流程·高 | §1 P0-1 |
| **A-2** | `EXCHANGE_RATE` 來源 ID `OVSLXLON01`→`02` | 確認換匯源 ID 是**刻意改**還是 regression（金錢） | 換錯匯率源·中 | §2 / §7 line71 |
| **A-3** | `E21` 非 USD 非 KHR 輸出 `0`（舊全換匯） | 是否隨 KHR 在地化刻意改；非 USD/KHR 幣別該如何出 | T24 值錯·中 | §2 / §7 |
| **A-4** | `0921` 檢核對等：`CheckMainBorr`/`CheckCoBorr`（身分/sector/account/`DATA_SEQ`/business-section）、`info CO_CHECK ='Y'` vs 舊 `!='N'`、Finished gate 未驗 `mbCheck`、law firm `IS_SHOW` 版本條件、address `UPD_DATE` 來源 | 逐項裁「嚴格度差異是 intended 還是 regression」 | 檢核漏放/誤擋·中 | §3 P2 |
| **A-5** 🟢 | `KHR` 換匯 + 在地化（舊僅 USD） | **疑刻意演進——確認後標明「勿改回」**，避免後續被當 bug 還原 | 改回會破壞·高 | §3 / §7 |
| **A-6** | `0922 submit` history `25`→`24` | confirm 正確序號後再定 | 狀態序·低 | §7 line72 |

## B. T24 整合 owner / T24 spec
| # | 主題 | 需要的決策 | 影響·信心 | 出處 |
|---|---|---|---|---|
| **B-1** 🔴 | `T24_COMPANY` 死路：`B8`/`C9` 讀新 schema **已移除的欄** → 空值，**無替代來源** | **決定值來源**（從哪取 B8/C9）；無解則此二欄永遠空 | T24 缺值·高 | §1 P0-3 |
| **B-2** | `A16` `NORMAL.LAON`→`LOAN` | 確認 `LAON` 是否為 **T24 期望的 key**（疑非錯字、勿順手改） | 改錯會破 T24·中 | §2 / §7 |
| **B-3** | `C12` `SUG_VAL` 讀錯表、`C13` `DECISION_DATE`→`CHECK_DATE` 來源、`G4`/`G10`/`H8` 換匯欄、`G11–G12` fee remark mapping、`A15` 空值補 `N/A` | 逐欄對 **真 T24 spec** 定來源/格式（部分金錢） | T24 值/格式·中 | §2 / §7 line71 |
| **B-4** | `AGREEMENT_NO` 截斷（`A31`/`G7`，舊取後 16 碼） | confirm **T24 欄寬**後定截斷規則 | T24 欄寬·中 | §2 / §7 |
| **B-5** | 行尾 `\r\n` vs `\n`（T24 可能敏感）、`C26` title-deed 全 join 到每筆 C row | T24 對行尾/重複的容忍度 | 格式符合性·中 | §3 P2 |
| **B-6** | 架構：`t24DealResult`→批次 `EPROZ0B006`(async)、mail 改 scheduler 後送、`IS_AUTODIS=YC` | 是否採新批次/async 架構（非單純 bug） | 架構選擇·中 | §3 P2 |

## C. DBA / 舊 DDL（**06-12：舊庫可連（Oracle），DDL 可自查**）
| # | 主題 | 需要的決策 | 影響·信心 | 出處 |
|---|---|---|---|---|
| **C-1** | 金額 **precision**：新 `NUMBER(17,2)` vs 舊 scale **UNKNOWN** | **舊庫 DDL 自查**核對 scale（已解鎖），定金額精度 | 金錢精度·UNSURE | §4 P3 |
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

> 維護：本檔只列**待 owner 裁**項；裁決後回填對應 `triage`/`verification-handoff`，並把已決項從本檔移除或標 ✅。

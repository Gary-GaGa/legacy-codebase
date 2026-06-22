# 00100 / 00118 待裁決 Digest（給 owner；decision aid，**非 SSOT**）

> **用途**：把 `EPROZ00100`（10 條 `PENDING-Z001~Z010`）＋ `EPROC00118`（18 條 `PENDING-001~018`）的開放 `@PENDING`，**依 owner 分組＋標 gate 層級＋點出可一次裁的共決＋DB-resolvable triage**，讓 owner/RD/DBA/Security/風控 一眼知道「**先裁什麼、誰的、卡到哪一關**」。
> **權威來源（本檔不取代）**：每項細節＝各頁 `spec.md §@PENDING`（單一出處）；登記視圖＝[`../pending-register.md`](../pending-register.md)。**本檔只做分析（分組/分層/共決/DB-resolvable），不複寫條目細節、不裁定**——裁定回填 `spec.md §@PENDING` ＋ `decisions.md`，本 digest 裁完歸檔。
> **狀態**：兩束 In Review（Draft）、覆蓋 2/67；跨模型 N 軸 Blocker 已修（06-19 複審 PASS）。以下為**定版前**待裁的 `@PENDING`（gate 欄取自各 spec.md 的 blocking 欄）。

## 1. 關鍵少數：擋「SRS Approved」的（先裁這 2 條）
| 項 | owner | 主題 | 為何擋 Approved |
|---|---|---|---|
| `00100 Z001` | PM/SA | 各 action（delete/close/download/redistribution/session set-clear）**逐角色權限** | spec 標 **"Yes for final action approval"**＝定版閘（role 顯示 label 已 carried、非 pending）|
| `00118 001` | PM/SA/**風控** | 兩碼 `CR_SCORE_CARD_COMPLETED` 語意（跨 scorecard）＋**E1 CU-return 分流**＋**E2 整欄覆寫** | spec 標 **"Yes for final approval"**＝定版閘；牽動 QA-030/030A |
> 其餘 26 條皆標「Yes for [validation/RC/seed/API/perf/impl/deploy] signoff」或「No for draft」＝**擋後續 signoff／部署、不擋 draft 定版**。**先清這 2 條 → 兩束可推進 Approved**，其餘併入實作/部署軌逐關清。

## 2. 部署硬閘（即使 Approved，上測試環境前必清）
| 項 | owner | 主題 | 強度 |
|---|---|---|---|
| `00118 012` | RD/Security | 明確 BE 拒絕 non-AO/non-CR save ＋ `TB_API_AUTH` EPROC00118 列 | **"Yes before ANY testing deployment"＝最硬**（regression/security blocker）|
| `00100 Z006` | RD/Security | 呈報書下載 token/path 策略 ＋ 保留/到期 | download 實作閘 |
| `00100 Z009` | RD | 每個 `epl-*` 一列 `TB_API_AUTH`（role allow-list ＋ `REF_FUNCTION_ID`）| auth seed signoff |
| `00118 016` | RD | 非數值 `SCORE` → `MSG_QUERY_FAIL`、**勿靜默歸零** | 計算正確性（SRS 建議 fail-safe＝安全預設）|
| `00118 017` | RD/QA | `scoreDatetime` 保證 UTC+8（勿裸 `LocalDateTime.now()`）| API signoff |

## 3. 可一次裁的共決（decide-once，省 owner 來回）
- **授權模型（auth seed）**：`00100 Z009` ＋ `00118 012` ＝同一件「`TB_API_AUTH` seed ＋ 非授權角色拒絕」 → **RD/Security 一次定模型、覆蓋兩束**（以 00118-012「部署前最硬」為基準先定）。
- **PM/SA 業務字典**：`00100 Z001 / Z002 / Z007`（逐角色權限 / 狀態碼語意 / delete-close reason 碼＋D99-C99）＝**一輪 PM/SA 全裁**。
- **風控 scorecard 語意**：`00118 001 / 004 / 005 / 007 / 011`（兩碼完成＋E1/E2 / role 003 可否改 AO 側 / AO→CR copy 含不含 `_AR_SCR`·`_INVENTORY_SCR` / option seed / Default 短路）＝**一輪 風控＋PM/SA**。

## 4. DB-resolvable／provenance（CLAUDE.md §4：DB-resolvable fact **不該當判斷題留著**，帶 db-diff provenance 解）
| 項 | owner | 為何是事實題（非判斷）|
|---|---|---|
| `00100 Z010` | DBA/RD | `PROCESS_AGENT_CODE/NAME` 存哪＝查 `TB_APP_HISTORY` schema/DAO 映射 |
| `00118 002` | SA/RD/DBA | RC 是否另建 checkpoint＝查新 DB snapshot 有無 RC 欄（`TB_CHECK_POINTS_CS/CU` 只露 `EPROC00118`）|
| `00118 010` | SA/RD/DBA | 參數有效日是否套 `END_DATE`＝查 `TB_SCORE_CARD_PARAM_DETAIL` 欄義 |
> ⚠️ **db-diff＝母資料夾-local、不在本 repo** → 實際查值＝Codex/DBA 帶 source（同 refactor-audit carried-status 結構限制）。**良性示範（已正確推出 pending）**：`00118 003/014` 數值精度（db-diff/OpenAPI 定）、`00100 Z001` role labels（carried）——SRS 已把 DB-resolvable fact 移出 pending。

## 5. 依 owner 完整佇列（細節一律見 `spec.md §@PENDING`）
| owner | 00100 | 00118 |
|---|---|---|
| **PM/SA**（＋風控/Risk/RD 牽涉） | `Z001` `Z002` `Z007` | `001`(風控) `004` `007`(RD) `011`(Risk) |
| **SA/RD**（＋QA） | `Z003` `Z005`(QA) | `003` `005` `008` `009`(QA) `013` `014`(QA) `015` `018`(QA) |
| **RD**（純實作/驗證） | `Z004` `Z008` | `006` `016` `017`(QA) |
| **RD/Security** | `Z006` `Z009` | `012` |
| **DBA**（＋SA/RD） | `Z010` | `002` `010` |

## 6. 建議 owner 動作順序（解 Approved → 部署 → 實作）
1. **PM/SA ＋ 風控 一輪** → 裁 §1 兩條（解 Approved 閘）＋ §3 業務字典/scorecard 共決。**← 解兩束定版的最短路徑。**
2. **RD/Security 一次** → 定 §3 授權模型（覆蓋 `Z009`/`012`）＋排 §2 部署硬閘順序。
3. **DBA ＋ Codex（帶 source）** → 解 §4 三條 DB-resolvable（provenance 回填、不留判斷 pending）。
4. 裁定逐條回填各 `spec.md §@PENDING` ＋ `decisions.md`；本 digest 歸檔（`done/`）。

> **不變式**：本檔零裁定權（裁定在 owner）、零 SSOT 權（細節在 spec.md）；只把「散在兩束 28 條」整理成「先裁哪 2 條、哪些一次裁、哪些是查 DB 不是判斷」。對應追蹤載具＝`build-tasks/EPROZ00100-EPROC00118-nfix-card.md`（In Review→Approved 迴圈）。

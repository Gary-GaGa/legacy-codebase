# Build Task — 本機 FE+BE 同跑 runtime 整合驗證（Phase V runtime 層）

> 載具：**你/Codex 在母資料夾**（規劃 repo 起不了服務——無原始碼）。**性質＝runtime 整合測試**，與 `verification/verification-execution.md`（Codex bounded session 逐項唯讀「程式碼/語意比對」）互補：那層找邏輯 gap，本卡找「真的跑不跑得動」。
> **觸發**：DB 連線已通（2026-06-12），runtime 這層第一次可行。
> **長程序鐵則**（`process/SETUP-codex.md`）：`ng serve` / `spring-boot:run` **絕不讓 agent 跑**（等不到結束會卡死）——你在自己終端跑，agent 只改 code / 看錯誤。

## 0. 決策：寫入測試打 `OVSLXLON02`（使用者裁定 2026-06-14）
> 本機 BE 用 **DB 既有帳號**（**不創新帳號**——讀 backend datasource config 既有 profile，或唯讀查 `ALL_USERS` 撈 `OVSLXLON02` 既有可用帳號）直連 **正式新 app schema `OVSLXLON02`** 做 save/submit 寫測。**已知代價＝測試髒資料會寫進正式新庫**——故下列護欄為**強制**：

### 0.1 護欄（寫測前必讀，強制）
1. **測試案件可識別**：寫測一律用**保留測試案件號段**（與真案件不撞；開測前先 SELECT 確認該段未被佔用，記錄用了哪些 `APPLICATION_NO`/caseNo）。
2. **可清除**：寫測前列「預期會動到的表」清單；測完產 **teardown SQL**（DELETE 限定測試案件號）——**DML 不由 agent 直執行**（`decisions.md §三`），產檔交人審套用，同 `c0-authz-sql` 模式。
3. **快照**：寫測前請 DBA 對受影響表（或整 schema）做一次快照/備份；無法快照則只挑「可由 teardown 完全還原」的頁先測。
4. **不撞線上使用**：避開他人實際使用 `OVSLXLON02` 的時段；寫測時段與 owner 對齊。
5. **唯讀帳號做查證/清單**：寫測後的「比對實際落庫」用 agent **唯讀帳號** SELECT（不另開寫權給 agent）。

## 1. 前置 gate（缺一不可往下）
- [ ] **後端可 build**：Nexus `maven-settings.xml` → `mvn clean package -Dmaven.test.skip=true` 綠（baseline 測試與 main 不同步，跳測試編譯）。
- [ ] **前端可 build**：Node **16.20.2**（`nvm use`；切版刪 `node_modules` 重裝）→ `yarn install --frozen-lockfile` → `yarn ng build` 綠。
- [ ] **授權列已套**（**測 c0/csu 頁的前提**）：在 `OVSLXLON02` 套 `docs/build-tasks/c0-authz-sql.sql`（ops 照 `c0-authz-sql-findings.md` 的 Ops Apply Checklist；預期 insert 16）——**未套打 c0 endpoint 全 403**。不測 c0/csu 可暫略，但主流程 save 仍需此庫。
- [ ] **BE profile** 指向：DB URL=`OVSLXLON02`、**既有帳號**（讀 config／`ALL_USERS` 撈，不創新；密碼不進 repo）、（護欄 0.1 的測試案件段就緒）。
- [ ] **FE `environment`** API base 指向 local BE（**勿 commit 進正式 profile**）。

## 2. Bring-up 順序
```
後端  自己終端：mvn spring-boot:run（或 java -jar target/*.jar）——啟動後確認健康/連 DB OK
前端  自己終端：yarn ng serve ——啟動後瀏覽器開 localhost
登入  真 dev 帳號登入拿 JWT（看真資料）；或 DevTools 塞 dummy token（只看皮，API 401）
```
> auth bypass（dummy token / 關 guard）**只限本機、絕不 commit**（`SETUP-codex.md` 疑難排解）。

## 3. 能驗 / 不能驗矩陣
| 範圍 | 能否本機 | 前提 / 備註 |
|---|---|---|
| 個金/企金主流程 載入·save·submit·return | ✅ 端到端 | 寫帳號 + 測試案件段（護欄 0.1）|
| Phase G 新頁 G1–G3（0150/0160/0170+popup）互動·save | ✅ | 同上；**G3 共用 return dialog 改造的 ISU 回歸一併測**（caseType 切 ISU 走預設 endpoint）|
| c0/csu 評分頁 00110–00120 | ✅（需先套授權列）| 否則 403（gate §1）|
| 契約對齊 FE↔BE DTO | ✅ | 真資料/真授權跑一次（handoff §5）|
| 角色權限分支顯示、businessType G/F 切換 | ⚠️ 受限 | 需真 JWT + 真案件資料 |
| 撥貸 authorize（T24）| 🚫 本機測不到 | T24/SFTP 外部整合起不來；且 authorize 核心仍 throw-stub（A-1，handoff §2.2）|
| R2 報表 PDF（0181/00640 PDF…）| 🚫 | R2 報表服務未建 |
| 檔案上傳 API | 🚫 | 暫緩 track |

## 4. 建議 smoke 順序（由淺入深，先驗不寫的）
1. 登入 + 開一個**唯讀載入頁**（如個金主流程 borrower 載入）→ 確認 FE↔BE↔DB 三段通、JWT/授權鏈活。
2. 開 **Phase G 新頁**（0150/0160/0170）render + dropdown + 載入（不 save）→ 驗版面/契約。
3. 對**測試案件**做一次 **save**（個金或企金主流程）→ 唯讀帳號 SELECT 確認落庫正確。
4. 套授權列後，開 **c0/csu 評分頁** → 確認非 403、載入/calc/save。
5. G3 **共用 return dialog**：CSU return → CSU endpoint；切 ISU → 預設 endpoint（**回歸**）。
6. 寫測收尾：產 **teardown SQL**（限測試案件）交人審清庫。

## Tasks（checklist——session 中斷在此記斷點續跑）
- [ ] T1 前置 gate 四項綠（build×2 / 授權列 / profile+environment）
- [ ] T2 BE+FE 起來、登入通（smoke 1）
- [ ] T3 Phase G 新頁 render/載入（smoke 2）
- [ ] T4 主流程 save 落庫驗證（smoke 3；測試案件段）
- [ ] T5 c0/csu 評分頁非 403（smoke 4；授權列已套）
- [ ] T6 G3 return dialog ISU 回歸（smoke 5）
- [ ] T7 teardown SQL 產出交人審（smoke 6）
- 斷點：（起手＝T1）

## 回報
- 每項 PASS/FAIL/⚠️ + 證據（畫面截點 / 唯讀 SELECT 結果 / 錯誤訊息）；**不吐大段 code**。
- 用了哪些測試 `APPLICATION_NO`；teardown SQL 路徑 + 預期刪除筆數。
- 結果回填 `verification/verification-handoff.md` §6（runtime）對應列 + `feature-inventory.md`。

> 過了：主流程/Phase G/c0-csu 的 runtime 整合驗證落地；撥貸/報表/上傳留待 T24·R2·檔案 API 就緒（各自 track）。

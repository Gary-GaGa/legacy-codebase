# Build Task（PARKED → QA Flow）— v3：寫入 conformance（save/submit）

> Status: **PARKED（owner 2026-06-27：v3 不當 RD-per-page gate ⑧，改歸未來 QA Flow 整合 tier）**。
> **為何移出 gate ⑧**：save/submit 是**案件流程耦合**（CASE_PROGRESS 狀態/角色/上游頁/checkpoint 鏈），單頁難孤立驗 → 本質整合/acceptance、非 RD per-page 閘。RD Flow 的 gate ⑧ 維持**讀型 v1/v2 only**。見 `decisions.md`「gate ⑧ 範圍＝讀型」列。
> **未來歸屬**：QA Flow 回來時的**整合 conformance tier**（吸收 Phase V harness/真庫）；本卡內容＝該 tier 的寫入測法草稿（護欄/手法）。
> **過渡（QA 未回）**：高風險 save（評分 save、00800 insert）用 **fixture-case 半自動**；廣面流程耦合 save 交 **UAT 人跑真案件**（同 `verification-handoff §2` domain 驗法）。
> 依據：`local-phase-v-bringup.md §0.1`（寫測護欄，強制）+ `process/local-env-manager.md`。

## 範圍
- **納入**：已 v2 過的頁的**寫入端點**（save / insert / submit；如 c0 評分 save、EPROZ00800 insert-reviseditem、主流程 save）。
- **暫不納**：撥貸 authorize（T24/SFTP/外部整合，本機測不到）、R2 報表、檔案上傳（見 bringup §3 能驗矩陣）。
- 每寫入 case：app 端點寫 → **唯讀帳號 SELECT 驗落庫正確**（值/側效/checkpoint）→ 產 teardown SQL。

## 🔒 寫測護欄（強制，缺一不可——bringup §0.1）
1. **保留測試案件號段**：用不撞真案件的 `APPLICATION_NO` 段；開測前 SELECT 確認該段未被佔、記錄用了哪些。
2. **teardown SQL 人審**：測後產 `DELETE`（限測試案件號）交人審執行——**DML 不由 agent/Codex 直執行**（同 `c0-authz-sql` 模式）。app 端點的寫入是 SUT（可由 agent 觸發）；清理 DML 不可。
3. **快照**：寫測前 DBA 對受影響表快照/備份；無法快照則只挑「teardown 可完全還原」的頁。
4. **不撞線上**：避開他人實際使用 OVSLXLON02 時段、與 owner 對齊。
5. **唯讀帳號做驗證 SELECT**（不另開寫權給 agent）。
6. **可識別/可重複**：測試資料可識別、idempotent（重跑前先 teardown 或用新案號段）。

## gate ⑧ 寫入斷言（runtime conformance）
- save → 對應表落庫值**逐欄正確**（API 寫入 == DB；金額精度/截斷照 schema）。
- **側效/checkpoint**：save 觸發的 side-effect（如 R13 刪 detail、checkpoint 標記）與 spec Rn 一致；calc 不寫 checkpoint（R7）等不變式守住。
- 失敗三分類（同 gate ⑧）：assertion-conformance → 開 RD 卡（碼≠契約）；契約模糊/安全/金額 → escalate 不自改；infra/auth → 修 env/role。

## 可貼 Codex 啟動（v3；母資料夾、寫入帶護欄）
```
任務：Phase V L2 v3——寫入路徑 conformance（save/submit），帶 §0.1 護欄。經 runner 起停、結束 down。
依據 docs/build-tasks/phase-v-l2-v3-writes.md + local-phase-v-bringup §0.1 + orchestration-playbook §4c。
前置：v2 已過、specs 在母資料夾、c0-authz 已套。

0. 護欄就緒：① SELECT 確認保留測試案件號段未被佔、記錄案號 ② 與 owner 對齊測試時段 ③ 受影響表快照（DBA）。
   缺任一 → 停、回報，不寫。
1. 產 v3 manifest（從母資料夾 specs openapi/spec/schema）：每頁寫入端點 + 寫入 payload（用測試案號段）
   + 落庫驗證唯讀 SQL（值/側效/checkpoint）+ 斷言。
2. 跑 tools/phase-v-run.ps1（local-env up→smoke→per-case role JWT→harness→finally down）：
   - 寫入＝呼叫 app save/submit 端點（SUT）；驗證＝唯讀帳號 SELECT 比對落庫。
   - **不直接執行任何清理 DML**。
3. 測後：產 teardown SQL（DELETE 限測試案號）→ **交人審**（不自跑）。回報用了哪些 APPLICATION_NO、預期刪除筆數。
4. 歸因三分類：assertion-conformance gap → RD 卡；契約模糊/金額/安全/側效不可逆 → escalate；infra/auth → 修 env/role。
回報：PASS/FAIL 表（per 寫入端點，三分類）+ 用的測試案號（去敏）+ teardown SQL 路徑+預期筆數 + down 後無 listener。
   回填 verification-handoff §6。
鐵則：寫入只經 app 端點、清理 DML 人審不自執行；JWT/帳密走 env 不進 repo；真案號去敏；finally 必 down + teardown 交審。
```

## 關聯
- v2＝`done/phase-v-api-selfverify-runtime-bugs.md` 同 harness 擴；護欄＝`local-phase-v-bringup §0.1`；gate ⑧＝`orchestration-playbook §4c`。

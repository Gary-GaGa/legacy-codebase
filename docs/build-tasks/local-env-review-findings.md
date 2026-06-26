# 獨立複驗 — local-env manager v1（tools/local-env.ps1，commit 58b5075）

> planning 側對 dev 同步的 env manager 做交叉複驗（只報、ps1 屬 dev 主編，避免分叉不由 planning 改）。

## 結論：v1 紮實，核心痛點已解 ✅
- 自測 a~f 全過——**含最關鍵的 (d) orphan 測**：只殺 mvn/yarn wrapper(13124/22360) 後 5500/4200 仍由子程序(16988/22212) listen → down 以 **kill-by-port** 清掉、無殘留。**wrapper-PID 真 bug 已被正面驗證解掉**＝「上次沒關停擺」根治。
- (e) 歸屬判定：認得的殘留(fake 20528)pre-flight 清掉、認不得的(fake 20164)fail-fast exit 1 不誤殺 ✅。
- (f) 逾時：BE 不 ready → up 逾時 exit 1 + 自動 down、無殘留 ✅。
- descriptor PID == listener PID（非 wrapper）✅；idempotent 重用 ✅。

## 待處理（dev 端修）
### 🔴 LE-1 .gitignore 未同步（dev 宣稱已加、repo 實際沒有）
- dev report 稱「更新 .gitignore 忽略 `.local-env/` + `tools/local-env*.local.json`」，但 commit 58b5075 **只含 tools/local-env.ps1**、`.gitignore` 無此條目 → 本機 profile（**含 DB 帳密**）、descriptor、pidfile **未受保護**，下次可能誤 commit。
- **planning 側已補**（本輪 commit）：`.gitignore` 加 `.local-env/`、`tools/local-env*.local.json`、`*.pidfile`。
- **dev 端**：若你本機也改過 `.gitignore`，以 repo 為準（別各改各的造成分叉）；確認本機 profile 檔名符合 `tools/local-env*.local.json` 或落 `.local-env/`。

### 🟡 LE-2 ps1 硬編本機路徑 + 工號（line 91）
- `Get-Node16Root` 寫死 `C:\Users\00596357\Documents\project\pkg\node\v16.20.2`（含**工號 00596357** + 特定機器路徑）→ 不可攜、且違「本機 only、不 commit」。
- **修法**：改走 `-Profile`/env（如 `NODE16_ROOT`）覆寫，腳本不內含機器路徑；找不到再 fallback PATH 的 node。
- 註：此值已在 git history（58b5075）；屬內部工號非憑證，**不值得 force-push 改史**（且 force push 被 deny）——往後版本移除即可。

### 🟡 LE-3 BE readiness＝純 liveness（info.status=UP 是注入值、非真健康）
- dev 用 `/actuator/info` + 啟動注入 `info.status=UP`（因 `/actuator/health` 被 JWT filter 回 401；**未改後端/未碰 JWT＝正確克制**）。
- 但注入的 `status=UP` 是**靜態值、非真健康信號** → env 的 ready 實質＝**liveness（app 能回 200）**，非「BE+DB 真能服務」。**這符合兩層 readiness 設計（env=liveness、serviceability=消費者）**，可接受。
- ⚠️ **因此第二張 harness/runner 派工的 serviceability smoke（打一條碰 DB 的唯讀 endpoint 得 200+非錯誤碼）變成必做**——別把 env 的 UP 當「app 真能服務」的證據。已在 `local-env-manager.md §4.4` / 歸因三分類載明。

### ✅ LE-4 runner 被 local-env「歸屬判定」卡住 — RESOLVED（2026-06-26，commit 946dcb0）
> **修畢複驗**：`Get-ListenerOwnership` 改＝**pidfile/descriptor 主 → marker `LOCAL_ENV_OWNED=<runId>` 補 → owned=false**，**不再靠子程序 cmdline 字串**（根因解除）。pre-flight：owned→清理重起（不 fail）；非 owned 且無 `-Force`→fail-fast 報明（cmdline 已遮罩）、`-Force` 才清。密鑰掃描乾淨。runner 不再被自家服務卡住。（up 採「認得→清理重起」而非「重用」＝契約 §4.2.1「或要重起時清理」允許範圍，重用為可選優化、非必要。）

<details><summary>原始 finding（保留）</summary>
- RI-2 RD 驗證時 `tools/phase-v-run.ps1 -SkipBuild` **卡在 local-env listener ownership 檢查**；dev 改直接跑既有 `tools/phase-v-api-selfverify.ps1`（對已可達服務）才完成驗證。
- 即：批判複審加的「pre-flight 只殺認得的、認不得 fail-fast」（`local-env-manager.md §4.2`）**過嚴/誤判**，擋掉了正常 runner 路徑 → **gate ⑧ 的「經 runner 跑」未被完整走到**（本次靠直跑 harness 繞過）。
- **影響**：gate ⑧ 要靠 runner（env up→smoke→harness→down）才成立；ownership 檢查若常誤判，RD 每次都得手動繞過＝破「單一入口」。
- **待修（dev/env-manager 下一輪）**：調 ownership 判定——對「本工具 pidfile/descriptor 記錄的、或 cmdline 明確是 spring-boot.run/ng serve 且本工作目錄」者放行重用/清理，別把自己起的服務誤判成「認不得」而 fail-fast；fail-fast 應限「真不明的第三方占用」。修前 RD 可用 `-Force` 或直跑 harness 暫繞（已知 workaround）。
</details>

## 關聯
- 工具契約＝`docs/process/local-env-manager.md`；Phase V 消費＝`phase-v-env-manager.md`。

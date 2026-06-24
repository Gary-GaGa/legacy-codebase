# Build Task — PRD→SRS orchestrator **PILOT**（規模化前先跑通一頁）

> Status: **已歸檔（移入 done/，2026-06-24）** — pilot 任務完成（`EPROZ00100`/`EPROC00118` 2026-06-18 跑通 → drain 啟用）。單頁首跑紀律已併入 `prd-to-srs-orchestrator-drain.md` 首批放量段；本卡留作方法論歷史。


> **載具**：Codex（母資料夾：產品碼 + 規劃 repo 可讀 + Bible v1.1 + 新版 PRD + local `docs/db-diff/`/`docs/refactor-spec/`）。
> **目的**：用 SRS orchestrator 跑通 **1 頁**（**非批量**），確認「取佇列 → 產 SRS → 機械 gate（含 gateⓇ）→ N 軸驗證 → 回填 ledger → 停等審」整條順、四條守則守得住，**再放大到 67 頁**。
> **權威**（prompt 已內聯關鍵，不可讀亦能跑）：流程＝`docs/process/orchestration-playbook.md §4b（N 軸）/§5b（SRS 迴圈）/§6b（prompt 骨架）`；產 SRS＝`docs/build-tasks/prd-to-srs-codex-dispatch.md`；機械閘門＝`scripts/check-srs-bundle.py`（含 **gateⓇ** reconcile）；pilot 頁 risk-tier/舊對應＝`docs/build-tasks/c0-legacy-parity-recheck.md`。

## 0. 前置（owner 先做，缺一不可）

**0a. 啟動位置＝母資料夾（不是只在規劃 repo `codex`）**：在能**同時看到三者**的母資料夾啟動 Codex——① 規劃 repo `legacy-codebase/`〔寫 SRS bundle + 改佇列〕② 產品碼 `backend/`/`frontend/`〔讀 as-is，N 軸 B / brownfield 最低驗證深度〕③ local `docs/db-diff/`＋`docs/refactor-spec/`〔reconcile，gateⓇ / N 軸 E〕。**只在規劃 repo 啟動 → 碰不到產品碼（as-is 變「待 RD」）與 db-diff/refactor-spec（reconcile 跑不了、gateⓇ 只能 disclaim）**。母資料夾結構＋3 個 `AGENTS.md` 疊加見 `docs/process/SETUP-codex.md §1`。
  - ⚠️ `docs/db-diff/`、`docs/refactor-spec/`＝**local only**：放母資料夾 sibling、**勿放進 `backend/`、勿 commit/push、勿納入 build**（否則被 Maven 拉進/被 git 追蹤）。

1. **選 pilot 頁**：建議 risk-tier T1 最前＝**`EPROC00118`**（有 refactor baseline、可實際操練 reconcile 軸 E；`00119/00120` 才是 refactor 缺頁、勿混——**`00120` 雖也在 T1 佇列，但屬 refactor 缺頁→走 i0-mirror、不選為 pilot**）。或你手邊已有 PRD 的任一頁（seed 後 orchestrator 仍依佇列 risk 序取，非繞過）。
2. **PRD 放好**：`docs/specs/prd/`，檔名 **`PRD-*<funcId>*.md`**（不符 gateⒷ/Ⓔ 找不到；rename 腳本 `scripts/rename-prd.ps1`；格式 7 點預檢見 dispatch 卡「PRD 放置與對應」）。
3. **佇列回填**：`build-tasks/refactor-audit/per-page-reinventory-matrix.md` 的「PRD→SRS 佇列 + ledger」表，把該頁 `status=prd-ready`＋填 `prd` 欄。**若該頁是 bundle/佔位列（多 funcId）→ 先拆成一 funcId 一列**。

## ⬇️ 複製以下給 Codex（pilot；一頁）

```
你是 SRS orchestrator（pilot 模式，**只跑一頁**）。任務板＝docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md 的「PRD→SRS 佇列 + ledger」表。

【取頁（含對帳/拆列）】
0. 起手對帳：列 docs/specs/prd/PRD-*.md 實檔 ⟷ 佇列 prd 欄。實檔有但佇列仍 not-started → 回報「PRD 已放、待標 prd-ready」並停。
1. 取 risk-tier 最前、status=prd-ready 的「一頁」（同 risk 依表序）。**bundle/佔位列（多 funcId）不可直接 pick** → 回報「需先拆列」並停。記下該 funcId 與其 PRD 路徑。

【產 SRS】
2. spawn 獨立 sub-agent，照 docs/build-tasks/prd-to-srs-codex-dispatch.md 的 prompt（填該 funcId / PRD 路徑）產 SRS bundle 到 docs/specs/srs/<funcId>/。**含 §5 reconcile：必到 local docs/db-diff/（by table_name）+ docs/refactor-spec/（by module_code/artifact_id）對應新 DB + 寫「新舊 DB / 更動 delta」段（每條附來源+三判）**——不得只寫「待 RD」。

【機械 gate】
3. python scripts/check-srs-bundle.py docs/specs/srs/<funcId> 必 exit 0；逐 warn 確認（gateⓇ 段缺=補 delta 段；gateⒺ 漏碼=補承載；@PENDING/xfile 屬已知者註明）。

【N 軸驗證（§4b；多角度、非單一 spec-reviewer）】
4. 依 playbook §4b 各 spawn 一「read-only、獨立 session、最好跨模型」sub-agent 跑下列軸（brief=§4b 表「只看」欄；risk-tier T1 全跑 A–G、低風險頁可只 A+E+G）：
   A 綜合（=spec-reviewer.md 7 維/紅旗）｜B as-is parity（含 throw-stub/regression 三判/legacy 細節別抄進契約）｜C 錯誤碼承載（含裸名碼，補 gateⒺ 盲區）｜D 安全·授權（Bible BR/SC/災難 + TB_API_AUTH/SECURE_ATTRIBUTE + mutating FE-only）｜E DB reconcile（delta 段每條附來源+三判、schema.sql 真帶 hint 非只「待 RD」）｜F 金錢·精度·截斷（精度/rounding/maxlength/截斷欄逐欄）｜G 可測試性（QA 真測精神、多分支 happy/error/edge）。
   各軸回 PASS / Blocker(file:line)。**採納修正後再跑該軸一輪**（修正可能引入新錯）。

【回填 ledger + 停】
5. 達標（機械 exit 0 + N 軸全軸無 Blocker）→ 回填佇列表該頁 status=in-review、填 srs 路徑（=ledger，防重複/防漏）。
6. **停此等人審/裁 TBD**。不得自宣 approved（TBD 全關+人裁才 approved）、不得跳 gate/軸、不得碰 C 類（裁 TBD/風險/架構/domain，只整理證據備到蓋章）。context 衛生：每 sub-task 獨立 session，主控只收 PASS/FAIL/findings 路徑。

【回報格式】
- 該頁 funcId + bundle 路徑（docs/specs/srs/<funcId>/ 四檔）。
- 機械 gate：exit code + 殘 warn 一行。
- N 軸：每軸一行（PASS / Blocker+file:line）；採納修正/複審結果。
- 佇列回填 diff（status→in-review、srs 路徑）。
- @PENDING（未關 TBD）彙總成表（給 PM/SA 裁）。
- 一句話：pilot 是否四條守則守住（停等審/不自宣 done/不碰 C 類/N 軸真獨立）。
```

## 通過條件
- 機械 `check-srs-bundle.py` exit 0（含 gateⓇ reconcile）。
- N 軸（§4b A–G）全軸無未解 Blocker（採納修正後再審一輪）。
- 佇列 ledger 回填 `status=in-review`＋`srs` 路徑（覆蓋計數由此衍生）。
- 停在等人審/裁 TBD；未自宣 approved、未碰 C 類。

## pilot 過了才放大
四條守則守住 + 上述通過 → 放大到批量＝**drain 模式（已啟用 2026-06-20，§5b/§6b）**：同 prompt 去掉「只跑一頁」，依佇列 risk-tier **序列逐頁**（每頁各自 gate+N 軸+ledger 回填、序列非並行），但**一頁達標即接下一頁、不在每頁停**，drain 完所有 `prd-ready`→`in-review` 才停在 **batch checkpoint 一次**交人審/裁 TBD（非每頁人審）；終點 `in-review`、不自升 approved、不碰 C 類、單頁 FAIL 標因續跑。**pilot 未過先別批量**（avoid「假綠當完成」，orchestration-playbook §3）。

> 過了：回填本卡「pilot 結果」一行 + 佇列表該頁 status；下一頁照辦。卡歸檔 `done/` 於批量啟動後。

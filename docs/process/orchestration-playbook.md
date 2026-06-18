# Orchestration Playbook — Codex 多任務編排（自動到 checkpoint、停下交人）

> **定位**：把「派工＋執行＋機械閘門」自動化（orchestrator + sub-agent），**停在「等人審／等 owner 裁」**。審查與裁定仍是人——這是 workflow 價值核心（Phase V 證明：build 全綠也漏 RV-1/RV-2）。
> **權威**：本檔＝三類分法／依賴 DAG／完成定義／三軸驗證的**單一出處**；`docs/env/codex/verifier-*.toml` 為薄殼指向本檔。
> **何時用**：可並行的多個 build-task（recon／已盤點的 sweep 修／明確 typo／批量 PRD→SRS Phase 1）。單一小任務不必編排。

## 1. 任務三類（orchestrator 只碰 A，整理 B，不碰 C）
| 類 | 例 | orchestrator 能到 |
|---|---|---|
| **A 可自動執行→等審** | 唯讀 recon、已盤點的 sweep 修、明確 typo（OQ-5）、批量 PRD→SRS Phase 1 | spawn sub-agent 執行＋機械 gate＋三軸驗（**SRS 軌＝§4b N 軸**）→**停「等人審」** |
| **B 半自動→等裁** | SRS 產初稿後的 `@PENDING` | 標出＋彙總成表→**停「等 owner 裁」** |
| **C 停止點（人/owner）** | 風險取捨（RP1）、架構（RP9）、domain（A-1）、AUD/BP | **只整理證據「備到蓋章即可」**，不裁 |

## 2. 依賴 DAG（餵 orchestrator，禁盲目並行）
- 輸入＝`STATUS.md §六`（進行中/待派）+ `pending-register.md`（依賴/owner）。
- 硬依賴例：`get-body #3` ← `RP9` ← `epl-* method 慣例 recon`；`A-1 施工` ← `T24 OQ-1`；c0/csu Phase V ← ops 套授權列。
- **依賴未滿足的任務不准動**（卡頭標「待 X」者跳過）。

## 3. 完成定義（防 progress bias——最重要）
> AI 急著標完成是已坐實傾向（00800 批判教訓 15；`spec-architecture §9`）。故：
- task「done」**只認**：機械 gate 綠（`verify-c0` / `check-srs-bundle` / `mvn` / `ng build` exit 0）**＋** 三軸驗證 PASS（**SRS 軌＝§4b N 軸 PASS**）**＋** 狀態標「等人審」。
- **orchestrator 不得自宣 done / 不得跳過 gate / 不得把假綠當完成**。終點是「等審」，不是「上線」。

## 4. 三軸正交驗證（code 階段；≥3 sub-agent，但**必須真獨立**）
> 「3 個 PASS」≠ 3 倍信心——同模型/同 context/同指示會 correlated blindness（3 個一起漏同一個，Phase V 即此）。故定**三個正交視角**（最好跨模型，至少不同指示），各 read-only：
| 軸 | agent | 只看 |
|---|---|---|
| **contract** | `verifier-contract` | FE↔BE DTO/method/契約對齊、openapi/schema 一致 |
| **scope** | `verifier-scope` | commit 範圍、有無誤動 OUT/越界、是否只改該改的 |
| **regression** | `verifier-regression` | 對舊系統/i0 鏡像有無偏離、既有路徑回歸、有無 reflection/委派 |
- 三軸全 PASS 才算「三軸驗證 PASS」；同質 3 個＝theater，不算。
- 仍 ≠ 人審：三軸是**強化自驗**，orchestration 仍停在等人審。

## 4b. SRS 階段 N 軸驗證（PRD→SRS 專用；§4 code 三軸不適用）
> SRS 是「**還沒 code**」的文件——§4 三軸（git diff／FE↔BE DTO／build／runtime）對一份 `spec.md` 幾乎無話可說。SRS 階段的「多角度」改用下列 **≥6 正交軸**，各 read-only、獨立 session、**最好跨模型**（同 §4 反 correlated-blindness）。**一份 SRS 完成＝這 N 軸全無 Blocker**＝owner「每份 SRS 完成後多開 sub-agent 不同角度再驗」的落地（取代「單一 spec-reviewer」）。
| 軸 | 只看 | 對應易疏漏陷阱 |
|---|---|---|
| **A. 綜合/完整性** | `spec-reviewer.md` 7 維（REQ↔Rn↔QA、Non-Goals、TBD→@PENDING、Traceability、批判輪紅旗）| 缺需求／追溯斷裂 |
| **B. as-is parity** | to-be 有無把 legacy 當已核准需求；as-is ✅⚠️🔴 引 `file:line`；throw-stub「結構在≠行為對」；regression vs 刻意演進三判（`legacy-parity-sop`）；**PRD 帶的 legacy 細節（checkpoint key 名/現行 method/欄寬）有無原樣抄進 openapi/schema 契約（B1 教訓）** | ⑥ throw-stub、⑤ regression、③ checkpoint key/欄寬抄進契約 |
| **C. 錯誤碼承載** | PRD Error 表逐碼（**含裸名碼**，補機械 gateⒺ 盲區）→ Rn＋openapi＋對的 HTTP status；勿 400/500 conflation | ① 裸名碼繞 gateⒺ |
| **D. 安全·授權** | Bible BR/SC/災難情境＋`TB_API_AUTH`/`SECURE_ATTRIBUTE` 逐條 carried/disclaimed；mutating 端點 FE-only 須有 BE 強制 Rn | 安全/災難未承載 |
| **E. DB reconcile** | spec 有無「新舊 DB/更動 delta」段（`gateⓇ` 已 warn 段缺，本軸查**內容**）；每條附來源＋三判；`schema.sql` 真帶 change-hint 還是只寫「待 RD」| ④ db-schema/refactor reconcile 漏 |
| **F. 金錢·精度·截斷** | 精度/rounding/maxlength/截斷欄逐欄（**現流程最空白、風險最高**）；金錢欄 BE 權威＋交易一致 | ② 金錢/截斷/精度欄 |
| **G. 可測試性** | 每 Rn 的 QA 真測到精神（非掛名）；多分支 happy/error/edge 齊（補 gate⑤「≥1」假綠）| QA 充數 |
- **真獨立**：各軸獨立 session、不同指示、最好跨模型；同質多個＝theater、不算 N 軸 PASS。
- **A 廣度兜底、C–G 深度窮舉**：A（含 spec-reviewer 6 紅旗）與 C/D/E 在錯誤碼/安全/reconcile 上**刻意重疊＝雙保險**（跨模型反 correlated-blindness），非互推皮球；專軸逐項窮舉、A 顧整體一致——**跑了 A 不替代專軸**。
- **規模調配**：低風險頁（z0 KEEP）可只跑 A＋E＋G；**risk-tier T1（金錢/計分/checkpoint/授權）或 refactor 覆蓋缺頁，A–G 全跑**（owner「易疏漏處多開 sub-agent」）。
- **仍 ≠ 人審**：N 軸是強化自驗，orchestration 仍停在等人審／等裁 TBD。
- **落地**：Claude 主 session 用 Agent 工具各 spawn 一軸；Codex 同（部署見 §7；**briefs 權威＝本表**）。axis A＝既有 `spec-reviewer`。

## 5. orchestrator 迴圈
```
讀 STATUS §六 + pending-register（任務板）
 → 篩 A 類且依賴已滿足
 → 各 spawn 獨立 sub-agent 執行（獨立 context；只回 PASS/FAIL/findings 路徑，不塞全文）
 → 每 task：機械 gate + 三軸驗證
 → 完成定義達標 → 標「等人審」；否則標 FAIL+原因 / blocked+依賴
 → 彙總一行/task 回報，停 checkpoint
人審 → 採納 → 回填 → 下一輪 orchestrator
```

## 5b. SRS 軌迴圈（PRD→SRS 規模化；輸入＝PRD 佇列、非 STATUS §六）
> code 軌（§5）吃 code 任務板；**SRS 軌吃 `build-tasks/refactor-audit/per-page-reinventory-matrix.md` 的「PRD→SRS 佇列 + ledger」表**（＝orchestrator 可機械迭代的逐 funcId 清單＋完成 ledger，補 owner ①「依序處理每個 PRD、不重複不漏」）。
```
讀 per-page-reinventory-matrix「PRD→SRS 佇列 + ledger」表
 → 取 risk-tier 最前、status=prd-ready 的一頁（status=not-started 但 prd 欄空＝PRD 未放→跳過、回報「待 owner 放 PRD」）
 → spawn 獨立 sub-agent 跑 prd-to-srs（dispatch 卡 prompt，填 funcId/PRD 路徑）→ 產 bundle 到 docs/specs/srs/<funcId>/
 → 機械 gate：check-srs-bundle.py exit 0（含 gateⓇ reconcile）
 → SRS N 軸驗證（§4b 的 A–G，≥6 正交、跨模型）→ 採納修正後再審一輪
 → 達標 → 佇列表該頁 status=in-review、填 srs 路徑（＝ledger 回填，防重複/防漏；覆蓋計數由此衍生）
 → 停 checkpoint 等人審/裁 TBD；下一輪取佇列下一頁
```
- **一次一頁**（dispatch 鐵則）：別一次吞整批；每頁各自過 gate＋N 軸＋人審。
- **不急著轉完**：佇列無期限，risk-tier 前段先；owner 未放 PRD 的頁＝blocked、不臆造。
- **bundle/佔位列不可直接 pick**：佇列表的多頁列（企金線 T2/T3、撥貸群、ISU/i0/z0 增量）＝佔位、非派工單位；PRD 進場須先**拆成一 funcId 一列**才可 `prd-ready`（守「一頁一列、一次一頁」）。同 risk tier 內 tie-break＝**表序由上而下**。
- **起手對帳（防漏）**：每輪先列 `docs/specs/prd/PRD-*.md` 實檔 ⟷ 佇列 `prd` 欄；**實檔有而表列仍 not-started＝回報 owner「PRD 已放、待標 prd-ready（或拆列）」、不靜默漏**（補 plan①「不漏」）。

## 6. orchestrator prompt 骨架（可直接 pilot）
```
你是 orchestrator。讀 docs/STATUS.md §六 + docs/pending-register.md 當任務板。
1. 只自動執行 A 類（唯讀 recon／已盤點 sweep 修／明確 typo；卡頭標可派工且依賴已滿足）。
2. 依賴 DAG：get-body #3 待 RP9；A-1 施工待 T24 OQ-1；c0/csu 驗證待 ops 套授權列——未滿足不准動。
3. 每 A 類 task spawn 獨立 sub-agent 執行 → 跑該層機械 gate（mvn / ng build / verify-c0 / check-srs-bundle）→ 三軸驗證（verifier-contract/scope/regression，各 read-only、不同視角）。
4. task「完成」= 機械 gate 綠 + 三軸 PASS，標「等人審」；**不得自宣 done、不得跳 gate、不得碰 C 類（裁定/風險/架構/domain）**。
5. context 衛生：每 sub-task 獨立 session，主控只收 PASS/FAIL/findings 路徑。
彙總回報：每 task 一行（等審 / FAIL+原因 / blocked+依賴）+ findings/commit 路徑。停此等人審。
```

## 6b. SRS orchestrator prompt 骨架（PRD→SRS 規模化；可直接 pilot）
> **pilot 派工卡（一頁、含前置/對帳/拆列/N 軸/回填）＝`build-tasks/prd-to-srs-orchestrator-pilot.md`**——規模化前先用它跑通一頁。
```
你是 SRS orchestrator。任務板＝docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md 的「PRD→SRS 佇列 + ledger」表。
1. 取 risk-tier 最前、status=prd-ready（PRD 快照已在 docs/specs/prd/、檔名 PRD-*<funcId>*.md）的一頁；status=not-started 且 prd 欄空＝PRD 未放→跳過、回報「待 owner 放 PRD」。不一次吞整批。
   起手先對帳 docs/specs/prd/ 實檔 ⟷ 佇列 prd 欄：實檔有但表列 not-started→回報「PRD 已放、待標 prd-ready」；bundle/佔位列（多 funcId）不可直接 pick，須先拆成一 funcId 一列；同 risk 依表序。
2. spawn 獨立 sub-agent 跑 prd-to-srs（用 build-tasks/prd-to-srs-codex-dispatch.md 的 prompt，填該 funcId/PRD 路徑）→ 產 bundle 到 docs/specs/srs/<funcId>/。
3. 機械 gate：python scripts/check-srs-bundle.py docs/specs/srs/<funcId> 必 exit 0（含 gateⓇ reconcile）。
4. SRS N 軸驗證：依 playbook §4b 各 spawn 一 read-only sub-agent 跑 A–G 軸（各獨立 session、不同指示、最好跨模型；非單一 spec-reviewer；低風險頁可 A+E+G、risk-tier T1 全 A–G）→ 採納修正後再審一輪。
5. 達標（機械 exit 0 + N 軸無 Blocker）→ 回填佇列表該頁 status=in-review、填 srs 路徑（＝ledger，防重複/防漏）；不得自宣 approved（TBD 全關+人裁才 approved）、不得跳 gate/軸、不得碰 C 類（裁 TBD/風險/架構/domain）。
6. context 衛生：每 sub-task 獨立 session，主控只收 PASS/FAIL/findings 路徑。
彙總回報：每頁一行（in-review / FAIL+原因 / blocked=待 PRD 或待裁）+ bundle/findings 路徑。停此等人審/裁 TBD，下一輪取佇列下一頁。
```

## 7. config 落地（部署本機 `.codex/`）
- `.codex/agents/verifier-{contract,scope,regression}.toml`（範本 `docs/env/codex/verifier-*.toml`；`sandbox_mode="read-only"`、三軸不同 `developer_instructions`、建議跨模型）。
- **SRS 軌 N 軸（§4b）**：Codex orchestrator 依 §4b briefs 各 spawn 一 read-only sub-agent（跨模型）跑 A–G 軸；**不需 per-axis toml**（briefs 權威＝§4b，同薄殼指標）；axis A＝既有 `spec-reviewer.toml`。
- `.codex/hooks.json`（範本 `docs/env/codex/hooks.json`）：Stop 掛 `verify-c0`+`check-srs-bundle`＝**唯一硬強制層**（「3 agent」hook 驗不了，靠本檔規範＋完工報告列名/結論）。
- `.codex/config.toml`：`-a on-request -s workspace-write`（多 task 別 `never`；範本 `docs/env/codex/config-permissions.md`）。
- `AGENTS.md §Spec workflow`：orchestration 鐵則指標（薄殼，內容權威＝本檔）。

## 8. 天花板（誠實標）
orchestration 省的是「派工打字＋貼 prompt」，**省不掉審查＋裁定**。天花板＝「自動到等審」，非「自動到上線」。pilot 建議：先用 `epl-* method 慣例 recon` + `0922-t24-exchrate-colname-fix`（兩個 A 類、互不相依）跑一輪,確認「停在等審、不自宣 done、不碰 C 類、三軸真獨立」四條守得住,再放大到批量 PRD→SRS（SRS 軌 pilot＝`build-tasks/prd-to-srs-orchestrator-pilot.md`，跑通一頁再批量）。

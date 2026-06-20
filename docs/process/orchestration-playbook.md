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

> **B vs C 由來源優先序定**（`docs/spec-architecture.md §5b`）：可由新 DB 判定的 **fact**＝A 類自解（含 provenance）、不再列 B；**升級觸發**（Bible/PRD 衝突·regression·高風險面·同層無 upstream）命中＝**C 類**待裁；refactor vs legacy 純本層契約取捨＝可自決 refactor-wins（留 `REF-Dn` delta）。

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
> SRS 是「**還沒 code**」的文件——§4 三軸（git diff／FE↔BE DTO／build／runtime）對一份 `spec.md` 幾乎無話可說。SRS 階段的「多角度」改用下列 **七正交軸（A–G）**，各 read-only、獨立 session、**最好跨模型**（同 §4 反 correlated-blindness）。**一份 SRS 完成＝這 N 軸全無 Blocker**＝owner「每份 SRS 完成後多開 sub-agent 不同角度再驗」的落地（取代「單一 spec-reviewer」）。
| 軸 | 只看 | 對應易疏漏陷阱 |
|---|---|---|
| **A. 綜合/完整性** | `spec-reviewer.md` 7 維（REQ↔Rn↔QA、Non-Goals、TBD→@PENDING、Traceability、批判輪紅旗）| 缺需求／追溯斷裂 |
| **B. as-is parity** | to-be 有無把 legacy 當已核准需求；as-is ✅⚠️🔴 引 `file:line`；throw-stub「結構在≠行為對」；regression vs 刻意演進三判（`legacy-parity-sop`）；**PRD 帶的 legacy 細節（checkpoint key 名/現行 method/欄寬）有無原樣抄進 openapi/schema 契約（B1 教訓）** | ⑥ throw-stub、⑤ regression、③ checkpoint key/欄寬抄進契約 |
| **C. 錯誤碼承載** | PRD Error 表逐碼（**含裸名碼**，補機械 gateⒺ 盲區）→ Rn＋openapi＋對的 HTTP status；勿 400/500 conflation | ① 裸名碼繞 gateⒺ |
| **D. 安全·授權** | Bible BR/SC/災難情境＋`TB_API_AUTH`/`SECURE_ATTRIBUTE` 逐條 carried/disclaimed；mutating 端點 FE-only 須有 BE 強制 Rn | 安全/災難未承載 |
| **E. DB reconcile** | spec 有無「新舊 DB/更動 delta」段（`gateⓇ` 已 warn 段缺，本軸查**內容**）；每條附來源＋三判；`schema.sql` 真帶 change-hint 還是只寫「待 RD」| ④ db-diff/refactor-spec reconcile 漏 |
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
 → 起手對帳：docs/specs/prd/ 實檔 ⟷ 佇列 prd 欄（實檔有而表列 not-started→回報待標 prd-ready，不靜默漏）
 → while 佇列仍有 status=prd-ready 列（可多頁同時 ready）：           ← drain 迴圈
     取 risk-tier 最前、status=prd-ready 的【一頁】（序列、一次只一頁；同 risk 依表序）
      → spawn 獨立 sub-agent 跑 prd-to-srs（dispatch 卡 prompt，填 funcId/PRD 路徑）→ 產 bundle 到 docs/specs/srs/<funcId>/
      → 機械 gate：check-srs-bundle.py exit 0（含 gateⓇ reconcile）
      → SRS N 軸驗證（§4b 的 A–G 七正交、跨模型）→ 採納修正後再審一輪
      → 達標（exit 0 + N 軸無 Blocker）→ 該頁 status=in-review、填 srs 路徑（＝ledger 回填，防重複/防漏；覆蓋計數由此衍生）
      → 未達標（gate FAIL / N 軸殘 Blocker 需 C 類裁定）→ 該頁標 FAIL/blocked+原因、status 留 prd-ready（不誤升 in-review）
                                                          → 繼續下一頁（單頁失敗不擋整批 drain；批末一併回報）
 → 佇列 prd-ready 全清（皆 in-review 或 FAIL/blocked）→ 停【batch checkpoint】，彙總「整批」等人審/裁 TBD
人審/裁 TBD → in-review 升 approved（人裁，orchestrator 不自升）→ 下一批（owner 再放 PRD 標 prd-ready）
```
- **drain 到底，但仍序列一次一頁**：允許多頁同時 `prd-ready`；orchestrator **逐頁序列**處理（每頁各自過 gate＋N 軸＋ledger 回填），**一頁達標即接下一頁、不在每頁停**——checkpoint 從「每頁停」改為「**整批 prd-ready 清空後停一次**」(batch checkpoint)。序列(非並行)＝保 context 衛生＋避免 correlated 錯。
- **終點仍是 in-review、非 approved**：drain 只把 `prd-ready`→`in-review`（產出+gate+N 軸無 Blocker，含 open @PENDING/TBD）；**升 approved 仍須人裁 TBD**（C 類不碰）。安全網不變、只是把人審聚到批末一次做。
- **單頁 FAIL 不擋整批**：某頁 gate FAIL 或 N 軸殘 Blocker（需 C 類）→ 標 FAIL/blocked+原因、留 `prd-ready`、續跑下一頁；批末彙總哪些頁卡、卡什麼。
- **owner 控放量、orchestrator 控 drain**：佇列無期限、risk-tier 前段先；**owner 放多少 PRD（升多少 prd-ready）就 drain 多少**——「不急著轉完」指 owner 放 PRD 的步調，非 drain 本身（既有 `prd-ready` 一律 drain 到 in-review）。owner 未放 PRD 的頁＝not-started、跳過不臆造。
- **bundle/佔位列不可直接 pick**：佇列表的多頁列（ISU/i0/z0 增量等）＝佔位、非派工單位；PRD 進場須先**拆成一 funcId 一列**才可 `prd-ready`（守「一頁一列、序列一次一頁」）。同 risk tier 內 tie-break＝**表序由上而下**。

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
0. 起手對帳 docs/specs/prd/ 實檔 ⟷ 佇列 prd 欄：實檔有但表列 not-started→回報「PRD 已放、待標 prd-ready」；bundle/佔位列（多 funcId）不可直接 pick，須先拆成一 funcId 一列。
1. **drain 迴圈**：只要佇列還有 status=prd-ready 列（可多頁），就取 risk-tier 最前、同 risk 依表序的【一頁】處理（序列、一次只一頁、不並行、不一次吞整批）；status=not-started/prd 欄空＝PRD 未放→不 pick。
2. spawn 獨立 sub-agent 跑 prd-to-srs（用 build-tasks/prd-to-srs-codex-dispatch.md 的 prompt，填該 funcId/PRD 路徑）→ 產 bundle 到 docs/specs/srs/<funcId>/。
3. 機械 gate：python scripts/check-srs-bundle.py docs/specs/srs/<funcId> 必 exit 0（含 gateⓇ reconcile）。
4. SRS N 軸驗證：依 playbook §4b 各 spawn 一 read-only sub-agent 跑 A–G 軸（各獨立 session、不同指示、最好跨模型；非單一 spec-reviewer；低風險頁可 A+E+G、risk-tier T1 全 A–G）→ 採納修正後再審一輪。
5. 該頁達標（機械 exit 0 + N 軸無 Blocker）→ 回填該頁 status=in-review、填 srs 路徑（＝ledger，防重複/防漏）→ **回到步驟 1 取下一個 prd-ready 頁**（不在每頁停）。未達標（gate FAIL / N 軸殘 Blocker 需 C 類）→ 該頁標 FAIL/blocked+原因、留 prd-ready、**續跑下一頁**（單頁失敗不擋整批）。**不得自宣 approved（TBD 全關+人裁才 approved）、不得跳 gate/軸、不得碰 C 類（裁 TBD/風險/架構/domain）。**
6. context 衛生：每 sub-task 獨立 session，主控只收 PASS/FAIL/findings 路徑。
**佇列 prd-ready 全清（皆 in-review 或 FAIL/blocked）才停**＝batch checkpoint。彙總回報：每頁一行（in-review / FAIL+原因 / blocked=待裁）+ bundle/findings 路徑，整批一起交人審/裁 TBD。
```

## 7. config 落地（部署本機 `.codex/`）
- `.codex/agents/verifier-{contract,scope,regression}.toml`（範本 `docs/env/codex/verifier-*.toml`；`sandbox_mode="read-only"`、三軸不同 `developer_instructions`、建議跨模型）。
- **SRS 軌 N 軸（§4b）**：Codex orchestrator 依 §4b briefs 各 spawn 一 read-only sub-agent（跨模型）跑 A–G 軸；**不需 per-axis toml**（briefs 權威＝§4b，同薄殼指標）；axis A＝既有 `spec-reviewer.toml`。
- `.codex/hooks.json`（範本 `docs/env/codex/hooks.json`）：Stop 掛 `verify-c0`+`check-srs-bundle`＝**唯一硬強制層**（「3 agent」hook 驗不了，靠本檔規範＋完工報告列名/結論）。
- `.codex/config.toml`：`-a on-request -s workspace-write`（多 task 別 `never`；範本 `docs/env/codex/config-permissions.md`）。
- `AGENTS.md §Spec workflow`：orchestration 鐵則指標（薄殼，內容權威＝本檔）。

## 8. 天花板（誠實標）
orchestration 省的是「派工打字＋貼 prompt」，**省不掉審查＋裁定**。天花板＝「自動到等審」，非「自動到上線」。pilot 建議：先用 `epl-* method 慣例 recon` + `0922-t24-exchrate-colname-fix`（兩個 A 類、互不相依）跑一輪,確認「停在等審、不自宣 done、不碰 C 類、三軸真獨立」四條守得住,再放大到批量 PRD→SRS（SRS 軌 pilot＝`build-tasks/prd-to-srs-orchestrator-pilot.md`，跑通一頁再批量）。
> **SRS 軌 drain 模式已啟用（2026-06-20）**：pilot 已過（`EPROZ00100`/`EPROC00118` 重產 → Approved）→ SRS 軌改 **drain 迴圈**（§5b/§6b）：允許多頁同時 `prd-ready`、**序列一次一頁**逐頁過 gate＋N 軸，**checkpoint 從「每頁停」改為「整批 prd-ready 清空後停一次」**（batch checkpoint）。守則不變：序列非並行、每頁全 gate＋N 軸、終點 `in-review`（不自升 approved）、C 類不碰、單頁 FAIL 標因續跑。

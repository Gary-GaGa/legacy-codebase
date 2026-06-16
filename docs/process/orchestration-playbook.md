# Orchestration Playbook — Codex 多任務編排（自動到 checkpoint、停下交人）

> **定位**：把「派工＋執行＋機械閘門」自動化（orchestrator + sub-agent），**停在「等人審／等 owner 裁」**。審查與裁定仍是人——這是 workflow 價值核心（Phase V 證明：build 全綠也漏 RV-1/RV-2）。
> **權威**：本檔＝三類分法／依賴 DAG／完成定義／三軸驗證的**單一出處**；`docs/env/codex/verifier-*.toml` 為薄殼指向本檔。
> **何時用**：可並行的多個 build-task（recon／已盤點的 sweep 修／明確 typo／批量 PRD→SRS Phase 1）。單一小任務不必編排。

## 1. 任務三類（orchestrator 只碰 A，整理 B，不碰 C）
| 類 | 例 | orchestrator 能到 |
|---|---|---|
| **A 可自動執行→等審** | 唯讀 recon、已盤點的 sweep 修、明確 typo（OQ-5）、批量 PRD→SRS Phase 1 | spawn sub-agent 執行＋機械 gate＋三軸驗→**停「等人審」** |
| **B 半自動→等裁** | SRS 產初稿後的 `@PENDING` | 標出＋彙總成表→**停「等 owner 裁」** |
| **C 停止點（人/owner）** | 風險取捨（RP1）、架構（RP9）、domain（A-1）、AUD/BP | **只整理證據「備到蓋章即可」**，不裁 |

## 2. 依賴 DAG（餵 orchestrator，禁盲目並行）
- 輸入＝`STATUS.md §六`（進行中/待派）+ `pending-register.md`（依賴/owner）。
- 硬依賴例：`get-body #3` ← `RP9` ← `epl-* method 慣例 recon`；`A-1 施工` ← `T24 OQ-1`；c0/csu Phase V ← ops 套授權列。
- **依賴未滿足的任務不准動**（卡頭標「待 X」者跳過）。

## 3. 完成定義（防 progress bias——最重要）
> AI 急著標完成是已坐實傾向（00800 批判教訓 15；`spec-architecture §9`）。故：
- task「done」**只認**：機械 gate 綠（`verify-c0` / `check-srs-bundle` / `mvn` / `ng build` exit 0）**＋** 三軸驗證 PASS **＋** 狀態標「等人審」。
- **orchestrator 不得自宣 done / 不得跳過 gate / 不得把假綠當完成**。終點是「等審」，不是「上線」。

## 4. 三軸正交驗證（≥3 sub-agent，但**必須真獨立**）
> 「3 個 PASS」≠ 3 倍信心——同模型/同 context/同指示會 correlated blindness（3 個一起漏同一個，Phase V 即此）。故定**三個正交視角**（最好跨模型，至少不同指示），各 read-only：
| 軸 | agent | 只看 |
|---|---|---|
| **contract** | `verifier-contract` | FE↔BE DTO/method/契約對齊、openapi/schema 一致 |
| **scope** | `verifier-scope` | commit 範圍、有無誤動 OUT/越界、是否只改該改的 |
| **regression** | `verifier-regression` | 對舊系統/i0 鏡像有無偏離、既有路徑回歸、有無 reflection/委派 |
- 三軸全 PASS 才算「三軸驗證 PASS」；同質 3 個＝theater，不算。
- 仍 ≠ 人審：三軸是**強化自驗**，orchestration 仍停在等人審。

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

## 7. config 落地（部署本機 `.codex/`）
- `.codex/agents/verifier-{contract,scope,regression}.toml`（範本 `docs/env/codex/verifier-*.toml`；`sandbox_mode="read-only"`、三軸不同 `developer_instructions`、建議跨模型）。
- `.codex/hooks.json`（範本 `docs/env/codex/hooks.json`）：Stop 掛 `verify-c0`+`check-srs-bundle`＝**唯一硬強制層**（「3 agent」hook 驗不了，靠本檔規範＋完工報告列名/結論）。
- `.codex/config.toml`：`-a on-request -s workspace-write`（多 task 別 `never`；範本 `docs/env/codex/config-permissions.md`）。
- `AGENTS.md §Spec workflow`：orchestration 鐵則指標（薄殼，內容權威＝本檔）。

## 8. 天花板（誠實標）
orchestration 省的是「派工打字＋貼 prompt」，**省不掉審查＋裁定**。天花板＝「自動到等審」，非「自動到上線」。pilot 建議：先用 `epl-* method 慣例 recon` + `0922-t24-exchrate-colname-fix`（兩個 A 類、互不相依）跑一輪,確認「停在等審、不自宣 done、不碰 C 類、三軸真獨立」四條守得住,再放大到批量 PRD→SRS。

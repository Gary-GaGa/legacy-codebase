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
- **規模調配（2026-06-22 起：SRS pilot/drain 一律全 A–G）**：**每頁全 A–G、每軸一隻 read-only sub-agent（可叢集 ≥3 隻）、跨模型**——drain 對齊 pilot 品質,**不因批量降軸**。〔早前「低風險頁可 A+E+G」**已棄用**;若 owner 對個別 trivial 頁明示放行才例外,且 F/D 綁欄位內容**仍不可省**。〕F 軸＝現流程最空白、風險最高(pilot 跨模型 F 軸抓到 `nfix-card` C-B1~B3 精度/截斷/缺 `TB_API_AUTH`,機械閘門看不到);D 軸＝授權/四眼(0922 N 軸抓到 Maker-Checker 缺四眼控制)。批量靠 **context 隔離+壓縮+分批**承載全軸(見 `prd-to-srs-orchestrator-drain.md §1b`)。
- **度量驅動軸配置（斷言→量測）**：本表的軸 profile／再審輪數目前是**斷言的**。每軸每頁的 {提出 Blocker／確認為真／誤報} 一律回填 `docs/process/n-axis-findings-ledger.md`；累積 ≥10 頁（T1 ≥5）後用實測 catch-rate 回調本節（砍低 ROI 軸、加碼高 ROI 軸如 F/D、定再審輪數）。**改軸 profile＝改本表 + `decisions.md` 指回 ledger**，不憑單一事件拍板。
- **仍 ≠ 人審**：N 軸是強化自驗，orchestration 仍停在等人審／等裁 TBD。
- **落地**：Claude 主 session 用 Agent 工具各 spawn 一軸；Codex 同（部署見 §7；**briefs 權威＝本表**）。axis A＝既有 `spec-reviewer`。

## 4c. RD flow 驗證軸（code 階段；§4 三軸 + 強制點落實；advisory）
> RD flow（⑤ SRS→code）的驗證＝**§4 code 三軸 + 一條 RD 專屬軸**，各 read-only、跨模型。**code 階段＝advisory**（同 ai-flow ⑦；blocking 的是 DoD 機械閘門 ①②③⑥，非本軸）。
| 軸 | agent | 只看 |
|---|---|---|
| **contract** | `verifier-contract` | FE↔BE DTO/method、openapi/schema 一致（§4） |
| **scope** | `verifier-scope` | commit 範圍、誤動 OUT/越界、只改該改（§4） |
| **regression** | `verifier-regression` | 對舊系統/i0 鏡像偏離、既有路徑回歸、reflection/委派（§4） |
| **強制點落實**（RD 新） | `verifier-enforcement` | 每 Rn 的強制點 FE/BE/both 真落地：完整性/安全的 BE 強制有且為權威；mutating 端點非 FE-only；標「後端為準」的欄 client 不可送（接 §4b 軸 D 在 code 端的對應驗） |
- 全軸 PASS 才算 RD 三軸+1 PASS；同質多隻＝theater。仍 ≠ 人審（T1 頁仍 per-page 人審）。

## 4d. QA flow 驗證軸（test 階段；新正交軸）
> QA flow（④ code→test）跑完三層測試後的「測試本身夠不夠好」驗證，各 read-only、跨模型。**brief 權威＝本表**；對應 DoD ④QA驗收＋⑤覆蓋率（機械）之上的語意層。
| 軸 | 只看 | 對應陷阱 |
|---|---|---|
| **Q1 覆蓋完整性** | 每 non-@PENDING Rn ≥1 test；多分支 happy/error/edge 齊（補 gate⑤「≥1」假綠） | 測試掛名、只測 happy |
| **Q2 oracle 真確** | 斷言對 Rn 精神（非鏡像實作）；紅燈正確分「impl-gap（回 RD）」vs「oracle/spec 錯（回 SRS，不自改 spec）」 | 把實作當預期、測了個寂寞 |
| **Q3 三層齊備** | DB+BE+FE 各測到該測：強制點 BE → BE+繞FE negative；FE 行為 → Playwright；DB 副作用 → DB 斷言 | 只測一層、強制點漏繞 FE |
| **Q4 環境隔離** | Testcontainers 自 seed（含授權列）、可 teardown、不污染共享 DB；不依賴 ops 套授權 | 測試彼此污染、依賴外部狀態 |
| **Q5 報告忠實** | 測試報告清單逐案 PASS/FAIL/SKIP + 證據齊；Rollup 數據與實跑一致；SKIP/deferred 標明不灌水 | 假綠、漏報 FAIL、覆蓋率灌水 |
- 真獨立、跨模型、各軸獨立 session；採納修正後再審一輪。仍 ≠ 人審（T1 頁 owner 審報告才升 done）。
- **度量**：每軸每頁 {提出問題／確認為真／誤報} 同樣回填 `docs/process/n-axis-findings-ledger.md`（與 SRS N 軸共用度量機制，分 stage 標記）。

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
      → 未達標（gate FAIL / N 軸殘 Blocker 需 C 類裁定）→ 該頁 **status=blocked**＋原因（**離開 prd-ready 集合→下輪不會再被取**；不誤升 in-review）
                                                          → 繼續下一頁（單頁失敗不擋整批 drain；批末一併回報）
 → 佇列已無 status=prd-ready（皆 in-review 或 blocked）→ 停【batch checkpoint】，彙總「整批」等人審/裁 TBD
   〔終止保證：每輪取一頁，結局必為 in-review 或 blocked，兩者都離開 prd-ready 集合 → |prd-ready| 每輪嚴格遞減 → 最多 N 輪必停〕
人審/裁 TBD → in-review 升 approved（人裁，orchestrator 不自升）→ 下一批（owner 再放 PRD 標 prd-ready）
```
- **drain 到底，但仍序列一次一頁**：允許多頁同時 `prd-ready`；orchestrator **逐頁序列**處理（每頁各自過 gate＋N 軸＋ledger 回填），**一頁達標即接下一頁、不在每頁停**——checkpoint 從「每頁停」改為「**整批 prd-ready 清空後停一次**」(batch checkpoint)。序列(非並行)＝保 context 衛生＋避免 correlated 錯。
- **終點仍是 in-review、非 approved**：drain 只把 `prd-ready`→`in-review`（產出+gate+N 軸無 Blocker，含 open @PENDING/TBD）；**升 approved 仍須人裁 TBD**（C 類不碰）。安全網不變、只是把人審聚到批末一次做。
- **⚠️ T1/金錢/授權頁＝per-page checkpoint（非批末）**（2026-06-22，採納「pilot 單跑 > drain」實證）：對 risk-tier T1（金錢/計分/checkpoint/授權，含撥貸 `0920/0921/0922`+T24、c0 評分線）——drain **每頁產完即停交人審**（＝單跑紀律：全 A–G 跨模型 + 人審 + 採納修正再審一輪），**不併入批末 batch checkpoint**；只有低風險頁（z0 KEEP 等）走批末 checkpoint。理由：pilot 每頁人審/跨模型 N 軸抓到機械閘門看不到的金錢/授權 Blocker（correlated-blindness 實證，`build-tasks/done/EPROZ00100-regenerate-pilot.md:43`、`build-tasks/done/EPROZ00100-EPROC00118-nfix-card.md` C-B1~B3 F 軸）；drain 把人審延到批末＝整批可能帶未檢出 Blocker。**T1 批量硬上限 ≤3 頁/批**（嚴於首批 ≤5、且跨所有批非僅首批）；**最高風險頁（撥貸金錢、c0 評分）保留單跑**、不入長 drain 佇列。
- **單頁 FAIL 不擋整批、但必須離開 prd-ready**：某頁 gate FAIL 或 N 軸殘 Blocker（需 C 類）→ `status=blocked`+原因（**不可留 prd-ready，否則同一頁會被重取＝無窮迴圈**）、續跑下一頁；批末彙總哪些頁 blocked、卡什麼。`blocked` 頁待 owner 母資料夾修（gate/N 軸可修者）或裁 C 類後，**重標 prd-ready** 才進下一批。
- **🛑 circuit-breaker（防系統性錯擴散）**：若偵測到**系統性/重複**失敗——同一 N 軸在連續多頁出同類 Blocker、或多頁共同 local 輸入缺陷（如 `docs/db-diff/` 版本舊、reconcile 範本缺，00100/00118 曾見「schema.sql 整段待 RD」）——**暫停整批 drain、回報、不續跑**，等修根因再重啟（別讓同一個錯複製到整批）。
- **首批放量上限（漸進）**：首次批量**建議 ≤5 頁、同 risk-tier**（低風險先；T1 ≤3）；證實人審/N 軸跟得上再擴大批量。**禁止為衝吞吐而降 N 軸**（**每頁一律全 A–G、多 sub-agent、跨模型，§4b；drain 對齊 pilot、不降軸**）。
- **Context Window（上下限）**：批量 × 全 A–G 多 sub-agent 靠**隔離+壓縮+分批**控在 context 內——主控只存 ledger+當頁 PASS/Blocker 路徑（不吞 bundle/transcript 全文）、**每頁完即丟細節**（跨頁不累積）；sub-agent 各自獨立 session **自讀原檔**（不吃摘要＝防空審）；單批頁數設上限、接近 context 上限即停輸出 ledger、靠 resume 冪等下批接續。細節＝`prd-to-srs-orchestrator-drain.md §1b/§2c`。
- **不中途改排序**：drain 啟動後**勿改 ledger 的 risk/表序**（會使「取最前 prd-ready」跳號/重做）；要調序先停整批再重啟。
- **resume 冪等**：中斷重跑＝再讀 ledger，`in-review`/`blocked` 頁不再 prd-ready→自動跳過；只有未完成（仍 prd-ready）頁會重做。回填順序＝**先確認 bundle 產出+gate+N 軸過，再一次寫 status+srs**；回填失敗則該頁留 prd-ready、下輪自然重做（不留中間態）。
- **owner 控放量、orchestrator 控 drain**：佇列無期限、risk-tier 前段先；**owner 放多少 PRD（升多少 prd-ready）就 drain 多少**——「不急著轉完」指 owner 放 PRD 的步調，非 drain 本身（既有 `prd-ready` 一律 drain 到 in-review/blocked）。owner 未放 PRD 的頁＝not-started、跳過不臆造。
- **bundle/佔位列不可直接 pick**：佇列表的多頁列（ISU/i0/z0 增量等）＝佔位、非派工單位；PRD 進場須先**拆成一 funcId 一列**才可 `prd-ready`（守「一頁一列、序列一次一頁」）。同 risk tier 內 tie-break＝**表序由上而下**。

## 5c. RD 軌迴圈（⑤ SRS→code；輸入＝ledger `rd-ready` 佇列）
> SRS 軌（§5b）把頁推到 `approved`；**RD 軌接 `approved→rd-ready` 的頁**（owner 放行進開發），逐頁產 code。權威迴圈，運行殼＝`build-tasks/rd-orchestrator-drain.md`。
```
讀 per-page-reinventory-matrix ledger（同一張，狀態欄擴 rd-ready/rd-done/…）
 → 入口閘：只取 status=rd-ready（其前置＝該頁 SRS status=approved、N軸無Blocker、@PENDING全裁）；非 approved 衍生的 rd-ready 一律拒（回報）
 → while 佇列仍有 rd-ready（序列、一次一頁、不並行）：
     取 risk-tier 最前一頁
      → spawn sub-agent 跑 rd-codex-dispatch（填 funcId）→ 產 code 到產品 repo（brownfield=對位驗碼 / greenfield=盤點+計畫）
      → 機械閘門：DoD ①契約 ②schema ③verify-c0 ⑥build（mvn/ng build exit 0、verify-c0.py exit 0）
      → RD 軸（§4c：contract/scope/regression/強制點落實，跨模型、advisory）→ 採納修正後再審一輪
      → 達標 → ledger status=rd-done、填 code 路徑（commit/PR）→ 回填觸發 QA 軌入口（該頁可轉 qa-ready）
      → 未達標（build 紅 / verify-c0 違規 / 軸有 Blocker 需 C 類）→ status=blocked+原因（離開 rd-ready）→ 續下一頁
 → 佇列無 rd-ready → batch checkpoint
```
- 守則全 mirror §5b（序列非並行、context 衛生、circuit-breaker、單頁 FAIL 標 blocked、首批漸進）。**終點＝`rd-done`、不得自宣 Done**（QA 還沒跑）。
- **T1（金錢/評分/授權）頁＝per-page checkpoint**：code 產完即停交人審（diff 審 + 三軸跨模型 + 採納修正再審），不併批末。

## 5d. QA 軌迴圈（④ code→test；輸入＝ledger `qa-ready` 佇列）
> RD 軌把頁推到 `rd-done`；**QA 軌接 `rd-done→qa-ready` 的頁**，產三層測試、跑、出報告。權威迴圈，運行殼＝`build-tasks/qa-orchestrator-drain.md`。
```
讀 ledger（qa-ready 佇列）
 → 入口閘：只取 status=qa-ready（前置＝該頁 rd-done、build 綠）；build 紅不收
 → while 佇列仍有 qa-ready（序列一次一頁）：
     取一頁
      → spawn sub-agent 跑 qa-codex-dispatch（填 funcId）→ 依 qa-cases.md 產三層測試：
          DB（Testcontainers 自 seed→DB 斷言）／BE（epl-* + response/DB 斷言）／FE（Playwright e2e）
      → 跑測試 → 機械閘門：DoD ④QA驗收（三層測試綠）＋⑤覆蓋率（check-srs-bundle gate⑤）
      → QA 軸（§4d Q1–Q5，跨模型）→ 採納修正後再審一輪
      → 產【測試報告清單】（格式＝docs/specs/qa-report-format.md）
      → 達標 → ledger status=qa-passed、填 report 路徑
      → 未達標：紅燈分類——impl-gap→回 RD（該頁 status=rd-ready 重排）／oracle-spec 錯→回 SRS（標，不自改）／測試環境問題→blocked
 → 佇列無 qa-ready → batch checkpoint；交 owner 審報告
```
- **終點＝`qa-passed`、非 done**；**最終 `done` 由 owner 蓋章**（T1 頁逐頁審報告）。其餘守則 mirror §5b。

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
> **首次跑先單頁**（規模化前驗四守則）：見 `build-tasks/prd-to-srs-orchestrator-drain.md` 首批放量段（單頁模式＝drain prompt 去掉迴圈、只取一頁）。pilot 歷史卡＝`build-tasks/done/prd-to-srs-orchestrator-pilot.md`（已歸檔）。
> **運行殼 ↔ 本節權威同步**：drain 殼的迴圈不變式由 `python scripts/check-prompt-parity.py` 驗（anchor 漏在一邊＝FAIL；改本節記得同步 drain 殼）。
```
你是 SRS orchestrator。任務板＝docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md 的「PRD→SRS 佇列 + ledger」表。
0. 起手對帳 docs/specs/prd/ 實檔 ⟷ 佇列 prd 欄：實檔有但表列 not-started→回報「PRD 已放、待標 prd-ready」；bundle/佔位列（多 funcId）不可直接 pick，須先拆成一 funcId 一列。
1. **drain 迴圈**：只要佇列還有 status=prd-ready 列（可多頁），就取 risk-tier 最前、同 risk 依表序的【一頁】處理（序列、一次只一頁、不並行、不一次吞整批）；status=not-started/prd 欄空＝PRD 未放→不 pick。
2. spawn 獨立 sub-agent 跑 prd-to-srs（用 build-tasks/prd-to-srs-codex-dispatch.md 的 prompt，填該 funcId/PRD 路徑）→ 產 bundle 到 docs/specs/srs/<funcId>/。
3. 機械 gate：python scripts/check-srs-bundle.py docs/specs/srs/<funcId> 必 exit 0（含 gateⓇ reconcile）。
4. SRS N 軸驗證：依 playbook §4b 各 spawn 一 read-only sub-agent 跑 A–G 軸（各獨立 session、不同指示、最好跨模型；非單一 spec-reviewer；低風險頁可 A+E+G、risk-tier T1 全 A–G）→ 採納修正後再審一輪。
5. 該頁達標（機械 exit 0 + N 軸無 Blocker）→ 回填該頁 status=in-review、填 srs 路徑（＝ledger，防重複/防漏）→ **回到步驟 1 取下一個 prd-ready 頁**（不在每頁停）。未達標（gate FAIL / N 軸殘 Blocker 需 C 類）→ 該頁 **status=blocked**+原因（**離開 prd-ready→不重取**）、**續跑下一頁**（單頁失敗不擋整批）。**不得自宣 approved（TBD 全關+人裁才 approved）、不得跳 gate/軸、不得碰 C 類（裁 TBD/風險/架構/domain）。**
6. context 衛生：每 sub-task 獨立 session，主控只收 PASS/FAIL/findings 路徑。
7. 🛑 circuit-breaker：偵測系統性/重複失敗（同軸連續多頁同類 Blocker、或共同 local 輸入缺陷）→ **暫停整批、回報、不續跑**，等修根因。首批 ≤5 頁同 risk-tier；不中途改 ledger 排序；不為吞吐降 N 軸。
**佇列已無 prd-ready（皆 in-review 或 blocked）才停**＝batch checkpoint。彙總回報：每頁一行（in-review / blocked=gate-fail 或 待裁 C 類）+ bundle/findings 路徑，整批一起交人審/裁 TBD。
```

## 6c. RD orchestrator prompt（PRD→code 規模化）
> 迴圈權威＝§5c；**可貼運行殼＝`build-tasks/rd-orchestrator-drain.md`**（單頁 worker＝`rd-codex-dispatch.md`）。殼 ↔ §5c 迴圈不變式由 `python scripts/check-prompt-parity.py` 驗（改 §5c 記得同步殼）。首次跑先單頁(殼只取一頁)驗四守則再批量。

## 6d. QA orchestrator prompt（code→test 規模化）
> 迴圈權威＝§5d；**可貼運行殼＝`build-tasks/qa-orchestrator-drain.md`**（單頁 worker＝`qa-codex-dispatch.md`；三層測試對映＝`docs/specs/qa-to-test.md`、FE＝`docs/specs/fe-test-convention.md`、報告＝`docs/specs/qa-report-format.md`）。殼 ↔ §5d 由 `check-prompt-parity.py` 驗。00118（spec+impl 已完成）＝QA flow 首跑 pilot 頁。

## 7. config 落地（部署本機 `.codex/`）
- `.codex/agents/verifier-{contract,scope,regression}.toml`（範本 `docs/env/codex/verifier-*.toml`；`sandbox_mode="read-only"`、三軸不同 `developer_instructions`、建議跨模型）。
- **SRS 軌 N 軸（§4b）**：Codex orchestrator 依 §4b briefs 各 spawn 一 read-only sub-agent（跨模型）跑 A–G 軸；**不需 per-axis toml**（briefs 權威＝§4b，同薄殼指標）；axis A＝既有 `spec-reviewer.toml`。
- `.codex/hooks.json`（範本 `docs/env/codex/hooks.json`）：Stop 掛 `verify-c0`+`check-srs-bundle`＝**唯一硬強制層**（「3 agent」hook 驗不了，靠本檔規範＋完工報告列名/結論）。
- `.codex/config.toml`：`-a on-request -s workspace-write`（多 task 別 `never`；範本 `docs/env/codex/config-permissions.md`）。
- `AGENTS.md §Spec workflow`：orchestration 鐵則指標（薄殼，內容權威＝本檔）。

## 8. 天花板（誠實標）
orchestration 省的是「派工打字＋貼 prompt」，**省不掉審查＋裁定**。天花板＝「自動到等審」，非「自動到上線」。pilot 建議：先用 `epl-* method 慣例 recon` + `0922-t24-exchrate-colname-fix`（兩個 A 類、互不相依）跑一輪,確認「停在等審、不自宣 done、不碰 C 類、三軸真獨立」四條守得住,再放大到批量 PRD→SRS（首次跑先單頁＝drain 殼只取一頁，跑通再批量；§6b）。
> **SRS 軌 drain 模式已啟用（2026-06-20）**：pilot 已過（`EPROZ00100`/`EPROC00118` 重產 → Approved）→ SRS 軌改 **drain 迴圈**（§5b/§6b）：允許多頁同時 `prd-ready`、**序列一次一頁**逐頁過 gate＋N 軸，**checkpoint 從「每頁停」改為「整批 prd-ready 清空後停一次」**（batch checkpoint）。守則不變：序列非並行、每頁全 gate＋N 軸、終點 `in-review`（不自升 approved）、C 類不碰、單頁 FAIL 標因續跑。

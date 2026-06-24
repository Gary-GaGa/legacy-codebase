# SRS finalize 派工卡 — EPROC00115 / 00119 / 00120 推到規格定版 Approved

> **用途**:企金線 c0 的 9 包裡,5 包(00110/112/114/116/117)已規格定版 Approved、00118 已實作完成;**剩這 3 包卡在 open @PENDING**。本卡把它們推到「可 owner 蓋規格定版 Approved」,作為「9 包一起開發(RD)」的前置。
> **權威**:迴圈＝`docs/process/orchestration-playbook.md §5b`;N 軸＝`§4b`(A–F;G 隨 QA 2026-06-24 暫拔除);待決機制＝`docs/spec-architecture.md §5b`。
> **在哪跑**:母資料夾 Codex(可讀產品碼 + local db-diff/refactor-spec)。**先 `git pull`**(main 已到含 5 包 Approved + SSOT 同步;避免分叉)。
> **接續**:3 包 Approved 後 → 跑 RD 派工(`rd-codex-dispatch.md` / `rd-orchestrator-drain.md`)9 包一起開發。

## 為何這 3 包還不能 Approve(grounded)
- **EPROC00115**:rule-level open @PENDING 12;N 軸自述「Still not Approvable:孤兒錯誤碼 E130/E201/E999/E498 + RP20 save authz open」。
- **EPROC00119**:`spec.md` 自己寫「must not be Approved until RP40 and parity/security items close」;pending-register 列 RP40–RP54(15)open。**RP40 = 缺 corporate refactor baseline(缺料、非拍板能解)**。
- **EPROC00120**:open @PENDING 10;blocked on P-009/P-011/P-012/P-013;且只跑過單輪 axis-A,T1 需全 A–F + 跨模型。

## owner 必裁項(關了才到 Approved;agent 不自決)
- **00115**:① 孤兒碼 E130/E201/E999/E498 保留為平台碼/移除? ② RP20 save 授權政策。
- **00119**:① **RP40 corporate baseline 從哪來**(提供 / 裁定走 i0-mirror + parity disclaim)? ② RP41–54 逐項裁;③ parity/security。
- **00120**:P-009/P-011/P-012/P-013 四項待決。

---

## ⬇️ 複製給 dev 機 Codex(Prompt 1 — finalize 3 包)

```
你是 SRS finalize orchestrator(序列一次一頁,目標:把 3 包推到可 owner 蓋「規格定版 Approved」)。
權威:orchestration-playbook §5b/§4b(N軸 A–F,G 隨 QA 暫拔除)。在母資料夾跑;先 git pull。
本批:EPROC00115、EPROC00119、EPROC00120(其餘 6 包已 Approved/已實作,不在此批,勿動)。

逐頁:
1. 列該頁所有 open @PENDING:
   - 00115:12 條(含孤兒碼 E130/E201/E999/E498、RP20 save authz)
   - 00119:RP40–RP54(RP40=缺 corporate refactor baseline)
   - 00120:P-009/P-011/P-012/P-013(+ 其餘 rule @PENDING)
2. 逐項分類 a/b/c/d/e,分流:
   - a(DB 可查 fact,有 provenance)、d(spec 側 to-be 契約)→ agent 直接關、寫進 spec.md,附來源。
   - b(parity)/c(業務政策)/e(跨模組)/缺 baseline → 判斷題不自裁:停下、出「owner 決策卡」
     (每項:問題+選項+影響+建議),等人裁。**00119 RP40 缺 baseline → 回報「需 owner/SA 提供
     corporate baseline 或裁定走 i0-mirror+parity disclaim」,不得臆造 baseline。**
3. 每關一項回 spec.md:去該 Rn 的 @PENDING 標籤或改 ✅ 定版;pending-register 對應列移已關。
4. 機械 gate:python scripts/check-srs-bundle.py docs/specs/srs/<funcId> exit 0(gateⓅ 同步、去 @PENDING
   後恢復檢查;新包另含 structure warn 對照 spec-template.md,既有包 grandfathered)。
5. A–F 跨模型複審(各 read-only、獨立 session、不同指示)→ 採納修正後再審一輪。
6. @PENDING 全關 + A–F 無 Blocker → 停,交 owner 蓋「規格定版: Approved」(orchestrator 不自蓋)。
   仍有待 owner 裁的 → status=blocked+列決策卡,續下一頁(不擋整批)。

守則:不自宣 Approved;不碰 C 類自決(列卡等 owner);不改既有已 Approved 6 包;context 衛生、
一頁一 commit;🛑 系統性失敗暫停整批。
回報(每頁一張):已自解 @PENDING 清單 vs 待 owner 裁的決策卡(逐項:問題/選項/建議);是否達可定版。
```

## 誠實預期 + 順序
- 跑完這輪,3 包大概率**停在 owner 決策卡**——尤其 **00119 卡 RP40 缺 baseline(可能當下無法 Approve)**。
- owner 拍掉決策(+ 00119 baseline 給/裁)→ agent 重跑該頁 → Approved。
- **3 包 Approved → 9 包全綠 → 跑 RD 派工 9 包一起開發**(`rd-codex-dispatch`/`rd-orchestrator-drain`,T1 每頁停人審)。
- 收尾後本卡移 `done/`。

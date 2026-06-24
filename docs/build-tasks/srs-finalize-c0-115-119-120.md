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

## owner 決策(2026-06-24 已裁 — dev 機照此關 @PENDING、不再停問)

**跨包政策(4 條)**
1. **缺 baseline(00119 RP40 / 00120 P-009)→ code-as-baseline + parity 驗**:用 legacy(0119/0219、0120/0220)+ current code 當 as-is baseline 做 parity 碼驗,不等正式 refactor-spec artifact;parity 風險在 spec 標 disclaim + 留 commit SHA 追溯。
2. **疑似 legacy bug → 預設修正成正確**(REF-Dn delta 標明):RP43 balance 比較〔**修向定版 2026-06-24:End Balance 應等於 Cash & Cash Equivalent,任一期不等→阻擋 Finished(修正 legacy 反向判斷)**〕、RP50 cashflow opening、RP52 borrowerRisk、00115 報表擔保品幣別等,預設 fix;除非該行為被外部依賴(那就保留+標)。對應 legacy-parity-sop 的 regression→修回。
3. **save 授權 → 雙層**:DB `TB_API_AUTH` seed + service 層 case-edit/ownership guard(00115 RP20、00120 P-011),合 `backend/AGENTS.md` 慣例、BE 權威。
4. **其餘 → 全採 agent 建議**(下表);agent 可自解的(a 查 DB fact / d 草 to-be 契約)直接做。

**per-item 裁定(照建議)**
- 00115:LOAN_LIMIT_TYPE 保留 current `!=2`+註假設｜第三幣別只收 USD/KHR｜row 上限先查 legacy groupSize｜blank-flag API 拒查逼補｜RC/0215 checkpoint DBA 查新表確認已併 CS/CU｜RC 舊案不分、統一允許 Finished｜報表幣別修正 COLLATERAL_CUR｜facility label 改 Group/Exposure｜route/menu 查 TB_PAGE_MENU 確認＝EPROC00115｜facilities `@NotNull`+RP20 雙層授權(agent/政策3)。
- 00119:RP40 code-as-baseline(政策1)｜RP43 修正(政策2,QA 對真實財報規則)｜RP44 reference 資格預設 AND(照 legacy)、PM 可改｜RP50/RP52 修正(政策2)｜RP41/42/45/46/47/48/49/51/53/54 agent 查 code/schema 自解。
- 00120:P-009 code-as-baseline(政策1)｜P-011 雙層授權(政策3)｜P-012 parent checkpoint 走獨立 endpoint、本頁 DTO 不膨脹｜P-013 rounding 照 legacy HALF_DOWN｜P-001 count mismatch STRICT 拒絕+不丟未捕例外｜P-002 PERIODS=0 回 N/A｜P-005 Finished 必填＝dataSeq+ratiosDate+PRD 5.3.1 之 6 個人工 required 欄〔**校正 2026-06-24:原措辭「自動公式欄」改採 spec/PRD 人工必填欄;自動公式欄由系統算、非使用者必填**〕｜P-006 RC 舊案照 legacy(無 Finished)｜P-007 i18n 統一 EPROC00120_FUNC_NAME｜P-008 c0/i0 共表＝各自 SRS、i0 後補｜P-003/004/010 agent 自解。

> dev 機:**照上述關 @PENDING**。若遇**未被上述涵蓋**的新待決,才停下出卡問 owner;否則一路執行到 gate+A–F、停在「待 owner 蓋規格定版 Approved」。

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
2. 逐項**照上方「owner 決策(2026-06-24 已裁)」執行**:
   - 該項在裁定表內 → 直接照裁定關(a/d 自查/草擬;b/c/e 照已裁政策)、寫進 spec.md 附來源+REF-Dn delta。
   - **缺 baseline(RP40/P-009)= code-as-baseline + parity 驗**(政策1):用 legacy+current code 當 as-is、做 parity 碼驗、標 disclaim+commit SHA,**不臆造正式 artifact、不停問**。
   - 疑似 bug 預設修正(政策2)、授權雙層(政策3)。
   - **只有遇到裁定表未涵蓋的新待決,才判斷題不自裁:停下出卡問 owner**;其餘不停。
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

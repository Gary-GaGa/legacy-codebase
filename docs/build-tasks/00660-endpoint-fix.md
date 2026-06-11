# Build Task — `EPROZ00660` CAD On Hand：FE endpoint 名修正（F-12/DIFF-014）

> 載具：Codex（前端）。**一行級修復、最高 CP 值**：FE 打 `epl-case-TLOD-onhandstatus-query-list`，BE 只有 `epl-case-CAD-onhandstatus-query-list` → 查詢必 404。證據＝`refactor-audit/M8-z0.md`（00660 列）。

## 步驟
1. FE `cad-onhand-status` 的 api.service：endpoint 改 `epl-case-CAD-onhandstatus-query-list`（**以 BE 為準**——CAD 是正名）。
2. 全 FE 搜 `TLOD-onhandstatus` 確認無殘留引用（TLOD 報表的 `epl-sele-tlod-report` 等**不在此列、勿動**）。
3. `ng build` 綠;一 commit;報 diff 等審。

## 回報
diff＋搜尋紀錄（步驟 2）＋build 結果。

> 過了：「CR 範本」頁真的能查;回填 inventory §2E 00660 → ✅;本卡進 `done/`。Phase V 補一條實測。

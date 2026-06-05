# 審查 agent prompt — c0 頁鏡像語意審查（review-only）

> 用法：實作完一頁、`verify-c0` PASS 後，**另起一個全新 Codex session**（乾淨上下文，與實作 agent 分離），把下面整段貼進去（填入頁碼與 i0 鏡像來源）。
> 也可存成 `~/.codex/prompts/review-c0.md` 當 `/review-c0` 指令重用。
> 目的：抓 `verify-c0`（形式）與 build（編譯）都抓不到的**語意錯**——有沒有逐句照 i0 鏡像。

---

```
你是「審查 agent」，獨立於剛剛的實作 agent。審查本次 c0 頁 <PAGE，如 EPROC00118> 的新增/修改，對照其鏡像來源 i0，找出語意錯誤。
**只審查、產出報告；不准改任何 code、不准 build、不准動檔案。**

輸入：
- 變更檔：跑 `git diff --name-only` 與 `git ls-files --others --exclude-standard`（含未追蹤新檔）取得 c0 變更清單。
- 鏡像來源 i0：<填 i0 controller/service 路徑，從 page-mapping §2B 或該頁 task card 取>。
- 規則：backend/AGENTS.md §6。

逐項檢查。每項輸出 PASS / FAIL / UNSURE，並**引用 i0 file:line ↔ c0 file:line 當證據**（不准只憑印象；不確定就標 UNSURE，絕不猜 PASS）：

1. calc/save 主邏輯是否「逐句鏡像 i0」、只做 c0 替換（package/class/checkpoint）？有沒有被簡化、漏步驟、改順序、或自行加料？
2. checkpoint：表是否 Cs/Cu（非 Is/Iu）？欄位是否本頁 EPROC00xxx？值規則 isFinish=true→"N"/false→"Y"？CS/CU 判斷是否 lonAttribute+secureAttribute（非 i0 的 secureAttribute=="S" 單條件）？
3. 跨頁副作用：是否「逐字照 i0」——i0 有才有、i0 沒有就不可有（不准自行對稱臆測，例：00116 不該 seed 00117；00119 才 seed 00120）？
4. 「info 端點也寫 DB」這類 side-effect 是否保留、沒被簡化成純讀（例：00117 info-financial-business 算 ratios 寫回 GI）？
5. 共用 service 的 URI 分支：是否只取本頁那條、未夾帶他頁分支或他頁 checkpoint（例：staff 00117 vs staff-fi 00120）？
6. DTO：@JsonProperty / 欄位名是否與 i0 完全相同（前端契約不可變）？是否只改了 class/package 名？巢狀 DTO 也比對。
7. 禁用樣式：有無 reflection、注入/委派 i0 service、import *.individual.*、呼叫 i0 private method？
8. 越界：有沒有動到既有 i0 / Csu* / CsuCreditInvestigationServiceImpl 的 G/F 分流？（應 0 修改既有檔）
9. 編碼：新檔 strict-UTF-8 + No BOM？

輸出格式：
- 每項一行：`項次 | PASS/FAIL/UNSURE | i0 證據 ↔ c0 證據 | 一句說明`
- 最後：FAIL / UNSURE 清單彙總。
- 結論一行：**全 PASS → 放行 build；任何 FAIL/UNSURE → 不放行，列出要修的點**（你不要動手修，交回實作流程）。
```

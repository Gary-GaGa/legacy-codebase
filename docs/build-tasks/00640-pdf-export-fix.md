# Build Task — `EPROZ00640` Scorecard Report：BE PDF export 殘碼處置（F-11/DIFF-013）

> 載具：Codex（後端為主）。證據＝`refactor-audit/M8-z0.md`（00640 列）：FE 期待 blob，BE controller 回 `ResponseEntity<String>` 且 **PDF writer/document 輸出整段被註解**;Excel export 正常。

## 步驟
1. **先查依賴再動手**：讀被註解的 PDF 段——它依賴什麼（Jasper？iText？未定的報表服務？）。
   - 依賴**未定的 R2 報表服務** → 不修：殘碼段補註 `@PENDING(R2 報表服務)`＋回報，本卡轉結論「掛 R2」。
   - 依賴**repo 內既有可用 lib**（對照其他可運作的 PDF 輸出，如 TLOD report `epl-ppdf-*` 用什麼）→ 修通：恢復 writer、回 blob（`ResponseEntity<byte[]>`/`Resource`）、與 FE 既有 blob 處理對齊（FE 已對齊 GET，sweep① `48e687f`，FE 不動）。
2. `mvn` build 綠;一 commit;報 diff 等審。Excel 路徑**不准動**。

## 回報
依賴查證結論（修通 or 掛 R2）;diff（若修）;build 結果。

> 過了：回填 inventory §2E 00640;修通→Phase V 實測 PDF;掛 R2→併入 R2 track 清單。

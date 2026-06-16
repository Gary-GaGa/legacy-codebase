# Build Task — `EPROZ00700` deputy entity vs DB 複合 PK 復驗（legacy-reverify 連動）

> 載具：Codex（後端唯讀）。**來源**：`legacy-schema-db-reverify-findings.md`（2026-06-16 審過）坐實 **`TB_EMP_PROXY` DB PK ＝複合 `EMP_ID`+`STR_TIME`**（`legacy_schema_reverify_new02_pk.tsv:139-140`），**推翻**早期「`EMP_ID` 單鍵／一人一筆代理 upsert」假設。
> ⚠️ **deputy（`EPROZ00700`）已完成歸檔**（`done/EPROZ00700-assign-substitute.md`）——但若 entity `@Id`／upsert 照**單鍵假設**寫,DB 複合 PK 下行為可能錯（一人**多筆**代理期間被誤覆蓋／查詢錯）。**已完成頁的潛在 runtime bug**。

## 目標（唯讀坐實，不修碼）
查 deputy 新碼,回答：entity 與 DB 複合 PK 對齊了嗎?
1. **entity `@Id`**：`TB_EMP_PROXY` entity 是單一 `@Id EMP_ID` 還是複合 `@IdClass`/`@EmbeddedId`（EMP_ID+STR_TIME）?附 `file:line`。
2. **save/upsert**：deputy insert/update 邏輯——是「一人一筆覆蓋」（假設單鍵）還是允許「一人多筆代理期間」（對齊複合 PK）?
3. **delete**：刪代理是按 EMP_ID 全刪,還是按 (EMP_ID,STR_TIME) 單筆?
4. 對照 DB 複合 PK 實況,判 deputy 行為對不對。

## 鐵則
唯讀、不修碼、`file:line` 必附;對 DB pk 實證為準。

## 回報
- entity `@Id` 形式 + save/delete 邏輯 file:line;結論一句：**✅ 已對齊複合 PK** ／ **🔴 假設單鍵需修**（附 gap）。
- findings 寫 `docs/build-tasks/00700-deputy-pk-reverify-findings.md`。

> 過了：🔴 → 開 deputy PK 修復卡（entity 改複合 + upsert/delete 對齊）;✅ → 結案、回填 inventory deputy 列「DB 複合 PK 已對齊」。

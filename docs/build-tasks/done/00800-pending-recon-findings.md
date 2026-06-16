# 00800 待決取證 findings（RP6/RP4/RP10——已全數由 DB 實查路徑完成，2026-06-12）

> 原卡 `00800-pending-recon.md` 設計走舊源 grep；實際由 **DB 唯讀實查**完成（更權威）。本檔=證據存檔。

## E1 / RP6 ✅ — ITEM1~14 正式名稱（來源：舊庫 `TB_COMMON_FIELD_OPTIONS`(SYS_CODE=EPRO, MSG_CODE=REVISED_ITEM) JOIN `TB_MULTI_LANG`(en_US)）
| ITEM | LANG_KEY | LANG_NAME（en_US）|
|---|---|---|
| 1 | REVISED_ITEM_01 | **Renew Loan Tenor** |
| 2 | REVISED_ITEM_02 | Guarantor |
| 3 | REVISED_ITEM_03 | Collateral |
| 4 | REVISED_ITEM_04 | Approved Terms and Conditions_Loan Purpose |
| 5 | REVISED_ITEM_05 | Approved Terms and Conditions_Loan Amount |
| 6 | REVISED_ITEM_06 | Approved Terms and Conditions_Facility Type |
| 7 | REVISED_ITEM_07 | Approved Terms and Conditions_Repayment Mode |
| 8 | REVISED_ITEM_08 | Approved Terms and Conditions_Repayment Frequency |
| 9 | REVISED_ITEM_09 | Approved Terms and Conditions_ Grace Period（原文含多餘空格）|
| 10 | REVISED_ITEM_10 | **Approved Terms and Conditions_Tenor** |
| 11 | REVISED_ITEM_11 | Approved Terms and Conditions_Interest Rate |
| 12 | REVISED_ITEM_12 | Approved Fees |
| 13 | REVISED_ITEM_13 | Disbursement Terms and Conditions |
| 14 | REVISED_ITEM_14 | Other Conditions from Approver |

結構：`MSG_OPTION`=01~14（選項值）、`MSG_SER_NO`=1~14（排序）、`LANG_KEY`=i18n key→`TB_MULTI_LANG.LANG_NAME`；僅 en_US 一種 locale（14 列）。

## E2 / RP4 ✅ — ITEM1 vs ITEM10「皆 TENOR」＝誤讀，**設計、非缺陷**
- ITEM1＝**Renew Loan Tenor**（展期動作本身——呼應 R5：`LON_TYPE=03` 展期案強制勾 ITEM1＝定義性必然，**RP2 業務原因就此補文**）。
- ITEM10＝**Approved T&C_Tenor**（核准條件中的期限欄變更）。
- 兩者語意不同 → R13.4/13.5 之 ITEM1 與 ITEM10 分支各自成立；findings S6「ITEM10/11 else ITEM1 疑錯欄」重審基準＝本名稱表＋PRD §5.5.2 矩陣（RD 實作 rimat F9 時逐欄對）。

## E3 / RP10 ✅ — 已於 06-12 checkpoint DDL 枚舉關閉（見 SRS v0.8、`schema-diff-findings.md`）。

> 本卡三題全關 → 原 recon 卡歸檔 `done/`。

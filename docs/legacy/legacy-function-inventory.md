# 舊系統 Function 權威盤點表（owner 提供，2026-06-16）

> **來源**：owner 提供之最新權威盤點（197 資料列；個金 96／企金 69／共用 32）。**＝upstream SSOT**：舊 funcId → 案件類型 → 對應重構新頁 的權威對照，比我們反推的 `page-mapping.md` 更權威。
> **用途**：refactor-audit 補跑的 upstream 來源；重推結果＝`build-tasks/refactor-audit/owner-inventory-reconcile.md`。
> **欄義**：`對應重構系統頁籤`＝新頁（NaN＝fragment/群組/SQL 支援、非工作單位；`已無使用`＝不遷；`舊系統無`＝新建無舊源；`批次`＝B001–B008）。後 4 欄（PRD進度/SA前端/SA後端/功能畫面）owner 留白＝待我們回填驗證進度。

## 查核總表
| 個企金 | 舊系統Function | 案件類型 | 頁籤名稱 | 對應重構系統頁籤 | 主要JSP | 主要後端/批次 | PRD進度 | SA前端 | SA後端 | 功能畫面 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 個金 | EPROI0\_0110 | 新案/增貸 | Credit Investigation (頁框) | EPROI00110 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00110.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0110.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0210 | 展期/展變 | NaN | EPROI00110 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00210.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0210.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0111 | 新案/增貸 | Financial Evaluation Table | EPROI00111 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00111.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0111.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0211 | 展期/展變 | NaN | EPROI00111 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00211.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0211.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0112 | 新案/增貸 | CBC-Banking Relationship | EPROI00112 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00112.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0112.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0212 | 展期/展變 | NaN | EPROI00112 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00212.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0212.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0113 | 新案/增貸 | Individual Scorecard | EPROI00113 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00113.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0113.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0213 | 展期/展變 | NaN | EPROI00113 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00213.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0213.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0114 | 新案/增貸 | Collateral Assessment | EPROI00114 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00114.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0114.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0214 | 展期/展變 | NaN | EPROI00114 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00214.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0214.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0115 | 新案/增貸 | Borrower Group Exposure | EPROI00115 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00115.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0115.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0215 | 展期/展變 | NaN | EPROI00115 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00215.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0215.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0116 | 新案/增貸 | Financial Statement and comments GI | EPROI00116 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00116.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0116.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0216 | 展期/展變 | NaN | EPROI00116 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00216.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0216.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0117 | 新案/增貸 | Financial Evaluation Table GI | EPROI00117 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00117.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0117.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0217 | 展期/展變 | NaN | EPROI00117 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00217.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0217.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0118 | 新案/增貸 | Corporate Scorecard | EPROI00118 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00118.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0118.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0218 | 展期/展變 | NaN | EPROI00118 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00218.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0218.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0119 | 新案/增貸 | Financial Statement and comments FI | EPROI00119 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00119.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0119.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0219 | 展期/展變 | NaN | EPROI00119 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00219.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0219.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0120 | 新案/增貸 | Financial Evaluation Table FI | EPROI00120 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0100/EPROI00120.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0120.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0220 | 展期/展變 | NaN | EPROI00120 | EPROWeb/WebContent/html/cathaybk/system/epro/i0/EPROI0\_0200/EPROI00220.jsp | EPROWeb/JavaSource/com/cathaybk/epro/i0/trx/EPROI0\_0220.java | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0100 | 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0160 | 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROI0\_0200 | 展期/展變 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0110 | 有擔 - 新案/增貸 | Main Borrower Info | EPROISU0110 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0110.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0110.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0210 | 有擔 - 展期/展變 | NaN | EPROISU0110 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0210.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0210.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0110 | 無擔 - 新案/增貸 | NaN | EPROISU0110 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0110.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0110.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0210 | 無擔 - 展期/展變 | NaN | EPROISU0110 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0200/EPROIU0210.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0210.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0120 | 有擔 - 新案/增貸 | Co-Borrower Info | EPROISU0120 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0120.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0120.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0220 | 有擔 - 展期/展變 | NaN | EPROISU0120 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0220.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0220.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0120 | 無擔 - 新案/增貸 | NaN | EPROISU0120 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0120.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0120.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0220 | 無擔 - 展期/展變 | NaN | EPROISU0120 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0200/EPROIU0220.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0220.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0130 | 有擔 - 新案/增貸 | Guarantor Info | EPROISU0130 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0130.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0130.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0230 | 有擔 - 展期/展變 | NaN | EPROISU0130 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0230.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0230.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0130 | 無擔 - 新案/增貸 | NaN | EPROISU0130 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0130.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0130.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0230 | 無擔 - 展期/展變 | NaN | EPROISU0130 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0200/EPROIU0230.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0230.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0140 | 有擔 - 新案/增貸 | Property Info | 已無使用 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0140.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0140.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0240 | 有擔 - 展期/展變 | NaN | 已無使用 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0240.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0240.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0140 | 無擔 - 新案/增貸 | NaN | 已無使用 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0140.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0140.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0240 | 無擔 - 展期/展變 | NaN | 已無使用 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0200/EPROIU0240.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0240.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0190 | 有擔 - 新案/增貸 | Collateral Provider Info | EPROISU0140 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0190.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0190.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0290 | 有擔 - 展期/展變 | Collateral Provider Info | EPROISU0140 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0290.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0290.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0150 | 有擔 - 新案/增貸 | Collateral | EPROISU0150 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0150.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0150.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0250 | 有擔 - 展期/展變 | NaN | EPROISU0150 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0250.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0250.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0160 | 有擔 - 新案/增貸 | Loan Condition | EPROISU0160 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0160.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0160.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0260 | 有擔 - 展期/展變 | NaN | EPROISU0160 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0260.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0260.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0160 | 無擔 - 新案/增貸 | NaN | EPROISU0160 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0160.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0160.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0260 | 無擔 - 展期/展變 | NaN | EPROISU0160 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0200/EPROIU0260.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0260.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0170 | 有擔 - 新案/增貸 | Credit Evaluation and Credit Decision | EPROISU0170 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0170.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0170.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0270 | 有擔 - 展期/展變 | NaN | EPROISU0170 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0270.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0270.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0170 | 無擔 - 新案/增貸 | NaN | EPROISU0170 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0170.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0170.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0270 | 無擔 - 展期/展變 | NaN | EPROISU0170 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0200/EPROIU0270.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0270.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0171 | 有擔 - 新案/增貸 | Loan Committee Conclusion | EPROISU0171 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0171.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0171.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0171 | 無擔 - 新案/增貸 | NaN | EPROISU0171 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0171.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0171.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0172 | 有擔 - 新案/增貸 | Approved Loan Condition | EPROISU0172 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0172.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0172.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0172 | 無擔 - 新案/增貸 | NaN | EPROISU0172 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0172.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0172.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0173 | 有擔 - 新案/增貸 | Credit Evaluation Old | EPROISU0173 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0173.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0173.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0173 | 無擔 - 新案/增貸 | NaN | EPROISU0173 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0173.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0173.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0180 | 有擔 - 新案/增貸 | 報表/SQL 支援 | EPROISU0180 | NaN | com.cathaybk.epro.is.module.EPRO\_IS0180 | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0180 | 無擔 - 新案/增貸 | NaN | NaN | NaN | com.cathaybk.epro.iu.module.EPRO\_IU0180 | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0181 | 有擔 - 新案/增貸 | TLOD Report | EPROISU0181 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0181.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0181.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0181 | 無擔 - 新案/增貸 | NaN | EPROISU0181 | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0181.jsp | EPROWeb/JavaSource/com/cathaybk/epro/iu/trx/EPROIU\_0181.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0182 | 有擔 - 新案/增貸 | 報表/SQL 支援 | EPROISU0182 | NaN | com.cathaybk.epro.is.module.EPRO\_IS0182 | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0183 | 有擔 - 新案/增貸 | 報表/SQL 支援 | EPROISU0183 | NaN | com.cathaybk.epro.is.module.EPRO\_IS0183 | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0184 | 有擔 - 新案/增貸 | 報表模板 | EPROISU0184 | NaN | com.cathaybk.epro.is.module.EPRO\_IS0184 | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0910 | 有擔 - 新案 | Contract Preparation (頁框) | EPROISU0910 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0900/EPROIS0910.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0910.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0911 | 有擔 - 新案 | Condition Confirmation | EPROISU0911 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0900/EPROIS0911.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0911.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0912 | 有擔 - 新案 | Contract Production | EPROISU0912 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0900/EPROIS0912.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0912.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0913 | 有擔 - 新案 | Closed Info | EPROISU0913 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0900/EPROIS0913.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0913.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0920 | 有擔 - 新案 | Disbursement Process(頁框) | EPROISU0920 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0900/EPROIS0920.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0920.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0921 | 有擔 - 新案 | Data Input | EPROISU0921 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0900/EPROIS0921.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0921.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0922 | 有擔 - 新案 | Summary | EPROISU0922 | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0900/EPROIS0922.jsp | EPROWeb/JavaSource/com/cathaybk/epro/is/trx/EPROIS\_0922.java | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0100 | 有擔 - 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0102 | 有擔 - 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0151 | 有擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0151.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0174 | 有擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0174.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0175 | 有擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0175.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0176 | 有擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0100/EPROIS0176.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0200 | 有擔 - 展期/展變 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0251 | 有擔 - 展期/展變 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0251.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0261 | 有擔 - 展期/展變 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0200/EPROIS0261.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0300 | NaN | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0500 | NaN | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0700 | NaN | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0900 | 有擔 - 新案 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0901 | 有擔 - 新案 | SQL/module 支援 | NaN | NaN | com.cathaybk.epro.is.module.EPRO\_IS0901 | NaN | NaN | NaN | NaN |
| 個金 | EPROIS\_0923 | 有擔 - 新案 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/is/EPROIS\_0900/EPROIS0923.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0100 | 無擔 - 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0150 | 無擔 - 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0174 | 無擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0174.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0175 | 無擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0175.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0176 | 無擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0100/EPROIU0176.jsp | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0200 | 無擔 - 展期/展變 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0250 | 無擔 - 展期/展變 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 個金 | EPROIU\_0261 | 無擔 - 展期/展變 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/iu/EPROIU\_0200/EPROIU0261.jsp | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0110 | 新案/增貸 | Credit Investigation (頁框) | EPROC00110 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00110.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0110.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0210 | 展期/展變 | NaN | EPROC00110 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00210.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0210.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0112 | 新案/增貸 | CBC-Banking Relationship | EPROC00112 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00112.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0112.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0212 | 展期/展變 | NaN | EPROC00112 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00212.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0212.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0114 | 新案/增貸 | Collateral Assessment | EPROC00114 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00114.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0114.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0214 | 展期/展變 | NaN | EPROC00114 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00214.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0214.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0115 | 新案/增貸 | Borrower Group Exposure | EPROC00115 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00115.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0115.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0215 | 展期/展變 | NaN | EPROC00115 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00215.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0215.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0116 | 新案/增貸 | Financial Statement and comments GI | EPROC00116 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00116.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0116.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0216 | 展期/展變 | NaN | EPROC00116 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00216.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0216.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0117 | 新案/增貸 | Financial Evaluation Table GI | EPROC00117 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00117.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0117.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0217 | 展期/展變 | NaN | EPROC00117 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00217.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0217.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0118 | 新案/增貸 | Corporate Scorecard | EPROC00118 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00118.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0118.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0218 | 展期/展變 | NaN | EPROC00118 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00218.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0218.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0119 | 新案/增貸 | Financial Statement and comments FI | EPROC00119 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00119.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0119.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0219 | 展期/展變 | NaN | EPROC00119 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00219.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0219.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0120 | 新案/增貸 | Financial Evaluation Table FI | EPROC00120 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0100/EPROC00120.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0120.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0220 | 展期/展變 | NaN | EPROC00120 | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00220.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0220.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0211 | NaN | 流程中無看到對應的頁籤 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00211.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0211.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0213 | NaN | NaN | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0\_0200/EPROC00213.jsp | EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0\_0213.java | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0100 | 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0111 | 新案/增貸 | SQL/module 支援 | NaN | NaN | com.cathaybk.epro.c0.module.EPRO\_C00111 | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0113 | 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | com.cathaybk.epro.c0.module.EPRO\_C00113 | NaN | NaN | NaN | NaN |
| 企金 | EPROC0\_0200 | 展期/展變 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0110 | 有擔 - 新案/增貸 | Main Borrower Info | EPROCSU0110 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0110.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0110.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0210 | 有擔 - 展期/展變 | NaN | EPROCSU0110 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0200/EPROCS0210.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0210.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0110 | 無擔 - 新案/增貸 | NaN | EPROCSU0110 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0110.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0110.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0210 | 無擔 - 展期/展變 | NaN | EPROCSU0110 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0200/EPROCU0210.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0210.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0120 | 有擔 - 新案/增貸 | Co-Borrower Info | EPROCSU0120 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0120.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0120.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0220 | 有擔 - 展期/展變 | NaN | EPROCSU0120 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0200/EPROCS0220.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0220.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0120 | 無擔 - 新案/增貸 | NaN | EPROCSU0120 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0120.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0120.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0220 | 無擔 - 展期/展變 | NaN | EPROCSU0120 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0200/EPROCU0220.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0220.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0130 | 有擔 - 新案/增貸 | Guarantor Info | EPROCSU0130 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0130.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0130.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0230 | 有擔 - 展期/展變 | NaN | EPROCSU0130 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0200/EPROCS0230.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0230.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0130 | 無擔 - 新案/增貸 | NaN | EPROCSU0130 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0130.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0130.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0230 | 無擔 - 展期/展變 | NaN | EPROCSU0130 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0200/EPROCU0230.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0230.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0240 | NaN | Property Info | 已無使用 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0200/EPROCS0240.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0240.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0150 | 有擔 - 新案/增貸 | Collateral | EPROCSU0150 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0150.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0150.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0250 | 有擔 - 展期/展變 | NaN | EPROCSU0150 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0200/EPROCS0250.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0250.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0160 | 有擔 - 新案/增貸 | Loan Condition | EPROCSU0160 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0160.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0160.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0260 | 有擔 - 展期/展變 | NaN | EPROCSU0160 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0200/EPROCS0260.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0260.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0160 | 無擔 - 新案/增貸 | NaN | EPROCU0160 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0160.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0160.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0260 | 無擔 - 展期/展變 | NaN | EPROCU0160 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0200/EPROCU0260.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0260.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0170 | 有擔 - 新案/增貸 | Credit Evaluation and Credit Decision | EPROCSU0170 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0170.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0170.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0270 | 無擔 - 新案/增貸 | NaN | EPROCSU0170 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0200/EPROCS0270.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0270.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0170 | 有擔 - 展期/展變 | NaN | EPROCSU0170 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0170.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0170.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0270 | 無擔 - 展期/展變 | NaN | EPROCSU0170 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0200/EPROCU0270.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0270.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0171 | 有擔 - 新案/增貸 | Loan Committee Conclusion | EPROCSU0171 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0171.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0171.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0171 | 無擔 - 新案/增貸 | NaN | EPROCSU0171 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0171.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0171.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0172 | 有擔 - 新案/增貸 | Approved Loan Condition | EPROCSU0172 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0172.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0172.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0172 | 無擔 - 新案/增貸 | NaN | EPROCSU0172 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0172.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0172.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0173 | 有擔 - 新案/增貸 | Credit Evaluation Old | EPROCSU0173 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0173.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0173.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0173 | 無擔 - 新案/增貸 | NaN | EPROCSU0173 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0173.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0173.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0180 | 有擔 - 新案/增貸 | 報表/SQL 支援 | EPROISU0180 | NaN | com.cathaybk.epro.cs.module.EPRO\_CS0180 | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0180 | 無擔 - 新案/增貸 | 報表/SQL 支援 | NaN | NaN | com.cathaybk.epro.cu.module.EPRO\_CU0180 | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0181 | 有擔 - 新案/增貸 | TLOD(CAD) Report | EPROISU0181 | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0181.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS\_0181.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0181 | 無擔 - 新案/增貸 | NaN | EPROISU0181 | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0181.jsp | EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU\_0181.java | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0100 | 有擔 - 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0174 | 有擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0174.jsp | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0175 | 有擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0100/EPROCS0175.jsp | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0200 | 有擔 - 展期/展變 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCS\_0261 | 有擔 - 展期/展變 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/cs/EPROCS\_0200/EPROCS0261.jsp | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0100 | 無擔 - 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0150 | 無擔 - 新案/增貸 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0174 | 無擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0174.jsp | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0175 | 無擔 - 新案/增貸 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0100/EPROCU0175.jsp | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0200 | 無擔 - 展期/展變 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0250 | 無擔 - 展期/展變 | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
| 企金 | EPROCU\_0261 | 無擔 - 展期/展變 | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/cu/EPROCU\_0200/EPROCU0261.jsp | NaN | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0100 | NaN | TO DO LIST | EPROZ00100 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0100/EPROZ00100.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0100.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0200 | NaN | New Case Application | EPROZ00200 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0200/EPROZ00200.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0200.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0300 | NaN | Document Checklist | EPROZ00300 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0300/EPROZ00300.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0300.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0400 | NaN | Case Distribution | EPROZ00400 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0400/EPROZ00400.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0400.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0410 | NaN | Related Party Information | EPROZ00410 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0400/EPROZ00410.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0410.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0500 | NaN | Comparison table of loans to related party in CUBC | EPROZ00500 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0500/EPROZ00500.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0500.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0600 | NaN | Search | EPROZ00600 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0600/EPROZ00600.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0600.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0610 | NaN | Credit Reviewer On Hand Status | EPROZ00610 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0600/EPROZ00610.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0610.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0620 | NaN | Application Delete Report | EPROZ00620 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0600/EPROZ00620.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0620.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0630 | NaN | Deviation Case Report | EPROZ00630 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0600/EPROZ00630.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0630.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0640 | NaN | Scorecard Report | EPROZ00640 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0600/EPROZ00640.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0640.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0650 | NaN | Application Cancel Report | EPROZ00650 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0600/EPROZ00650.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0650.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0660 | NaN | CAD On Hand Status | EPROZ00660 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0600/EPROZ00660.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0660.java | NaN | NaN | NaN | NaN |
| 共用 | 舊系統無 | NaN | TLOD Report 查詢畫面 | EPROZ00670 | NaN | NaN | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0700 | NaN | Assign Substitute | EPROZ00700 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0700/EPROZ00700.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0700.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0800 | NaN | Revised Item | EPROZ00800 | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0800/EPROZ00800.jsp | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0\_0800.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0101 | NaN | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0100/EPROZ00101.jsp | NaN | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0102 | NaN | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0100/EPROZ00102.jsp | NaN | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_0601 | NaN | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0\_0600/EPROZ00601.jsp | NaN | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_B001 | 批次 | Branch/Dept profile 匯入：讀取 BRANCH\_PROFILE，新增/更新 TB\_BRANCH\_PROFILE | 批次 | NaN | EPROWeb/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0\_B001.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_B002 | 批次 | Employee profile 匯入：讀取 EMP\_PROFILE，重建 TB\_EMP\_PROFILE | 批次 | NaN | EPROWeb/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0\_B002.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_B003 | 批次 | 自動結案/逾期放款處理：依 TB\_LON\_SUMMARY\_INFO 條件寫入 APP\_HISTORY/CLO\_REASON 並更新案件狀態 | 批次 | NaN | EPROWeb/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0\_B003.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_B004 | 批次 | 暫存報表檔案清理：刪除 Jasper/temp 目錄下檔案 | 批次 | NaN | EPROWeb/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0\_B004.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_B005 | 批次 | 匯率資料匯入：呼叫 KH\_B\_FTR37001 服務並寫入 TB\_EXCHANGE\_RATE | 批次 | NaN | EPROWeb/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0\_B005.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_B006 | 批次 | 放款/訊息結果檔處理：讀取 message/result 檔並更新通知、歷程、結案與案件狀態 | 批次 | NaN | EPROWeb/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0\_B006.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_B007 | 批次 | SFTP 檔案傳送：依 SFTP 設定上傳/傳送批次輸出檔 | 批次 | NaN | EPROWeb/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0\_B007.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZ0\_B008 | 批次 | DB/security log 歸檔：搬移 securityPath 下 log 到 securityLog/yyyy 目錄 | 批次 | NaN | EPROWeb/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0\_B008.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZZ\_0100 | NaN | 查詢地址欄位相關選單 | 有共用API | NaN | EPROWeb/JavaSource/com/cathaybk/epro/zz/trx/EPROZZ\_0100.java | NaN | NaN | NaN | NaN |
| 共用 | EPROZZ\_0000 | NaN | 前端頁籤/片段 | NaN | EPROWeb/WebContent/html/cathaybk/system/epro/zz/EPROZZ\_0000/EPROZZ0000.jsp | NaN | NaN | NaN | NaN | NaN |
| 共用 | DEMOA0\_0100 | NaN | NaN | NaN | EPROWeb/WebContent/html/cathaybk/system/demo/a0/DEMOA0\_0100/DEMOA00100.jsp | EPROWeb/JavaSource/com/cathaybk/demo/a0/trx/DEMOA0\_0100.java | NaN | NaN | NaN | NaN |
| 共用 | DEMOA0\_0110 | NaN | NaN | NaN | EPROWeb/WebContent/html/cathaybk/system/demo/a0/DEMOA0\_0100/DEMOA00110.jsp | EPROWeb/JavaSource/com/cathaybk/demo/a0/trx/DEMOA0\_0110.java | NaN | NaN | NaN | NaN |
| 共用 | DEMOA0\_0200 | NaN | 群組/路徑/註解提及 | NaN | NaN | NaN | NaN | NaN | NaN | NaN |
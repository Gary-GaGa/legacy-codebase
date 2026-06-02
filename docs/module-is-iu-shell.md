# 個人申貸主流程 共用 Shell 分析（`is` / `iu`）— D3 結果

> **結論：主流程 shell 是「兩層」，不是單一母版。**
> ① 外層「流程頁籤」由後端 `pageMap` 驅動，切頁 = **server 重查**；② 內層「區塊頁籤」只在 `0110/0210` 頁內、client 切換。
> 主鍵 = **`APPLICATION_NO`**；**IS = 有擔、IU = 無擔**（差 collateral 頁）；**`_0100` = 申請建檔、`_0200` = 覆核審批**。
> → 解法：**一套 shell + 多份 config（非多套 shell）** 解 R6；補進 `golden-template` 的「Workflow Shell + Section Tabs」子樣式解 R3。

## 1. 兩層結構（關鍵發現）
- **外層：流程頁籤（真正的 shell）** — 由後端 `pageMap`（`EPRO_Z0Z006.formatIS()/formatIU()`）決定可見頁/順序，`pageMenu.jsp`+`header.jsp` render；點頁籤 = 重新 submit `${dispatcher}/{funcId}/prompt`。**每次切頁 = server round-trip + 重查（prompt → initQuery）**。
- **內層：區塊頁籤（只在 `0110/0210`）** — `Tabs()` 定義 3 個 client-side tab：Personal / Work / Family，**同頁切換、不重查**。

## 2. 外層流程頁清單（IS 0100）
| 順序 | funcId | 類型 | 說明 | IU |
|---|---|---|---|:--:|
| 1 | `EPROIS_0110` | 表單（內含 3 區塊 tabs）| 主借款人 | ✅ |
| 2 | `EPROIS_0120` | 表單 | 共同借款人 | ✅ |
| 3 | `EPROIS_0130` | 表單 | 保證人 | ✅ |
| 4 | `EPROIS_0140` | 表單 | 房屋/住宅資料 | ✅ |
| 5 | `EPROIS_0150` | 表單 + 上傳 | 擔保品主頁 | ❌ 無擔 |
| 6 | `EPROIS_0160` | 表單 | 放款/其他條件 | ✅ |
| 7 | `EPROIS_0170` | 表單 + 列印 + 上傳 | 審批主頁 | ✅ |
| 8 | `EPROIS_0171` | 上傳 | 審批附件 | ✅ |
| 9 | `EPROIS_0172` | 檢視 + 列印 | 提案/歷程 | ✅ |
| 10 | `EPROIS_0173` | 表單 + 上傳 | 審批補充 | ✅ |
| 11 | `EPROIS_0181` | 報表/下載 | CAD report（R2 暫緩）| ✅ |
| 12 | `EPROIS_0190` | 表單 | 擔保品提供人 | ❌ 無擔 |

> `0174`/`0175`/`0176` 是 **popup**（補件/退件/條件調整），非外層流程頁 → 對映 `mat-dialog`。

## 3. 對照矩陣
### 3.1 `_0100`（申請）↔ `_0200`（覆核）
`0110↔0210`、`0120↔0220`、`0130↔0230`、`0140↔0240`、`0150↔0250`、`0160↔0260`、`0190↔0290`。
- 最大差異在**審批段**：`0100` 拆成 `0170~0176`；`0200` 收斂進 `0270` + popup。
- `0100` = 資料蒐集 + 提案準備；`0200` = 覆核整合 + 意見/退件/條件調整（多唯讀）。

### 3.2 IS（有擔）↔ IU（無擔）
IU 缺整組 collateral 頁：`0150`/`0151`/`0190`（及 `0250`/`0251`/`0290`）。其餘（主借款人/共同借款人/保證人/房屋/條件/審批/CAD）相同。`formatIS()` 另控 `0190` 顯示。

## 4. 跨頁資料流
- **主鍵 `APPLICATION_NO`**：`prompt` 時自 session/context 取 → `initQuery` 重查 → `execute` 回寫。
- 傳遞 = session/context + `attrMap` + 每頁 `initQuery` + Ajax `execute`（**非 SPA 共用 store**）。
- 外層切頁 = **重查**；內層 3 tabs = **不重查**。

## 5. → 新架構（Angular）目標設計
**忠實對映兩層 + 「切頁重查」語意 → 用「shell + 子路由」，不是單一巨型 component。**

### 5.1 元件 / 路由結構
```
loan-application/                          # 流程 shell feature（lazy，掛 main-layout 下）
├── loan-application-shell.component       # 外層流程頁籤 nav + <router-outlet> + context
├── loan-application.routes.ts             # 各流程頁 = routed child（由 pageDescriptor 產生）
├── pages/
│   ├── main-borrower/                     # 0110/0210；內含 mat-tab-group(Personal/Work/Family)
│   ├── co-borrower/   guarantor/  property/
│   ├── collateral/                        # 0150/0250（僅 IS/CS）
│   ├── conditions/
│   └── approval/                          # 0170~(edit) / 0270(review)，由 mode 決定
├── shared/loan-application-context.service.ts   # APPLICATION_NO + mode + type
├── api.service.ts
└── config/
    ├── page-descriptor-config.ts          # 流程頁描述（見 5.3）
    └── *-config.ts                        # 各頁 field-item/form/validate
```
- 每個流程頁是 **routed child**，`ngOnInit` 用 `APPLICATION_NO` 自己 `initQuery`（對映舊「切頁重查」）。**不共用大 store**，只共用 context（案號/mode/type）→ 忠於舊模型、各頁可獨立測試。
- `main-borrower` 內用 `mat-tab-group` 做 Personal/Work/Family（client 切換、不重查）。
- `approval` 頁依 `mode`：edit 對 `0170` 群、review 對 `0270`。

### 5.2 參數化軸（一套 shell 重用）
| 軸 | 值 | 控制 |
|---|---|---|
| 個人/企金 | is·iu / cs·cu | descriptor config 來源 |
| 有擔/無擔 | is·cs（有）/ iu·cu（無）| 是否含 collateral 頁 |
| 申請/覆核 | `_0100`=edit / `_0200`=review | approval 樣式 + 唯讀 |
→ 全走 **route data + pageDescriptor config**，不為每組各做一套 shell。

### 5.3 PageDescriptor schema
```ts
interface PageDescriptor {
  funcId: string;     // 'EPROIS_0120'
  route: string;      // 'co-borrower'
  label: string;
  pageType: 'form' | 'view' | 'upload' | 'report';
  mode: 'edit' | 'review' | 'both';
  order: number;
  visibleRule?: string;   // 由後端 pageMap 決定（見 5.4）
}
```
IS config 含 collateral 頁；IU 省略（或單一 config + `securedOnly: true` 旗標）。

### 5.4 後端對應（重要）
- 把 `EPRO_Z0Z006.formatIS()/formatIU()`（pageMap）移植為
  **`GET /api/loan-application/{applicationNo}/pages?type=IS&mode=edit`** → 回傳 **server 權威的 page descriptor 清單**（可見頁/順序/權限）。
- 前端 shell **照後端回傳 render，不前端硬寫可見頁**（忠於舊系統由後端決定）。
- 各頁：`GET …/{section}`（initQuery）+ `POST …/{section}/execute`（回寫）。

## 6. 補進 golden-template（R3）
新增「Workflow Shell + Section Tabs」子樣式：shell + 子路由 + context service + pageDescriptor config + 各頁自取資料；供 is/iu/cs/cu 共用。

## 7. 開放項（不阻塞，實作前補）
- **B1**：審批段（`0170~0176` vs `0270`）欄位/動作細節 → 做 approval 頁前再開 D4 深掘。
- **B2**：upload/report 頁依 R2 暫緩（報表服務未定）。
- **B3**：cs/cu 是否與 is/iu 共用同一 shell（預期是，僅 config 差）→ 盤點 cs 時確認。
- **B4**：`APPLICATION_NO` 從何產生 / 進件入口（疑為 `EPROZ0_0200`）→ 串接點待確認。

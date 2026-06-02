# Phase 1 Build Spec — `EPROZ0_0700` 員工代理設定（Assign Substitute）

> 第一個垂直切片：驗證 **畫面 → API → DB → Auth** 端到端 + 斷網可 build。
> 目標棧（**修正**：前端為 **Angular 14**，非 React/Vue）：
> **Angular 14（config-driven，照 `deputy` 樣板，`cub-*`/Material）+ Spring Boot 3.3 / Java 17 + Oracle**。
> 來源：D1/D2 盤點（舊頁 `EPROZ0_0700`，自製 `HttpDispatcher`/`@CallMethod`、DB2）。

## 0. 範圍
- **要做**：查詢代理設定、新增一筆、刪除一筆，走 JWT + 進頁授權，落 Oracle 實表。
- **不做**：報表/上傳/Jasper（本頁本來就沒有）。Self/Others 進階角色分支第一版可簡化（見 §7 A3）。
- 舊頁 DB2 → **Oracle**（R1）；SQL 改寫見 §2.3 / §4.4。

## 1. 業務概述
請假期間指派代理人處理案件。**Self** 模式（本人設自己的代理）、**Others** 模式（角色 `101`/`405` 等可代他人設定）。單一主寫入表 `TB_EMP_PROXY`；其餘 `TB_EMP_PROFILE`/`TB_BRANCH_PROFILE` 僅查詢。

## 2. 資料模型（Oracle）

### 2.1 主表 `OVSLXLON01.TB_EMP_PROXY`（寫入）
✅ 欄位名與 **PK = (`EMP_ID`, `PROXY_ID`)** 已由 DAO 確認（A1）；`STR_TIME`/`END_TIME`/`UPDATE_DATE` 為 Timestamp、其餘為 String。
⚠️ 仍缺：精確型別/長度/nullable（repo 無 DDL）→ 向 DBA 取 DDL 補 `length`。

```java
// 欄位名/PK 已由 DAO 確認；@Column length 為佔位、待實際 DDL 校正
@Entity
@Table(name = "TB_EMP_PROXY", schema = "OVSLXLON01")
@IdClass(EmpProxyId.class)
public class EmpProxy {
    @Id @Column(name = "EMP_ID",   length = 20) private String empId;     // length 待 DDL
    @Id @Column(name = "PROXY_ID", length = 20) private String proxyId;   // length 待 DDL
    @Column(name = "STR_TIME")                 private LocalDateTime strTime;
    @Column(name = "END_TIME")                 private LocalDateTime endTime;
    @Column(name = "UPDATE_EMP_ID", length = 20) private String updateEmpId;
    @Column(name = "UPDATE_DATE")              private LocalDateTime updateDate;
    @Column(name = "RETURN_CASE_TO_CA", length = 1) private String returnCaseToCa; // 旗標
}

public class EmpProxyId implements java.io.Serializable {   // 複合主鍵
    private String empId;
    private String proxyId;
    // 預設建構子、equals/hashCode（依 empId+proxyId）
}
```
> **PK 影響**：主鍵僅 (`EMP_ID`,`PROXY_ID`) → 每組 emp+proxy **僅一筆**；**重複檢查/刪除以 (`EMP_ID`,`PROXY_ID`) 為鍵**，`STR_TIME` 非鍵（為日期區間值）。⚠️ 若業務允許同一對多筆日期區間，real DDL 之 PK 可能另含 `STR_TIME` → 取 DDL 時一併確認。

### 2.2 參考表（唯讀，用 projection 查詢、不必建完整 entity）✅ 欄位/PK 由 DAO 確認
- **`OVSLXLON01.TB_EMP_PROFILE`** — PK (`ROLE_ID`, `EMP_ID`)；欄位：`ROLE_ID`、`EMP_ID`、`EMP_NAME`、`BRANCH_CODE`、`E_MAIL`、`DEPT_CODE`、`STATUS`（皆 String）→ 可代理人 / 部門申請人 / 角色 / 顯示名。
  - ⚠️ **PK 含 `ROLE_ID` → 一員工多角色多列**；查代理人/顯示名（依 `EMP_ID`）時須 `DISTINCT` 或限定角色，避免 join 扇出重複。
- **`OVSLXLON01.TB_BRANCH_PROFILE`** — PK (`BRANCH_CODE`, `DEPT_CODE`)；欄位：`BRANCH_CODE`、`BRANCH_NAME`、`DEPT_CODE`、`DEPT_NAME`、`DATA_SEQ`、`DISPLAY`、`T24_COMPANY`、`T24_BRANCH_CODE`、`T24_DEPT_CODE`（皆 String）→ 部門下拉。
  - 註：DAO `fieldNames_general` 含 `T24_COMPANY` 但 insert/update SQL 未含 → DAO/SQL 不一致，取 DDL 時確認該欄是否存在。

### 2.3 DB2 → Oracle 改寫注意
- 時間一律用 **bind param**（`LocalDateTime`），勿用 DB2 `TIMESTAMP('…')` 字面值。
- 日期顯示格式 `dd/MM/yyyy` 移到 **Java/DTO 層**，SQL 只回 raw timestamp。
- 本頁無分頁需求 → 免 `ROWNUM`/`FETCH FIRST`。
- `NVL`/`||` 兩邊皆支援；查詢多為 ANSI join，改動小（主要是 schema 限定 + bind）。

## 3. API 合約（REST，base `/api/emp-proxy`，統一回 `EPROResponse<T>`）

| 方法 / 路徑 | 舊 action | 用途 | 主要參數 |
|---|---|---|---|
| `GET /page-init` | `init` | 進頁初始：目前角色 + 可代理人 + 部門 +（Self）本人代理清單 | — |
| `GET /employees?deptCode=` | `queryEmp` | 該部門「請假/申請人」清單 | `deptCode` |
| `GET /substitutes?empId=&deptCode=&strTime=` | `queryListOfSubstitute(2)` | 可代理人清單（依起日排除已占用）| `empId?`,`deptCode?`,`strTime?` |
| `GET /?deptCode=&scope=self\|others` | `query`/`queryOthersResult` | 代理結果清單 | `scope`,`deptCode?` |
| `POST /` | `execute` | 新增代理設定 | body=CreateRequest |
| `DELETE /` | `deleteDetail` | 刪除代理設定 | body=DeleteRequest |

> 設計取捨：把 RPC 式 action 收斂為資源導向；`queryListOfSubstitute` 與 `queryListOfSubstitute2`（起日重查）合併為帶 `strTime` 的同一端點。API 日期一律 **ISO `yyyy-MM-dd`**，UI 端再格式化為 `dd/MM/yyyy`。

### DTO
```ts
// 下拉選項通用
interface Option { value: string; label: string; }              // EMP_ID/EMP_NAME、DEPT_CODE/DEPT_NAME

interface EmpProxyInitResponse {
  roleId: string;
  scope: 'self' | 'others';        // 由 roleId 推導（101/405 可切 others）
  substitutes: Option[];
  depts: Option[];
  rows: ProxyRow[];                // Self：本人現有代理
}
interface ProxyRow {
  applicant?: Option;              // others 模式才有（EMP_ID/APP_NAME）
  strTime: string; endTime: string;
  substitute?: Option;            // PROXY_ID/PROXY_NAME（特定角色不顯示）
  returnCaseToCa?: string;
}
interface EmpProxyCreateRequest {
  empId?: string;                 // others 模式指定申請人；self 模式後端用登入者
  strTime: string; endTime: string;
  proxyId?: string;
  returnCaseToCa: string;
}
interface EmpProxyDeleteRequest {
  empId?: string; strTime: string; endTime: string;
  proxyId?: string; scope: 'self' | 'others';
}
```

### 驗證（DTO `@Valid` + 自訂，沿用 `@ValidDate` 模式）
- `strTime`/`endTime` **至少一個必填**（class-level validator）。
- `endTime >= strTime`；`strTime >= 今天`。
- 後端 service 仍做**重複檢查**（同 `EMP_ID/PROXY_ID/時間` 不可重疊，對應舊 `find()` 重複檢查）。

## 4. 後端骨架（Spring Boot 3.3 / Oracle）
- `EmpProxyController extends BaseController`：上列路徑，`@Valid` 驗 body，回 `EPROResponse`，例外交全域 `CommonErrorHandler`。
- `EmpProxyService`：寫入方法標 Spring `@Transactional`；含重複檢查 → insert → 重查回傳。
- `EmpProxyRepository extends JpaRepository<EmpProxy, EmpProxyId>`：結果查詢用 `@Query(nativeQuery=true)`（Oracle）；簡單查詢用 derived/JPQL。
- `EmpProxyMapper`（MapStruct `componentModel="spring"`）：entity ↔ DTO。
- Security：`APIAuthorizationFilter` 對 `apiPath=/api/emp-proxy/**`、functionId `EPROZ0_0700`。⚠️ **roleId 進頁白名單待補（A2）**。

### 4.4 SQL 改寫範例（`SQL_QUERY_001` → Oracle，代理結果清單）
```sql
SELECT p.EMP_ID, p.PROXY_ID, p.STR_TIME, p.END_TIME, p.RETURN_CASE_TO_CA,
       a.EMP_NAME AS APP_NAME, s.EMP_NAME AS PROXY_NAME
FROM   OVSLXLON01.TB_EMP_PROXY   p
JOIN   OVSLXLON01.TB_EMP_PROFILE a ON a.EMP_ID = p.EMP_ID
JOIN   OVSLXLON01.TB_EMP_PROFILE s ON s.EMP_ID = p.PROXY_ID
WHERE  (p.STR_TIME >= :now OR :now BETWEEN p.STR_TIME AND p.END_TIME)
  AND  (:empId    IS NULL OR p.EMP_ID = :empId)
  AND  (:deptCode IS NULL OR a.DEPT_CODE = :deptCode)
ORDER  BY p.STR_TIME, p.UPDATE_DATE
```
> 與 DB2 版差異很小（ANSI join）：改為 **schema 限定 + bind param**、移除 DB2 時間字面值；無分頁故不需方言分頁語法。`insert`/`delete` 同理以 entity/`@Modifying` native 處理。
> ⚠️ `TB_EMP_PROFILE` PK 含 `ROLE_ID`（一員工多列）→ join `a`/`s` 可能扇出重複；視業務加 `DISTINCT` 或在 join 上限定 `ROLE_ID`（取最新/特定角色）。

## 5. 前端骨架（Angular 14，照 `deputy` 複製改名為 `emp-proxy`）
```
src/app/emp-proxy/
├── emp-proxy.module.ts / emp-proxy-routing.module.ts     # lazy route 掛 main-layout 下
├── emp-proxy.component.{ts,html,scss}                    # 查詢列 + 結果表格 + 「新增代理」按鈕 + 列 Del
├── api.service.ts                                        # 對應 §3 端點
├── emp-proxy.ts                                          # DTO 型別（同 §3）
├── popup-add-emp-proxy/                                  # 新增表單彈窗
└── config/
    ├── search-item-config.ts    # scope(self/others)、dept、applicant 篩選
    ├── field-item-config.ts /form-config.ts  # 新增表單：申請人/代理人/起迄日
    ├── validate-rule.ts         # §3 日期規則
    └── role-id-config.ts        # functionId EPROZ0_0700；Self/Others by roleId
```
- **config-driven**：查詢列用 `app-table-search` + `search-item-config`；新增表單用 `app-field-item` + `field-item-config`；表格用 `app-table-search`/`cub-table`。**勿手刻 HTML。**
- **級聯**：dept 變更 → 載 employees；applicant 變更 → 載 substitutes；**起日變更 → 重載 substitutes**（排除已占用，對應舊 `queryListOfSubstitute2`）。
- **視覺**：照 XD「Assign Substitute」畫面（A5），用既有元件 + 主題變數，涵蓋 **空 / 載入 / 錯誤 / disabled / 無權限** 狀態。

## 6. 欄位對照（JSP → Angular config）
| JSP 欄位 | 送後端 | Angular config |
|---|---|---|
| `TYPE_RADIO`（Self/Others）| scope | `role-id-config` 推導 + search 切換 |
| `DEPT_NAME` | `DEPT_CODE` | search-item（select，來源 `/page-init` depts）|
| `PERSON_ON_LEAVE` | `EMP_ID` | search-item（select，來源 `/employees`，級聯 dept）|
| `START/END_SUBSTITUTE_DATE` | `STR_TIME`/`END_TIME` | field-item（date）+ `validate-rule` |
| `LIST_OF_SUBSTITUTE` | `PROXY_ID` | field-item（select，來源 `/substitutes`，級聯 emp+起日）|
| 結果表格 | — | 表格欄：申請人/代理日期/代理人/(returnCaseToCa) + Del |

## 7. 開放項（不阻塞，落地前要補）
- 🟡 **A1（部分完成）**：欄位名 + PK 已由 DAO 確認（§2）、entity 已可實作；**仍缺精確型別/長度/nullable**（repo 無 DDL）→ 向 DBA 取 DDL 補 `@Column(length=…)` 與 PK 是否含 `STR_TIME`。
- ⚠️ **A2**：roleId **進頁授權白名單**（repo 找不到靜態 FunctionAuth，推測在執行環境 DB/共用權限）→ 填 `APIAuthorizationFilter`/權限表。
- **A3**：Self/Others 角色分支（`101`/`102`/`103`/`405` 等）細節 → 第一版可**只做 Self**，Others 標 TODO。
- **A4**：`PROXY_ID` 與 `RETURN_CASE_TO_CA` 業務語意確認。
- **A5**：對應 XD 畫面連結（你補）。

## 8. 驗收門檻
- **離線 build**：後端 `backend/` `mvn -o package`；前端 `frontend/` `yarn install --frozen-lockfile` + `ng build`。
- **端到端**：登入(JWT) → 進頁(functionId 授權) → 查詢 → 新增一筆 → 表格出現 → 刪除 → 消失，全落 **Oracle 實表**。
- **狀態**：空 / 載入 / 錯誤 / 驗證失敗 皆正確呈現。

## 9. 附錄：A1 / A2 取得方式（拿回來我補 entity / 權限）

### A1 — `TB_EMP_PROXY` DDL（舊系統 DB2）
> 🟡 狀態：欄位名 + PK 已由 DAO 取得（見 §2，entity 已可實作）；**repo 無 DDL** → 仍需 DBA 提供 DDL 補欄位長度/nullable，及確認 PK 是否含 `STR_TIME`。下列查詢供取得 DB 端精確型別。

先在 repo 找（Copilot）：
```
@workspace 找 TB_EMP_PROXY 的建表 DDL 或 ORM mapping：搜尋 "TB_EMP_PROXY" 的
CREATE TABLE、.ddl/.sql、hbm.xml 或 entity 定義，列出欄位型別/長度/nullable/primary key。
同樣給 TB_EMP_PROFILE、TB_BRANCH_PROFILE 的欄位。
```
找不到就直接查 DB2（syscat）：
```sql
-- 欄位
SELECT colname, typename, length, scale, nulls, "DEFAULT"
FROM   syscat.columns
WHERE  tabschema='OVSLXLON01' AND tabname='TB_EMP_PROXY'
ORDER  BY colno;
-- 主鍵
SELECT kc.colname, kc.colseq
FROM   syscat.tabconst tc
JOIN   syscat.keycoluse kc ON tc.constname = kc.constname
WHERE  tc.tabschema='OVSLXLON01' AND tc.tabname='TB_EMP_PROXY' AND tc.type='P'
ORDER  BY kc.colseq;
```
→ 回來我把 DB2 型別映射到 Oracle（`VARCHAR→VARCHAR2`、`TIMESTAMP→TIMESTAMP`、`DECIMAL→NUMBER`…）並定稿 `EmpProxy` / `EmpProxyId`（§2.1）。

### A2 — roleId 進頁授權白名單
repo / 設定查找（Copilot）：
```
@workspace AuthManager 怎麼決定哪些 roleId 能進某個 functionId？找 FunctionAuth.xml /
MenuTree.xml / UserRole.xml 或權限 DB 表中與 "EPROZ0_0700" 對應的角色；
說明 function→role 對映的來源（XML 還是 DB 表名）。
```
→ 若在執行環境 DB：找到權限表後 `WHERE function_id='EPROZ0_0700'`。回來我把白名單填進新後端 `APIAuthorizationFilter`/權限表（`apiPath=/api/emp-proxy/**` ↔ roleId）。

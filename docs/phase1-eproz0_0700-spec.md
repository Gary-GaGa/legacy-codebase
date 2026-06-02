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

### 2.1 主表 `TB_EMP_PROXY`（寫入）✅ A1 已關閉（新 DB schema）
新 DB：**無 schema 限定、無 `EPRO_` 前綴**；**PK = `EMP_ID`（單一鍵）**。

```java
@Entity
@Table(name = "TB_EMP_PROXY")
public class EmpProxy {
    @Id
    @Column(name = "EMP_ID", length = 10)           private String empId;          // 行編
    @Column(name = "PROXY_ID", length = 10)         private String proxyId;        // 代理人員（可空）
    @Column(name = "STR_TIME", nullable = false)    private LocalDateTime strTime;  // 開始時間（必填）
    @Column(name = "END_TIME")                      private LocalDateTime endTime;  // 結束時間
    @Column(name = "UPDATE_EMP_ID", length = 10)    private String updateEmpId;     // 創建/更新人員
    @Column(name = "UPDATE_DATE")                   private LocalDateTime updateDate;
    @Column(name = "RETURN_CASE_TO_CA", length = 1) private String returnCaseToCa;  // 是否退回 CA，default 'N'
}
```
> **⚠️ PK 與舊 DAO 不一致（需業務確認）**：舊 DAO keyFields = (`EMP_ID`,`PROXY_ID`)，但**新 DB PK = `EMP_ID` 單鍵** → 語意變為**每位員工至多一筆代理設定**（再設定 = 覆蓋）。
> 影響：**不需 `@IdClass`**；新增/更新 = 依 `EMP_ID` **upsert**；刪除依 `EMP_ID`。`STR_TIME` 為 `NOT NULL`（API 必填）。請業務確認「一人一筆」是否為預期（相對舊系統的行為簡化）。

### 2.2 參考表（唯讀；新 DB 無 schema/`EPRO_` 前綴）✅ A1 已關閉
- **`TB_EMP_PROFILE`** — PK (`ROLE_ID`, `EMP_ID`)：`ROLE_ID` VARCHAR2(5)、`EMP_ID` VARCHAR2(5)、`EMP_NAME` VARCHAR2(50)、`BRANCH_CODE` VARCHAR2(8)、`E_MAIL` VARCHAR2(100)、`DEPT_CODE` VARCHAR2(8)、`STATUS` VARCHAR2(10)（active/inactive）→ 可代理人 / 申請人 / 角色 / 顯示名。
  - ⚠️ **PK 含 `ROLE_ID` → 一員工多角色多列**；依 `EMP_ID` 查時須 `DISTINCT` 或限定角色，避免 join 扇出。
  - ⚠️ **長度不一致**：此表 `EMP_ID` VARCHAR2(**5**)，但 `TB_EMP_PROXY.EMP_ID` VARCHAR2(**10**)；`BRANCH_CODE` 8 vs `TB_BRANCH_PROFILE.BRANCH_CODE` 5。join 可行但留意。
- **`TB_BRANCH_PROFILE`** — PK (`BRANCH_CODE`, `DEPT_CODE`)：`BRANCH_CODE` VARCHAR2(5)、`BRANCH_NAME` VARCHAR2(100)、`DEPT_CODE` VARCHAR2(3)、`DEPT_NAME` VARCHAR2(100)、`DATA_SEQ` NUMBER(3)、`DISPLAY` VARCHAR2(1)、`T24_BRANCH_CODE` VARCHAR2(5)、`T24_DEPT_CODE` VARCHAR2(5) → 部門下拉。
  - ✅ 新 DB **無 `T24_COMPANY`**（確認舊 DAO/SQL 不一致 = 新 DB 已移除該欄）。

### 2.3 DB2 → Oracle 改寫注意
- 時間一律用 **bind param**（`LocalDateTime`），勿用 DB2 `TIMESTAMP('…')` 字面值。
- 日期顯示格式 `dd/MM/yyyy` 移到 **Java/DTO 層**，SQL 只回 raw timestamp。
- 本頁無分頁需求 → 免 `ROWNUM`/`FETCH FIRST`。
- `NVL`/`||` 兩邊皆支援；查詢多為 ANSI join，改動小（主要是 bind param）。
- **新 DB 表名無 schema、無 `EPRO_` 前綴** → entity `@Table(name="TB_…")` 不加 `schema=`，SQL 不加 `OVSLXLON01.` 前綴。

## 3. API 合約（REST，base `/api/emp-proxy`，統一回 `EPROResponse<T>`）

| 方法 / 路徑 | 舊 action | 用途 | 主要參數 |
|---|---|---|---|
| `GET /page-init` | `init` | 進頁初始：目前角色 + 可代理人 + 部門 +（Self）本人代理清單 | — |
| `GET /employees?deptCode=` | `queryEmp` | 該部門「請假/申請人」清單 | `deptCode` |
| `GET /substitutes?empId=&deptCode=&strTime=` | `queryListOfSubstitute(2)` | 可代理人清單（依起日排除已占用）| `empId?`,`deptCode?`,`strTime?` |
| `GET /?deptCode=&scope=self\|others` | `query`/`queryOthersResult` | 代理結果清單 | `scope`,`deptCode?` |
| `PUT /{empId}` | `execute` | 新增/更新（upsert，PK=EMP_ID）| body=UpsertRequest |
| `DELETE /{empId}` | `deleteDetail` | 刪除代理設定 | path `empId` |

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
interface EmpProxyUpsertRequest {   // PK=EMP_ID → 新增/更新皆 upsert
  empId?: string;                 // others 指定申請人；self 用登入者
  strTime: string;                // 必填（DB NOT NULL）
  endTime?: string;
  proxyId?: string;
  returnCaseToCa: string;         // 'Y' / 'N'
}
// 刪除：DELETE /{empId}（PK 單鍵，無需其他欄位）
```

### 驗證（DTO `@Valid` + 自訂，沿用 `@ValidDate` 模式）
- `strTime` **必填**（DB `NOT NULL`）；`endTime` 選填。
- `endTime >= strTime`（若有）；`strTime >= 今天`。
- PK=`EMP_ID` → **不需重複檢查**；新增/更新為依 `EMP_ID` 的 **upsert**。

## 4. 後端骨架（Spring Boot 3.3 / Oracle）
- `EmpProxyController extends BaseController`：上列路徑，`@Valid` 驗 body，回 `EPROResponse`，例外交全域 `CommonErrorHandler`。
- `EmpProxyService`：寫入方法標 Spring `@Transactional`；依 `EMP_ID` **upsert**（`save()`，PK 存在即更新）→ 重查回傳；刪除依 `EMP_ID`。
- `EmpProxyRepository extends JpaRepository<EmpProxy, String>`（PK=`EMP_ID`）：結果查詢用 `@Query(nativeQuery=true)`（Oracle）；簡單查詢用 derived/JPQL。
- `EmpProxyMapper`（MapStruct `componentModel="spring"`）：entity ↔ DTO。
- Security：`APIAuthorizationFilter` 對 `apiPath=/api/emp-proxy/**`。✅ 舊權限為 **DB 驅動**（`AuthManager` source=db）：`TB_FUNCTION_INFO`(FUNC_ID,FUNC_URL,LANG_KEY) + `TB_FUNCTION_AUTH`(FUNC_ID,USER_ROLE)；`checkPermission` 把 bean 名**去底線**當 funcId → 本頁 funcId = **`EPROZ00700`**（`EPROZ0_0700` 去底線）。新後端：`apiPath=/api/emp-proxy/**` ↔ funcId `EPROZ00700` ↔ `USER_ROLE` 白名單（**遷移 `TB_FUNCTION_AUTH` 資料列**即可，與新 filter 同型）。實際 roleId 為 runtime DB 內容（§9 A2 查得）。

### 4.4 SQL 改寫範例（`SQL_QUERY_001` → Oracle，代理結果清單）
```sql
SELECT p.EMP_ID, p.PROXY_ID, p.STR_TIME, p.END_TIME, p.RETURN_CASE_TO_CA,
       a.EMP_NAME AS APP_NAME, s.EMP_NAME AS PROXY_NAME
FROM   TB_EMP_PROXY   p
JOIN   TB_EMP_PROFILE a ON a.EMP_ID = p.EMP_ID
JOIN   TB_EMP_PROFILE s ON s.EMP_ID = p.PROXY_ID
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
- ✅ **A1（完成）**：新 DB schema 已取得（型別/長度/nullable/PK/default）→ entity 定稿（§2）。⚠️ 衍生需業務確認：**PK=`EMP_ID` 單鍵與舊 DAO 複合鍵不一致**（語意 = 一人一筆代理）。
- 🟡 **A2（機制已定）**：舊權限走 DB（`TB_FUNCTION_INFO`+`TB_FUNCTION_AUTH`，FUNC_ID/USER_ROLE），funcId=`EPROZ00700`（bean 去底線）。✅ 與新 `APIAuthorizationFilter`（apiPath+roleId 查 DB）**同型 → 遷移資料即可**。residual：實際 `USER_ROLE` 資料列為 runtime DB 內容（§9 A2 查），及 `FUNC_ID → apiPath` 對映。
- **A3**：Self/Others 角色分支（`101`/`102`/`103`/`405` 等）細節 → 第一版可**只做 Self**，Others 標 TODO。
- **A4**：`PROXY_ID` 與 `RETURN_CASE_TO_CA` 業務語意確認。
- **A5**：對應 XD 畫面連結（你補）。

## 8. 驗收門檻
- **離線 build**：後端 `backend/` `mvn -o package`；前端 `frontend/` `yarn install --frozen-lockfile` + `ng build`。
- **端到端**：登入(JWT) → 進頁(functionId 授權) → 查詢 → 新增一筆 → 表格出現 → 刪除 → 消失，全落 **Oracle 實表**。
- **狀態**：空 / 載入 / 錯誤 / 驗證失敗 皆正確呈現。

## 9. 附錄：A1 / A2 取得方式（拿回來我補 entity / 權限）

### A1 — `TB_EMP_PROXY` DDL（舊系統 DB2）
> ✅ **已關閉**：改由**新 DB schema Excel** 取得精確型別/長度/nullable/PK/default（見 §2 與 `db-schema-catalog.md`）。以下 DB2 查詢保留備查。

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
→ ✅ 已查明機制：權限在 DB 表 `TB_FUNCTION_AUTH`（非 XML）。取實際 roleId 清單（⚠️ **funcId 去底線** = `EPROZ00700`）：
```sql
SELECT a.USER_ROLE
FROM   OVSLXLON01.TB_FUNCTION_AUTH a
WHERE  a.FUNC_ID = 'EPROZ00700';
-- 一併確認 funcId 寫法（含/不含底線）：
SELECT FUNC_ID, FUNC_URL, LANG_KEY
FROM   OVSLXLON01.TB_FUNCTION_INFO
WHERE  FUNC_ID IN ('EPROZ00700','EPROZ0_0700');
```
回來我把 `USER_ROLE` 清單填進新後端權限表（`apiPath=/api/emp-proxy/**` ↔ funcId `EPROZ00700` ↔ roleId）。

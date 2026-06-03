# Build Task — `EPROZ00700` Assign Substitute（第一張開工任務）

> 載具：**Codex CLI**（在各專案內執行；Codex 自動讀該專案的 `AGENTS.md`）。
> 前置：確認**前端專案**有 `frontend/AGENTS.md` 內容、**後端專案**有 `backend/AGENTS.md` 內容（+ 共用 root `AGENTS.md`）。完整規格參考規劃 repo 的 `phase1-eproz0_0700-spec.md`（本任務已自帶必要細節）。
> 狀態：前端未做、後端待 cross-check（多半未做）。先做這張驗證整條 pipeline。

---

## A. 後端任務（在「後端專案」跑 Codex CLI）

```
實作 Assign Substitute（功能代號 EPROZ00700）的後端 API。遵循本專案 AGENTS.md 既有慣例
（Controller/Service/Repository 分層、回傳 EPROResponse、全域 CommonErrorHandler、Spring
@Transactional 放 service、DTO↔Entity 用 MapStruct、Oracle、Spring Security + JWT）。

資料表（Oracle，無 schema、無 EPRO_ 前綴）：
- TB_EMP_PROXY（寫入）— 主鍵 EMP_ID 單一鍵：
  EMP_ID VARCHAR2(10) PK、PROXY_ID VARCHAR2(10) null、STR_TIME TIMESTAMP NOT NULL、
  END_TIME TIMESTAMP null、UPDATE_EMP_ID VARCHAR2(10)、UPDATE_DATE TIMESTAMP、
  RETURN_CASE_TO_CA VARCHAR2(1) default 'N'。→ Entity 用單一 @Id（不要 @IdClass）。
- TB_EMP_PROFILE（唯讀）PK(ROLE_ID,EMP_ID)：ROLE_ID(5)、EMP_ID(5)、EMP_NAME(50)、
  BRANCH_CODE(8)、E_MAIL(100)、DEPT_CODE(8)、STATUS(10)。⚠️ 一員工多角色多列 → 依 EMP_ID 查要 DISTINCT。
- TB_BRANCH_PROFILE（唯讀）PK(BRANCH_CODE,DEPT_CODE)：DEPT_CODE(3)、DEPT_NAME(100) 等。

API（base /api/emp-proxy，全部回 EPROResponse）：
- GET /page-init → { roleId, scope, substitutes[], depts[], rows[] }
- GET /employees?deptCode=        → 該部門申請人[]
- GET /substitutes?empId=&deptCode=&strTime=  → 可代理人[]（依起日排除已占用）
- GET /?scope=self|others&deptCode= → 代理結果清單[]
- PUT /{empId}   → upsert（empId 省略=登入者）。body: strTime(必填), endTime?, proxyId?, returnCaseToCa
- DELETE /{empId}
驗證：strTime 必填(NOT NULL)、endTime>=strTime、strTime>=今天。PK=EMP_ID → 不需重複檢查、save 即 upsert。
日期 API 用 ISO（yyyy-MM-dd），DB 存 timestamp。

權限：APIAuthorizationFilter 讀 TB_API_AUTH。新增本頁授權列：
  API_ID=/api/emp-proxy/**、REF_FUNCTION_ID=EPROZ00700、ROLE 取自
  TB_FUNCTION_AUTH WHERE FUNCTION_ID='EPROZ00700'。
```

## B. 前端任務（在「前端專案」跑 Codex CLI）

```
實作 Assign Substitute（EPROZ00700）頁面。遵循本專案 AGENTS.md：照既有 z0 查詢/管理頁
與參考 feature 結構複製改名；config-driven（app-table-search + *-config.ts）；元件優先序
app-* → cub-* → mat-*；視覺用既有元件 + 主題變數、勿寫死色碼、勿 override 元件樣式；
每個狀態都要（空/載入/錯誤/disabled）；API service 經 HTTP interceptor 附 JWT。

路由：新增一條 lazy route，命名比照既有 z0 頁（例如 /assign-substitute）。
版面：
- 查詢/表單：部門 → 申請人 → 代理人 三層級聯下拉；代理起日、迄日（date）。
  級聯：部門變更載申請人；申請人變更載可代理人；起日變更重載可代理人。
- 結果表格：代理日期、代理人、Del（刪除）。
- Self / Others 模式：第一版只做 Self；Others（角色 101/405 可代他人設定）先標 TODO。
驗證：起日必填、迄日>=起日、起日>=今天。
API：對應後端 /api/emp-proxy（page-init / employees / substitutes / 查詢 / PUT /{empId} / DELETE /{empId}）。
DTO 欄位：Option{value,label}；ProxyRow{strTime,endTime,substitute?,returnCaseToCa?}；
UpsertRequest{empId?,strTime,endTime?,proxyId?,returnCaseToCa}。
```

## C. 驗收
- 後端：`mvn -o package` 離線可 build；端到端 登入(JWT)→ 進頁授權 → 查詢 → PUT 新增/更新 → 表格出現 → DELETE → 消失，落 Oracle。
- 前端：`yarn install --frozen-lockfile` + `ng build` 離線可 build；空/載入/錯誤/驗證失敗 狀態正確。
- 完成 → 回填 `page-mapping.md` §2 狀態。

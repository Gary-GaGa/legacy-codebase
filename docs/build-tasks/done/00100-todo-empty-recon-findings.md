# EPROZ00100 TODO empty recon findings

結論一句：TODO 空 = 🔴 查詢/執行鏈 bug，不是正常空；以新版 as-is SQL、70201 的 role `002`、`langType=en_US` 查 OVSLXLON02，應回 85 筆 `CASE_PROGRESS=01`。

## Scope

- 日期：2026-06-15
- 範圍：唯讀盤點新版 `EPROZ00100` TODO List 查詢鏈、legacy-epro 對照、OVSLXLON02 現況。
- DB 操作：只透過既有唯讀 wrapper 執行 `SELECT`，未執行 DML/DDL。
- 程式碼操作：本次只新增本 findings 檔；未修改後端/前端程式碼。

## 新版查詢鏈 as-is

### Endpoint/controller

- `backend/src/main/java/khd/svc/epro/controller/common/ToDoListController.java:21-23`：`@RestController`，class extends `BaseController`。
- `backend/src/main/java/khd/svc/epro/controller/common/ToDoListController.java:63-68`：`POST /epl-list-todolist`，接 `ToDoListRequest`，回 `createSuccessResponse(toDoListService.getToDoList(request))`。
- `backend/src/main/java/khd/svc/epro/controller/BaseController.java:13-20`：成功 response 包成 `EPROResponse.data`。
- `backend/src/main/java/khd/svc/epro/dto/common/EPROResponse.java:21-23`：JSON 欄位為 `data`。

### Service

- `backend/src/main/java/khd/svc/epro/service/common/impl/ToDoListServiceImpl.java:155-170`
  - `jwtUtil.getCurrentEmployee()` 取登入者。
  - `roleId = loginEmployee.getRoleId()`，`empId = loginEmployee.getEmpId()`。
  - `lonTypeCodes` 來自 `LonTypeCodeEnum`。
  - `caseProgressNotIn` 來自 `CaseProgressNotInEnum`。
  - 呼叫 `vMainBorrowerInfoRepository.findToDoList(...)`。
- `backend/src/main/java/khd/svc/epro/service/common/impl/ToDoListServiceImpl.java:172-211`
  - 若 repository 結果空，直接回預設 `totalCount=0`、空 `toDoList`。
  - `SPECIAL_ROLE_IDS` 只影響 loan amount enrichment，不再做 DB filter。
- `backend/src/main/java/khd/svc/epro/util/jwt/JwtUtil.java:207-213`：登入者取自 `SecurityContextHolder`。
- `backend/src/main/java/khd/svc/epro/util/jwt/LoginEmployee.java:10-16`：登入者欄位包含 `roleId`、`empId`、branch/dept。

### Repository SQL

- `backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:13-65`：native SQL。
- 主表/關聯：
  - `V_MAIN_BORROWER_INFO S`：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:42`
  - `LEFT JOIN TB_RELATED_PARTY_INFO R`：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:43-45`
- 登入者匹配欄位：
  - 只用 `S.CURRENT_USER_ID = :userId`：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:48`
  - 不看 `AO_CODE`、`AO_ASSISTANT_CODE`。
- 語系條件：
  - `S.LOAN_TYPE_LANG_TYPE = :langType`：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:46`
  - `S.PROPOSED_APPROVAL_LEVEL_LANG_TYPE = :langType OR ... IS NULL`：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:47`
- Role 條件：
  - role `404/405`：只限 `S.LON_TYPE_CODE IN :lonTypeCodes`。
  - 非 `404/405`：限 `S.CASE_PROGRESS NOT IN :caseProgressNotIn`。
  - 來源：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:49-50`
- Optional filters：
  - `applicationNo`、approval date range、mainBorrowerName、docNo：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:51-61`
- 排序/分頁：
  - role `404/405` 用 `DECISION_DATE`，其他 role 用 `APPLICATION_DATE`：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:62`
  - `OFFSET (:page - 1) * :size FETCH NEXT :size`：`backend/src/main/java/khd/svc/epro/repository/VMainBorrowerInfoRepository.java:63`
- 排除狀態集合：
  - `03`, `D1`, `R0305`, `R0313`, `R0397`：`backend/src/main/java/khd/svc/epro/enums/CaseProgressNotInEnum.java:3-8`
- `V_MAIN_BORROWER_INFO` entity：
  - view mapping：`backend/src/main/java/khd/svc/epro/entity/VMainBorrowerInfoEntity.java:12-14`
  - `CASE_PROGRESS` 長度 5：`backend/src/main/java/khd/svc/epro/entity/VMainBorrowerInfoEntity.java:50-51`
  - `CURRENT_USER_ID` mapping：`backend/src/main/java/khd/svc/epro/entity/VMainBorrowerInfoEntity.java:101-102`

### Frontend request shape checked

- `frontend/src/app/pages/todo-list/todo-list.component.ts:94-97`：role `002` 這類 `isSearchShow=false` 時，`ngOnInit()` 會自動 `getTableData()`。
- `frontend/src/app/pages/todo-list/cols-list-params/colslist-config.ts:29-31`：role `002` 使用 CaseB，`isSearchShow=false`。
- `frontend/src/app/pages/todo-list/todo-list.component.ts:181-196`：payload 帶 `langType`、`page`、`size`、查詢欄位。
- `frontend/src/app/pages/todo-list/service/api.service.ts:27-31`：POST `epl-list-todolist` 後 map 成 `ToDoList`。
- `frontend/src/app/core/services/i18n/i18n.service.ts:18-22`：預設語系值是 `en_US`。
- `frontend/src/app/core/services/i18n/i18n.service.ts:36-43`：若 cookie `epro_lang` 存在，會覆蓋預設語系。

## OVSLXLON02 現況

只讀查詢結果：

### 70201 employee

| EMP_ID | ROLE_ID | STATUS | BRANCH_CODE | DEPT_CODE |
|---|---|---|---|---|
| 70201 | 002 | active | 00012 | 012 |

### TB_LON_SUMMARY_INFO：70201 出現在任一 user 欄位

| CASE_PROGRESS | total_any | CURRENT_USER_ID | AO_CODE | AO_ASSISTANT_CODE |
|---|---:|---:|---:|---:|
| 01 | 86 | 85 | 86 | 0 |
| 08 | 4 | 0 | 4 | 0 |
| 27 | 7 | 0 | 7 | 0 |
| C1 | 15 | 0 | 14 | 1 |
| D1 | 23 | 23 | 23 | 0 |
| R0397 | 59 | 0 | 59 | 0 |

### V_MAIN_BORROWER_INFO：新版 exact WHERE

以新版 repository 條件展開：

- `roleId='002'`
- `userId='70201'`
- `langType='en_US'`
- `CASE_PROGRESS NOT IN ('03','D1','R0305','R0313','R0397')`

結果：

| langType | CASE_PROGRESS | count |
|---|---|---:|
| en_US | 01 | 85 |

同一條件若 `langType='zh_TW'`：0 筆。這代表若 runtime cookie 送 `zh_TW`，畫面會空；但在預設 `en_US` 下，backend as-is 不應空。

## 194 筆逐狀態比對

| CASE_PROGRESS | input count | 新版查詢是否會進 TODO | 判定 |
|---|---:|---|---|
| 01 | 86 | 會，但只限 `CURRENT_USER_ID=70201` 的 85 筆 | `01` 不在排除集合，85 筆應顯示；1 筆只是 AO_CODE 命中，不會顯示。 |
| R0397 | 59 | 不會 | `R0397` 在 `CaseProgressNotInEnum`，且 DB 這 59 筆都不是 `CURRENT_USER_ID=70201`。 |
| D1 | 23 | 不會 | `D1` 在 `CaseProgressNotInEnum`；即使 23 筆都是 `CURRENT_USER_ID=70201` 也會被排除。 |
| C1 | 15 | 依 SQL 狀態本身會通過，但實際不會 | `C1` 不在排除集合；但這 15 筆沒有 `CURRENT_USER_ID=70201`。舊/新 TODO 都是看 current user，所以不會出現。 |
| 27 | 7 | 依 SQL 狀態本身會通過，但實際不會 | `27` 不在排除集合；但 7 筆沒有 `CURRENT_USER_ID=70201`。 |
| 08 | 4 | 依 SQL 狀態本身會通過，但實際不會 | `08` 不在排除集合；但 4 筆沒有 `CURRENT_USER_ID=70201`。 |

關鍵：這 194 筆不是全部都「本來不該顯示」。其中 `01` 有 85 筆符合新版 TODO exact WHERE，應出現在 TODO。

## legacy-epro 對照

### Entry 與 TODO init query

- `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:150-157`：AJAX action `initQuery` 回 `new EPROZ0_0100_mod().initQuery(user)`。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:45`：`SQL_QUERY_001` 是 init query handle。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:58-59`：舊版 `NOT_IN_CASE_PROGRESS = {"03","D1","R0305","R0313","R0397"}`，與新版一致。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:70-74`：舊版 init query 傳入 `CURRENT_USER_ID = user.getEmpId()` 與 `NOT_IN_CASE_PROGRESS`，再呼叫 `SQL_QUERY_001`。

### CAD 查詢分支

- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:130-150`：`queryCAD` 會組 `IN_CURRENT_USER_ID`，包含本人與 proxy employees。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:179`：CAD 分支設定 `IN_LON_TYPE_CODE`。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:181`：CAD 分支呼叫 `SQL_QUERY_005`。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:56`：CAD 分支使用 `LON_TYPE_CODE = {"01","02","03","04"}`。

### 舊/新差異

- AO 70201 是 role `002`，不是 CAD role `404/405`。
- 新版非 `404/405` 分支等價於舊版 initQuery 的核心限制：看 `CURRENT_USER_ID`，排除 `03/D1/R0305/R0313/R0397`。
- 新版 repository 額外要求 `langType` 匹配 `V_MAIN_BORROWER_INFO` 語系欄位。DB 現況下 `CURRENT_USER_ID=70201` 且符合 TODO 的 85 筆只有 `en_US`；送 `zh_TW` 會空。
- 舊版 named SQL body 在本 checkout 的 `legacy-epro` 可讀文字檔中未找到；可引用的 file:line 證據停在 Java source 對 `CURRENT_USER_ID`、`NOT_IN_CASE_PROGRESS`、`LON_TYPE_CODE` 的參數注入與 named SQL handle。

## R0397 判定

`R0397` 不是髒資料，也不是別欄位混入；它是合法 5 字元 process code，但設為不顯示且被 TODO 排除。

證據：

- `backend/src/main/java/khd/svc/epro/entity/TBProcessCodeEntity.java:7-24`：`TB_PROCESS_CODE.APP_PROCESS_CODE` 長度 5，含 `APP_PROCESS_NAME`、`IS_SHOW`、`PROCESS_DESC`、`PROCESS_TYPE`。
- OVSLXLON02 `TB_PROCESS_CODE` 查到：

| APP_PROCESS_CODE | APP_PROCESS_NAME | IS_SHOW | PROCESS_TYPE | PROCESS_DESC |
|---|---|---|---|---|
| 97 | Submit to LLC | Y | OT | 送至LLC |
| R03 | CA Redistributing | Y | DS | CA重新分案 |
| R0305 | CA Redistributing | N | DS | CA重新分案(Credit reviewer 進行審查中退回案件) |
| R0313 | CA Redistributing | N | DS | CA重新分案(補件送至Credit reviewer 審查中退回案件) |
| R0397 | CA Redistributing | N | DS | CA重新分案(送至LLC退回案件) |
| R05 | Reviewing by Credit reviewer (Agent) | Y | RE | Credit reviewer 進行審查中(重新派件後) |
| R13 | Credit reviewer Re-review Application(Agent) | Y | RE | 補件送至Credit reviewer 審查中(重新派件后) |
| R97 | Submit to LLC (Agent) | Y | RE | 送至LLC(重新派件后) |

- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:253-260`：舊版 CA redistribution 將非 `05/98/13` 的退回狀態改成 `R0397`。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:273-276`：同段寫回 `CASE_PROGRESS` 與 `CURRENT_USER_ID`。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:308-314`：舊版另一個 redistribution 分支同樣會產生 `R0397`。
- `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:318-321`：同段寫回 `CASE_PROGRESS` 與 `CURRENT_USER_ID`。
- OVSLXLON02 `TB_LON_SUMMARY_INFO` 目前 `R0397` 共 456 筆；70201 任一 user 欄位命中的 59 筆都在 `AO_CODE`，不是 `CURRENT_USER_ID`。

## Final assessment

- 若本機以 AO 70201 登入、語系是預設 `en_US`、無額外查詢條件，新版 backend as-is 應從 `V_MAIN_BORROWER_INFO` 回 85 筆 `CASE_PROGRESS=01`。
- 因此畫面 TODO List 空不是正常業務結果；下一步應查 runtime request 是否送出 `langType=zh_TW`、JWT 是否真的是 `empId=70201/roleId=002`、API response 是否為 200 且 `data.totalCount=85`。

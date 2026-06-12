# AGENTS.md — 後端規範（Java 17 + Spring Boot 3.3.0）

> 本檔為 `backend/` 專屬規範，**與 repo 根 [`../AGENTS.md`](../AGENTS.md) 的共用規則（離線 mirror / 版本鎖定 / 策略 / 工作流程）一起適用**。

## 1. 版本與遷移
- **Spring Boot 3.3.0**（由 `spring-boot-starter-parent` 帶入，無額外 BOM）；Java 17；環境 Maven 3.9.16。
- 舊專案 Java 8 → 17 時做 **`javax.* → jakarta.*`** 全面遷移（servlet/persistence/validation），可用 OpenRewrite recipe（亦走內網 Nexus）。**既有重構後端已是 jakarta**，可直接當目標慣例。
- **DB：Oracle（新舊皆是；2026-06-12 實連更正——原依舊源 `DB2PoolSvc.xml` 誤判舊庫 DB2）**。鐵則不變：entity/SQL 一律以 Oracle（`OracleDialect`/`OracleDriver`）＋**新 schema** 為準，**勿原樣沿用舊系統 SQL**（schema/表名改了、map-key 大小寫陷阱在）；舊源若殘留 DB2 方言（`FETCH FIRST`/`WITH UR` 等）照樣改寫。
- 舊系統路由為自製 `HttpDispatcher`/`@CallMethod`（非 Spring MVC）→ 各 action **重寫為 REST endpoint** + service/repository，非直接搬移。

## 2. 分層
**Controller(REST) / Service / Repository**；**DTO 與 Entity 分離**。

## 3. JPA 慣例（✅ B2 確認）
- **Entity**：`jakarta.persistence`；常用 `@Entity/@Table/@Column/@Id/@EmbeddedId/@Embeddable/@IdClass`。**主鍵多為複合鍵/業務鍵**（`@EmbeddedId`/`@IdClass`），少數 `@GeneratedValue(strategy=SEQUENCE)`。
- **Repository**：以 `JpaRepository` 為主，**大量 `@Query(nativeQuery=true)`**；修改型用 `@Modifying`；少數自訂 interface + impl 以 `EntityManager` 拼 native SQL。**未用 Specification。**
- **DB**：Oracle（`org.hibernate.dialect.OracleDialect`、`oracle.jdbc.OracleDriver`）。
- **交易**：主要放 service 層；修改型 repository 方法也常直接標。⚠️ 既有混用 `jakarta.transaction.Transactional` 與 `org.springframework.transaction.annotation.Transactional` → **新程式碼一律用 Spring 版 `@Transactional`、放 service 層。**
- **Entity↔DTO**：既有混用 MapStruct / 自寫 `DTOMapper`(反射) / `ObjectMapper.convertValue()` / 手寫轉換 → **新程式碼優先 MapStruct（`@Mapper(componentModel="spring")`）。**

## 4. 設定檔
- 用 **`.properties`**（非 yaml），依 profile：`application-{local,ut,uat,prod}.properties`，預設 `spring.profiles.active=local`。
- **機密外部化**：local/ut 可內含 datasource；uat/prod 由環境變數/容器注入，**勿提交帳密**。

## 5. API 橫切慣例（✅ B3 確認）
- **統一回應格式**：所有 API 回傳 `EPROResponse<T>`（欄位 `code` / `message` / `data`），成功與錯誤皆同格式（成功見 `BaseController`）。
- **全域例外處理**：`@ControllerAdvice`（`CommonErrorHandler`）集中處理 —— `EPROApiException`、`MethodArgumentNotValidException`、`Exception`，及 DB/交易例外（`TransactionSystemException`/`DataIntegrityViolationException`/`JpaSystemException`）→ 轉 `EPROResponse`。**沿用此模式，勿在 controller 各自 try-catch。**（注意既有用 `@ControllerAdvice` 而非 `@RestControllerAdvice`，保持一致。）
- **驗證**：controller 對 `@RequestBody` 標 `@Valid`/`@Validated`；DTO 用 `@NotBlank`/`@Pattern` 等與自訂驗證（`@ValidDate`/`@CustomDigits`）；巢狀/集合 `List<@NotNull @Valid ...>`；錯誤經全域處理轉統一格式；訊息語系由 `LocaleValidatorConfig` 強制英文。
- **認證/授權（已定案：Spring Security + JWT，STATELESS）**：
  - `SessionCreationPolicy.STATELESS`；filter 鏈 `JwtTokenAuthenticationFilter`（讀 `Authorization: Bearer`、驗 EPRO token → 塞 `SecurityContextHolder`、失敗回統一錯誤 JSON）→ `APIAuthorizationFilter`（依 `roleId`+`apiPath` 查 DB 權限表）。
  - `JwtUtil`：建立/驗證 EPRO JWT、驗 MIS token、取目前登入者。
  - 登入流程驗證**外部 MIS session key**（`misSessionVerifier`），非傳統 `HttpSession`。
  - → **前端須在 HTTP interceptor 附 `Authorization: Bearer <JWT>`。**
- **CORS**：設定在 `SecurityConfig`（非獨立 WebMvcConfig），兩條 chain 皆套用，`allowCredentials(true)` + `setExposedHeaders(...)`。⚠️ 既有為**全開**（`allowedOriginPatterns/Methods/Headers = "*"`）→ **正式環境應收斂 `allowedOrigins`**。
- **OpenAPI（契約優先）**：README 要求但**實作未落地**（pom 無 `springdoc`、無 `@OpenAPIDefinition`/`@Operation`）→ **建議導入 `springdoc-openapi`（從 Nexus 取）** 補上合約。

## 6. c0 評分頁鏡像 i0 — 自走硬規則（goal-mode 必讀）
> 補完剩餘 30%（企金評分 c0 controller + 撥貸 0920）的強制規則。違反任一條 = 該頁**不算完成**。亦見 `docs/archive/runbook-30pct.md`（順序/閘門/煞車；🗄 已凍結——30% 結案，狀態以 `docs/feature-inventory.md` 為準）。

### 6.1 鏡像原則（自足，不耦合 i0）
- 每個 c0 頁 = **新增一套自足 feature**（controller + service(+interface) + DTO package），鏡像對應 i0。
- **禁止**：注入/委派 i0 service、reflection（`java.lang.reflect`/`getDeclaredMethod`/`setAccessible`）、呼叫 i0 private method、在 c0 檔 import `*.individual.*`。需要 i0 邏輯 → **複製進 c0**（接受重複，不抽共用）。
- **唯一例外（2026-06-05 核准，限「共用計分引擎」）**：c0 calc **可注入 `individual.FunctionService` 並呼叫 `funcGetRate`/`funcGetCollateralTotalScore`**（含其 function DTO）。理由：它是**共用 compute 引擎**（既有企金頁 `00114 CsuCollateralAssessment` 已注入它在用）、為計分**單一真相**；若複製進 c0 等於**分叉算法、違反 §6.6**。**僅 `service.individual.FunctionService` 一支**例外，其餘 i0 page service / page DTO 仍一律禁止耦合。`verify-c0.py` 已對此 allowlist（`ALLOW_SHARED_FUNC`）。
- **`service.common.*` 共用基礎建設＝直接可用（非例外）**：如 `commonFunctionService`（`service.common.impl.FunctionServiceImpl`，例 `funcIsStaffLoan`）是個金/企金**共用 common 層、非 `individual`**，可直接注入使用，**不算 §6.1 的 i0 耦合**（`verify-c0` 只擋 `.individual.`）。⚠️ 注意它與上條 `service.individual.FunctionServiceImpl.funcGetRate`（在 individual 底下、需例外）**不同支**，勿混淆。
- **不得修改**任何既有 i0 / 既有 `Csu*` / `CsuCreditInvestigationServiceImpl` 的 G/F 分流。**只新增**。

### 6.2 命名與契約
- endpoint = `epl-{verb}-c0-{feature}`（鏡像 i0 的 `-i0-` 改 `-c0-`）；先翻既有 c0 controller 確認慣例。
- DTO **只改 class/package 名**；`@JsonProperty`/欄位名與 i0 **完全相同**（前端契約不可變）。
- export 模板沿用 i0 實際存在路徑（如 `EPROI001xx`），**不**硬改成 `EPROC001xx`。

### 6.3 checkpoint（最易錯）
- c0 一律寫 `TBCheckPointsCs/Cu`（**禁** `Is/Iu`），欄位 `EPROC001xx`。
- CS/CU 判斷用 **`lonAttribute + secureAttribute`**（同 `CsuCreditInvestigationServiceImpl`/`CsuMainBorrowerInfoServiceImpl`），**不要**用 i0 的 `secureAttribute=="S"` 單條件；寫法用既有 `DynamicUpdateSqlUtils`。
- 值規則照 i0：`isFinish=true→"N"`、`false→"Y"`。
- **跨頁副作用逐字照 i0，不自創**：已知 `00119` save 會 seed `00120="Y"`；但 `00116` save **不** seed `00117`（GI/FI 不對稱）。其餘頁**先確認 i0 實際行為再寫**。
- i0 若有「info 端點也寫 DB」的 side-effect（如 `00117` 的 `info-financial-business` 算 ratios 寫回 GI）→ **照鏡像，別簡化成純讀**。

### 6.4 共用 service 的 URI 分支（00117/00120）
- i0 `FinancialStaffServiceImpl` 用 URI 同時服務 `00117`(`-financial-staff`→`EPROI00117`) 與 `00120`(`-financial-evaluation-staff-fi`→`EPROI00120`）。c0 **每頁只取自己那條分支**，不得夾帶另一頁的分支或 checkpoint。

### 6.5 每頁完成判準（Definition of Done）
1. `python scripts/verify-c0.py --git` **通過**（strict-UTF-8 + **No BOM**、無禁用樣式、`-c0-` 命名、**未修改既有 i0/`Csu*` 檔**；`FunctionService` 共用計分引擎為核准例外）。
2. `mvn clean package "-Dmaven.test.skip=true"` 綠（在獨立終端機；Codex 勿自跑長 build）。
3. 回填 `docs/legacy/page-mapping.md` §2B 狀態 + 待整合驗證清單。

### 6.6 ⚠️ 遇到判斷題就停（goal-mode 的煞車）
以下情況**不准自行決定、不准猜**，停下產出報告等人審：
- 計分/算法邏輯需改動或無法 1:1 鏡像（尤其 `00118` Corporate Scorecard：邏輯散在 `CsuCreditEvalAndCreditDecisionServiceImpl`，**嚴禁另寫一套或分叉算法**）。
- **無 i0 可鏡像**的頁（`EPROISU0920` 撥貸）→ 先出「舊鏈路盤點 + 計畫」等人審，**不得直接開做**。
- 任何需要改既有 i0/`Csu*`、跨頁 checkpoint 副作用不確定、或 DTO 契約要變的情況。

### 6.7 ⚠️ 撥貸機械修正（scoped 授權，2026-06-05）
舊系統比對（`docs/disbursement/disbursement-triage.md`）後，**經人核可**：Codex **得**編輯撥貸 service（`DataInputServiceImpl` / `SummaryServiceImpl` / `FunctionServiceImpl` T24 組檔）——**僅限 `disbursement-triage.md` §7「機械修正 allowlist」逐項**。鐵則：
- **只做 allowlist 內項目**；P0-1 stub 實作、`T24_COMPANY`(B8/C9) 值來源、匯率源 ID、檢核嚴格度、架構/精度等**判斷題一律 §6.6 升級、不得在此順手改**。
- **舊行為為準且須引述**：每項修正引 `legacy-extract` 舊 spec 的 `file:line` 證明「舊明確正確且非移除依賴」；**不臆測、不 gold-plate、不改回刻意演進（如 KHR）**。
- **逐項閘門**：一項（或一組同類）一個 commit；`mvn package` 綠；**先回報 diff + 舊 spec 依據供人審，過了才推產品 repo**；不得 scope 外擴（只動該 method）。
- 來源不可得 / 一有歧義 → 立即轉 §6.6 升級，不硬修。

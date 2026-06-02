# AGENTS.md — 後端規範（Java 17 + Spring Boot 3.3.0）

> 本檔為 `backend/` 專屬規範，**與 repo 根 [`../AGENTS.md`](../AGENTS.md) 的共用規則（離線 mirror / 版本鎖定 / 策略 / 工作流程）一起適用**。

## 1. 版本與遷移
- **Spring Boot 3.3.0**（由 `spring-boot-starter-parent` 帶入，無額外 BOM）；Java 17；環境 Maven 3.9.16。
- 舊專案 Java 8 → 17 時做 **`javax.* → jakarta.*`** 全面遷移（servlet/persistence/validation），可用 OpenRewrite recipe（亦走內網 Nexus）。**既有重構後端已是 jakarta**，可直接當目標慣例。

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

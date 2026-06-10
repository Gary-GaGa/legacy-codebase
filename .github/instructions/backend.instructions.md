---
applyTo: "backend/**"
---
# 後端（Spring Boot 3.3.0 / Java 17 / Oracle）

> 與 repo-wide `.github/copilot-instructions.md` 的硬規則一起適用。詳見 `backend/AGENTS.md`。

- `jakarta.*`（非 javax）。分層 Controller / Service / Repository，**DTO ≠ Entity**。
- JPA：`JpaRepository` + 大量 `@Query(nativeQuery=true)`（修改型加 `@Modifying`）；主鍵多複合鍵（`@EmbeddedId`/`@IdClass`）；**未用 Specification**。
- 交易用 Spring `@Transactional`（service 層）；DTO 轉換新碼**優先 MapStruct**（`componentModel="spring"`）。設定用 `.properties`/profile，**機密外部化勿提交**。
- API 統一回 `EPROResponse<code,message,data>`；全域 `@ControllerAdvice`(`CommonErrorHandler`) 處理例外，**勿各自 try-catch**；`@Valid` 驗證 `@RequestBody`。
- 認證 **Spring Security + JWT（STATELESS）**：filter `JwtTokenAuthenticationFilter` → `APIAuthorizationFilter`（roleId+apiPath 查 DB）；前端附 `Authorization: Bearer`。CORS 既有全開→正式環境收斂；OpenAPI 未落地→建議補 springdoc。

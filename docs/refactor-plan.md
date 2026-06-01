# 重構計畫：全端 → 前後端分離

> 全端（Java 8 + JSP）→ 後端 Java 17 + Spring Boot 3.x／前端 Angular 14.x。
> 實作由 Codex CLI / GitHub Copilot 執行（不使用 Claude 產品）；本 repo 作為規劃、設定樣板與黃金樣板來源。

## 背景與硬限制
- **套件來源一律走內網 Nexus，禁止連公開 registry。**
  - Maven：`http://88.8.70.216:8081/repository/maven-public/`
  - npm：`http://88.8.70.216:8081/repository/npm-all/`
  - 設定樣板見 `docs/env/`。
- 既有資產：已有重構後的前後端可參考。後端架構大致定案、DB 採 **JPA**；前端 UI 為 **企業自製元件庫**，需從中萃取樣板。

## 目標技術版本
| 範疇 | 舊 | 新（目標） |
|---|---|---|
| 後端語言 | Java 8 | Java 17 |
| 後端框架 | （待確認） | Spring Boot 3.x |
| DB 存取 | （待確認） | Spring Data JPA |
| 前端 | JSP / JSTL | Angular 14.x |
| UI 元件 | JSP 版型 | 企業自製 Angular 元件庫 |

## 核心策略
| 原則 | 說明 |
|---|---|
| 絞殺者模式 (Strangler Fig) | 前置 reverse proxy，逐頁把流量從舊 JSP 切到新 Angular + API，可隨時上線/回退 |
| 契約優先 (Contract-first) | 後端先以 OpenAPI 定義 API 當合約，前後端平行開發 |
| DB schema 先凍結 | 初期不動資料表，新後端先「包住」現有資料存取 |
| 垂直切片 (Vertical slice) | 第一個里程碑只打通一條完整功能（畫面→API→DB），驗證架構與離線環境後再規模化 |

## 階段里程碑
| Phase | 內容 | 完成定義 |
|---|---|---|
| 0 | 離線環境就緒 | 前後端空骨架在斷網下可 build（`mvn -o package` / `npm ci --offline` + `ng build`） |
| 1 | 後端一條垂直切片 + OpenAPI 合約 | 一個 API 端到端打通到 DB |
| 2 | 前端黃金樣板頁面 | 一個畫面串通 Phase 1 API |
| 3 | 批次遷移頁面（依 JSP 盤點清單） | proxy 逐條把路由切到 Angular |
| 4 | 下線 JSP | 舊路由清空、移除舊容器 |

## 後端要點（Java 8 → 17 + Spring Boot 3）
- **`javax.* → jakarta.*` 命名空間遷移**（Spring Boot 3 強制；servlet/persistence/validation 全換）。可用 OpenRewrite recipe 自動化（recipe 也須走內網 Nexus）。
- Java 8 → 17 移除/變更 API 收尾。
- 分層 Controller(REST)→Service→Repository；DTO 與 Entity 分離；**JPA 慣例對齊既有重構後端**。
- 認證由 server-session 改為 token（JWT）或 cookie+CSRF（待決，見 decisions）。
- 產出 OpenAPI 規格當前端合約。

## 前端要點（JSP → Angular 14）
1. **盤點 JSP**：列出所有頁面、共用版型、JSTL/EL、表單與後端耦合點 →「頁面↔功能↔API」對照表。
2. **萃取黃金樣板**：從既有前端抽出專案結構、**企業自製元件庫用法**、HTTP service、interceptor、routing、表單、錯誤處理、build 設定。
3. **JSP→Angular 對應規則表**：
   | JSP | Angular 14 |
   |---|---|
   | `.jsp` 頁面 | component + route |
   | Tiles / include 版型 | layout component + `<router-outlet>` |
   | `<c:forEach>` | `*ngFor` |
   | `<c:if>`/`<c:choose>` | `*ngIf`/`ngSwitch` |
   | `${expr}` (EL) | 插值 / property binding |
   | form submit | Reactive Forms + `HttpClient` |
   | server-side 驗證訊息 | form validators + API error 對應 |
   | session 屬性 | state service / token |
4. **黃金頁面**：做一個完整 CRUD（清單+詳情+表單+API+驗證+錯誤處理）當藍本，其餘頁面複製此模式。

## 過渡期整合
- reverse proxy 路由：`/legacy/**`→舊 JSP、`/app/**`→Angular、`/api/**`→新後端。
- 認證橋接：新舊並存期間身分需兩邊皆成立（共享 cookie / SSO / 後端驗 token）。
- 盡量同源（透過 proxy）以降低 CORS 複雜度。

## 主要風險
- 內網 mirror 缺套件 → Phase 0 未過就硬寫會反覆卡關。
- `javax→jakarta` 漏改 → 編譯/執行期才爆。
- Angular 14 與 Node 版本不匹配。
- 認證模式由 session 改 token，過渡期橋接未設計好。

## 給 Codex CLI / Copilot 的落地方式
於 repo 放指令檔讓工具自動讀取：`AGENTS.md`（Codex）、`.github/copilot-instructions.md`（Copilot）。內容涵蓋：離線 mirror 設定、後端 JPA 規範、前端企業元件庫對應表、版本鎖定。每個頁面/API 任務 = 「複製黃金樣板 + 套用對應規則」。

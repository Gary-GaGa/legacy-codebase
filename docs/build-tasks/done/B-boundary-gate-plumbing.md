# Build Task — 把驗收邊界「閘門 1 / 4 / 5」接進產品後端（gate plumbing）

> 載具：Codex（後端專案）。把 [`../vision-pipeline.md`](../../process/vision-pipeline.md) §8 漸進落地的第 1–2 步變**可執行**；
> 第一個對象 = `EPROC00118` 的 boundary bundle（[`../golden-template/boundary-bundle/EPROC00118/`](../../specs/srs/README.md)）。
> 這是「示範接一次 → 之後每頁照接」的 plumbing 頁卡，**不是再補一個業務頁**。

## 0. 前置事實（直接決定做法，先讀）
- Spring Boot 3.3 / Java 17 / Maven / **套件一律走內網 Nexus**。
- 端點 RPC 式 `epl-{verb}`、統一 `EPROResponse<code,message,data>`、Spring Security + JWT **STATELESS**。
- ⚠️ **既有測試與 main 不同步**（baseline 用 `-Dmaven.test.skip=true`）→ 新閘門測試**不可混進壞掉的 test tree**：放**獨立 source set / 獨立 module / 純 script**，別讓壞 baseline 擋住。
- ⚠️ **大量 Oracle `nativeQuery`** → H2 跑不動 → in-loop 驗收要 **Oracle 相容 DB（Testcontainers `gvenzl/oracle-xe`）** 或對 **dev/uat**。

## 1. 閘門 1 — OpenAPI 契約 snapshot（code-first）
目標：springdoc 從**既有 controller** 生 OpenAPI → 與 bundle 的 `openapi.yaml` snapshot 比對；契約被改＝必須有意更新 snapshot，否則 FAIL。

1. **加依賴（Nexus）**：`org.springdoc:springdoc-openapi-starter-webmvc-ui:2.6.x`（對 Spring Boot 3.3；版本以 Nexus 有的為準）。
2. **生成 spec（避開壞 test tree → 不走 JUnit）**：
   - 首選 `springdoc-openapi-maven-plugin`：bind `integration-test` + `spring-boot:start/stop` → dump `target/openapi.json`。
   - 或手動：以 test profile（關 JWT filter）起 app → `curl /v3/api-docs.yaml > target/openapi.yaml`。
3. **snapshot 比對（deterministic gate）**：
   - 從整體 spec 切出 00118 的 4 條 path + schema，normalize 後與 `boundary-bundle/EPROC00118/openapi.yaml` diff（欄位/型別/required/enum/狀態碼）。
   - 用小 script（Python / `yq`）比，**不寫成 JUnit**（避開壞 baseline）。mismatch → exit 1。
4. **更新流程**：契約有意改 → 重生 → 覆寫 snapshot → code review（差異要看得見）。

注意：
- DTO 是手寫 → springdoc 靠註解/反射推 schema；`@JsonProperty` 要齊（**這跟「DTO 欄位 1:1 鏡像 i0」是同一件事**，順手一起顧）。
- 北極星是 contract-first（從 `openapi.yaml` **生** DTO、零 drift）；起步先 code-first + snapshot。

## 2. 閘門 4 — 一條 QA case 落成可跑驗收測試（PoC）
對象：`qa-cases.md` 的 **QA3**（save CS、`isFinish=true` → `TB_CHECK_POINTS_CS.EPROC00118='N'`、CU 表未寫）。

**in-loop 版（推薦先做這一條當證明）：**
1. **測試 DB**：Testcontainers `gvenzl/oracle-xe`（跑得動 nativeQuery）；用 `boundary-bundle/EPROC00118/schema.sql` 當建表來源（Flyway 或啟動 script 建 `TB_CORP_SCRCARD` / `TB_CHECK_POINTS_CS` / `TB_CHECK_POINTS_CU` / `TB_SCORE_CARD_PARAM_DETAIL`）。
2. **auth**：test profile 放行 JWT（注入測試 token，或 test `SecurityConfig` permitAll）——**只限 test**。
3. **測試本體（獨立 source set，不靠壞 baseline）**：
   - Given seed 一筆 CS 屬性案件；When POST `/epl-save-c0-corporateScorecard`（payload `isFinish=true`、CS 的 `lonAttribute+secureAttribute`）；Then 查 `TB_CHECK_POINTS_CS` 該列 `EPROC00118='N'` 且 `TB_CHECK_POINTS_CU` 未被寫。
4. 標 `covers: R3` → 進覆蓋對表（閘門 5）。

**務實備案**：Testcontainers Oracle 一時起不來 → 先把這條對 **dev/uat** 跑（符合既有「待整合驗證」現實），但標 `out-of-loop`；北極星仍是 in-loop。

## 3. 閘門 5 — 覆蓋率對表（順手，純 script）
- 掃 `spec.md` 的 `Rn` 與 `qa-cases.md` 的 `covers: Rn`：每個 `R` 至少一條 case，否則 FAIL。
- `@PENDING` case（如 R8）允許存在但**必須存在**（escalation 顯性化）。
- 可考慮併進 `scripts/`（與 `verify-c0.py` 同層），未來每頁通用。

## 4. 完成判準（這張 plumbing 頁卡）
- 閘門 1 script 能 dump + diff 00118 契約、綠；**故意改一個欄位 → FAIL**（證明擋得住）。
- 閘門 4 QA3 在 Testcontainers（或 dev/uat）跑綠；**故意把 checkpoint 寫成 CU 或值寫錯 → FAIL**。
- 閘門 5 對表 script 綠（R1–R7 有 case、R8 為 `@PENDING`）。
- 回填 `vision-pipeline.md §8`：從「計畫」變「已落地一頁」。

## 5. ⚠️ 要先解的前置（誠實，可能各自一張 infra 票）
- **baseline 測試修復 / 隔離**：否則新測試與壞 test tree 混難跑。最小解＝新閘門測試放**獨立 source set / module / script**；長期應把 baseline 修綠。
- **Testcontainers + Nexus + Oracle image**：確認內網 registry 拉得到 `gvenzl/oracle-xe`（或公司鏡像）；CI runner 要能跑 Docker。
- **JWT test 放行**：只在 test profile，**絕不**進正式 profile（同 SETUP-codex 的 auth-bypass 紀律：只限本機/test、不 commit 進正式）。

## 6. 範圍界線
- 本頁只示範**接一次**（00118）；接通後其它頁是「複製 boundary bundle + 重跑同一套 script」。
- **不**在本頁修 00118 業務邏輯（那是 `EPROC00118-corporate-scorecard.md`）；本頁只負責「邊界怎麼變成可跑的閘門」。

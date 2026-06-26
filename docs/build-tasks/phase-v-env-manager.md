# Build Task — Phase V 對 local-env manager 的消費（profile=epro）

> **本檔＝Phase V 消費者註記**；通用工具權威＝**`docs/process/local-env-manager.md`**（介面/descriptor/鐵則/materialize 殼都在那、勿在此複寫）。Phase V 只是其消費者之一。

## Phase V 怎麼用 local-env manager
- **L1 起停＝直接用** `tools/local-env.ps1 -Action up/down`（profile=epro：BE 5500 spring-boot:run / FE 4200 ng serve）。
- **L2 API harness**（`phase-v-api-selfverify-harness.md`）：吃 `-BaseUrl <descriptor.services.be.url>`、**不起停**；打不到→回 `ENV_NOT_READY`（與 test FAIL 區分）。
- **L3 FE Playwright（未來）**：`baseURL = descriptor.services.fe.url`。
- **JWT/授權不在 env manager**：per-case role/JWT（runtime-bug RB-2）在 harness/runner 這層。

## runner 組合（唯一 lifecycle+test 相遇處）
```
tools/phase-v-run.ps1：
  try {
    tools/local-env.ps1 -Action up -Profile epro      # 起+wait-ready（含 pre-flight，見通用契約）
    $d = read local-env descriptor (JSON)
    login (env 帳密) → 各 role JWT                     # auth 在這層，不在 env manager
    tools/phase-v-api-selfverify.ps1 -BaseUrl $d.services.be.url -ManifestPath docs/build-tasks/phase-v-api-selfverify-harness-v1.json
  } finally {
    tools/local-env.ps1 -Action down                  # 成敗都收，雙保險 teardown
  }
```

## 派工順序（owner 定：分兩次、先確認 env manager 正常）
1. **先** materialize + 自測 **通用 local-env manager**（殼＝`process/local-env-manager.md §7`）→ 回報自測 a~e 過＝正常。
2. **後** harness v1.1：改吃 `-BaseUrl`、修 RB-1/3、per-case role(RB-2)、RI-2 消歧(RB-4)，加 `phase-v-run.ps1` 組合（殼＝`done/phase-v-api-selfverify-runtime-bugs.md`，已完成歸檔）。

## 關聯
- 通用工具＝`process/local-env-manager.md`（權威）；強健性鐵則脈絡＝`local-phase-v-bringup.md §2.0`；harness＝`phase-v-api-selfverify-harness.md` + runtime-bug 卡。

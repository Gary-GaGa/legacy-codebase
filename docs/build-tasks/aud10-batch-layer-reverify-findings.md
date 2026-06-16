# AUD10 batch layer reverify findings

日期：2026-06-16

範圍：唯讀碼驗 `backend/` 新後端是否存在 legacy `EPROZ0_B001` 至 `EPROZ0_B008` 等價物。結論只採用程式碼與設定檔 `file:line` 證據，不以 inventory 或頁面 mapping 作為等價證據。

方法：`rg` 在本環境不可用，改用 PowerShell `Select-String` 做 grep 型搜尋。未執行 build，未修改後端程式碼。

## 給人審清單

| 優先 | 項目 | 本次判定 | 人審重點 |
|---|---|---|---|
| P0 | legacy B005 匯率排程 | `app 碼缺`：有 inline 匯率 API 更新路徑，但未找到 scheduled batch 等價物 | 若外部排程已改由 ops 觸發，需補 ops 配置證據；否則 batch-layer parity 未完成 |
| P0 | legacy B006 放款結果檔 async | `FOUND`：新 `EPROZ0B006` 為 active scheduled result-file processor | 撥貸結果回寫路徑未因批次層缺失而中斷 |
| P0 | legacy B007 SFTP | `FOUND`：新 `EPROZ0B004` 負責排程下載/刪除 T24 結果檔，授權流程 inline 上傳 T24 檔 | 注意 legacy B007 對映到新 B004，不是新 B007 |
| P1 | legacy B008 搬動 DB LOG | `UNFOUND` | 需人審確認是否已改由 logrotate、job scheduler、平台檔案歸檔或其他 ops 機制處理 |
| P1 | 新 `EPROZ0B005` mail sender | 非 legacy B005 等價物，且 `@Scheduled` 被註解 | 若 mail queue 後送是必要批次，需另列 gap；不得拿它抵 legacy B005 匯率排程 |

## 新後端批次入口盤點

| 類型 | file:line | 證據 |
|---|---|---|
| scheduling enabled | `backend/src/main/java/khd/svc/epro/config/SchedulerConfig.java:9` | `@Configuration` |
| scheduling enabled | `backend/src/main/java/khd/svc/epro/config/SchedulerConfig.java:10` | `@EnableScheduling` |
| scheduling config | `backend/src/main/java/khd/svc/epro/config/SchedulerConfig.java:11` | `implements SchedulingConfigurer` |
| scheduler thread pool | `backend/src/main/java/khd/svc/epro/config/SchedulerConfig.java:15`-`20` | `ThreadPoolTaskScheduler` pool size 10, registered through `ScheduledTaskRegistrar` |
| package | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:1` | `khd.svc.epro.task.controller` |
| active scheduled B001 | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:42`-`45` | 匯入柬埔寨單位檔資料，`@Scheduled("${scheduled.time.EPROZ0B001:0 0 6 * * ?}")` |
| active scheduled B002 | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:80`-`84` | 匯入柬埔寨人事檔資料，`@Scheduled("${scheduled.time.EPROZ0B002:0 10 6 * * ?}")` |
| active scheduled B003 | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:119`-`123` | 批次刪除下載檔案，`@Scheduled("${scheduled.time.EPROZ0B003:0 30 6 * * ?}")` |
| active scheduled B004 | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:156`-`160` | 下載交易結果檔批次，`@Scheduled("${scheduled.time.EPROZ0B004:0 * 8-19 * * ?}")` |
| inactive B005 method | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:193`-`198` | 發送 Mail；`@Scheduled` lines are commented out |
| active scheduled B006 | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:214`-`218` | 交易結果處理批次，`@Scheduled("${scheduled.time.EPROZ0B006:0 */2 8-19 * * ?}")` |
| active scheduled B007 | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:253`-`257` | 自動結案批次，`@Scheduled("${scheduled.time.EPROZ0B007:0 20 6 * * ?}")` |
| runtime close switch | `backend/src/main/java/khd/svc/epro/task/controller/BaseTask.java:20`-`33` | `scheduled.closed.list` 可讓 task 直接 return；local config 關閉全部 B001-B007 |
| schedule config | `backend/src/main/resources/config/application-prod.properties:65`-`71` | prod 設定 B001-B007 cron；未見 B008 |
| schedule config | `backend/src/main/resources/config/application-uat.properties:66`-`72` | uat 設定 B001-B007 cron；未見 B008 |
| schedule config | `backend/src/main/resources/config/application-ut.properties:79`-`85` | ut 設定 B001-B007 cron；未見 B008 |
| local close config | `backend/src/main/resources/config/application-local.properties:94`-`100` | local 設定 B001-B007 cron |
| local close config | `backend/src/main/resources/config/application-local.properties:108` | local `scheduled.closed.list=EPROZ0B001;...;EPROZ0B007` |

未找到的新後端入口：

| 搜尋項 | 判定 |
|---|---|
| `ApplicationRunner` / `CommandLineRunner` | 未找到批次入口；僅 `backend/src/main/java/khd/svc/epro/KhdSvcEproApplication.java:13` 為 `SpringApplication.run(...)` |
| `quartz` / `spring-batch` / `spring-boot-starter-quartz` / `spring-boot-starter-batch` | `backend/pom.xml` 未找到 |
| `batch` / `job` / `scheduler` package | 未找到同名 package；實際批次集中在 `khd.svc.epro.task.*` |
| `EPROZ0B008` / `EPROZ0_B008` in new backend | 未找到 |

## B001-B008 對映表

| legacy batch | legacy 職責證據 | 新後端等價物證據 | 判定 | 性質 |
|---|---|---|---|---|
| B001 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B001.java:74` defines insert SQL, `:77` update SQL, `:144` update, `:146` insert, `:171` error text points to `TB_BRANCH_PROFILE` | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:42`-`:45` active schedule；`backend/src/main/java/khd/svc/epro/task/service/impl/EPROZ0B001ServiceImpl.java:98`-`:116` imports source file；`:122`-`:153` maps to `TBBranchProfileEntity`；`:272`-`:274` saves；`backend/src/main/java/khd/svc/epro/entity/TBBranchProfileEntity.java:12` maps `TB_BRANCH_PROFILE` | `FOUND` | app 碼存在 |
| B002 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B002.java:74` delete SQL, `:77` insert SQL, `:147` delete, `:149` insert, `:173` error text points to `TB_EMP_PROFILE` | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:80`-`:84` active schedule；`backend/src/main/java/khd/svc/epro/task/service/impl/EPROZ0B002ServiceImpl.java:92`-`:109` imports source file；`:124`-`:132` maps and saves `TBEmpProfileEntity`；`:251`-`:254` delete then save；`backend/src/main/java/khd/svc/epro/entity/TBEmpProfileEntity.java:18` maps `TB_EMP_PROFILE` | `FOUND` | app 碼存在 |
| B003 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B003.java:32`-`:33` imports app-history/close-reason entities；`:103`-`:109` prepares DB updates；`:160`-`:168` sets `CASE_PROGRESS=C1`, `IS_AUTODIS`, close reason `C11;`；`:170`-`:173` inserts app history `C1` | 新等價為新 B007：`backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:253`-`:257` active schedule；`backend/src/main/java/khd/svc/epro/task/service/impl/EPROZ0B007ServiceImpl.java:85`-`:102` builds close lists；`:220`-`:237`, `:248`-`:287`, `:302`-`:314` collect candidates；`:328`-`:381` updates `TBLonSummaryInfo`, inserts `TBCloReason`, inserts `TBAppHistory` | `FOUND` | app 碼存在；legacy B003 對映到新 B007 |
| B004 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B004.java:23` says delete downloaded files；`:48` report root；`:51` `temp/`；`:64`-`:67` lists delete path；`:79` deletes file | 新等價為新 B003：`backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:119`-`:123` active schedule；`backend/src/main/java/khd/svc/epro/task/service/impl/EPROZ0B003ServiceImpl.java:84`-`:92` obtains delete path and calls `fileService.deleteAllFilesInFolder`；`backend/src/main/java/khd/svc/epro/service/model/impl/FileServiceImpl.java:520`-`:559` deletes folder files | `FOUND` | app 碼存在；legacy B004 對映到新 B003 |
| B005 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B005.java:20`-`:22` imports `KH_B_FTR37001` types；`:65` adds `ComsServiceMsgId.KH_B_FTR37001`；`:82`-`:91` builds request and calls exchange-rate API；`:121` inserts exchange-rate row | 未找到 scheduled exchange-rate batch。只找到 inline 路徑：`backend/src/main/java/khd/svc/epro/controller/common/FunctionController.java:183`-`:186` exposes `/funcGetExchangeRate`；`backend/src/main/java/khd/svc/epro/service/common/impl/FunctionServiceImpl.java:1157`-`:1218` calls `KH-B-FTR37001` and persists `TBExchangeRateEntity`；`backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java:2313`-`:2324` authorize flow calls `funcGetExchangeRate` before T24 file generation。新 `EPROZ0B005` 是 mail sender：`backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:193`-`:198` has commented `@Scheduled`；`backend/src/main/java/khd/svc/epro/task/service/impl/EPROZ0B005ServiceImpl.java:45`-`:61` reads notification rows；`:76`-`:92` calls MIS mail API | `PARTIAL / GAP` | `app 碼缺`：legacy「排程匯率匯入」等價物缺；目前只坐實 inline/request-driven 匯率更新 |
| B006 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B006.java:44` says import transaction result to DB；`:69` lists message/reference/status/error/application fields；`:241`-`:253` inserts `TB_MESS_RECORD`, updates case, app history, close reason；`:264` complete path `TRANRS/`；`:475`-`:491` writes `TB_MESS_BATCH_RECORD` | `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:214`-`:218` active schedule；`backend/src/main/java/khd/svc/epro/task/service/impl/EPROZ0B006ServiceImpl.java:126`-`:164` reads result files and imports txt；`:171`-`:186` checks application and case progress；`:191`-`:223` saves `TBMessRecordEntity`, updates summary, app history, close reason；`:403`-`:438` moves fail/complete files and writes `TBMessBatchRecordEntity`；`:456`-`:535` sends notification mail | `FOUND` | app 碼存在；P0 放款結果檔 async 未缺 |
| B007 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B007.java:27` says SFTP transaction-file download to local；`:55`-`:68` reads SFTP config；`:93` downloads T24 file；`:96` deletes T24 file；`:118`-`:123`, `:163`-`:172` download implementations；`:143`-`:148`, `:187`-`:213` delete implementations | 新等價分拆：下載/刪除在新 B004，`backend/src/main/java/khd/svc/epro/task/controller/TaskController.java:156`-`:160` active schedule；`backend/src/main/java/khd/svc/epro/task/service/impl/EPROZ0B004ServiceImpl.java:93`-`:107` downloads list and deletes T24 files；`backend/src/main/java/khd/svc/epro/thirdparty/sftp/impl/SftpApiServiceImpl.java:118`-`:128` download list；`:210`-`:219` delete；上傳 T24 檔在授權流程 inline，`backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java:2332`-`:2344` builds file, uploads, records SFTP upload；`backend/src/main/java/khd/svc/epro/thirdparty/sftp/impl/SftpApiServiceImpl.java:75`-`:82` upload path；`:321`-`:323` actual SFTP put | `FOUND` | app 碼存在；legacy B007 對映到新 B004 + 授權 inline 上傳 |
| B008 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B008.java:25` says move DB LOG；`:53` `SECURITYPATH`；`:64`-`:80` derives `securityLog/yyyy` target path；`:89`-`:92` deletes source if target exists；`:120` scans DB log files | 新後端未找到 `EPROZ0B008`、`securityLog` DB LOG 搬移批次、相關 `@Scheduled` 或 config | `UNFOUND` | `UNFOUND`：不猜是否已改 ops；需補外部排程或平台歸檔證據 |

## 高優先結論

1. B005 匯率：新後端有 `FunctionServiceImpl.funcGetExchangeRate` inline 路徑，且授權流程會呼叫；但 legacy B005 是排程匯率匯入，未找到 active `@Scheduled` 等價物。除非人審能提供外部排程證據，否則本次判為 `app 碼缺`。
2. B006 放款結果檔 async：已坐實新後端 active scheduled 等價物，不屬於批次層缺口。
3. B007 SFTP：已坐實新後端等價物，但編號改為新 B004，且 upload/download 分拆到授權 inline + scheduled download/delete；不屬於批次層缺口。
4. B008 DB LOG 搬移：新後端 app/config 未找到。性質暫列 `UNFOUND`，不能直接推定為 app 缺口或 ops 已處理。

## 注意事項

- 新 `EPROZ0B005` 名稱會誤導：它是通知信後送，不是 legacy B005 匯率排程；而且 `TaskController.java:196`-`:197` 的 `@Scheduled` 目前被註解。
- legacy B003/B004/B007 的等價物在新後端重新編號，後續 audit 不應以 batch id 名稱直接判斷。
- 本文件未證明外部排程不存在；只證明在 repo 新後端 app code/config 內未找到 B005 排程匯率與 B008 DB LOG 搬移等價入口。

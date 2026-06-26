| id | role | fixture | endpoint | zh_TW | en_US | db | category | status | detail | dump |
|---|---:|---|---|---:|---:|---:|---|---|---|---|
| LT-1 | 101 | - | /epl-list-todolist | 1 | 1 | 1 | - | PASS | ok | - |
| LT-2 | 405 | - | /epl-list-casedistribution | 5 | 5 | 5 | - | PASS | ok | - |
| LT-3 | 403 | - | /epl-list-caseapplication | 0 | 0 | 0 | - | PASS | ok | - |
| LT-4 | 403 | - | /epl-list-deviation | 293 | 293 | 293 | - | PASS | ok | - |
| LT-5 | 403 | - | /epl-list-cancelreport | 10 | 10 | 10 | - | PASS | ok | - |
| RI-1 | 403 | <fixture-A 有revised-item> | /epl-case-query-reviseditem | - | - | row | - | PASS | API fields match DB row | - |
| RI-2 | 403 | <fixture-B 空revised-item> | /epl-case-query-reviseditem | - | - | row=0 options=9 | assertion | FAIL | data envelope missing required revisedType per EPROZ00800 QueryRevisedItemResponse | docs\verification\phase-v-api-selfverify-responses\RI-2-response.json |

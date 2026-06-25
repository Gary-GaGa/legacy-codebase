| id | endpoint | zh_TW | en_US | db | status | detail |
|---|---|---:|---:|---:|---|---|
| LT-1 | /epl-list-todolist | - | - | - | FAIL | HTTP 401 from /epl-list-todolist: {"code":"E405","message":"Access denied: You do not have permission to access this resource.","data":{}} |
| LT-2 | /epl-list-casedistribution | 0 | 0 | 0 | PASS | ok |
| LT-3 | /epl-list-caseapplication | 0 | 0 | 0 | PASS | ok |
| LT-4 | /epl-list-deviation | 293 | 293 | 293 | PASS | ok |
| LT-5 | /epl-list-cancelreport | 10 | 10 | 10 | PASS | ok |
| RI-1 | /epl-case-query-reviseditem | - | - | - | FAIL | Invalid JSON primitive: SP2-0734. |
| RI-2 | /epl-case-query-reviseditem | - | - | row=0 options=9 | FAIL | response missing revisedType |

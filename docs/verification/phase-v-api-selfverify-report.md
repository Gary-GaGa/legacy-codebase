| id | endpoint | zh_TW | en_US | db | status | detail |
|---|---|---:|---:|---:|---|---|
| LT-1 | /epl-list-todolist | 0 | 0 | 0 | PASS | ok |
| LT-2 | /epl-list-casedistribution | 5 | 5 | 5 | PASS | ok |
| LT-3 | /epl-list-caseapplication | - | - | - | FAIL | HTTP 401 from /epl-list-caseapplication: {"code":"E405","message":"Access denied: You do not have permission to access this resource.","data":{}} |
| LT-4 | /epl-list-deviation | - | - | - | FAIL | HTTP 401 from /epl-list-deviation: {"code":"E405","message":"Access denied: You do not have permission to access this resource.","data":{}} |
| LT-5 | /epl-list-cancelreport | - | - | - | FAIL | HTTP 401 from /epl-list-cancelreport: {"code":"E405","message":"Access denied: You do not have permission to access this resource.","data":{}} |
| RI-1 | /epl-case-query-reviseditem | - | - | - | FAIL | Invalid JSON primitive: SP2-0734. |
| RI-2 | /epl-case-query-reviseditem | - | - | row=0 options=9 | FAIL | response missing revisedType |

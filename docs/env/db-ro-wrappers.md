# DB 唯讀存取部署範本（agent 用；新舊兩庫皆 Oracle）

> **本檔＝範本，repo 永不放真實帳密**（CLAUDE.md §7）。政策＝`decisions.md` §三（2026-06-12）：agent 唯讀（新舊各一）、DML/DDL 一律產 SQL 人審、MCP 暫不導入。
> 放置：照下列各節複製到**開發機**對應位置；兩個 repo（產品/規劃）內都不放。

## 1. 環境變數（Windows 開發機）
位置二選一：使用者環境變數（`setx`），或 `%USERPROFILE%\.epro\db.env`（wrapper 內讀取；**此檔不在任何 repo 內**）。
```
EPRO_DB_NEW_RO_URL=host:port/service     # 新庫
EPRO_DB_NEW_RO_USER=epro_ro
EPRO_DB_NEW_RO_PASS=<secret>
EPRO_DB_OLD_RO_URL=host:port/service     # 舊庫
EPRO_DB_OLD_RO_USER=<old_ro_user>
EPRO_DB_OLD_RO_PASS=<secret>
```

## 2. wrapper ×2（放 `%USERPROFILE%\bin`，加入 PATH）
`db-new-ro.cmd`：
```bat
@echo off
sqlplus -S %EPRO_DB_NEW_RO_USER%/"%EPRO_DB_NEW_RO_PASS%"@%EPRO_DB_NEW_RO_URL% %*
```
`db-old-ro.cmd` 同理（OLD 三變數）。
- **agent 只准經這兩個 wrapper 碰 DB**——帳密不出現在 prompt/紀錄。
- 更安全的升級：改 **Oracle Wallet**（`/@tns_alias` 免明文密碼），wrapper 介面不變。

## 3. Codex 護欄（填進 `.codex/config.toml`，配 `codex/config-permissions.md`）
- `db-new-ro` / `db-old-ro` → **ask**（逐次核准）。
- `sqlplus`/`sql` **直呼不核准**——全走 wrapper（權限邊界單一）。
- agent 行為規則：SELECT only；任何 DML/DDL＝產 `.sql` 檔交人審（c0-authz-sql 卡模式）。

## 4. 部署驗收
1. `db-new-ro` 跑 `SELECT 1 FROM DUAL;` → 通。
2. `db-old-ro` 跑 RP6 取數：`SELECT * FROM TB_COMMON_FIELD_OPTIONS WHERE SYSTEM='EPRO' AND FIELD_NAME='REVISED_ITEM';`（舊庫表名可能帶 `EPRO_` 前綴，先 `SELECT table_name FROM all_tables WHERE table_name LIKE '%COMMON_FIELD%';` 確認）→ 結果即 RP6 證據。

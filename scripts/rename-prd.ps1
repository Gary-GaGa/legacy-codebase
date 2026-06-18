# rename-prd.ps1 — 把 PRD 檔名調整成 prd-to-srs 閘門認得的格式（Windows 開發主機用）
#
# 目標：PRD-<docId>-<funcId>-<version>.md
# 原因：check-srs-bundle.py 的 gateⒷ/gateⒺ 用 glob `PRD-*<funcId>*.md` 找 PRD 快照
#       → 檔名「必須 PRD- 開頭、且含 funcId（如 EPROZ00100）」，否則覆蓋驗證會靜默略過。
# 假設來源樣式：<docId>_<funcId>_PRD_<version>.md（例：CDCEPRO0001_EPROZ00100_PRD_v1.0.md）
#
# 用法：
#   預覽（不改檔）  powershell -ExecutionPolicy Bypass -File .\rename-prd.ps1 -Path "C:\路徑\到\prd資料夾"
#   實際改名        powershell -ExecutionPolicy Bypass -File .\rename-prd.ps1 -Path "C:\路徑\到\prd資料夾" -Apply

param(
  [Parameter(Mandatory=$true)][string]$Path,
  [switch]$Apply
)

# <docId>_<funcId(EPRO...)>_PRD_<version>.md
$rx = '^(?<doc>.+?)_(?<func>EPRO[A-Za-z0-9]+)_PRD_(?<ver>.+)\.md$'

Get-ChildItem -LiteralPath $Path -Filter *.md -File | ForEach-Object {
  $name = $_.Name
  if ($name -like 'PRD-*') { Write-Host "skip (已符合)    : $name" -ForegroundColor DarkGray; return }
  $m = [regex]::Match($name, $rx)
  if (-not $m.Success)     { Write-Host "skip (樣式不符)  : $name" -ForegroundColor Yellow;  return }

  $new  = "PRD-$($m.Groups['doc'].Value)-$($m.Groups['func'].Value)-$($m.Groups['ver'].Value).md"
  $dest = Join-Path $_.DirectoryName $new
  if (Test-Path -LiteralPath $dest) { Write-Host "skip (目標已存在): $name -> $new" -ForegroundColor Red; return }

  if ($Apply) {
    Rename-Item -LiteralPath $_.FullName -NewName $new
    Write-Host "renamed         : $name -> $new" -ForegroundColor Green
  } else {
    Write-Host "would rename    : $name -> $new" -ForegroundColor Cyan
  }
}
if (-not $Apply) { Write-Host "`n(預覽模式；確認清單無誤後，同指令加 -Apply 才真的改名)" -ForegroundColor Cyan }

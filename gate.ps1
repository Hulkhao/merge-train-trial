<#
.SYNOPSIS
  Merge Train Fast Gate（TRIAL.md §5 固化版，档位 0.5）
.DESCRIPTION
  确定性命令链，五步全绿才算过；能用命令判定的不用模型猜。
  必须在 candidate worktree 根目录执行。
  退出码：0=GATE PASS，1=GATE FAIL，42=解释器过旧。
.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File gate.ps1 -Branch integration/trial-2 -ExpectedHead 0bdfcb4
#>
param(
  [string]$Branch = 'integration/trial-2',
  [string]$ExpectedHead = ''
)
# pwsh7 守卫（对齐 skill 仓库纪律）
if ($PSVersionTable.PSVersion.Major -lt 7) {
  Write-Warning '[gate] 需要 PowerShell 7（pwsh）。安装：winget install --id Microsoft.PowerShell --source winget'
  exit 42
}
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$results = [System.Collections.Generic.List[string]]::new()
function Step {
  param([string]$Name, [scriptblock]$Body)
  try {
    & $Body | Out-Null
    $script:results.Add("PASS $Name") | Out-Null
    Write-Host "[PASS] $Name"
    return $true
  } catch {
    $script:results.Add("FAIL $Name :: $($_.Exception.Message)") | Out-Null
    Write-Host "[FAIL] $Name :: $($_.Exception.Message)"
    return $false
  }
}

$ok = $true
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# ---- 1. sanity：root / branch / candidate HEAD ----
$ok = (Step 'sanity.toplevel' {
  $t = (git rev-parse --show-toplevel).Trim()
  if ($t -ne 'D:/AIGC/merge-train-int') { throw "toplevel=$t，应为 D:/AIGC/merge-train-int" }
}) -and $ok

$ok = (Step "sanity.branch($Branch)" {
  $b = (git branch --show-current).Trim()
  if ($b -ne $Branch) { throw "branch=$b，应为 $Branch" }
}) -and $ok

if ($ExpectedHead) {
  $ok = (Step "sanity.head($ExpectedHead)" {
    $h = (git rev-parse HEAD).Trim()
    if (-not $h.StartsWith($ExpectedHead)) { throw "HEAD=$h，应以 $ExpectedHead 开头" }
  }) -and $ok
}

# ---- 2. syntax：node --check 全部 src/*.js ----
$ok = (Step 'syntax' {
  Get-ChildItem (Join-Path (Get-Location) 'src') -Filter '*.js' | ForEach-Object {
    node --check $_.FullName
    if ($LASTEXITCODE -ne 0) { throw "node --check 失败：$($_.Name)" }
  }
}) -and $ok

# ---- 3. unit ----
$ok = (Step 'unit' {
  node --test 'tests/unit/**/*.test.js'
  if ($LASTEXITCODE -ne 0) { throw 'unit 测试未全绿' }
}) -and $ok

# ---- 4. e2e ----
$ok = (Step 'e2e' {
  node --test 'tests/e2e/**/*.test.js'
  if ($LASTEXITCODE -ne 0) { throw 'e2e 测试未全绿' }
}) -and $ok

# ---- 5. pollution ----
$ok = (Step 'pollution' {
  $dirty = (git status --porcelain) -join ''
  if ($dirty.Trim().Length -gt 0) { throw "工作区有污染：$dirty" }
}) -and $ok

$sw.Stop()
$verdict = if ($ok) { 'GATE=PASS' } else { 'GATE=FAIL' }
Write-Host ''
Write-Host ("{0}  steps={1}  elapsed_ms={2}" -f $verdict, $results.Count, $sw.ElapsedMilliseconds)
$results | ForEach-Object { Write-Host "  $_" }
exit ($ok ? 0 : 1)

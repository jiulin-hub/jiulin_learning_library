$ErrorActionPreference = 'Stop'
$Repo = 'jiulin-hub/jiulin_learning_library'
$RemoteUploadDir = 'upload'
$Names = @(
    'LuckyTeam_maxREL.zip',
    'LuckyTeam_maxREL.zip.sha256',
    'publish.ps1',
    'download-latest.ps1',
    '一键上传.bat',
    '一键下载.bat',
    'README-一键上传下载.md'
)
$Asset = Join-Path $PSScriptRoot 'LuckyTeam_maxREL.zip'
$Checksum = Join-Path $PSScriptRoot 'LuckyTeam_maxREL.zip.sha256'
if (-not (Test-Path -LiteralPath $Asset -PathType Leaf)) { throw "找不到发布包：$Asset" }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '未找到 Git。请先安装 Git for Windows（包含 Git Credential Manager）。' }

$hash = (Get-FileHash -LiteralPath $Asset -Algorithm SHA256).Hash.ToLowerInvariant()
Set-Content -LiteralPath $Checksum -Value $hash -Encoding ascii
$remote = "https://github.com/$Repo.git"
$tempRoot = [IO.Path]::GetFullPath($env:TEMP)
$work = Join-Path $tempRoot ('LuckyTeam-upload-' + [guid]::NewGuid().ToString('N'))
$success = $false
try {
    & git clone --depth 1 $remote $work
    if ($LASTEXITCODE -ne 0) { throw '克隆 GitHub 仓库失败。' }
    $dest = Join-Path $work $RemoteUploadDir
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    foreach ($name in $Names) {
        $source = Join-Path $PSScriptRoot $name
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "缺少上传文件：$source" }
        Copy-Item -LiteralPath $source -Destination (Join-Path $dest $name) -Force
    }
    $authorName = (& git -C $work log -1 --format=%an).Trim()
    $authorEmail = (& git -C $work log -1 --format=%ae).Trim()
    if (-not $authorName) { $authorName = 'jiulin-hub' }
    if (-not $authorEmail) { $authorEmail = 'jiulin.luckyliuliu@qq.com' }
    & git -C $work config user.name $authorName
    & git -C $work config user.email $authorEmail
    & git -C $work add -- $RemoteUploadDir
    if ($LASTEXITCODE -ne 0) { throw 'git add 失败。' }
    & git -C $work diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host 'GitHub 上的 upload/ 已是当前版本，无需再次上传。' -ForegroundColor Yellow
        $success = $true
    } elseif ($LASTEXITCODE -eq 1) {
        & git -C $work commit -m 'Publish LuckyTeam_maxREL package'
        if ($LASTEXITCODE -ne 0) { throw 'git commit 失败。' }
        & git -C $work push origin HEAD:main
        if ($LASTEXITCODE -ne 0) { throw 'git push 失败。请检查 GitHub 登录授权或仓库写入权限。' }
        Write-Host "上传成功：https://github.com/$Repo/tree/main/$RemoteUploadDir" -ForegroundColor Green
        $success = $true
    } else {
        throw '检查 Git 暂存区失败。'
    }
    Write-Host "下载链接：https://github.com/$Repo/raw/refs/heads/main/$RemoteUploadDir/LuckyTeam_maxREL.zip"
    Write-Host "SHA-256：$hash"
} finally {
    if ($success -and (Test-Path -LiteralPath $work)) {
        $resolvedWork = [IO.Path]::GetFullPath($work)
        $prefix = $tempRoot.TrimEnd('\') + '\'
        if ($resolvedWork.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedWork -Recurse -Force
        }
    } else {
        Write-Host "保留临时仓库以便排查：$work" -ForegroundColor Yellow
    }
}

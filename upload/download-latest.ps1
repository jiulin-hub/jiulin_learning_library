$ErrorActionPreference = 'Stop'
$Repo = 'jiulin-hub/jiulin_learning_library'
$RemoteUploadDir = 'upload'
$AssetName = 'LuckyTeam_maxREL.zip'
$OutDir = Join-Path $PSScriptRoot 'downloaded'
$ZipPath = Join-Path $OutDir $AssetName
$HashPath = Join-Path $OutDir ($AssetName + '.sha256')
$BaseUrl = "https://raw.githubusercontent.com/$Repo/refs/heads/main/$RemoteUploadDir"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
Write-Host "正在从 $Repo 下载最新版..."
Invoke-WebRequest -Uri "$BaseUrl/$AssetName" -OutFile $ZipPath
Invoke-WebRequest -Uri "$BaseUrl/$AssetName.sha256" -OutFile $HashPath
$expected = ((Get-Content -LiteralPath $HashPath -Raw).Trim() -split '\s+')[0].ToLowerInvariant()
$actual = (Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($expected -ne $actual) {
    Remove-Item -LiteralPath $ZipPath -Force -ErrorAction SilentlyContinue
    throw "SHA-256 校验失败，已删除下载文件。expected=$expected actual=$actual"
}
Write-Host "下载并校验成功：$ZipPath" -ForegroundColor Green
Write-Host "SHA-256：$actual"

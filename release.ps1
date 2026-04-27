param(
    [string]$Tag = "v1.0.2-1",
    [string]$Ver = "1.0.2-1",
    [string]$Date = "20251201"
)

# 최초 커밋 여부 확인 — HEAD가 없으면 파일을 스테이징하고 초기 커밋
git rev-parse --verify HEAD 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ℹ️ 초기 커밋이 없습니다. 파일을 스테이징하고 커밋합니다." -ForegroundColor Cyan
    git add .
    git commit -m "Initial release: $Tag"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 초기 커밋 실패, 중단합니다." -ForegroundColor Red
        exit 1
    }
}

# 현재 브랜치 자동 감지
$Branch = git rev-parse --abbrev-ref HEAD

# 태그 중복 체크
$existingTag = git tag -l $Tag
if ($existingTag -eq $Tag) {
    Write-Host "⚠️ 태그 '$Tag' 이미 존재 — 삭제 후 재생성합니다." -ForegroundColor Yellow
    git tag -d $Tag
    git push origin --delete $Tag 2>$null
}

# 태그 생성
git tag $Tag

# 원격 푸시
git push origin $Branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ push 실패, 중단합니다." -ForegroundColor Red
    exit 1
}
git push origin $Tag

# GitHub 릴리즈 생성 전에 파일 존재 확인
$file1 = ".\GSP120_SPack_v${Ver}_${Date}.hex"

if (-not (Test-Path $file1)) {
    Write-Host "❌ hex 파일을 찾을 수 없습니다. 파일명을 확인하세요." -ForegroundColor Red
    Write-Host "  $file1"
    exit 1
}

Write-Host "  $file1"

# GitHub 릴리즈 생성
gh release create $Tag $file1 `
  --title "GSP120_SPack_Firmware $Tag" `
  --notes-file .\GSP120_SPack_revision.md

Write-Host "✅ 릴리즈 완료: $Tag" -ForegroundColor Green

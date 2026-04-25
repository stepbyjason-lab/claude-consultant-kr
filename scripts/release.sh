#!/bin/bash
# ============================================================
# release.sh — 버전 릴리스 자동화
# ============================================================
# 사용법:
#   ./scripts/release.sh 0.3.0
# ============================================================

set -euo pipefail

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "사용법: $0 <version>"
  echo "예: $0 0.3.0"
  exit 1
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "오류: 버전은 Semantic Versioning 형식이어야 함 (예: 0.3.0)"
  exit 1
fi

# Git 상태 확인
if ! git diff-index --quiet HEAD --; then
  echo "오류: 커밋되지 않은 변경사항이 있습니다. 먼저 커밋하세요."
  exit 1
fi

# 현재 브랜치 확인
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
  echo "경고: 현재 브랜치가 main 이 아닙니다 ($BRANCH)"
  read -p "계속 진행하시겠습니까? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# CHANGELOG 확인
if ! grep -q "## \[$VERSION\]" CHANGELOG.md; then
  echo "오류: CHANGELOG.md 에 [$VERSION] 섹션이 없습니다."
  echo "먼저 CHANGELOG를 업데이트하세요."
  exit 1
fi

echo "========================================"
echo "버전: v$VERSION"
echo "브랜치: $BRANCH"
echo "========================================"
read -p "릴리스를 진행하시겠습니까? [y/N] " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

# package.json 버전 일치 확인
PKG_VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "")
if [ -z "$PKG_VERSION" ]; then
  echo "오류: package.json 의 version 을 읽지 못했습니다."
  exit 1
fi
if [ "$PKG_VERSION" != "$VERSION" ]; then
  echo "오류: package.json version ($PKG_VERSION) 과 인자 버전 ($VERSION) 이 다릅니다."
  echo "package.json 의 version 을 먼저 $VERSION 으로 맞추세요."
  exit 1
fi

# npm 로그인 확인
if ! npm whoami &>/dev/null; then
  echo "오류: npm 에 로그인되어 있지 않습니다. 'npm login' 후 다시 시도하세요."
  exit 1
fi

# 태그 생성
git tag -a "v$VERSION" -m "Release v$VERSION"
echo "✓ 태그 v$VERSION 생성됨"

# 푸시
git push origin main
git push origin "v$VERSION"
echo "✓ 원격 저장소에 푸시됨"

# npm 배포
echo ""
echo "npm 배포를 진행합니다..."
read -p "npm publish --access public 실행하시겠습니까? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  npm publish --access public
  echo "✓ npm 레지스트리에 v$VERSION 배포됨"
  echo "  → npx consultant-kr-cli@$VERSION 로 즉시 사용 가능"
else
  echo "⚠ npm 배포 건너뜀 — 수동 배포: npm publish --access public"
fi

echo ""
echo "릴리스 완료!"
echo "다음 단계:"
echo "1. GitHub Releases 페이지에서 릴리스 노트 작성"
echo "   https://github.com/gaebalai/claude-consultant-kr/releases/new?tag=v$VERSION"
echo "2. CHANGELOG.md의 해당 섹션 내용을 복사해 릴리스 노트로 사용"
echo "3. npm 배포 확인: https://www.npmjs.com/package/consultant-kr-cli"

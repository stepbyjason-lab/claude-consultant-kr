#!/bin/bash
# ============================================================
# claude-consultant-kr 원클릭 설치 스크립트
# ============================================================
# 사용법:
#   ./scripts/install.sh --local     # 프로젝트 로컬 설치 (현재 디렉토리)
#   ./scripts/install.sh --global    # 전역 설치 (~/.claude/)
#   ./scripts/install.sh --check     # 설치 상태 확인만
#   ./scripts/install.sh --uninstall # 제거
#
# 옵션:
#   --yes, -y                        # 모든 프롬프트에 자동 동의 (CI 등 비대화형)
# ============================================================

set -euo pipefail

# ---------- 색상 코드 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ---------- 로고 ----------
print_logo() {
  echo -e "${BLUE}"
  echo "  ┌─────────────────────────────────────────┐"
  echo "  │  claude-consultant-kr                   │"
  echo "  │  한국 시장 특화 Claude Code 컨설턴트     │"
  echo "  │                                         │"
  echo "  │  Made by gaebalai                       │"
  echo "  └─────────────────────────────────────────┘"
  echo -e "${NC}"
}

# ---------- 경로 설정 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---------- 인자 파싱 ----------
MODE=""
AUTO_YES=0
for arg in "$@"; do
  case "$arg" in
    --local)
      MODE="local"
      TARGET_BASE="$(pwd)/.claude"
      ;;
    --global)
      MODE="global"
      TARGET_BASE="$HOME/.claude"
      ;;
    --check)
      MODE="check"
      ;;
    --uninstall)
      MODE="uninstall"
      ;;
    --yes|-y)
      AUTO_YES=1
      ;;
    *)
      print_logo
      echo "사용법:"
      echo "  $0 --local      # 프로젝트 로컬 설치 (현재 디렉토리)"
      echo "  $0 --global     # 전역 설치 (~/.claude/)"
      echo "  $0 --check      # 설치 상태 확인"
      echo "  $0 --uninstall  # 제거"
      echo ""
      echo "옵션:"
      echo "  --yes, -y       # 프롬프트 자동 동의 (CI 등 비대화형)"
      exit 1
      ;;
  esac
done

if [ -z "$MODE" ]; then
  print_logo
  echo "사용법: $0 --local | --global | --check | --uninstall  [--yes]"
  exit 1
fi

# ---------- Claude Code 설치 확인 ----------
check_claude() {
  if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Claude Code CLI가 설치되어 있지 않습니다.${NC}"
    echo ""
    echo "설치 방법:"
    echo "  https://docs.claude.com/en/docs/claude-code/setup"
    echo ""
    echo "npm 설치 예시:"
    echo "  npm install -g @anthropic-ai/claude-code"
    exit 1
  fi
  echo -e "${GREEN}✓${NC} Claude Code CLI 감지: $(claude --version 2>&1 | head -1)"
}

# ---------- 설치 상태 확인 ----------
cmd_check() {
  print_logo
  echo "설치 상태 확인..."
  echo ""

  check_claude

  for base in "$HOME/.claude" "./.claude"; do
    if [ -d "$base" ]; then
      local scope=$([ "$base" = "$HOME/.claude" ] && echo "전역" || echo "로컬")
      echo ""
      echo -e "${BLUE}[$scope] $base${NC}"

      [ -f "$base/agents/consultant-kr.md" ] \
        && echo -e "  ${GREEN}✓${NC} agents/consultant-kr.md" \
        || echo -e "  ${YELLOW}✗${NC} agents/consultant-kr.md"

      for cmd in analyze-business design-pricing benchmark-competitors prioritize-features; do
        [ -f "$base/commands/$cmd.md" ] \
          && echo -e "  ${GREEN}✓${NC} commands/$cmd.md" \
          || echo -e "  ${YELLOW}✗${NC} commands/$cmd.md"
      done

      [ -f "$base/settings.json" ] \
        && echo -e "  ${GREEN}✓${NC} settings.json (hooks)" \
        || echo -e "  ${YELLOW}✗${NC} settings.json"

      [ -d "$base/hooks/scripts" ] \
        && echo -e "  ${GREEN}✓${NC} hooks/scripts/" \
        || echo -e "  ${YELLOW}✗${NC} hooks/scripts/"
    fi
  done

  echo ""
  echo "설치가 필요하면:"
  echo "  $0 --local     # 프로젝트 로컬"
  echo "  $0 --global    # 전역"
  exit 0
}

# ---------- 설치 ----------
cmd_install() {
  print_logo
  echo -e "${BLUE}설치 모드: $MODE${NC}"
  echo -e "${BLUE}설치 경로: $TARGET_BASE${NC}"
  echo ""

  check_claude

  # 디렉토리 생성
  mkdir -p "$TARGET_BASE/agents"
  mkdir -p "$TARGET_BASE/commands"
  mkdir -p "$TARGET_BASE/hooks/scripts"

  # 1. 에이전트
  echo -e "${BLUE}[1/4] 에이전트 설치 중...${NC}"
  cp "$REPO_ROOT/agents/consultant-kr.md" "$TARGET_BASE/agents/"
  echo -e "  ${GREEN}✓${NC} consultant-kr 에이전트"

  # 2. 슬래시 커맨드
  echo -e "${BLUE}[2/4] 슬래시 커맨드 설치 중...${NC}"
  for cmd_file in "$REPO_ROOT/commands/"*.md; do
    local name=$(basename "$cmd_file")
    [ "$name" = "USAGE.md" ] && continue
    cp "$cmd_file" "$TARGET_BASE/commands/"
    echo -e "  ${GREEN}✓${NC} /$(basename "$name" .md)"
  done

  # 3. Hooks
  echo -e "${BLUE}[3/4] Hooks 설치 중...${NC}"
  if [ -f "$TARGET_BASE/settings.json" ]; then
    echo -e "  ${YELLOW}⚠${NC} 기존 settings.json 발견"
    local do_overwrite=0
    if [ "$AUTO_YES" -eq 1 ]; then
      do_overwrite=1
      echo -e "  ${BLUE}--yes 감지: 자동 덮어쓰기 (.bak 백업)${NC}"
    else
      read -p "  덮어쓰시겠습니까? (기존 파일은 settings.json.bak 으로 백업됨) [y/N] " -n 1 -r REPLY
      echo
      [[ $REPLY =~ ^[Yy]$ ]] && do_overwrite=1
    fi
    if [ "$do_overwrite" -eq 1 ]; then
      cp "$TARGET_BASE/settings.json" "$TARGET_BASE/settings.json.bak"
      cp "$REPO_ROOT/hooks/settings.json" "$TARGET_BASE/settings.json"
      echo -e "  ${GREEN}✓${NC} settings.json (기존 파일은 .bak 으로 백업)"
    else
      echo -e "  ${YELLOW}⚠${NC} settings.json 설치 건너뜀 — 수동 병합 필요"
      echo "      수동 병합 참고: $REPO_ROOT/hooks/settings.json"
    fi
  else
    cp "$REPO_ROOT/hooks/settings.json" "$TARGET_BASE/settings.json"
    echo -e "  ${GREEN}✓${NC} settings.json"
  fi

  cp "$REPO_ROOT/hooks/scripts/"*.sh "$TARGET_BASE/hooks/scripts/"
  chmod +x "$TARGET_BASE/hooks/scripts/"*.sh
  echo -e "  ${GREEN}✓${NC} hooks/scripts/ (4개 스크립트)"

  # 4. 환경변수 템플릿
  echo -e "${BLUE}[4/4] 환경변수 템플릿 배치 중...${NC}"
  if [ "$MODE" = "local" ]; then
    if [ ! -f "./.env" ]; then
      cp "$REPO_ROOT/.env.example" "./.env.example"
      echo -e "  ${GREEN}✓${NC} .env.example 생성"
      echo -e "  ${YELLOW}→${NC} cp .env.example .env 후 웹훅 URL 입력 필요 (선택사항)"
    else
      echo -e "  ${YELLOW}⚠${NC} 기존 .env 파일 발견 — 건너뜀"
    fi
  else
    echo -e "  ${YELLOW}→${NC} 전역 설치에서는 프로젝트별로 .env 파일을 따로 만드세요"
  fi

  # 완료 메시지
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✨ 설치 완료!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "다음 단계:"
  echo ""
  echo "  1. Claude Code 세션 시작"
  echo -e "     ${BLUE}\$ claude${NC}"
  echo ""
  echo "  2. 에이전트 설치 확인"
  echo -e "     ${BLUE}> /agents${NC}"
  echo "     → 목록에 consultant-kr 이 보이면 성공"
  echo ""
  echo "  3. 첫 분석 실행"
  echo -e "     ${BLUE}> /analyze-business${NC}"
  echo ""
  if [ "$MODE" = "local" ]; then
    echo "  4. (선택) 알림 설정"
    echo -e "     ${BLUE}\$ cp .env.example .env${NC}"
    echo -e "     ${BLUE}\$ vi .env${NC}   # 카카오워크 · Slack 웹훅 URL 입력"
    echo ""
  fi
  echo "문서: $REPO_ROOT/docs/"
  echo "이슈 리포트: https://github.com/gaebalai/claude-consultant-kr/issues"
  echo ""
}

# ---------- 제거 ----------
cmd_uninstall() {
  print_logo
  echo -e "${YELLOW}제거를 시작합니다.${NC}"
  echo ""

  local proceed_global=0
  if [ "$AUTO_YES" -eq 1 ]; then
    proceed_global=1
  else
    read -p "전역 설치를 제거하시겠습니까? [y/N] " -n 1 -r REPLY
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && proceed_global=1
  fi
  if [ "$proceed_global" -eq 1 ]; then
    rm -f "$HOME/.claude/agents/consultant-kr.md"
    for cmd in analyze-business design-pricing benchmark-competitors prioritize-features; do
      rm -f "$HOME/.claude/commands/$cmd.md"
    done
    rm -f "$HOME/.claude/hooks/scripts/"{load-context.sh,inject-date.sh,notify-on-report.sh,generate-blog-draft.sh}
    echo -e "${GREEN}✓${NC} 전역 설치 제거 완료"
    echo -e "${YELLOW}⚠${NC} settings.json 은 수동 편집 필요 (다른 hook 과 혼재 가능)"
  fi

  echo ""
  local proceed_local=0
  if [ "$AUTO_YES" -eq 1 ]; then
    proceed_local=1
  else
    read -p "현재 프로젝트(./.claude) 의 로컬 설치를 제거하시겠습니까? [y/N] " -n 1 -r REPLY
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && proceed_local=1
  fi
  if [ "$proceed_local" -eq 1 ]; then
    rm -f "./.claude/agents/consultant-kr.md"
    for cmd in analyze-business design-pricing benchmark-competitors prioritize-features; do
      rm -f "./.claude/commands/$cmd.md"
    done
    rm -f "./.claude/hooks/scripts/"{load-context.sh,inject-date.sh,notify-on-report.sh,generate-blog-draft.sh}
    echo -e "${GREEN}✓${NC} 로컬 설치 제거 완료"
  fi

  echo ""
  echo "제거 완료."
}

# ---------- 메인 ----------
case "$MODE" in
  check)
    cmd_check
    ;;
  uninstall)
    cmd_uninstall
    ;;
  local|global)
    cmd_install
    ;;
esac

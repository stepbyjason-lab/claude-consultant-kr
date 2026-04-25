#!/bin/bash
# ============================================================
# install-industry.sh — 산업 특화 에이전트 설치 스크립트
# ============================================================
# 사용법:
#   ./scripts/install-industry.sh --local              # 대화형 선택 (로컬)
#   ./scripts/install-industry.sh --local --all        # 4개 모두 (로컬)
#   ./scripts/install-industry.sh --global             # 대화형 선택 (전역)
#   ./scripts/install-industry.sh --local --fintech    # 핀테크만
#   ./scripts/install-industry.sh --local --healthcare --ecommerce  # 복수 지정
#   ./scripts/install-industry.sh --list               # 사용 가능한 에이전트 목록
# ============================================================

set -euo pipefail

# ---------- 색상 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------- 경로 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INDUSTRY_DIR="$REPO_ROOT/agents/industry"

# ---------- 사용 가능한 에이전트 ----------
# bash 3.2 (macOS 기본) 호환을 위해 associative array 대신 함수 사용
AVAILABLE_AGENTS=("fintech" "healthcare" "construction" "ecommerce")

agent_desc() {
  case "$1" in
    fintech)      echo "핀테크 · 전자금융 · 가상자산 · 토큰증권" ;;
    healthcare)   echo "헬스케어 · 디지털치료제 · 의료기기 · 원격의료" ;;
    construction) echo "건설 · 스마트건설 · BIM · 건설안전" ;;
    ecommerce)    echo "이커머스 · D2C · 오픈마켓 · 크로스보더" ;;
    *)            echo "" ;;
  esac
}

# ---------- 로고 ----------
print_logo() {
  echo -e "${BLUE}"
  echo "  ┌─────────────────────────────────────────────┐"
  echo "  │  claude-consultant-kr  |  산업 특화 에이전트  │"
  echo "  │  Industry-Specific Agents                   │"
  echo "  └─────────────────────────────────────────────┘"
  echo -e "${NC}"
}

# ---------- 사용법 ----------
usage() {
  print_logo
  echo "사용법:"
  echo "  $0 --local                              # 대화형 선택 (프로젝트 로컬)"
  echo "  $0 --global                             # 대화형 선택 (전역)"
  echo "  $0 --local --all                        # 4개 모두 설치 (로컬)"
  echo "  $0 --local --fintech --healthcare       # 복수 지정"
  echo "  $0 --list                               # 사용 가능한 에이전트 목록"
  echo ""
  echo "사용 가능한 에이전트:"
  for agent in "${AVAILABLE_AGENTS[@]}"; do
    echo "  --${agent}          $(agent_desc "$agent")"
  done
  echo ""
  exit 1
}

# ---------- 목록 ----------
cmd_list() {
  print_logo
  echo "산업 특화 에이전트 4종:"
  echo ""
  for agent in "${AVAILABLE_AGENTS[@]}"; do
    local file="$INDUSTRY_DIR/consultant-kr-${agent}.md"
    if [ -f "$file" ]; then
      echo -e "  ${GREEN}✓${NC} ${BLUE}consultant-kr-${agent}${NC}"
      echo -e "    $(agent_desc "$agent")"
    else
      echo -e "  ${RED}✗${NC} consultant-kr-${agent} (파일 누락)"
    fi
    echo ""
  done
  exit 0
}

# ---------- 인자 파싱 ----------
MODE=""
SELECTED=()
INSTALL_ALL=false

if [ $# -eq 0 ]; then
  usage
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --local)
      MODE="local"
      TARGET_BASE="$(pwd)/.claude"
      ;;
    --global)
      MODE="global"
      TARGET_BASE="$HOME/.claude"
      ;;
    --list)
      cmd_list
      ;;
    --all)
      INSTALL_ALL=true
      ;;
    --fintech|--healthcare|--construction|--ecommerce)
      SELECTED+=("${1#--}")
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo -e "${RED}알 수 없는 옵션: $1${NC}"
      usage
      ;;
  esac
  shift
done

if [ -z "$MODE" ]; then
  echo -e "${RED}오류: --local 또는 --global 지정 필요${NC}"
  usage
fi

# ---------- 대화형 선택 ----------
interactive_select() {
  print_logo
  echo -e "${BLUE}설치할 산업 에이전트를 선택하세요:${NC}"
  echo ""
  for i in "${!AVAILABLE_AGENTS[@]}"; do
    local agent="${AVAILABLE_AGENTS[$i]}"
    echo -e "  ${GREEN}$((i+1)))${NC} consultant-kr-${agent}"
    echo -e "     $(agent_desc "$agent")"
  done
  echo -e "  ${GREEN}5)${NC} 모두 설치"
  echo -e "  ${GREEN}0)${NC} 취소"
  echo ""
  read -p "번호 (복수 선택 시 공백 구분, 예: 1 3): " -r choices
  
  for choice in $choices; do
    case "$choice" in
      1) SELECTED+=("fintech") ;;
      2) SELECTED+=("healthcare") ;;
      3) SELECTED+=("construction") ;;
      4) SELECTED+=("ecommerce") ;;
      5) INSTALL_ALL=true ;;
      0) echo "취소됨"; exit 0 ;;
      *) echo -e "${YELLOW}⚠${NC} 무시된 선택: $choice" ;;
    esac
  done
}

if [ "$INSTALL_ALL" = false ] && [ ${#SELECTED[@]} -eq 0 ]; then
  interactive_select
fi

if [ "$INSTALL_ALL" = true ]; then
  SELECTED=("${AVAILABLE_AGENTS[@]}")
fi

if [ ${#SELECTED[@]} -eq 0 ]; then
  echo -e "${RED}선택된 에이전트가 없습니다.${NC}"
  exit 1
fi

# ---------- 설치 실행 ----------
print_logo
echo -e "${BLUE}설치 모드: $MODE${NC}"
echo -e "${BLUE}설치 경로: $TARGET_BASE${NC}"
echo ""

# 베이스 consultant-kr 설치 여부 확인
if [ ! -f "$TARGET_BASE/agents/consultant-kr.md" ]; then
  echo -e "${YELLOW}⚠ 베이스 consultant-kr 에이전트가 설치되어 있지 않습니다.${NC}"
  echo -e "${YELLOW}  산업 에이전트가 베이스를 계승하므로 먼저 설치를 권장합니다.${NC}"
  echo ""
  read -p "  그래도 계속 진행하시겠습니까? [y/N] " -n 1 -r REPLY
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

mkdir -p "$TARGET_BASE/agents"

echo -e "${BLUE}산업 에이전트 설치 중...${NC}"
for agent in "${SELECTED[@]}"; do
  src="$INDUSTRY_DIR/consultant-kr-${agent}.md"
  dst="$TARGET_BASE/agents/consultant-kr-${agent}.md"
  
  if [ ! -f "$src" ]; then
    echo -e "  ${RED}✗${NC} consultant-kr-${agent} — 소스 파일 누락"
    continue
  fi
  
  cp "$src" "$dst"
  echo -e "  ${GREEN}✓${NC} consultant-kr-${agent}"
done

# ---------- 완료 ----------
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ 산업 에이전트 설치 완료!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "사용 방법:"
echo ""
for agent in "${SELECTED[@]}"; do
  echo -e "  ${BLUE}@consultant-kr-${agent}${NC}  <질문>"
done
echo ""
echo "예시:"
echo "  @consultant-kr-fintech 간편결제 사업 진입 전략"
echo "  @consultant-kr-healthcare 디지털치료제 출시 로드맵"
echo ""
echo "자세한 사용법: docs/USAGE.md · examples/ 디렉토리 참고"
echo ""

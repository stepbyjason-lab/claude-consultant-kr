#!/bin/bash
# ============================================================
# Humanize KR (im-not-ai) 동적 설치 스크립트
# ============================================================
# 외부 리포지토리(epoko77-ai/im-not-ai) 에서 직접 fetch 하여
# 사용자의 ~/.claude/ 또는 ./.claude/ 에 배치합니다.
#
# 라이선스 고지:
#   원본 리포는 라이선스가 명시되지 않은 공개 리포입니다.
#   본 스크립트는 재배포가 아닌 "사용자 환경에서의 직접 다운로드"
#   를 수행합니다. 사용 책임은 사용자에게 있습니다.
#   원본: https://github.com/epoko77-ai/im-not-ai
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

UPSTREAM_REPO="epoko77-ai/im-not-ai"
UPSTREAM_REF="main"
RAW_BASE="https://raw.githubusercontent.com/${UPSTREAM_REPO}/${UPSTREAM_REF}"

AGENT_FILES=(
  "ai-tell-detector.md"
  "content-fidelity-auditor.md"
  "humanize-web-architect.md"
  "korean-ai-tell-taxonomist.md"
  "korean-style-rewriter.md"
  "naturalness-reviewer.md"
)

SKILL_ROOT_FILES=(
  "SKILL.md"
)

SKILL_REF_FILES=(
  "ai-tell-taxonomy.md"
  "rewriting-playbook.md"
  "web-service-spec.md"
)

print_header() {
  echo -e "${BLUE}"
  echo "  ┌─────────────────────────────────────────┐"
  echo "  │  Humanize KR — 한글 AI 티 제거기          │"
  echo "  │  (epoko77-ai/im-not-ai)                  │"
  echo "  │                                         │"
  echo "  │  via claude-consultant-kr               │"
  echo "  └─────────────────────────────────────────┘"
  echo -e "${NC}"
}

print_help() {
  print_header
  cat <<EOF
사용법:
  $0 --local       현재 프로젝트의 ./.claude/ 에 설치
  $0 --global      ~/.claude/ 에 설치
  $0 --uninstall   설치 제거 (양쪽 모두 인터랙티브)
  $0 --check       설치 상태 확인

옵션:
  --yes, -y        라이선스 고지에 자동 동의 (CI 등 비인터랙티브 환경)

설치되는 파일:
  agents/ ${#AGENT_FILES[@]}개 + skills/humanize-korean/ (SKILL.md + references 3개)

원본 리포: https://github.com/${UPSTREAM_REPO}
EOF
}

MODE=""
AUTO_YES=0
for arg in "$@"; do
  case "$arg" in
    --local) MODE="local" ;;
    --global) MODE="global" ;;
    --uninstall) MODE="uninstall" ;;
    --check) MODE="check" ;;
    --yes|-y) AUTO_YES=1 ;;
    -h|--help) print_help; exit 0 ;;
    *) echo "알 수 없는 인자: $arg"; print_help; exit 1 ;;
  esac
done

if [ -z "$MODE" ]; then
  print_help
  exit 1
fi

case "$MODE" in
  local) TARGET_BASE="$(pwd)/.claude" ;;
  global) TARGET_BASE="$HOME/.claude" ;;
esac

# ---------- 의존 도구 확인 ----------
need_tool() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "${RED}❌ 필수 도구를 찾을 수 없습니다: $1${NC}"
    exit 1
  fi
}

# curl 또는 wget 둘 중 하나만 있으면 됨
DOWNLOADER=""
if command -v curl &>/dev/null; then
  DOWNLOADER="curl"
elif command -v wget &>/dev/null; then
  DOWNLOADER="wget"
else
  echo -e "${RED}❌ curl 또는 wget 이 필요합니다.${NC}"
  exit 1
fi

fetch() {
  local url="$1"
  local dest="$2"
  if [ "$DOWNLOADER" = "curl" ]; then
    curl -fsSL "$url" -o "$dest"
  else
    wget -q "$url" -O "$dest"
  fi
}

# ---------- 라이선스 고지 ----------
show_license_notice() {
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}⚠ 라이선스 고지${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  echo "원본 리포 ${UPSTREAM_REPO} 에는 LICENSE 파일이 없습니다."
  echo "이 스크립트는 원본을 재배포하지 않고, 사용자 환경에서"
  echo "GitHub raw URL 로 직접 다운로드만 수행합니다."
  echo
  echo "원본 저작권은 원작자에게 있으며, 사용 책임은 사용자에게 있습니다."
  echo "원본 리포: https://github.com/${UPSTREAM_REPO}"
  echo
  echo -e "${YELLOW}이 스크립트는 '${UPSTREAM_REF}' 브랜치를 추적합니다. 원본의 향후 변경"
  echo -e "(악성 코드 포함 가능성)이 다음 설치/재설치 시 그대로 적용됩니다.${NC}"
  echo
  if [ "$AUTO_YES" -eq 1 ]; then
    echo -e "${BLUE}--yes 플래그 감지: 자동 진행${NC}"
    echo
    return
  fi
  read -p "위 내용에 동의하고 진행하시겠습니까? [y/N] " -n 1 -r REPLY
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "취소되었습니다."
    exit 0
  fi
  echo
}

# ---------- 설치 상태 확인 ----------
cmd_check() {
  print_header
  echo "Humanize KR 설치 상태 확인..."
  echo
  for base in "$HOME/.claude" "./.claude"; do
    if [ -d "$base" ]; then
      local scope=$([ "$base" = "$HOME/.claude" ] && echo "전역" || echo "로컬")
      echo -e "${BLUE}[$scope] $base${NC}"
      local missing=0
      for f in "${AGENT_FILES[@]}"; do
        if [ -f "$base/agents/$f" ]; then
          echo -e "  ${GREEN}✓${NC} agents/$f"
        else
          echo -e "  ${YELLOW}✗${NC} agents/$f"
          missing=$((missing+1))
        fi
      done
      for f in "${SKILL_ROOT_FILES[@]}"; do
        if [ -f "$base/skills/humanize-korean/$f" ]; then
          echo -e "  ${GREEN}✓${NC} skills/humanize-korean/$f"
        else
          echo -e "  ${YELLOW}✗${NC} skills/humanize-korean/$f"
          missing=$((missing+1))
        fi
      done
      for f in "${SKILL_REF_FILES[@]}"; do
        if [ -f "$base/skills/humanize-korean/references/$f" ]; then
          echo -e "  ${GREEN}✓${NC} skills/humanize-korean/references/$f"
        else
          echo -e "  ${YELLOW}✗${NC} skills/humanize-korean/references/$f"
          missing=$((missing+1))
        fi
      done
      [ $missing -eq 0 ] && echo -e "  ${GREEN}→ 완전 설치됨${NC}" || echo -e "  ${YELLOW}→ ${missing}개 파일 누락${NC}"
      echo
    fi
  done
}

# ---------- 설치 ----------
cmd_install() {
  print_header
  show_license_notice
  echo -e "${BLUE}설치 경로: $TARGET_BASE${NC}"
  echo

  mkdir -p "$TARGET_BASE/agents"
  mkdir -p "$TARGET_BASE/skills/humanize-korean/references"

  echo -e "${BLUE}[1/2] 에이전트 ${#AGENT_FILES[@]}개 다운로드 중...${NC}"
  for f in "${AGENT_FILES[@]}"; do
    fetch "${RAW_BASE}/.claude/agents/${f}" "${TARGET_BASE}/agents/${f}"
    echo -e "  ${GREEN}✓${NC} agents/${f}"
  done

  echo -e "${BLUE}[2/2] 스킬 (humanize-korean) 다운로드 중...${NC}"
  for f in "${SKILL_ROOT_FILES[@]}"; do
    fetch "${RAW_BASE}/.claude/skills/humanize-korean/${f}" \
          "${TARGET_BASE}/skills/humanize-korean/${f}"
    echo -e "  ${GREEN}✓${NC} skills/humanize-korean/${f}"
  done
  for f in "${SKILL_REF_FILES[@]}"; do
    fetch "${RAW_BASE}/.claude/skills/humanize-korean/references/${f}" \
          "${TARGET_BASE}/skills/humanize-korean/references/${f}"
    echo -e "  ${GREEN}✓${NC} skills/humanize-korean/references/${f}"
  done

  echo
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✨ Humanize KR 설치 완료!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  echo "사용법: claude 세션에서 자연어로 호출"
  echo "  > AI 티 없애줘"
  echo "  > 사람이 쓴 것처럼 윤문해줘"
  echo "  > 번역투 제거"
  echo
  echo "원본: https://github.com/${UPSTREAM_REPO}"
}

# ---------- 제거 ----------
cmd_uninstall() {
  print_header
  echo -e "${YELLOW}Humanize KR 제거를 시작합니다.${NC}"
  echo
  for base in "$HOME/.claude" "./.claude"; do
    if [ -d "$base" ]; then
      local scope=$([ "$base" = "$HOME/.claude" ] && echo "전역" || echo "로컬")
      if [ "$AUTO_YES" -eq 0 ]; then
        read -p "${scope} ($base) 의 Humanize KR 을 제거할까요? [y/N] " -n 1 -r REPLY
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && continue
      fi
      for f in "${AGENT_FILES[@]}"; do
        rm -f "$base/agents/$f"
      done
      rm -rf "$base/skills/humanize-korean"
      echo -e "  ${GREEN}✓${NC} ${scope} 제거 완료"
    fi
  done
}

case "$MODE" in
  check) cmd_check ;;
  uninstall) cmd_uninstall ;;
  local|global) cmd_install ;;
esac

#!/bin/bash
# ============================================================
# Humanize KR (im-not-ai) 동적 설치 스크립트
# ============================================================
# 외부 리포지토리(gaebalai/im-not-ai, MIT) 에서 직접 fetch 하여
# 사용자의 ~/.claude/ 또는 ./.claude/ 에 배치합니다.
#
# 라이선스:
#   원본 리포는 MIT 라이선스로 배포됩니다.
#   본 스크립트는 GitHub raw URL 에서 직접 다운로드만 수행하며,
#   원본의 LICENSE 파일도 함께 받아 보존합니다.
#   원본: https://github.com/gaebalai/im-not-ai
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

UPSTREAM_REPO="gaebalai/im-not-ai"
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

COMMAND_FILES=(
  "humanize.md"
  "humanize-detect.md"
  "humanize-redo.md"
  "humanize-status.md"
  "humanize-list.md"
  "humanize-web.md"
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
  echo "  │  (gaebalai/im-not-ai · MIT)              │"
  echo "  │                                         │"
  echo "  │  via consultant-kr-cli                  │"
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
  agents/      ${#AGENT_FILES[@]}개 (서브에이전트)
  commands/    ${#COMMAND_FILES[@]}개 (슬래시 커맨드 — /humanize 외)
  skills/humanize-korean/  SKILL.md + references 3개
  LICENSE-humanize-kr  원본 MIT 라이선스 사본

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
  echo -e "${YELLOW}ℹ 라이선스 안내${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  echo "원본 리포 ${UPSTREAM_REPO} 는 MIT 라이선스로 배포됩니다."
  echo "본 스크립트는 GitHub raw URL 에서 직접 파일을 다운로드하며,"
  echo "원본의 LICENSE 파일도 함께 받아 \$TARGET/LICENSE-humanize-kr 로 보존합니다."
  echo
  echo "원본 리포: https://github.com/${UPSTREAM_REPO}"
  echo
  echo -e "${YELLOW}본 스크립트는 '${UPSTREAM_REF}' 브랜치를 추적합니다."
  echo -e "원본의 향후 변경이 다음 설치/재설치 시 그대로 적용됩니다.${NC}"
  echo
  if [ "$AUTO_YES" -eq 1 ]; then
    echo -e "${BLUE}--yes 플래그 감지: 자동 진행${NC}"
    echo
    return
  fi
  read -p "진행하시겠습니까? [Y/n] " -n 1 -r REPLY
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
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
      for f in "${COMMAND_FILES[@]}"; do
        if [ -f "$base/commands/$f" ]; then
          echo -e "  ${GREEN}✓${NC} commands/$f"
        else
          echo -e "  ${YELLOW}✗${NC} commands/$f"
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
  mkdir -p "$TARGET_BASE/commands"
  mkdir -p "$TARGET_BASE/skills/humanize-korean/references"

  echo -e "${BLUE}[1/4] 에이전트 ${#AGENT_FILES[@]}개 다운로드 중...${NC}"
  for f in "${AGENT_FILES[@]}"; do
    fetch "${RAW_BASE}/agents/${f}" "${TARGET_BASE}/agents/${f}"
    echo -e "  ${GREEN}✓${NC} agents/${f}"
  done

  echo -e "${BLUE}[2/4] 슬래시 커맨드 ${#COMMAND_FILES[@]}개 다운로드 중...${NC}"
  for f in "${COMMAND_FILES[@]}"; do
    fetch "${RAW_BASE}/commands/${f}" "${TARGET_BASE}/commands/${f}"
    echo -e "  ${GREEN}✓${NC} commands/${f}"
  done

  echo -e "${BLUE}[3/4] 스킬 (humanize-korean) 다운로드 중...${NC}"
  for f in "${SKILL_ROOT_FILES[@]}"; do
    fetch "${RAW_BASE}/skills/humanize-korean/${f}" \
          "${TARGET_BASE}/skills/humanize-korean/${f}"
    echo -e "  ${GREEN}✓${NC} skills/humanize-korean/${f}"
  done
  for f in "${SKILL_REF_FILES[@]}"; do
    fetch "${RAW_BASE}/skills/humanize-korean/references/${f}" \
          "${TARGET_BASE}/skills/humanize-korean/references/${f}"
    echo -e "  ${GREEN}✓${NC} skills/humanize-korean/references/${f}"
  done

  echo -e "${BLUE}[4/4] LICENSE 사본 다운로드 중...${NC}"
  fetch "${RAW_BASE}/LICENSE" "${TARGET_BASE}/LICENSE-humanize-kr" 2>/dev/null \
    && echo -e "  ${GREEN}✓${NC} LICENSE-humanize-kr (MIT)" \
    || echo -e "  ${YELLOW}⚠${NC} LICENSE 사본 받기 실패 (원본 리포에서 직접 확인하세요)"

  echo
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✨ Humanize KR 설치 완료!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  echo "사용법: claude 세션에서 슬래시 커맨드 또는 자연어로 호출"
  echo "  > /humanize <텍스트 또는 파일 경로>"
  echo "  > /humanize-detect <텍스트>      # AI 티 탐지만"
  echo "  > /humanize-redo <텍스트>        # 2차 윤문"
  echo "  > AI 티 없애줘                    # 자연어 트리거"
  echo
  echo "consultant-kr-cli 와의 통합:"
  echo "  > /analyze-business              # 분석 후 자동으로 윤문 적용 (옵트인)"
  echo "  > /refine-report                 # 기존 리포트를 사후 윤문"
  echo
  echo "원본: https://github.com/${UPSTREAM_REPO} (MIT)"
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
      for f in "${COMMAND_FILES[@]}"; do
        rm -f "$base/commands/$f"
      done
      rm -rf "$base/skills/humanize-korean"
      rm -f "$base/LICENSE-humanize-kr"
      echo -e "  ${GREEN}✓${NC} ${scope} 제거 완료"
    fi
  done
}

case "$MODE" in
  check) cmd_check ;;
  uninstall) cmd_uninstall ;;
  local|global) cmd_install ;;
esac

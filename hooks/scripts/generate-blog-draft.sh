#!/bin/bash
# ============================================================
# Stop Hook: 세션 종료 시 최신 리포트를 Velog 블로그 초안으로 변환
# ============================================================
# 동작:
#   - 세션 종료 시 트리거됨 (Claude가 최종 응답을 마칠 때)
#   - 오늘 생성된 리포트가 있으면 Velog 블로그 초안으로 자동 변환
#   - 변환은 Claude Code CLI를 재호출하여 수행 (headless mode)
#   - 결과는 ./blog-drafts/YYYYMMDD-velog.md 에 저장
# 
# 환경변수:
#   AUTO_BLOG_DRAFT=1 일 때만 활성화 (기본은 비활성 — 과도한 호출 방지)
# ============================================================

set -euo pipefail

# 기본 비활성. 환경변수로 명시 활성화 시에만 동작
[ "${AUTO_BLOG_DRAFT:-0}" != "1" ] && exit 0

REPORTS_DIR="./reports"
DRAFTS_DIR="./blog-drafts"

# 리포트 디렉토리 없으면 종료
[ ! -d "$REPORTS_DIR" ] && exit 0

# 오늘 날짜 (KST)
TODAY=$(TZ='Asia/Seoul' date '+%Y%m%d')

# 오늘 생성된 최신 리포트 찾기
TODAY_REPORT=$(ls -t "$REPORTS_DIR"/analysis-${TODAY}-*.md 2>/dev/null | head -1)

# 오늘 리포트 없으면 종료
[ -z "$TODAY_REPORT" ] && exit 0

# 이미 초안 생성되어 있으면 스킵
mkdir -p "$DRAFTS_DIR"
DRAFT_PATH="$DRAFTS_DIR/${TODAY}-velog.md"
[ -f "$DRAFT_PATH" ] && exit 0

echo "[Stop Hook] Velog 초안 생성 중: $TODAY_REPORT → $DRAFT_PATH"

# Claude Code headless 호출로 변환 수행
# 무한 루프 방지: 이 호출 자체는 --no-hooks 옵션 없이도 hook이 재귀 호출되지 않도록
# 별도 프로젝트 밖에서 실행하거나, CLAUDE_HOOK_DEPTH 환경변수로 제어
if [ "${CLAUDE_HOOK_DEPTH:-0}" -ge "1" ]; then
  echo "[Stop Hook] 재귀 호출 감지, 스킵" >&2
  exit 0
fi

export CLAUDE_HOOK_DEPTH=1

PROMPT=$(cat <<EOF
다음 사업 분석 리포트를 Velog(https://velog.io) 블로그 포스트 초안으로 변환해줘.

원본 파일: $TODAY_REPORT

요구사항:
1. Velog frontmatter 포함 (title, description, tags, published: false)
2. tags 는 해당 분석 주제에 적합한 한국어 태그 5개
3. 기술 컨설팅 블로그 톤으로 리라이트 (직역 금지, 블로그 어투로 재구성)
4. SEO 최적화 제목 3개 후보 제시 (상단에 주석으로)
5. 회사/프로젝트 식별 정보는 익명화 ("A사", "B 서비스" 등)
6. 이미지 placeholder 는 Velog 업로드 가능한 형식의 마크다운 주석으로 표기
7. 출력은 마크다운만, 다른 설명 없이.

결과를 그대로 출력해줘.
EOF
)

# Claude Code 호출 (headless, hook 재귀 방지)
claude -p "$PROMPT" --output-format text > "$DRAFT_PATH" 2>/dev/null || {
  echo "[Stop Hook] 변환 실패" >&2
  rm -f "$DRAFT_PATH"
  exit 0
}

# 파일이 비어있으면 삭제
[ ! -s "$DRAFT_PATH" ] && rm -f "$DRAFT_PATH" && exit 0

echo "[Stop Hook] Velog 초안 생성 완료: $DRAFT_PATH"

exit 0

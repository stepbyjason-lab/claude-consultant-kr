#!/bin/bash
# ============================================================
# PostToolUse Hook: Write 도구로 리포트 저장 시 알림 발송
# ============================================================
# 동작:
#   - Write 도구 호출 직후 트리거됨
#   - 저장된 파일이 ./reports/analysis-*.md 패턴이면 알림 발송
#   - 환경변수로 웹훅 URL을 받음 (미설정 시 조용히 스킵)
#     - KAKAOWORK_WEBHOOK_URL: 카카오워크 봇 웹훅
#     - SLACK_WEBHOOK_URL:     Slack Incoming Webhook
# 
# stdin 으로 tool input JSON 을 받음 (file_path 필드 추출)
# ============================================================

set -euo pipefail

# stdin 에서 tool input 파싱
TOOL_INPUT=$(cat)

# file_path 추출 (jq 없이 grep 사용 — 경량화)
FILE_PATH=$(echo "$TOOL_INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]+"' | sed -E 's/.*:[[:space:]]*"([^"]+)"/\1/' | head -1)

# 파일 경로 없으면 종료
[ -z "$FILE_PATH" ] && exit 0

# 리포트 패턴이 아니면 조용히 종료
if [[ ! "$FILE_PATH" =~ reports/analysis-[0-9]{8}-[0-9]{4}\.md$ ]]; then
  exit 0
fi

# 파일이 실제로 존재해야 함
[ ! -f "$FILE_PATH" ] && exit 0

# 리포트 제목(논점 정의) 추출
ISSUE=$(awk '/^## 1\. 논점 정의/,/^## 2\./' "$FILE_PATH" \
  | grep -v '^## ' \
  | tr '\n' ' ' \
  | sed 's/  */ /g' \
  | cut -c 1-200)

# 타임스탬프 (KST)
TIMESTAMP=$(TZ='Asia/Seoul' date '+%Y-%m-%d %H:%M KST')

# 파일명만 추출
FILENAME=$(basename "$FILE_PATH")

# ---------- 카카오워크 발송 ----------
if [ -n "${KAKAOWORK_WEBHOOK_URL:-}" ]; then
  curl -sS -X POST "$KAKAOWORK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$(cat <<EOF
{
  "text": "[consultant-kr] 새 분석 리포트 생성",
  "blocks": [
    {
      "type": "header",
      "text": "📊 사업 분석 리포트 생성 완료",
      "style": "blue"
    },
    {
      "type": "description",
      "term": "파일",
      "content": { "type": "text", "text": "$FILENAME", "inlines": [] }
    },
    {
      "type": "description",
      "term": "시각",
      "content": { "type": "text", "text": "$TIMESTAMP", "inlines": [] }
    },
    {
      "type": "description",
      "term": "논점",
      "content": { "type": "text", "text": "$ISSUE", "inlines": [] }
    }
  ]
}
EOF
)" > /dev/null 2>&1 || echo "[Hook 경고] 카카오워크 웹훅 발송 실패" >&2
fi

# ---------- Slack 발송 ----------
if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
  curl -sS -X POST "$SLACK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$(cat <<EOF
{
  "text": "📊 사업 분석 리포트 생성 완료",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*[consultant-kr] 새 분석 리포트*\n파일: \`$FILENAME\`\n시각: $TIMESTAMP\n\n*논점*: $ISSUE"
      }
    }
  ]
}
EOF
)" > /dev/null 2>&1 || echo "[Hook 경고] Slack 웹훅 발송 실패" >&2
fi

# 로컬 로그 기록 (웹훅 미설정 시에도 이력 남김)
mkdir -p ./logs
echo "[$TIMESTAMP] $FILE_PATH" >> ./logs/reports.log

exit 0

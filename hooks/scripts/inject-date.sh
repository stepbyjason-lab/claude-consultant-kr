#!/bin/bash
# ============================================================
# UserPromptSubmit Hook: KST 현재 시각을 프롬프트 컨텍스트에 주입
# ============================================================
# 동작:
#   - 사용자가 프롬프트를 제출할 때마다 현재 시각(KST)을 컨텍스트로 추가
#   - 에이전트가 "오늘", "이번 주" 같은 상대 시간 표현을 정확히 해석하도록 보조
#   - 특히 /analyze-business, /benchmark-competitors 등 시장 상황 분석 시 유용
# ============================================================

set -euo pipefail

# KST 기준 현재 시각
# 서버가 UTC인 경우에도 KST로 변환
KST_NOW=$(TZ='Asia/Seoul' date '+%Y-%m-%d %H:%M:%S %Z')
KST_DOW=$(TZ='Asia/Seoul' date '+%A')

# 한국어 요일 변환
case "$KST_DOW" in
  Monday)    DOW_KR="월요일" ;;
  Tuesday)   DOW_KR="화요일" ;;
  Wednesday) DOW_KR="수요일" ;;
  Thursday)  DOW_KR="목요일" ;;
  Friday)    DOW_KR="금요일" ;;
  Saturday)  DOW_KR="토요일" ;;
  Sunday)    DOW_KR="일요일" ;;
  *)         DOW_KR="$KST_DOW" ;;
esac

echo "[현재 시각 컨텍스트] $KST_NOW ($DOW_KR)"

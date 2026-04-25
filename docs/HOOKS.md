# Hook 설정 가이드

4개 Hook의 상세 동작 원리, 웹훅 URL 발급, Cron 연동 방법.

---

## 🎯 Hook 레이어 개요

Claude Code의 Hook은 특정 이벤트 발생 시 자동으로 스크립트를 실행하는 메커니즘입니다. 이 패키지는 4개 Hook 포인트를 활용합니다.

```
[사용자 입력]
    ↓
[UserPromptSubmit Hook] → inject-date.sh (KST 시각 주입)
    ↓
[Claude 처리]
    ↓
[PostToolUse:Write Hook] → notify-on-report.sh (알림 발송)
    ↓
[세션 종료]
    ↓
[Stop Hook] → generate-blog-draft.sh (Velog 초안 생성)
```

세션 시작 시점:
```
[claude 실행]
    ↓
[SessionStart Hook] → load-context.sh (이전 리포트 주입)
    ↓
[사용자와 대화 시작]
```

---

## 📋 Hook별 상세

### 1. SessionStart — `load-context.sh`

**목적**: 세션 시작 시 이전 분석 맥락을 자동 주입.

**동작**:
1. `./reports/analysis-*.md` 중 최신 파일 탐색
2. "1. 논점 정의" 와 "6. 추천 시책" 섹션만 추출
3. stdout으로 출력 → Claude 컨텍스트에 자동 반영

**효과**: 사용자가 "이전 분석 참고해서…" 같은 지시를 할 필요 없음.

**비활성화**: `.claude/settings.json` 에서 `SessionStart` 블록 제거.

### 2. UserPromptSubmit — `inject-date.sh`

**목적**: 매 프롬프트마다 KST 현재 시각과 요일 주입.

**효과**:
- "이번 주 트렌드" → 정확한 날짜 범위로 해석
- "다음 분기" → 정확한 분기 경계 인식
- Cron 자동 실행 시 특히 유용 (언제 실행되었는지 명확)

### 3. PostToolUse:Write — `notify-on-report.sh`

**목적**: 리포트 저장 시 팀 채널에 자동 알림.

**발송 채널**: 카카오워크, Slack (환경변수 설정된 채널만)

**메시지 내용**:
- 파일명
- 생성 시각 (KST)
- 논점 정의 첫 200자

**로컬 로그**: `./logs/reports.log` 에 항상 기록 (웹훅 미설정 시에도).

### 4. Stop — `generate-blog-draft.sh`

**목적**: 세션 종료 시 오늘 리포트를 Velog 초안으로 자동 변환.

**활성화**: `AUTO_BLOG_DRAFT=1` 환경변수 설정 시에만 동작 (기본 비활성).

**이유**: Claude 재호출로 토큰 소모가 있으므로 의도적으로 활성화해야 동작.

**재귀 방지**: `CLAUDE_HOOK_DEPTH` 환경변수로 2단 제한.

---

## 🔑 웹훅 URL 발급

### 카카오워크

1. 카카오워크 관리자 페이지 접속 (`https://{workspace}.kakaowork.com/admin`)
2. 좌측 메뉴: **봇 관리 → 봇 추가**
3. 봇 이름 입력 (예: "consultant-kr 알림")
4. **웹훅 URL** 탭에서 "추가" 클릭
5. 발송할 채널 선택
6. 생성된 URL 복사 (형식: `https://bot.kakaowork.com/v1/webhook/xxxxx`)

`.env` 에 설정:

```bash
KAKAOWORK_WEBHOOK_URL="https://bot.kakaowork.com/v1/webhook/xxxxx"
```

### Slack

1. Slack 앱 생성: https://api.slack.com/apps → **Create New App**
2. **From scratch** 선택 → 앱 이름과 워크스페이스 입력
3. 좌측 메뉴: **Incoming Webhooks → Activate Incoming Webhooks (On)**
4. **Add New Webhook to Workspace** 클릭
5. 채널 선택 → **Allow**
6. 생성된 URL 복사 (형식: `https://hooks.slack.com/services/T00/B00/xxxxx`)

`.env` 에 설정:

```bash
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00/B00/xxxxx"
```

---

## 🔧 환경변수 설정

### .env 파일 생성

```bash
cp .env.example .env
vi .env
```

### 필수 항목

없습니다. 모든 항목은 **선택사항**이며, 설정되지 않은 채널은 조용히 스킵됩니다.

### 전체 설정 예시

```bash
# 카카오워크 알림
KAKAOWORK_WEBHOOK_URL="https://bot.kakaowork.com/v1/webhook/xxxxx"

# Slack 알림
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00/B00/xxxxx"

# Velog 초안 자동 생성 (토큰 소모 주의)
AUTO_BLOG_DRAFT=1
```

### 환경변수 로드 방법

#### 방법 A: direnv (권장)

```bash
# direnv 설치 (macOS)
brew install direnv

# shell 훅 추가 (한 번만)
# .zshrc 또는 .bashrc 에 다음 추가:
eval "$(direnv hook zsh)"   # zsh
eval "$(direnv hook bash)"  # bash

# 프로젝트 디렉토리에서
echo "dotenv" > .envrc
direnv allow
```

이후 프로젝트 디렉토리 진입 시 자동 로드.

#### 방법 B: 수동 로드

```bash
set -a && source .env && set +a
claude
```

#### 방법 C: Cron 내 인라인

```cron
0 9 * * 1 cd /path/to/project && set -a && source .env && set +a && claude -p "..." >> logs/weekly.log 2>&1
```

---

## 🕐 Cron 연동

### 기본 형식

```cron
분 시 일 월 요일 명령
```

KST 표준으로 작성. 서버가 UTC면 시간 환산 필요 (KST = UTC + 9).

### 추천 스케줄

```cron
# 일일 아침 분석 (매일 오전 8시 KST)
0 8 * * * cd /path/to/project && set -a && source .env && set +a && claude -p "/analyze-business 오늘의 초점 과제" >> logs/daily.log 2>&1

# 주간 종합 분석 (매주 월요일 오전 9시 KST)
0 9 * * 1 cd /path/to/project && set -a && source .env && set +a && claude -p "/analyze-business 주간 종합 리뷰" >> logs/weekly.log 2>&1

# 월간 가격 재검토 (매월 1일 오전 10시 KST)
0 10 1 * * cd /path/to/project && set -a && source .env && set +a && claude -p "/design-pricing 당월 재검토" >> logs/monthly-pricing.log 2>&1

# 분기 경쟁사 벤치마킹 (1, 4, 7, 10월 1일 오전 11시 KST)
0 11 1 1,4,7,10 * cd /path/to/project && set -a && source .env && set +a && claude -p "/benchmark-competitors 주력 카테고리" >> logs/quarterly.log 2>&1
```

### Crontab 편집

```bash
crontab -e
```

### Cron 로그 확인

```bash
tail -f /path/to/project/logs/weekly.log
```

### 실행 안 될 때

1. **절대 경로 사용**: `cd /path/to/project` 를 정확한 절대 경로로
2. **환경변수 로드**: `source .env` 포함 확인
3. **PATH 설정**: Cron 은 기본 PATH가 좁음. 필요시 crontab 상단에 추가:
   ```cron
   PATH=/usr/local/bin:/usr/bin:/bin
   ```
4. **claude CLI 경로 확인**: `which claude` 결과가 PATH에 포함되어야 함

---

## 📊 PPT 변환 파이프라인 연동

생성된 분석 리포트를 자동으로 PPT로 변환하는 예시. Jaewoo님의 기존 `pptxgenjs + LibreOffice + pdftoppm` 파이프라인과 호환.

### 스크립트 예시: `scripts/analysis-to-pptx.sh`

```bash
#!/bin/bash
set -euo pipefail

LATEST=$(ls -t reports/analysis-*.md | head -1)
OUTPUT="reports/$(basename "$LATEST" .md).pptx"

# 1. Claude Code로 PPT 스크립트 생성
claude -p "다음 마크다운 리포트를 pptxgenjs 기반 JS 스크립트로 변환해줘. 파일: $LATEST" \
  --output-format text > scripts/generated-ppt.js

# 2. PPT 생성
node scripts/generated-ppt.js --output "$OUTPUT"

# 3. QA용 PDF 변환
libreoffice --headless --convert-to pdf "$OUTPUT" --outdir reports/

# 4. 미리보기 PNG 생성
pdftoppm -r 100 "${OUTPUT%.pptx}.pdf" "reports/preview" -png

echo "완료: $OUTPUT"
```

실행:

```bash
chmod +x scripts/analysis-to-pptx.sh
./scripts/analysis-to-pptx.sh
```

### Cron 연동 (매주 월요일 리포트 생성 후 PPT까지)

```cron
# 9시: 분석
0 9 * * 1 cd /path/to/project && set -a && source .env && set +a && claude -p "/analyze-business 주간 리뷰" >> logs/weekly.log 2>&1

# 9시 30분: PPT 변환
30 9 * * 1 cd /path/to/project && ./scripts/analysis-to-pptx.sh >> logs/ppt-gen.log 2>&1
```

---

## 🔐 보안 고려사항

### .env 파일 관리

- **`.env` 는 `.gitignore` 에 포함되어 있습니다**. Git에 커밋되지 않도록 주의.
- 팀 공유가 필요하면 `.env.example` 만 커밋하고, 실제 값은 별도 채널로 전달.
- 프로덕션 환경은 환경변수 매니저(AWS Secrets Manager, Vault 등) 사용 권장.

### 웹훅 URL 유출 방지

- 웹훅 URL은 해당 채널에 메시지 발송 권한을 가집니다. 공개 저장소에 절대 커밋 금지.
- 실수로 커밋한 경우 즉시 웹훅 재발급.

### 로그 관리

- `./logs/reports.log` 에는 리포트 파일명만 기록됩니다 (내용 노출 없음).
- 필요시 로그 로테이션 설정:

```bash
# /etc/logrotate.d/consultant-kr
/path/to/project/logs/*.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
}
```

---

## 🧪 Hook 테스트 방법

### notify-on-report.sh 수동 테스트

```bash
# 가짜 리포트 생성
mkdir -p reports
cat > reports/analysis-20260425-1200.md <<EOF
## 1. 논점 정의
테스트 논점입니다.

## 2. 초기 가설
...
EOF

# Hook 스크립트 수동 실행
echo '{"tool_input":{"file_path":"reports/analysis-20260425-1200.md"}}' | \
  bash .claude/hooks/scripts/notify-on-report.sh

# 카카오워크 또는 Slack에 알림이 도착하면 성공
```

### load-context.sh 수동 테스트

```bash
bash .claude/hooks/scripts/load-context.sh
# 이전 리포트가 있으면 추출된 내용이 stdout 으로 출력됨
```

### inject-date.sh 수동 테스트

```bash
bash .claude/hooks/scripts/inject-date.sh
# 예상 출력: [현재 시각 컨텍스트] 2026-04-25 12:00:00 KST (토요일)
```

---

## 📚 추가 자료

- Claude Code Hooks 공식 문서: https://docs.claude.com/en/docs/claude-code/hooks
- Cron 문법: https://crontab.guru/
- direnv: https://direnv.net/
- 카카오워크 봇 API: https://docs.kakaoi.ai/kakao_work/webhookapi/
- Slack Incoming Webhooks: https://api.slack.com/messaging/webhooks

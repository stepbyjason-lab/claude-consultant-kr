# 예시 2: 주간 자동 분석 파이프라인 구축

매주 월요일 자동으로 사업 현황을 분석하고, 팀에 알림을 발송하며, Velog 블로그 초안까지 생성하는 완전 자동화 시나리오.

---

## 🎯 목표

- ✅ 매주 월요일 오전 9시 자동 분석 실행
- ✅ 결과를 카카오워크 팀 채널에 알림 발송
- ✅ 매주 월요일 오전 10시 자동으로 Velog 블로그 초안 생성

---

## 🏗️ 전체 아키텍처

```
[Cron: 매주 월요일 09:00 KST]
    ↓
[Claude Code 세션 시작]
    ↓
[SessionStart Hook: 지난주 리포트 컨텍스트 주입]
    ↓
[/analyze-business 실행]
    ↓
[consultant-kr 에이전트가 주간 비교 분석]
    ↓
[리포트 파일 생성 → Write 도구]
    ↓
[PostToolUse Hook]
    ├─ 카카오워크 알림
    └─ Slack 알림
    ↓
[Stop Hook: Velog 초안 자동 생성]
    ↓
[./blog-drafts/YYYYMMDD-velog.md 저장]
```

---

## 📋 설정 단계

### 1. 패키지 설치

```bash
cd ~/projects/my-saas
git clone https://github.com/gaebalai/claude-consultant-kr.git /tmp/cc
/tmp/cc/scripts/install.sh --local
```

### 2. 환경변수 설정

```bash
cp .env.example .env
vi .env
```

`.env` 내용:
```bash
# 카카오워크 팀 채널
KAKAOWORK_WEBHOOK_URL="https://bot.kakaowork.com/v1/webhook/YOUR_ID"

# Slack 경영진 채널 (선택)
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00/B00/YOUR_ID"

# Velog 블로그 초안 자동 생성 활성화
AUTO_BLOG_DRAFT=1
```

### 3. direnv 설정 (권장)

```bash
echo "dotenv" > .envrc
direnv allow
```

### 4. Crontab 등록

```bash
crontab -e
```

다음 라인 추가:

```cron
# 환경변수 경로 (claude CLI 위치 포함)
PATH=/usr/local/bin:/usr/bin:/bin:/Users/YOU/.npm-global/bin

# 주간 사업 분석 (매주 월요일 오전 9시 KST)
0 9 * * 1 cd /Users/YOU/projects/my-saas && set -a && source .env && set +a && claude -p "/analyze-business 주간 사업 현황 및 전주 대비 변화점" >> logs/weekly.log 2>&1
```

> **주의**: `/Users/YOU/projects/my-saas` 를 실제 프로젝트 절대 경로로 교체.

### 5. 동작 테스트

```bash
# 수동 실행 테스트 (Cron 설정 전 확인 권장)
cd /Users/YOU/projects/my-saas
set -a && source .env && set +a
claude -p "/analyze-business 테스트 실행"
```

확인 사항:
- [ ] `./reports/analysis-*.md` 파일 생성
- [ ] 카카오워크 채널에 알림 도착
- [ ] `./blog-drafts/*-velog.md` 파일 생성

---

## 📊 기대 결과물

### 월요일 오전 9시 — 카카오워크 알림

```
📊 사업 분석 리포트 생성 완료
파일: analysis-20260427-0900.md
시각: 2026-04-27 09:00 KST
논점: 지난 주 대비 핵심 지표 변화 분석 — 신규 가입자 수 23% 증가 원인 파악 필요
```

### 월요일 오전 9시 5분 — 리포트 파일

`./reports/analysis-20260427-0900.md`:
- 지난주 대비 변화점
- 이번 주 우선 과제
- 다음 주 예상 리스크

### 월요일 오전 9시 7분 — Velog 초안

`./blog-drafts/20260427-velog.md`:
- Velog frontmatter 포함
- 회사명 익명화 ("A사", "B 서비스")
- SEO 제목 3개 후보
- 블로그 어투로 재작성

사용자는 초안을 검토 → 편집 → 발행.

---

## 🎓 실전 팁

### 1. Cron 실패 디버깅

로그 확인:

```bash
tail -f /Users/YOU/projects/my-saas/logs/weekly.log
```

오류 패턴:
- `command not found: claude` → PATH 설정 미비
- `KAKAOWORK_WEBHOOK_URL: unbound variable` → .env 로드 실패
- `reports/: Permission denied` → 디렉토리 권한 문제

### 2. 분석 깊이 조정

너무 얕으면 프롬프트 구체화:

```text
/analyze-business 주간 사업 현황 — 다음을 필수 포함:
- 지난주 논점 대비 진척도
- 신규 감지된 리스크
- 이번 주 필수 액션 3가지
```

### 3. 다중 프로젝트 관리

여러 프로젝트를 주간 분석하려면 각각 Cron 라인 추가:

```cron
0 9 * * 1 cd /proj-a && source .env && claude -p "/analyze-business" >> /proj-a/logs/weekly.log 2>&1
0 9 * * 1 cd /proj-b && source .env && claude -p "/analyze-business" >> /proj-b/logs/weekly.log 2>&1
0 9 * * 1 cd /proj-c && source .env && claude -p "/analyze-business" >> /proj-c/logs/weekly.log 2>&1
```

### 4. 주간 요약 리포트 자동 통합

여러 프로젝트 리포트를 하나로 통합하는 별도 스크립트:

```bash
# scripts/weekly-digest.sh
#!/bin/bash
DIGEST=./reports/digest-$(date +%Y%m%d).md
echo "# 주간 사업 현황 통합 리포트" > "$DIGEST"
for proj in proj-a proj-b proj-c; do
  echo "## $proj" >> "$DIGEST"
  LATEST=$(ls -t /$proj/reports/analysis-*.md 2>/dev/null | head -1)
  awk '/^## 1\. 논점/,/^## 2\./' "$LATEST" >> "$DIGEST"
  echo "" >> "$DIGEST"
done
```

---

## 💰 비용 추정

주 1회 실행 기준 (Claude Sonnet):
- `/analyze-business`: ~30k 토큰 × $0.003/1k = **$0.09**
- `generate-blog-draft.sh`: ~20k 토큰 × $0.003/1k = **$0.06**
- **주당 약 $0.15**, **월 약 $0.60**

인간 컨설턴트 주간 리포트 비용 대비 사실상 무료.

---

## 🔐 보안 체크리스트

- [ ] `.env` 는 `.gitignore` 에 포함되어 있는가
- [ ] 웹훅 URL은 공개 저장소에 없는가
- [ ] `reports/` 디렉토리는 기밀 정보 포함 시 `.gitignore` 처리되는가
- [ ] Cron 로그에 민감 정보가 노출되지 않는가

---

## 🚀 확장 아이디어

이 파이프라인을 베이스로 확장 가능한 방향:

1. **Slack 슬래시 커맨드 연동**: 팀원이 `/analyze` 입력 시 즉시 분석
2. **GitHub Actions 통합**: 배포 후 자동 사업 영향 분석
3. **Notion 자동 업데이트**: 리포트를 Notion 페이지로 자동 전송
4. **경영진 대시보드**: 주간 리포트를 누적해 트렌드 차트 생성

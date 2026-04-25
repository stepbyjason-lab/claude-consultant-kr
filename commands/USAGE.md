# consultant-kr Slash Command 패키지

`consultant-kr` 에이전트를 실전 워크플로우에 묶는 4개 커맨드 세트.

---

## 포함된 커맨드

| 커맨드 | 용도 | 인자 |
| --- | --- | --- |
| `/analyze-business` | 전체 사업 전략 분석 + 리포트 자동 저장 | 분석 초점(선택) |
| `/design-pricing` | 한국 SaaS 기준 가격 정책 설계 | 타깃 세그먼트 |
| `/benchmark-competitors` | 국내 경쟁사 벤치마킹 (3C + SWOT) | 카테고리 |
| `/prioritize-features` | 기능/과제 우선순위 판단 (RICE + 파레토) | 판단 대상 |

---

## 설치

### 전제 조건
먼저 `consultant-kr` 에이전트가 설치되어 있어야 합니다.

```bash
# 아직 미설치 시
mkdir -p ~/.claude/agents
cp consultant-kr.md ~/.claude/agents/
```

### 커맨드 설치

**프로젝트 로컬 (권장 — 팀 공유 가능)**

```bash
mkdir -p .claude/commands
cp commands/*.md .claude/commands/
```

**전역 (개인 환경 전체)**

```bash
mkdir -p ~/.claude/commands
cp commands/*.md ~/.claude/commands/
```

### 설치 확인

```bash
claude
# 세션 진입 후
/
# 자동완성 목록에서 analyze-business, design-pricing 등이 보이면 정상
```

---

## 사용 예시

### 1. 전체 사업 분석

```text
/analyze-business
```

인자 없이 실행하면 전반적 사업 전략 분석. 결과는 `./reports/analysis-YYYYMMDD-HHMM.md` 로 저장.

특정 주제로 초점 맞추기:

```text
/analyze-business MVP 론칭 전 2주간 필수 개선 과제
```

### 2. 가격 정책 설계

```text
/design-pricing 소상공인 B2C SaaS
```

출력 예상:
- 3단계 플랜 (원화, VAT 별도 명기)
- 연간 결제 할인 반영
- 아임웹/식스샵/카페24 가격 비교 테이블
- 업그레이드 유도 포인트

### 3. 경쟁사 벤치마킹

```text
/benchmark-competitors 노코드 홈페이지 빌더
```

출력 예상:
- 국내 주력 3~5개사 기능 매트릭스
- 3C + SWOT 분석
- 차별화 가능 포인트 TOP 3

### 4. 기능 우선순위 판단

```text
/prioritize-features 다음 스프린트 기능 7개 중 3개 선정 (개발자 2명, 4주)
```

출력 예상:
- RICE 스코어 테이블
- 파레토 원칙 기반 선정 근거
- 탈락 기능의 재검토 조건

---

## Cron 자동화 — 정기 리포트 파이프라인

주간/월간 정기 분석을 자동화하려면 crontab에 등록합니다.

```bash
crontab -e
```

### 매주 월요일 오전 9시 (KST) 사업 분석

```cron
0 9 * * 1 cd /path/to/project && claude -p "/analyze-business 주간 사업 현황" --output-format text >> logs/weekly.log 2>&1
```

### 매월 1일 오전 10시 (KST) 가격 재검토

```cron
0 10 1 * * cd /path/to/project && claude -p "/design-pricing 현재 타깃 세그먼트 유지 전제" >> logs/monthly-pricing.log 2>&1
```

### 분기별 경쟁사 벤치마킹 (1/4/7/10월 1일)

```cron
0 11 1 1,4,7,10 * cd /path/to/project && claude -p "/benchmark-competitors 주력 카테고리" >> logs/quarterly-benchmark.log 2>&1
```

> **KST 주의**: 서버가 UTC면 시간 환산 필요. 한국 서버 기본값은 KST이므로 위 표기 그대로 사용 가능.

---

## PPT 변환 파이프라인 연동

Jaewoo님의 기존 `pptxgenjs + LibreOffice + pdftoppm` 파이프라인과 연결.

### 예시 스크립트 (`scripts/analysis-to-pptx.sh`)

```bash
#!/bin/bash
# 최신 분석 리포트 → PPT 변환

LATEST=$(ls -t reports/analysis-*.md | head -1)
OUTPUT="reports/$(basename $LATEST .md).pptx"

# 1. Claude Code로 PPT 스크립트 생성
claude -p "다음 마크다운 리포트를 pptxgenjs 기반 JS 스크립트로 변환해줘. 파일: $LATEST" \
  --output-format text > scripts/generated-ppt.js

# 2. PPT 생성
node scripts/generated-ppt.js --output $OUTPUT

# 3. QA용 PDF 변환
libreoffice --headless --convert-to pdf $OUTPUT --outdir reports/
pdftoppm -r 100 "${OUTPUT%.pptx}.pdf" "reports/preview" -png

echo "완료: $OUTPUT"
```

실행:

```bash
chmod +x scripts/analysis-to-pptx.sh
./scripts/analysis-to-pptx.sh
```

---

## 트러블슈팅

### 커맨드가 목록에 안 나타날 때

```bash
# 권한 확인
ls -la .claude/commands/
# 또는
ls -la ~/.claude/commands/

# 파일명 확인 (.md 확장자 필수)
# frontmatter에 description 필드 존재 확인
head -5 .claude/commands/analyze-business.md
```

### consultant-kr 에이전트가 호출 안 될 때

```bash
claude
/agents
# 목록에 consultant-kr 없으면 에이전트 미설치 → consultant-kr.md 재설치 필요
```

### 인자가 전달 안 될 때

Slash command 내부에서 `$ARGUMENTS` 가 전달됩니다. 
전달 확인용 테스트:

```text
/analyze-business 테스트 인자입니다
```

에이전트 출력에 "테스트 인자입니다" 문자열이 반영되는지 확인.

---

## 커스터마이징 포인트

### 리포트 저장 경로 변경

`analyze-business.md` 의 다음 부분 수정:

```markdown
- 파일명: `./reports/analysis-{YYYYMMDD-HHMM}.md`
```

### 출력 언어 강제

각 커맨드 frontmatter 아래 지시사항에 추가:

```markdown
- 모든 출력은 한국어로 작성
- 기술 용어는 영문 병기 (예: 마이크로서비스(Microservices))
```

### 산업별 특화 커맨드 추가

건설 산업 특화가 필요하면 `analyze-business-construction.md` 같이 파일명을 다르게 해서 추가. 
에이전트도 `consultant-kr-construction.md` 로 별도 정의하면 KCS-AI 프로젝트 전용 분석 가능.

---

## 다음 단계 (Hook 연동)

정기 분석 리포트를 자동으로 Slack/카카오워크에 전송하려면 Hook 설정이 필요합니다.
이 패키지의 다음 확장 단계는 **PostToolUse Hook**으로 리포트 생성 시 알림 자동화입니다.

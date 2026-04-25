# FAQ — 자주 묻는 질문

## 📦 설치 · 설정

### Q. Claude Code 유료 플랜이 필수인가요?

Claude Code 자체는 무료/유료 플랜 모두 사용 가능합니다. 단, 일일 분석을 자동화하는 경우 Pro/Max 플랜의 토큰 한도가 더 여유롭습니다.

### Q. 프로젝트 로컬 설치와 전역 설치, 어느 것이 좋나요?

| 상황 | 권장 |
|---|---|
| 팀 공유 필요 | 로컬 (Git 커밋 가능) |
| 개인 전체 사용 | 전역 |
| 프로젝트별 커스터마이징 | 로컬 |
| 설치/관리 간편함 | 전역 |

둘 다 설치 가능하며, 같은 이름의 에이전트가 있으면 **로컬이 우선 적용**됩니다.

### Q. 설치 후 `/agents` 목록에 안 나타나요.

다음 순서로 확인:

1. 파일 위치: `.claude/agents/consultant-kr.md` 또는 `~/.claude/agents/consultant-kr.md`
2. frontmatter 문법: 파일 상단 `---` 블록 확인
3. Claude Code 재시작: `exit` 후 다시 `claude`

### Q. macOS에서 설치 스크립트가 실행이 안 됩니다.

```bash
# 실행 권한 부여
chmod +x scripts/install.sh

# Bash 버전 확인 (4.0 이상 필요)
bash --version

# 낡은 Bash면 Homebrew로 업그레이드
brew install bash
```

### Q. Windows에서는 어떻게 설치하나요?

현재 WSL2 환경을 권장합니다. PowerShell 네이티브 지원은 로드맵에 있습니다.

```powershell
# WSL2 진입 후
wsl
cd /mnt/c/Users/you/projects/claude-consultant-kr
./scripts/install.sh --global
```

---

## 🤖 사용

### Q. 에이전트 호출은 `@consultant-kr` 만 가능한가요?

아뇨, 여러 방법이 있습니다.

1. **명시적 호출**: `@consultant-kr 분석 시작`
2. **자동 위임**: "사업 전략 분석해줘" 같은 맥락에서 Claude가 자동 선택
3. **슬래시 커맨드 통한 간접 호출**: `/analyze-business`

초기에는 명시적 호출이 가장 확실합니다.

### Q. 분석이 너무 간단/과하게 나와요.

에이전트 정의의 "출력 포맷" 섹션을 조정하거나, 프롬프트에 추가 지시:

```text
/analyze-business 현재 SaaS 사업 평가 (각 섹션 최소 500자 이상 상세히)
```

또는:

```text
/analyze-business 간략하게 (각 섹션 3줄 이내)
```

### Q. 글로벌 사례(Stripe, Slack 등)만 계속 나옵니다.

몇 가지 원인과 해법:

1. **분석 대상이 글로벌 시장임**: 정상 동작
2. **한국 시장 명시 안 함**: 프롬프트에 "한국 시장 기준" 추가
3. **에이전트 버전이 낡음**: 최신 버전 재설치

```text
/analyze-business 반드시 한국 국내 경쟁사 · 결제 · 플랫폼 기준으로 분석
```

### Q. 여러 프로젝트에서 다른 설정을 쓰고 싶어요.

프로젝트 로컬 설치가 전역보다 우선합니다:

```bash
# 프로젝트 A
cd ~/project-a
./scripts/install.sh --local

# 프로젝트 B (다른 설정)
cd ~/project-b
./scripts/install.sh --local
# 이후 .claude/agents/consultant-kr.md 수정
```

### Q. 리포트 저장 경로를 바꾸고 싶어요.

`commands/analyze-business.md` 수정:

```markdown
- 파일명: `./custom-path/analysis-{YYYYMMDD-HHMM}.md`
```

---

## 🔔 Hook · 알림

### Q. 카카오워크 알림이 안 와요.

체크리스트:

1. `.env` 파일에 `KAKAOWORK_WEBHOOK_URL` 입력했나?
2. `.env` 가 실제로 로드되었나? (`echo $KAKAOWORK_WEBHOOK_URL` 로 확인)
3. 웹훅 URL이 유효한가? (curl로 수동 테스트)
4. 방화벽/프록시가 외부 요청 차단 중인가?

수동 테스트:

```bash
curl -X POST "$KAKAOWORK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"text": "테스트 메시지"}'
```

### Q. Hook이 세션을 너무 느리게 만들어요.

Hook 스크립트에 무거운 작업(큰 파일 읽기, 네트워크 호출)이 있으면 세션 시작이 느려질 수 있습니다. 해결책:

1. `SessionStart Hook` 간소화: 이전 리포트 1개만 요약
2. 네트워크 호출은 `PostToolUse` 같이 비동기성 높은 시점으로 이동
3. 필요 없는 Hook은 `settings.json` 에서 제거

### Q. `generate-blog-draft.sh` 가 무한 루프에 빠집니다.

`CLAUDE_HOOK_DEPTH` 환경변수로 재귀 방지 로직이 들어있지만, 환경에 따라 실패 가능. 임시 비활성화:

```bash
# .env
AUTO_BLOG_DRAFT=0
```

또는 `settings.json` 에서 `Stop Hook` 블록 제거.

### Q. Cron 자동 실행 시 "command not found: claude" 오류.

Cron 은 기본 PATH가 좁아 `claude` 위치를 못 찾을 수 있습니다. crontab 상단에 PATH 명시:

```cron
PATH=/usr/local/bin:/usr/bin:/bin:/home/USER/.npm-global/bin

0 9 * * 1 cd /path/to/project && ...
```

또는 claude 의 절대 경로 사용:

```cron
0 9 * * 1 cd /path/to/project && /home/USER/.npm-global/bin/claude -p "..." >> log 2>&1
```

---

## 💰 비용 · 토큰

### Q. 이 패키지가 Claude 사용량을 늘리나요?

각 커맨드 호출당 일반 대화보다 더 많은 토큰을 소비합니다. 다만 서브에이전트는 별도 컨텍스트를 쓰므로 메인 세션의 누적 토큰은 오히려 줄어듭니다.

대략적 토큰 추정 (Claude Sonnet 기준):
- `/analyze-business`: 20k ~ 50k 토큰
- `/design-pricing`: 10k ~ 25k 토큰
- `/benchmark-competitors`: 30k ~ 70k 토큰 (WebSearch 포함)
- `/prioritize-features`: 10k ~ 20k 토큰

### Q. 토큰 사용량을 측정하고 싶어요.

Jaewoo님의 `claude-token-meter` NPX 패키지를 활용 가능합니다:

```bash
npx claude-token-meter
```

또는 본 리포의 `token-meter` 스킬 참고 (향후 추가 예정).

### Q. 자동 실행 시 비용이 걱정됩니다.

대책:

1. **주 1회 정도로 빈도 조절**: 일일 실행은 과함
2. **AUTO_BLOG_DRAFT 비활성화**: Stop Hook 의 Claude 재호출 방지
3. **로컬 테스트 먼저**: 프로덕션 Cron 설정 전 수동 실행으로 결과 확인

---

## 🛠️ 개발 · 기여

### Q. 에이전트 개선 PR을 만들고 싶어요.

[CONTRIBUTING.md](../CONTRIBUTING.md) 참고.

특히 다음 영역이 환영됩니다:
- 국내 경쟁사 매핑 업데이트
- 산업별 특화 에이전트
- 실전 사용 사례
- 다국어 번역

### Q. 버그를 발견했어요.

GitHub Issues 에 다음 정보와 함께 제보:

- OS (macOS/Linux/WSL2)
- Claude Code 버전 (`claude --version`)
- 재현 절차
- 기대 동작 vs 실제 동작
- 관련 로그 (`./logs/`)

### Q. 기능 제안은 어디에?

GitHub Discussions 에서 먼저 논의 → 반응 좋으면 Issue 전환 → PR.

---

## 🌏 기타

### Q. 영어로도 쓸 수 있나요?

가능합니다. 에이전트 정의 상단에 추가:

```markdown
## 출력 언어
- 모든 출력은 영어로 작성
- 단, 한국 경쟁사·서비스명은 한글 병기 (예: Imweb(아임웹))
```

또는 `consultant-kr-en.md` 로 영어 버전 별도 생성.

### Q. 다른 국가 시장용 버전은 없나요?

공식으로는 한국 버전만 제공합니다. 다른 국가 버전을 만드실 분은 다음 포크 권장:

- `consultant-jp` (일본)
- `consultant-sg` (싱가포르)
- `consultant-us` (미국)

커스터마이징 방법은 [CUSTOMIZING.md](./CUSTOMIZING.md) 참고.

### Q. 이 패키지의 철학은 무엇인가요?

> **"글로벌 AI 도구를 한국 시장 1급 시민으로 만든다"**

Claude 같은 강력한 도구는 영어·글로벌 시장 기본값으로 설계됩니다. 국내 환경에서 실제 가치를 내려면 시장 컨텍스트가 도구 자체에 내장되어야 합니다. 이 패키지는 그 격차를 메우는 시도입니다.

---

## 🆘 더 많은 도움이 필요하면

- GitHub Issues: 버그 · 기능 요청
- GitHub Discussions: 사용법 질문 · 워크플로우 공유
- Velog: [@gaebalai](https://velog.io/@gaebalai) 의 Claude Code 관련 포스트

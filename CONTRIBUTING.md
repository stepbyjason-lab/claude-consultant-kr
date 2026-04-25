# 기여 가이드 (CONTRIBUTING)

`claude-consultant-kr` 에 관심 가져주셔서 감사합니다. 이 문서는 기여 방법을 안내합니다.

---

## 🤝 기여 방향

### 환영하는 기여

1. **경쟁사 벤치마크 매핑 업데이트** — 신규 국내 플레이어 추가
2. **산업별 특화 에이전트** — `agents/consultant-kr-{industry}.md` 형태
3. **실전 사용 사례** — `examples/` 디렉토리에 케이스 스터디 추가
4. **버그 리포트 · 기능 제안** — 이슈 트래커 활용
5. **다국어 README** — 영어/중국어/일본어 등
6. **문서 개선** — `docs/` 디렉토리 내 가이드 보완
7. **Hook 스크립트 확장** — Discord, Telegram 등 알림 채널 추가

---

## 📋 기여 절차

### 1. 이슈 먼저 논의

큰 변경 전에는 이슈를 열어 논의합니다. 작은 오타/버그 수정은 바로 PR 가능.

### 2. 포크 → 브랜치 → PR

```bash
# 포크 후 클론
git clone https://github.com/YOUR_USERNAME/claude-consultant-kr.git
cd claude-consultant-kr

# 브랜치 생성 (컨벤션: type/short-description)
git checkout -b feat/fintech-agent
# 또는
git checkout -b fix/install-script-macos
# 또는
git checkout -b docs/korean-faq

# 변경 작업
# ...

# 커밋 (Conventional Commits 권장)
git commit -m "feat(agents): add fintech industry agent"

# 푸시 후 PR 생성
git push origin feat/fintech-agent
```

### 3. 커밋 메시지 규칙 (Conventional Commits)

```
<type>(<scope>): <subject>

[body]

[footer]
```

- `feat`: 새 기능 추가
- `fix`: 버그 수정
- `docs`: 문서만 변경
- `refactor`: 리팩토링
- `test`: 테스트 추가/수정
- `chore`: 빌드/설정 변경

예시:
- `feat(agents): add healthcare industry agent`
- `fix(hooks): handle empty report directory gracefully`
- `docs(readme): add screenshot of /analyze-business output`

---

## 🧪 PR 체크리스트

제출 전 다음을 확인해주세요.

- [ ] 파일이 올바른 디렉토리에 있는가 (`agents/`, `commands/`, `hooks/`, `docs/`, `examples/`)
- [ ] 에이전트/커맨드 파일에 `frontmatter` 가 올바르게 있는가
- [ ] Hook 스크립트의 경우 `set -euo pipefail` 포함 및 실행 권한(`chmod +x`) 설정
- [ ] README 또는 관련 문서 업데이트
- [ ] 한국어 표현은 자연스러운가 (직역체 피하기)
- [ ] 국내 서비스명 표기가 올바른가 (공식 표기 준수)

---

## 🏗️ 파일 컨벤션

### 에이전트 (`agents/`)

파일명: `consultant-kr-{industry}.md`  
frontmatter 필수 필드:

```yaml
---
name: consultant-kr-{industry}
description: {200자 이내 한국어 설명, 호출 키워드 포함}
tools:
  - Read
  - Grep
  - Glob
  - WebFetch
  - WebSearch
---
```

**권장사항**:
- 금융/의료 등 규제 민감 산업은 관련 법 · 인증 섹션 필수
- "행동 지침 → 해야 할 것 / 하지 말 것" 섹션 유지
- 출력 포맷은 8단계 구조 준수 (또는 명확한 대안 제시)

### 슬래시 커맨드 (`commands/`)

frontmatter 필수 필드:

```yaml
---
description: {명령 설명}
argument-hint: {인자 가이드}
allowed-tools: {사용 도구 명시}
---
```

### Hook 스크립트 (`hooks/scripts/`)

- Bash 스크립트는 `#!/bin/bash` 및 `set -euo pipefail` 로 시작
- 상단에 주석 블록으로 목적 · 동작 · 환경변수 문서화
- 실패 시 silent exit 원칙 (세션 방해 방지)
- 필요 시 로컬 로그(`./logs/`) 남기기

---

## 🌏 국내 서비스 표기 가이드

기여 시 아래 공식 표기를 준수해주세요.

| 잘못된 표기 | 올바른 표기 |
|---|---|
| 네이버페이, 네이버 페이 | 네이버페이 |
| 카카오톡 페이 | 카카오페이 |
| 아임포트 | 포트원 (구 아임포트) |
| 업비트코인 | 업비트 |
| 뱅크샐러드 | 뱅크샐러드 |
| 카페24몰 | 카페24 |
| 벨로그 | Velog |
| 티스토리 | Tistory |
| 젠데스크 | Zendesk |

확실치 않은 경우 공식 홈페이지 표기를 따릅니다.

---

## 🧑‍⚖️ 행동 강령

친절하게, 존중하며 기여합니다. 차별적 · 공격적 표현은 금지합니다.

---

## 📜 라이선스

본 리포지토리에 기여하는 모든 코드/문서는 MIT 라이선스 하에 배포됨에 동의하는 것으로 간주됩니다.

---

## 💬 문의

- 기술 질문: GitHub Discussions
- 버그/기능 요청: GitHub Issues
- 비공개 문의: (메인테이너 연락처는 프로필 참고)

감사합니다! 🙏

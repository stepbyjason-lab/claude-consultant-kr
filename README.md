# claude-consultant-kr

> 🇰🇷 한국 시장 컨텍스트로 맥킨지식 사업 전략을 분석하는 비공식 Claude Code 에이전트 패키지
>
> *맥킨지 · BCG식 사고 체계를 Claude Code에 이식하고, 국내 SaaS · 스타트업 · 엔터프라이즈 환경에서 실행 가능한 전략을 자동 생성합니다.*

> **npm 패키지**: [`consultant-kr-cli`](https://www.npmjs.com/package/consultant-kr-cli) · **저장소**: `gaebalai/claude-consultant-kr`
> Anthropic 비공식 도구이며, "Claude" 는 Anthropic, PBC 의 상표입니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-blue)](https://docs.claude.com/en/docs/claude-code)
[![npm](https://img.shields.io/badge/npm-consultant--kr--cli-cb3837)](https://www.npmjs.com/package/consultant-kr-cli)
[![Korean](https://img.shields.io/badge/Localized-Korean-red)](./README.md)
[![Made by gaebalai](https://img.shields.io/badge/Made%20by-gaebalai-purple)](https://github.com/gaebalai)

---

## 🎯 이 패키지가 해결하는 문제

Claude Code를 사업 분석에 쓰다 보면 반복되는 불편이 있습니다.

- 매번 프롬프트에 "맥킨지처럼 분석해줘" 를 다시 써야 합니다
- 글로벌 레퍼런스(Wix, Stripe, Slack)가 한국 서비스 분석에 그대로 끼어듭니다
- 가격 제안이 달러·엔화 환산값으로 나와 국내 체감과 어긋납니다
- "두 안 모두 유효합니다" 같은 애매한 답변으로 끝납니다

**`claude-consultant-kr`** 은 이 문제를 3개 레이어로 해결하고, 선택적 외부 연동까지 제공합니다.

| 레이어 | 역할 | 파일 위치 |
|---|---|---|
| **Agent** | 맥킨지식 사고 + 한국 시장 컨텍스트가 내장된 서브에이전트 | `agents/consultant-kr.md` |
| **Slash Command** | 사업 분석·가격 설계·경쟁사 벤치마킹·기능 우선순위 판단 | `commands/*.md` |
| **Hook** | 이전 맥락 자동 로드, 카카오워크·Slack 알림, Velog 초안 자동 생성 | `hooks/` |
| **외부 연동** *(선택)* | 분석 리포트의 AI 문체를 자연스러운 한국어로 윤문 — Humanize KR 동적 fetch | `scripts/install-humanize.sh` |

---

## ⚡ 빠른 시작 (30초)

### 방법 1: `npx` 원라이너 (권장)

클론도 다운로드도 없이 한 줄로 설치됩니다. Node.js 14+ 필요.

```bash
# 프로젝트 로컬 설치 (현재 디렉토리의 .claude/ 에 배치)
npx consultant-kr-cli@latest --local

# 전역 설치 (~/.claude/ 에 배치, 모든 프로젝트에서 사용)
npx consultant-kr-cli@latest --global

# 설치 상태 확인 / 제거
npx consultant-kr-cli@latest --check
npx consultant-kr-cli@latest --uninstall
```

> **지원 플랫폼**: macOS · Linux · WSL2. Windows 네이티브 PowerShell/CMD 는 미지원입니다.
>
> <details>
> <summary>🪟 Windows 사용자 안내 (펼쳐보기)</summary>
>
> 이 패키지는 bash 기반 설치·Hook 스크립트를 사용하므로 Windows 네이티브 셸에서는 동작하지 않습니다. **WSL2 + Ubuntu** 환경을 권장합니다 (Microsoft 공식 권장 Windows 개발 환경).
>
> ```powershell
> # PowerShell 관리자 권한
> wsl --install -d Ubuntu
> # 재부팅 후 Ubuntu 실행, 사용자 계정 생성
> ```
>
> WSL 안에서는 일반 Linux 환경처럼 npx 명령이 그대로 동작합니다.
>
> ```bash
> # WSL Ubuntu 안에서
> sudo apt update && sudo apt install -y nodejs npm
> npx consultant-kr-cli@latest --local
> ```
>
> 주의: WSL 의 `~` (사용자 홈) 은 Windows 의 `C:\Users\xxx` 와 다른 별개 경로입니다. `--global` 설치 시 WSL 사용자 홈 (`/home/<user>/.claude/`) 에 배치됩니다.
>
> </details>
>

### 방법 2: 저장소 클론

```bash
git clone https://github.com/gaebalai/claude-consultant-kr.git
cd claude-consultant-kr

./scripts/install.sh --local    # 프로젝트 로컬
./scripts/install.sh --global   # 전역
```

설치 확인:

```bash
claude
/agents          # consultant-kr 표시 확인
/                # 자동완성 목록에 analyze-business 등 4개 커맨드 확인
```

첫 분석 실행:

```text
/analyze-business
```

---

## 📦 포함 구성

### 1. 에이전트 (`agents/consultant-kr.md`)

맥킨지 · BCG식 사고 체계를 주입한 비즈니스 컨설턴트.

- **공우산 프레임워크**: 사실(空) → 해석(雨) → 제안(傘)
- **MECE · 피라미드 스트럭처 · 3C · SWOT · 4P** 내장
- **한국 시장 컨텍스트 테이블**: 노코드 빌더 · 결제 · 클라우드 · 블로그 등 10개 카테고리
- **가격 대역 재매핑**: 엔화 단순 환산 방지, B2C · B2B 원화 기준
- **법 · 규제 컨텍스트**: PIPA · ISMS-P · CSAP · 전자금융거래법
- **권한 분리**: Read / Grep / Glob / WebFetch / WebSearch만 허용 (Edit / Write 제외)

#### 🆕 산업 특화 파생 에이전트 4종 (`agents/industry/`)

베이스 에이전트를 계승하면서 각 산업의 규제 · 경쟁 · 수익 구조를 내장:

| 에이전트 | 분야 | 주요 내장 컨텍스트 |
|---|---|---|
| `consultant-kr-fintech` | 핀테크 · 전자금융 · 가상자산 | 전자금융거래법 · 특금법 · 금보원 기준 · 샌드박스 |
| `consultant-kr-healthcare` | 디지털치료제 · 의료기기 · 원격의료 | 의료법 · SaMD 등급 · HIRA 급여 · 선진입 후평가 |
| `consultant-kr-construction` | 스마트건설 · BIM · 건설안전 | 건설산업기본법 · 중대재해처벌법 · KCS · 공공 조달 |
| `consultant-kr-ecommerce` | D2C · 오픈마켓 · 크로스보더 | 전자상거래법 · 오픈마켓 수수료 · 풀필먼트 생태계 |

선택적 설치:

```bash
# npx 방식
npx consultant-kr-cli@latest industry --local --fintech --healthcare
npx consultant-kr-cli@latest industry --local    # 대화형

# 클론 방식
./scripts/install-industry.sh --local --fintech --healthcare
./scripts/install-industry.sh --local               # 대화형
```

자세한 내용은 [`agents/industry/README.md`](./agents/industry/README.md) 참고.

#### 🔌 외부 연동: Humanize KR (선택)

[gaebalai/im-not-ai](https://github.com/gaebalai/im-not-ai) (MIT, `epoko77-ai/im-not-ai` 의 fork) 의 "한글 AI 티 제거기" 를 함께 설치할 수 있습니다. 분석 리포트 초안의 AI 문체를 자연스러운 한국어로 윤문할 때 유용하며, 우리 분석 커맨드 4종에 자동 통합됩니다.

설치되는 항목: 에이전트 6개 + 슬래시 커맨드 6개 (`/humanize`, `/humanize-detect`, `/humanize-redo`, `/humanize-status`, `/humanize-list`, `/humanize-web`) + 스킬 1개 (`humanize-korean`) + LICENSE 사본.

```bash
npx consultant-kr-cli@latest humanize --local    # 프로젝트 로컬
npx consultant-kr-cli@latest humanize --global   # 전역
npx consultant-kr-cli@latest humanize --check    # 상태 확인
npx consultant-kr-cli@latest humanize --uninstall

# 비대화형 (CI 등): 라이선스 고지 자동 동의
npx consultant-kr-cli@latest humanize --local --yes
```

설치 후 다음 두 가지 방식으로 활용할 수 있습니다.

**1. 자동 통합** — `/analyze-business` 등 분석 커맨드를 호출하면 결과 출력 후 자동으로 한국어 윤문이 적용됩니다 (스킬이 설치돼 있을 때만).

**2. 직접 호출** — 슬래시 커맨드 또는 자연어로 직접 호출:

```text
> /humanize <텍스트 또는 파일 경로>
> /humanize-detect <텍스트>      # AI 티 탐지만
> /refine-report                  # 가장 최근 분석 리포트 윤문
> AI 티 없애줘                    # 자연어 트리거
```

> ℹ **라이선스**: 원본 리포 [`gaebalai/im-not-ai`](https://github.com/gaebalai/im-not-ai) 는 **MIT 라이선스**로 배포됩니다. 본 패키지는 원본을 재배포하지 않고, 설치 시점에 사용자 환경에서 GitHub raw URL 로 직접 다운로드를 수행하며, 원본 LICENSE 사본도 함께 받아 보존합니다.
>
> ⚠ **업스트림 추적 안내**: 설치는 `gaebalai/im-not-ai` 의 `main` 브랜치를 fetch 합니다. 원본이 향후 변경되면 다음 설치/재설치 시 그대로 적용됩니다. 운영 환경에서는 한 번 설치 후 업그레이드를 신중히 검토하세요. (특정 commit 핀 옵션은 0.4.0+ 마일스톤 예정)

### 2. Slash Commands (`commands/`)

| 커맨드 | 용도 | 인자 예시 |
|---|---|---|
| `/analyze-business` | 전체 사업 전략 분석 + 자동 리포트 저장 + (옵션) 한국어 윤문 | `MVP 론칭 전 2주 과제` |
| `/design-pricing` | 원화 · VAT · 연간할인 반영 3단계 가격안 + (옵션) 한국어 윤문 | `소상공인 B2C SaaS` |
| `/benchmark-competitors` | 국내 경쟁사 벤치마킹 (3C + SWOT) + (옵션) 한국어 윤문 | `노코드 홈페이지 빌더` |
| `/prioritize-features` | RICE + 파레토 기반 우선순위 판단 + (옵션) 한국어 윤문 | `기능 7개 중 3개 선정` |
| `/refine-report` 🆕 | 기존 리포트를 humanize-korean 으로 사후 윤문 (`*-refined.md` 별도 저장) | (생략 시 가장 최근 리포트) |

> "한국어 윤문" 단계는 `humanize-korean` 스킬 설치 시에만 동작합니다. 미설치 시 한 줄 안내만 출력되고 건너뜁니다. 설치: `npx consultant-kr-cli@latest humanize --local`

### 3. Hooks (`hooks/`)

| Hook 시점 | 스크립트 | 동작 |
|---|---|---|
| `SessionStart` | `load-context.sh` | 이전 리포트의 논점 · 추천 시책을 세션 컨텍스트에 자동 주입 |
| `UserPromptSubmit` | `inject-date.sh` | KST 현재 시각 · 요일 주입 ("오늘", "이번 주" 정확 해석) |
| `PostToolUse:Write` | `notify-on-report.sh` | 리포트 저장 시 카카오워크 · Slack 웹훅 병렬 알림 |
| `Stop` | `generate-blog-draft.sh` | 세션 종료 시 오늘 리포트를 Velog 초안으로 자동 변환 |

---

## 🖼️ 스크린샷

> *참고: 실제 사용 화면 캡처는 `docs/images/` 에 추가 예정*

<!-- TODO: 설치 직후 /agents 화면 -->
<!-- TODO: /analyze-business 실행 결과 -->
<!-- TODO: 카카오워크 알림 수신 화면 -->

---

## 📖 상세 문서

- [설치 가이드](./docs/INSTALL.md) — 프로젝트 로컬 vs 전역, 수동 설치 절차
- [사용 예시](./docs/USAGE.md) — 4개 커맨드별 실전 활용 사례
- [Hook 설정](./docs/HOOKS.md) — 웹훅 URL 발급, 환경변수, Cron 연동
- [커스터마이징](./docs/CUSTOMIZING.md) — 산업별 특화 에이전트 파생 방법
- [FAQ](./docs/FAQ.md) — 자주 묻는 질문과 트러블슈팅

---

## 🧪 실전 예시

### 예시 1: SaaS 사업 분석

```text
/analyze-business 템플릿 기반 홈페이지 빌더의 국내 시장 진입 전략
```

출력:
- **논점 정의**: "기존 대형 플레이어(아임웹 · 식스샵 · 카페24)를 앞두고, 어느 타깃 세그먼트에 특화해야 지속 가능한가"
- **공(사실)**: 코드베이스 직독 결과 (구현된 기능 / 미구현 기능)
- **우(해석)**: 사업 · 사용자 관점 함의
- **산(제안)**: Phase 1/2/3 로드맵 (리소스 · 기한 포함)

### 예시 2: 가격 정책 설계

```text
/design-pricing 중소기업 B2B 협업 도구
```

출력:
| 플랜 | 월액 | 연간 (20% 할인) | VAT |
|---|---|---|---|
| 라이트 | ₩9,900/좌석 | ₩95,040/좌석 | 별도 |
| 스탠다드 | ₩19,000/좌석 | ₩182,400/좌석 | 별도 |
| 프리미엄 | ₩49,000/좌석 | ₩470,400/좌석 | 별도 |

국내 경쟁사(잔디 · 카카오워크 · 두레이) 포지셔닝 비교 포함.

---

## 🚀 왜 이 패키지인가

- ✅ **한국 시장이 1급 시민** — 글로벌 레퍼런스가 부록이 아님
- ✅ **프레임워크 내장** — 맥킨지 · BCG 식 사고 즉시 활용
- ✅ **"두 안 모두 유효" 금지** — 명확한 1안 추천 강제
- ✅ **자동화 준비 완료** — Cron + Hook으로 완전 무인 파이프라인
- ✅ **토큰 효율** — 서브에이전트로 메인 컨텍스트 오염 최소화
- ✅ **확장 용이** — 산업별(건설 · 핀테크 · 헬스케어) 파생 에이전트 템플릿 제공
- ✅ **npx 한 줄 설치** — 클론·다운로드 없이 즉시 사용, 외부 스킬도 옵트인 fetch

---

## 🤝 기여

PR · 이슈 · 토론 환영합니다. 자세한 가이드라인은 [CONTRIBUTING.md](./CONTRIBUTING.md) 참조.

특히 다음 기여를 환영합니다.
- 국내 경쟁사 벤치마크 매핑 업데이트 (신규 플레이어 추가)
- 산업별 특화 에이전트 (`consultant-kr-{industry}.md`)
- 실전 사용 사례 (`examples/` 디렉토리)
- 다국어 README (일본어 · 중국어 등 추가 번역)

---

## 📜 라이선스

MIT © [gaebalai](https://github.com/gaebalai)

---

## 💬 커뮤니티

- **Velog 블로그**: 사용기 · 커스터마이징 팁 공유 (Tag: `claude-code`, `consultant-kr`)
- **이슈 트래커**: 버그 리포트 · 기능 제안
- **Discussions**: 국내 AI 컨설팅 워크플로우 토론

---

## 🙏 크레딧

이 패키지는 Claude Code 에이전트 기능에 관한 기술 문서를 한국 시장 컨텍스트로 재해석하며 시작되었습니다. 원문 저자, Anthropic의 Claude Code 팀, 그리고 국내 Claude 사용자 커뮤니티에 감사드립니다.

---

**Made with ❤️ by [gaebalai](https://github.com/gaebalai) — AI-fluent liberal arts Engineer**

---

## 🔌 이 포크에 대하여 (fork + minimal-additive)

이 저장소는 [`gaebalai/claude-consultant-kr`](https://github.com/gaebalai/claude-consultant-kr)의 개인 공개 포크입니다. 원작을 새로 저술한 것이 아니라, **원본 콘텐츠를 그대로 유지한 채 Claude Code 플러그인 발견 규약에 맞추기 위한 최소 추가(minimal-additive) 변경만** 더했습니다.

### 수정 목적

원본 `agents/`·`commands/` 구조를 옮기거나 고치지 않고, Claude Code가 marketplace/plugin 메커니즘으로 바로 설치·발견할 수 있도록 노출하기 위함입니다.

### 변경 내역

- `.claude-plugin/plugin.json` 신규 추가 — 기존 `agents/`·`commands/` 디렉터리는 Claude Code 플러그인 표준 규약(convention directory)으로 자동 발견되므로 별도 경로 선언 없이 그대로 노출됩니다. (참고: 플러그인 매니페스트 스키마의 `agents`/`commands` 필드는 표준 디렉터리 밖의 *추가* `.md` 파일 하나하나를 가리키는 용도라 디렉터리 경로를 넣으면 스키마 검증에 실패합니다 — 표준 디렉터리명과 일치하므로 필드 자체를 생략했습니다.)
- `.claude-plugin/marketplace.json` 신규 추가 — 같은 레포를 가리키는 self-marketplace(`"source": "./"`)입니다. 별도 marketplace 레포는 만들지 않았습니다.
- `hooks/`는 이번 매니페스트에 **의도적으로 포함하지 않았습니다.** `hooks/settings.json`은 프로젝트 `.claude/settings.json`으로 손복사(copy-install)하도록 저술된 파일이라(`.claude/hooks/scripts/...` 하드코딩 경로, `${CLAUDE_PLUGIN_ROOT}` 미사용) 플러그인 hooks 매니페스트로 그대로 노출하면 런타임에서 스크립트를 찾지 못해 작동하지 않습니다. hooks 플러그인 배선은 후속 라운드로 넘깁니다.
- 그 외 upstream 파일은 이동·이름변경·수정하지 않았습니다.

### upstream 업데이트 방법

```
git fetch upstream
git merge upstream/main
git push origin main
```

push 후 marketplace/plugin은 git SHA 기준으로 최신 커밋을 따라가며, 이 포크에서 별도 재설치 없이 갱신됩니다.

### 원저자 크레딧

원저자는 [`gaebalai`](https://github.com/gaebalai)이며, 정본 upstream은 [`gaebalai/claude-consultant-kr`](https://github.com/gaebalai/claude-consultant-kr)입니다. 이 저장소는 그 원작에 대한 **fork + minimal-additive**이며, 원작을 새로 저술한 것으로 오인되어서는 안 됩니다.

### 라이선스

기존 MIT LICENSE를 수정 없이 그대로 보존했습니다.

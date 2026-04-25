# 설치 가이드

`claude-consultant-kr` 의 설치 방법을 단계별로 안내합니다.

---

## 📋 사전 요구사항

| 항목 | 버전 | 확인 명령 |
|---|---|---|
| Claude Code CLI | 최신 | `claude --version` |
| Bash | 4.0 이상 | `bash --version` |
| Git | 2.0 이상 | `git --version` |
| curl | 7.0 이상 (Hook 알림용) | `curl --version` |

### Claude Code CLI 설치

공식 가이드: https://docs.claude.com/en/docs/claude-code/setup

npm 기반 설치:

```bash
npm install -g @anthropic-ai/claude-code
```

설치 후 인증:

```bash
claude
# 최초 실행 시 브라우저 인증 플로우 진행
```

---

## 🚀 원클릭 설치 (권장)

### 1. 저장소 클론

```bash
git clone https://github.com/gaebalai/claude-consultant-kr.git
cd claude-consultant-kr
```

### 2. 설치 스크립트 실행

**프로젝트 로컬 설치 (권장)**

```bash
./scripts/install.sh --local
```

현재 작업 디렉토리의 `.claude/` 에 설치됩니다. 프로젝트별로 다른 설정 가능하며, Git에 커밋하면 팀원과 공유할 수 있습니다.

**전역 설치**

```bash
./scripts/install.sh --global
```

`~/.claude/` 에 설치됩니다. 모든 프로젝트에서 자동으로 사용 가능합니다.

### 3. 설치 확인

```bash
./scripts/install.sh --check
```

---

## 🛠️ 수동 설치

원클릭 스크립트를 사용하지 않고 직접 설치하려면 다음 단계를 따릅니다.

### 1. 디렉토리 준비

**프로젝트 로컬**:
```bash
mkdir -p .claude/agents .claude/commands .claude/hooks/scripts
```

**전역**:
```bash
mkdir -p ~/.claude/agents ~/.claude/commands ~/.claude/hooks/scripts
```

### 2. 에이전트 복사

```bash
# 로컬
cp agents/consultant-kr.md .claude/agents/

# 전역
cp agents/consultant-kr.md ~/.claude/agents/
```

### 3. 슬래시 커맨드 복사

```bash
# 로컬
cp commands/analyze-business.md .claude/commands/
cp commands/design-pricing.md .claude/commands/
cp commands/benchmark-competitors.md .claude/commands/
cp commands/prioritize-features.md .claude/commands/

# 전역은 경로만 ~/.claude/ 로 변경
```

### 4. Hooks 복사

```bash
# 로컬
cp hooks/settings.json .claude/settings.json
cp hooks/scripts/*.sh .claude/hooks/scripts/
chmod +x .claude/hooks/scripts/*.sh

# 전역은 경로만 ~/.claude/ 로 변경
```

> **주의**: 이미 `.claude/settings.json` 이 존재하는 경우, 내용을 수동으로 병합해야 합니다. 원클릭 스크립트는 백업(`settings.json.bak`) 후 덮어쓰기 옵션을 제공합니다.

### 5. 환경변수 설정 (선택)

```bash
# 로컬
cp .env.example .env
vi .env   # 웹훅 URL 입력
```

---

## ✅ 설치 검증

### 에이전트 검증

```bash
claude
```

세션 내에서:
```
/agents
```

목록에 `consultant-kr` 이 표시되면 정상.

### 커맨드 검증

세션 내에서:
```
/
```

자동완성 목록에 다음이 보이면 정상:
- `/analyze-business`
- `/design-pricing`
- `/benchmark-competitors`
- `/prioritize-features`

### Hook 검증

간단한 테스트 명령으로 Hook이 동작하는지 확인합니다.

```bash
claude
```

세션 시작 직후 `[현재 시각 컨텍스트]` 같은 출력이 보이면 `UserPromptSubmit` Hook 이 정상 작동합니다.

---

## 🌍 OS별 주의사항

### macOS

기본 Bash 버전이 3.x로 낡았습니다. Homebrew로 업그레이드 권장:

```bash
brew install bash
# /opt/homebrew/bin/bash 가 생김
```

### Windows

**WSL2 (권장)**: Linux 환경과 동일하게 작동합니다.

**Git Bash / MSYS2**: 대부분의 Hook 스크립트는 작동하지만, 경로 처리에 주의가 필요합니다.

**PowerShell 네이티브**: 현재 미지원. 추후 버전에서 `install.ps1` 제공 예정.

### Linux

대부분의 배포판에서 추가 작업 없이 동작합니다.

---

## 🗑️ 제거

```bash
./scripts/install.sh --uninstall
```

또는 수동:

```bash
# 로컬
rm -f .claude/agents/consultant-kr.md
rm -f .claude/commands/{analyze-business,design-pricing,benchmark-competitors,prioritize-features}.md
rm -f .claude/hooks/scripts/{load-context,inject-date,notify-on-report,generate-blog-draft}.sh

# 전역은 경로만 ~/.claude/ 로 변경
```

> **settings.json 주의**: 다른 hook 설정과 혼재 가능하므로 수동 편집이 안전합니다.

---

## 🔧 트러블슈팅

### `claude: command not found`

Claude Code CLI 가 PATH에 없습니다. 전역 npm bin 경로 확인:

```bash
npm bin -g
export PATH="$(npm bin -g):$PATH"
```

### 원클릭 스크립트 실행 권한 오류

```bash
chmod +x scripts/install.sh
```

### Hook이 작동하지 않음

다음 순서로 확인:

1. `settings.json` 위치 확인: 로컬이면 `.claude/settings.json`, 전역이면 `~/.claude/settings.json`
2. 스크립트 실행 권한: `ls -la .claude/hooks/scripts/`
3. 스크립트 수동 실행 테스트:
   ```bash
   bash .claude/hooks/scripts/inject-date.sh
   ```
4. Claude Code 재시작

### 상세 FAQ

더 많은 문제 해결 방법은 [FAQ](./FAQ.md) 참고.

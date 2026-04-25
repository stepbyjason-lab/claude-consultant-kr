---
description: 기존 분석 리포트의 한국어 문장을 humanize-korean 스킬로 윤문 (원본 보존, *-refined.md 별도 저장)
argument-hint: [리포트 파일 경로 — 생략 시 reports/ 의 가장 최근 .md 자동 선택]
allowed-tools: Read, Write, Bash(ls:*), Bash(test:*), Bash(date:*)
---

# 분석 리포트 한국어 윤문

이미 작성된 분석 리포트(`reports/*.md` 또는 임의 경로)에 대해 `humanize-korean` 스킬을 적용하여 자연스러운 한국어로 다듬는 후처리 커맨드.

## 사전 검증

다음 경로 중 하나에 `SKILL.md` 가 존재해야 한다:
- `~/.claude/skills/humanize-korean/SKILL.md`
- `./.claude/skills/humanize-korean/SKILL.md`

**미설치 시 즉시 중단하고 안내**:
```
❌ humanize-korean 스킬이 설치되어 있지 않습니다.

설치 명령:
  npx consultant-kr-cli humanize --local    # 프로젝트 로컬
  npx consultant-kr-cli humanize --global   # 전역

자세한 내용:
  https://github.com/gaebalai/im-not-ai
```

## 실행 절차

1. **대상 파일 결정**
   - `$ARGUMENTS` 가 있으면: 해당 경로의 `.md` 파일 사용
   - 비어 있으면: `ls -t reports/*.md | head -1` 로 가장 최근 리포트 자동 선택
   - `reports/` 디렉터리가 없거나 파일이 없으면 사용자에게 경로 입력 요청 후 종료

2. **원본 읽기**
   - Read 도구로 대상 파일 전체 본문 로드
   - 메타데이터 블록(상단 YAML frontmatter)은 별도 보관

3. **humanize-korean 스킬 호출**
   - 본문(메타데이터 제외)에 대해 5단계 파이프라인 실행:
     - `ai-tell-detector` → `korean-style-rewriter` → 병렬(`content-fidelity-auditor` + `naturalness-reviewer`)
   - 옵션:
     - 장르: `리포트` 고정
     - 강도: `기본`
     - 최소심각도: `S2`

4. **절대 변경 금지 사항**
   - 메타데이터 블록(`---` YAML)
   - 모든 수치, 가격(₩), 백분율, 점수
   - 고유명사: 회사명·제품명·플랫폼명·법령명
   - 표 데이터의 셀 값
   - 코드 블록(``` … ```) 내부 내용
   - 헤더 레벨(#, ##, ### 구조)

5. **저장**
   - 파일명: 원본이 `reports/foo.md` 라면 `reports/foo-refined.md`
   - 동일 디렉터리에 저장 (원본은 그대로 보존)
   - 윤문본 상단에 추가 메타 블록 삽입:
     ```yaml
     ---
     원본: <원본 파일 경로>
     윤문일시: <KST 현재 시각>
     윤문스킬: humanize-korean (gaebalai/im-not-ai, MIT)
     ---
     ```

6. **결과 출력**
   - 원본 경로 / 윤문본 경로 둘 다 표시
   - 변경 통계:
     - 카테고리별 탐지 건수 before/after
     - 점수 변화와 품질 등급(A/B/C/D)
   - 주요 변경 하이라이트 3~5건 (before/after 인라인)
   - 등급 B 이하면 "재윤문 가능: `/humanize-redo` 또는 같은 파일에 다시 `/refine-report`" 안내

## 사용 예시

```text
# 가장 최근 리포트 자동 윤문
/refine-report

# 특정 파일 지정
/refine-report reports/analysis-20260425-1430.md

# 임의 위치 마크다운
/refine-report docs/proposal.md
```

## 주의

- 윤문은 **의미 보존**이 최우선. 분석의 정확성·구체성·"두 안 모두 유효 금지" 원칙을 해치지 않는 선에서만 자연스러움 향상
- 등급 D(원본 손상)가 나오면 윤문본 저장을 거부하고 사용자에게 보고
- humanize-korean 스킬 자체의 동작은 [gaebalai/im-not-ai](https://github.com/epoko77-ai/im-not-ai) 의 SKILL.md 절차를 따름

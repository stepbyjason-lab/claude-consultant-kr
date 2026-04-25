# 커스터마이징 가이드

`consultant-kr` 를 기반으로 산업별 · 조직별 특화 에이전트를 만드는 방법.

---

## 🎯 커스터마이징 범위

이 패키지는 다음 3단계 커스터마이징을 지원합니다.

| 수준 | 난이도 | 예시 |
|---|---|---|
| **1. 매핑 테이블 업데이트** | 쉬움 | 신규 경쟁사 추가, 가격 대역 조정 |
| **2. 산업 특화 파생 에이전트** | 중간 | `consultant-kr-fintech.md`, `consultant-kr-healthcare.md` |
| **3. 전용 커맨드 추가** | 중간 | `/analyze-investment`, `/compliance-check` |

---

## 1️⃣ 매핑 테이블 업데이트

`agents/consultant-kr.md` 의 **"한국 시장 컨텍스트"** 섹션 내 테이블을 수정합니다.

### 경쟁사 추가 예시

기존:
```markdown
| 노코드 홈페이지 빌더 | 아임웹, 식스샵, 카페24, 웨일즈 | Wix, Squarespace, STUDIO(JP) |
```

신규 플레이어 추가:
```markdown
| 노코드 홈페이지 빌더 | 아임웹, 식스샵, 카페24, 웨일즈, 모두닷컴 | Wix, Squarespace, STUDIO(JP) |
```

### 가격 대역 조정

시장 동향 반영해 주기적 업데이트:

```markdown
| B2B SaaS(좌석당) | 월 12,900원 | 월 25,000~35,000원 | 월 55,000원 이상 | 별도 협의 |
```

> 💡 **주기적 업데이트 권장**: 분기 1회 정도 시장 조사를 반영하면 에이전트 제안의 현실감이 유지됩니다.

---

## 2️⃣ 산업 특화 파생 에이전트

### 템플릿 복사

```bash
cp agents/consultant-kr.md agents/consultant-kr-{industry}.md
```

`{industry}` 예시: `fintech`, `healthcare`, `construction`, `edutech`, `logistics`

### 필수 수정 포인트

#### 2-1. frontmatter

```yaml
---
name: consultant-kr-fintech
description: 핀테크 · 전자금융 · 토큰증권 사업 분석에 특화된 한국 시장 컨설턴트. 전자금융거래법, 금보원 안전성 기준, 가상자산 규제 환경을 반영한다.
tools:
  - Read
  - Grep
  - Glob
  - WebFetch
  - WebSearch
---
```

#### 2-2. 역할 정의 재작성

```markdown
# 역할 정의

당신은 한국 핀테크 · 전자금융 시장에 특화된 비즈니스 컨설턴트이다.
...
```

#### 2-3. 산업 특유의 규제 · 법 컨텍스트 추가

**핀테크 예시**:
```markdown
## 핀테크 특유 규제

- **전자금융거래법**: 모든 결제·송금 서비스 의무 준수
- **금보원 안전성 기준**: 금융 클라우드, 인증, 로그 관리
- **특정금융정보법(특금법)**: 가상자산 사업자(VASP) 등록
- **신용정보법**: 개인신용정보 처리 제약
- **전자서명법**: 공인인증 체계 변화 반영
- **CSAP 공공**: 공공기관 납품 시 필수
```

**헬스케어 예시**:
```markdown
## 헬스케어 특유 규제

- **의료법**: 비대면 진료 가능 범위
- **의료기기법**: SaMD(Software as Medical Device) 분류
- **개인정보보호법**: 민감정보(건강정보) 처리 별도 요건
- **HIRA(건강보험심사평가원)**: 급여·비급여 분류
- **식약처 가이드라인**: AI 의료기기 심사 절차
```

#### 2-4. 산업 특유 프레임워크 추가

**핀테크 예시**:
```markdown
## 핀테크 분석 프레임워크 (추가)

### 규제 샌드박스 적합성 평가
- 금융규제 샌드박스 신청 요건 검토
- 혁신금융서비스 지정 가능성

### 수익 모델 분석
- 거래 수수료 vs 구독 vs 프리미엄 라이센스
- 결제 대행(PG) 수수료 구조 (카드사 정산 고려)
```

**헬스케어 예시**:
```markdown
## 헬스케어 분석 프레임워크 (추가)

### B2B vs B2C vs B2G 포지셔닝
- 병원 · 의원 영업 채널
- 보험사 연계 가능성
- 공공 의료 시스템 연동

### 급여 · 수가 체계 검토
- 건강보험 급여 적용 가능성
- 비급여 시장 규모
```

#### 2-5. 경쟁사 매핑 재구성

기존 테이블을 산업 특화로 재구성.

**핀테크 예시**:
```markdown
## 핀테크 경쟁사 매핑 (한국)

| 카테고리 | 국내 주력 플레이어 | 핵심 차별점 |
|---|---|---|
| 간편결제 | 토스페이, 카카오페이, 네이버페이 | 각 플랫폼 생태계 |
| 송금 | 토스, 카카오페이 | UX, 무료 정책 |
| 증권 | 토스증권, 카카오페이증권, 미래에셋페이 | MTS 접근성 |
| 보험 | 토스보험, 캐롯 | 디지털 언더라이팅 |
| 자산관리 | 뱅크샐러드, 핀크 | MyData 활용 |
| 가상자산 | 업비트, 빗썸, 코인원 | 원화마켓 특화 |
```

### 등록

파일 저장 후 Claude Code 에서 자동 인식:

```bash
claude
/agents
# consultant-kr-fintech 이 목록에 추가됨 확인
```

### 호출

```text
@consultant-kr-fintech 당사의 BNPL 서비스 진입 전략을 분석해줘.
```

---

## 3️⃣ 전용 커맨드 추가

### 템플릿 복사

```bash
cp commands/analyze-business.md commands/analyze-investment.md
```

### frontmatter 수정

```yaml
---
description: 투자 유치를 위한 사업 현황 리포트 자동 생성
argument-hint: <투자 라운드> (예: "Seed" / "Series A" / "Pre-IPO")
allowed-tools: Task, Bash(mkdir:*), Bash(date:*), Write
---
```

### 본문 재작성

```markdown
# 투자 유치용 사업 분석

현재 프로젝트를 투자자 관점에서 평가 가능한 형태로 분석합니다.

## 실행 절차

1. **리포트 디렉토리 준비**
   - `./reports/investment/` 생성

2. **consultant-kr 에이전트 호출**
   - 투자 라운드: `$ARGUMENTS` (미지정 시 "Series A")
   - 에이전트 지시:
     - 코드베이스 + 시장 상황 + 재무 추정 3축 분석
     - 투자자가 즉시 판단할 수 있는 1페이지 요약 포함
     - **TAM / SAM / SOM** 수치 추정
     - 핵심 KPI 지표 (MAU/ARR/Churn 등) 추정치
     - 경쟁 우위 (Moat) 분석

3. **리포트 저장**
   - 파일명: `./reports/investment/deck-{YYYYMMDD}.md`

4. **요약 출력**
   - 1페이지 피치 텍스트
   - 질문 Top 3 (투자자가 물어볼 법한)
```

### 사용

```text
/analyze-investment Series A
```

---

## 🏗️ 조직 전용 커스터마이징

### 시나리오: 특정 회사 내부용

회사의 제품/서비스 특성을 에이전트에 내장하여 항상 "우리 회사 기준"으로 분석하게 만듭니다.

#### 방법 A: 에이전트 정의에 직접 내장

```markdown
## 자사 컨텍스트 (필수 반영)

**회사명**: {COMPANY}
**주력 제품**: {PRODUCT}
**타깃 고객**: {SEGMENT}
**핵심 가치 제안**: {VALUE_PROP}
**보유 자산**:
  - {ASSET_1}
  - {ASSET_2}

모든 분석은 위 컨텍스트 하에서 수행할 것.
```

#### 방법 B: 별도 컨텍스트 파일로 분리

```bash
# .claude/context/company.md
```

`SessionStart Hook` 의 `load-context.sh` 를 수정하여 자동 주입:

```bash
# load-context.sh 에 추가
if [ -f ".claude/context/company.md" ]; then
  echo "===== 자사 컨텍스트 ====="
  cat .claude/context/company.md
  echo ""
fi
```

### 시나리오: 특정 브랜드 톤매너 반영

출력 문체를 회사 브랜드에 맞게 조정합니다.

에이전트 정의 하단에 추가:

```markdown
## 출력 톤매너

- 격식체 (존댓말) 사용
- 1인칭 "저희"로 통일
- 이모지 사용 금지
- 모든 제안에 "예상 효과"와 "성공 지표" 명기
```

---

## 🧬 고급: 멀티 에이전트 오케스트레이션

`consultant-kr` 를 다른 에이전트와 결합해 더 복잡한 워크플로우를 만들 수 있습니다.

### 예시: 컨설턴트 → 엔지니어 → 기술 라이터

```
.claude/agents/
├── consultant-kr.md        # 사업 전략 (분석)
├── engineer.md             # 기술 구현 (설계)
└── tech-writer.md          # 문서화 (정리)
```

슬래시 커맨드 `/full-pipeline.md`:

```markdown
---
description: 사업 분석 → 기술 설계 → 개발자 문서까지 자동 생성
---

1. @consultant-kr 로 사업 전략 분석
2. 결과를 @engineer 에게 넘겨 기술 설계 요청
3. 최종 결과를 @tech-writer 로 README 생성
```

> 💡 **Jaewoo님의 AI-CEO Framework 연계**: 이 패턴은 AI-CEO Framework 의 CTO 서브에이전트와 결합 가능합니다. `consultant-kr` 가 전략을 만들면 CTO 에이전트가 실행 가능성을 검증하는 구조입니다.

---

## 📦 커스터마이징 배포

### 조직 내부 배포

```bash
# 조직 GitHub Enterprise 에 별도 포크
git clone https://github.com/gaebalai/claude-consultant-kr.git internal-consultant
cd internal-consultant

# 조직 전용 변경
# ...

# 내부 Git 으로 origin 변경
git remote set-url origin https://git.company.com/ai/consultant.git
git push -u origin main
```

### 공개 기여

조직 비의존적인 개선은 본 리포지토리에 PR 환영합니다. [CONTRIBUTING.md](../CONTRIBUTING.md) 참고.

---

## 💡 커스터마이징 팁

### 테스트 주도 변경

에이전트 정의를 변경할 때마다 동일한 프롬프트로 결과 비교:

```bash
# 변경 전 저장
claude -p "/analyze-business 샘플 프로젝트 분석" > before.md

# 에이전트 수정

# 변경 후 비교
claude -p "/analyze-business 샘플 프로젝트 분석" > after.md
diff before.md after.md
```

### 프롬프트 엔지니어링 원칙

- **구체성**: "좋은 답변" 대신 "8단계 구조 준수, 각 섹션 300자 이내"
- **금지 표현**: "하지 말 것" 리스트를 명시
- **예시**: 원하는 출력 패턴의 예시를 에이전트 정의에 포함

### 버전 관리

커스터마이징한 에이전트는 반드시 Git 관리:

```bash
cd .claude
git init  # 로컬 설치인 경우
git add agents/ commands/
git commit -m "Add custom fintech agent"
```

---

## 🚀 다음 단계

- 커스터마이징한 에이전트의 실전 사례를 `examples/` 디렉토리에 추가
- 유용한 산업 템플릿은 본 리포지토리에 PR 기여
- 커뮤니티에서 만든 에이전트 모음집 (구축 예정): `awesome-claude-agents-kr`

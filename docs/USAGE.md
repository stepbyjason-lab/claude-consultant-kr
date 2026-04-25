# 사용 가이드

4개 슬래시 커맨드의 실전 활용 사례와 팁.

---

## 📖 목차

- [/analyze-business — 전체 사업 분석](#analyze-business)
- [/design-pricing — 가격 정책 설계](#design-pricing)
- [/benchmark-competitors — 경쟁사 벤치마킹](#benchmark-competitors)
- [/prioritize-features — 기능 우선순위 판단](#prioritize-features)
- [고급: 커맨드 조합](#고급-커맨드-조합)
- [고급: Cron 정기 실행](#고급-cron-정기-실행)

---

## analyze-business

전체 사업 전략을 공우산 프레임워크로 분석하고 리포트를 자동 저장합니다.

### 기본 사용

```text
/analyze-business
```

인자 없이 실행하면 "전반적 사업 전략" 분석. 결과는 `./reports/analysis-YYYYMMDD-HHMM.md` 로 저장됩니다.

### 초점을 지정한 분석

```text
/analyze-business MVP 론칭 전 2주간 필수 개선 과제
```

```text
/analyze-business 시리즈 A 투자 유치를 위한 사업 현황 정리
```

```text
/analyze-business 향후 6개월간 시장 포지셔닝 재검토
```

### 출력 구조

```
## 1. 논점 정의
해결해야 할 본질적 문제 (1문장)

## 2. 초기 가설
"아마도 이럴 것이다" (3줄 이내)

## 3. 조사 결과와 사실 (공, 空)
- 코드베이스 직독 결과
- 시장 · 경쟁 상황
- 내부 리소스 · 제약

## 4. 해석 (우, 雨)
사실들이 의미하는 바

## 5. 선택지 (MECE)
| 옵션 | 개요 | 메리트 | 디메리트 | 난이도 |

## 6. 추천 시책 (산, 傘)
1개 안으로 좁힌 추천

## 7. 실행 로드맵
Phase 1/2/3 구분, 주체·기한 명기

## 8. 예상 리스크와 대책
```

---

## design-pricing

한국 SaaS 시장 체감 가격대에 맞춘 3단계 가격안을 설계합니다.

### 기본 사용

```text
/design-pricing 소상공인 B2C SaaS
```

### 세그먼트별 예시

```text
/design-pricing 중소기업 B2B 협업 도구
```

```text
/design-pricing 프리랜서 대상 포트폴리오 빌더
```

```text
/design-pricing 엔터프라이즈 화상회의 솔루션
```

### 자동 반영되는 국내 특성

- ✅ 원화 단위 표기 (달러/엔화 환산값 금지)
- ✅ VAT 별도/포함 명기
- ✅ 연간 결제 17~20% 할인 반영
- ✅ 국내 경쟁사(아임웹, 식스샵, 잔디 등) 비교 테이블
- ✅ 등급별 타깃 페르소나
- ✅ 업그레이드 유도 포인트

### 출력 예시

| 플랜 | 월액 | 연간 (20% 할인) | VAT |
|---|---|---|---|
| 라이트 | ₩5,000 | ₩48,000 | 별도 |
| 스탠다드 | ₩15,000 | ₩144,000 | 별도 |
| 프리미엄 | ₩35,000 | ₩336,000 | 별도 |
| 엔터프라이즈 | 별도 협의 | - | - |

---

## benchmark-competitors

국내 경쟁사를 중심으로 3C + SWOT 분석을 수행합니다.

### 기본 사용

```text
/benchmark-competitors 노코드 홈페이지 빌더
```

### 카테고리별 예시

```text
/benchmark-competitors B2B SaaS 협업 툴
```

```text
/benchmark-competitors D2C 이커머스 플랫폼
```

```text
/benchmark-competitors 국내 AI 코딩 어시스턴트
```

### 자동 수행 사항

- 자사 코드베이스 직독으로 현황 파악
- 국내 주력 플레이어 3~5곳 선정 (에이전트 정의의 매핑 테이블 기반)
- 필요 시 WebSearch로 최신 가격/기능 확인
- 기능 매트릭스 · 3C · SWOT 종합 분석

### 출력 예시

```markdown
## 3C 분석

### Customer
타깃 세그먼트 정의와 핵심 니즈

### Competitor
| 업체 | 강점 | 약점 | 가격대 |

### Company
자사 현재 포지션

## SWOT 매트릭스

|   | 기회(O) | 위협(T) |
| 강점(S) | SO 전략 | ST 전략 |
| 약점(W) | WO 전략 | WT 전략 |

## 추천 액션 (우선순위 순)
```

---

## prioritize-features

이슈 드리븐 + 파레토 원칙 + RICE 스코어로 우선순위를 판단합니다.

### 기본 사용

```text
/prioritize-features 다음 스프린트 기능 7개 중 3개 선정 (개발자 2명, 4주)
```

### 예시

```text
/prioritize-features 제품 출시 전 MVP 필수 기능 확정 (팀 3명, 6주, 예산 5천만 원)
```

```text
/prioritize-features 기술 부채 항목 15개 중 이번 분기 처리할 5개
```

### 출력 예시

```markdown
## 판단 결과 요약

**선정**: 기능 A, 기능 C, 기능 F
**보류**: 기능 B (→ 다음 분기 재검토)
**탈락**: 기능 D, E, G

## 평가 테이블

| 기능 | Reach | Impact | Confidence | Effort | RICE | 이슈도 | 결정 |

## 선정 이유 (공·우·산)
...
```

### 필수 입력 정보

에이전트가 정확히 판단하려면 다음이 필요합니다.

- 판단 대상 기능/과제 목록
- 가용 리소스 (인원 수, 기간)
- 달성 목표 (사업/기술 KPI)

부족하면 에이전트가 먼저 질문합니다.

---

## 고급: 커맨드 조합

### 시나리오 1: 신규 프로젝트 초기 분석

```text
> /analyze-business 사업 초기 포지셔닝 수립
# ... 리포트 생성됨

> /benchmark-competitors <분석 결과에서 도출된 카테고리>
# 경쟁 환경 파악

> /design-pricing <경쟁 분석 결과 반영한 세그먼트>
# 가격 정책 설계

> /prioritize-features MVP 필수 기능 선정 (위 3개 분석 종합)
```

### 시나리오 2: 피벗 검토

```text
> /analyze-business 현재 포지션 유지 vs 피벗 선택지 비교

> /benchmark-competitors 피벗 후보 카테고리
```

### 시나리오 3: 정기 리뷰

```text
> /analyze-business 월간 사업 현황 리뷰
# → Hook이 자동으로 이전 리포트 컨텍스트 주입
# → 전월 대비 변화점 자동 분석
```

---

## 고급: Cron 정기 실행

### 주간 자동 분석 (매주 월요일 9시 KST)

```cron
0 9 * * 1 cd /path/to/project && set -a && source .env && set +a && claude -p "/analyze-business 주간 사업 현황" >> logs/weekly.log 2>&1
```

### 월간 가격 재검토 (매월 1일 10시 KST)

```cron
0 10 1 * * cd /path/to/project && set -a && source .env && set +a && claude -p "/design-pricing 현재 타깃 세그먼트 유지 전제" >> logs/monthly-pricing.log 2>&1
```

### 분기별 경쟁사 벤치마킹

```cron
0 11 1 1,4,7,10 * cd /path/to/project && set -a && source .env && set +a && claude -p "/benchmark-competitors 주력 카테고리" >> logs/quarterly-benchmark.log 2>&1
```

> **Hook 연동**: Cron 자동 실행이 리포트를 생성할 때마다 `PostToolUse Hook`이 카카오워크/Slack 알림을 자동 발송합니다. 사람이 자리에 없어도 팀 전체가 결과를 실시간 공유합니다.

---

## 💡 사용 팁

### 더 정확한 분석을 원할 때

분석 대상에 코드베이스가 있으면 해당 디렉토리에서 실행하세요. 에이전트가 실제 코드를 직독해서 분석합니다.

### 결과가 애매할 때

에이전트가 "두 안 모두 유효" 같은 답을 내놓으면(드물지만) 재호출합니다:

```text
하나로 좁혀 추천할 것. 이유 포함.
```

### 이전 분석 컨텍스트 활용

`SessionStart Hook`이 자동으로 `./reports/` 의 최신 리포트를 주입합니다. 즉, 매번 세션을 시작할 때마다 이전 분석을 에이전트가 자동 인지합니다. 명시적 참조도 가능:

```text
이전 분석의 추천 시책 중 Phase 1 실행 결과를 반영해서 재분석해줘.
```

### 리포트 공유

생성된 리포트는 `./reports/` 에 마크다운으로 저장되므로, Velog/Tistory 업로드나 PPT 변환이 쉽습니다.

PPT 변환 파이프라인 예시는 [HOOKS.md](./HOOKS.md) 참고.

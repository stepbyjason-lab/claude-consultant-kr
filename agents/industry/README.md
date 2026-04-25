# 산업별 특화 에이전트 (Industry-Specific Agents)

`consultant-kr` 베이스 에이전트에서 파생된 4개 산업 특화 에이전트 모음입니다.

각 에이전트는 베이스의 **공우산 프레임워크 · MECE · "두 안 모두 유효" 금지** 원칙을 계승하면서, 해당 산업의 **규제 · 경쟁 매핑 · 가격 구조 · 평가 지표**를 내장하고 있습니다.

---

## 📦 제공 에이전트

### 1. `consultant-kr-fintech.md` — 핀테크

**적합한 상황**:
- 간편결제·송금·증권·보험 사업 분석
- MyData·오픈뱅킹 활용 서비스 검토
- 가상자산 거래소·지갑 전략
- 토큰증권(STO) 신사업 탐색
- 금융사 디지털 전환 자문

**내장 특수성**:
- 전자금융거래법·특금법·금보원 안전성 기준·샌드박스 제도
- 국내 핀테크 10대 카테고리 경쟁사 매핑
- 거래 수수료·NIM·구독 수익 모델 분해
- 금융사 파트너십(지정대리인·BaaS) 평가 프레임

**호출 예시**:
```
@consultant-kr-fintech 국내 소상공인 대상 간편 정산 서비스 사업 타당성
@consultant-kr-fintech MyData 활용 Gen Z 타겟 자산관리 앱 출시 전략
```

---

### 2. `consultant-kr-healthcare.md` — 헬스케어·디지털 헬스

**적합한 상황**:
- 디지털치료제(DTx) 출시 전략
- AI 영상·병리 의료기기 사업 분석
- 원격의료·비대면 진료 플랫폼 검토
- 건강보험 급여 전환 로드맵
- 유전체·PHR·웨어러블 사업

**내장 특수성**:
- 의료법·의료기기법·생명윤리법·건강보험법
- 식약처 SaMD 1~4등급 인허가 절차
- HIRA 급여·비급여·선진입 후평가 전략
- 의료인·의료기관 면허 체계 고려
- B2B2C (병원→환자) 모델 설계 가이드

**호출 예시**:
```
@consultant-kr-healthcare 불면증 디지털치료제 국내 시장 진입 전략
@consultant-kr-healthcare 중소병원 대상 AI 영상 판독 SaaS 사업 타당성
```

---

### 3. `consultant-kr-construction.md` — 건설·스마트건설

**적합한 상황**:
- 건설 안전관리 SaaS 사업 검토
- BIM·스마트건설 플랫폼 전략
- 중대재해처벌법 대응 솔루션
- 발주처·원도급·하도급 타깃 차별화
- 공공 조달 진입 로드맵

**내장 특수성**:
- 건설산업기본법·중대재해처벌법·KCS 표준시방서
- 발주자·원도급·전문건설 하도급 계층 이해
- 10대 건설사 + 중견·전문건설 플레이어 매핑
- 공공 조달(나라장터·혁신제품) 진입 경로
- 현장 적용성 스크리닝 (통신·오프라인·착용장비)

**호출 예시**:
```
@consultant-kr-construction 중대재해처벌법 대응 안전관리 SaaS 사업 타당성
@consultant-kr-construction 10대 건설사 대상 BIM 협업 플랫폼 시장 진입
```

---

### 4. `consultant-kr-ecommerce.md` — 이커머스·D2C

**적합한 상황**:
- D2C 브랜드 론칭·성장 전략
- 오픈마켓 셀러 마케팅 자동화 SaaS
- 버티컬 커머스(패션·뷰티·신선) 사업
- 구독 커머스·정기배송 설계
- 크로스보더·직구 플랫폼 검토

**내장 특수성**:
- 전자상거래법·공정거래법·EPR·관세법
- 쿠팡·네이버·SSG·11번가·G마켓 수수료 구조
- 카페24·아임웹·식스샵 쇼핑몰 구축 생태계
- 풀필먼트(쿠팡 로켓그로스·네이버 NFA·3PL) 옵션
- 카테고리별(패션·뷰티·신선·리셀) 특수성 반영

**호출 예시**:
```
@consultant-kr-ecommerce 뷰티 D2C 브랜드 3년 내 1천억 매출 로드맵
@consultant-kr-ecommerce 신선식품 새벽배송 커머스 시장 진입 타당성
```

---

## 🔧 설치 방법

### 원하는 산업만 선택 설치

```bash
# 핀테크만 설치
cp agents/industry/consultant-kr-fintech.md .claude/agents/

# 여러 개 설치
cp agents/industry/consultant-kr-{fintech,healthcare}.md .claude/agents/
```

### 전체 4개 일괄 설치

```bash
cp agents/industry/consultant-kr-*.md .claude/agents/
```

### 전역 설치

```bash
cp agents/industry/consultant-kr-*.md ~/.claude/agents/
```

---

## 🎯 언제 어떤 에이전트를 쓸까

### 베이스 `@consultant-kr` 를 쓸 때
- 일반 SaaS·스타트업 사업 분석
- 산업이 특정되지 않은 범용 분석
- 여러 산업에 걸친 포트폴리오 기업 전략

### 산업 특화 에이전트를 쓸 때
- **규제가 사업 모델을 정의**하는 영역 (핀테크·헬스케어)
- **생태계 구조가 복잡**한 영역 (건설·이커머스)
- **국내 공급자·플레이어 매핑이 중요**한 영역

둘 다 같은 세션에서 쓸 수도 있습니다:

```
# 일반 전략은 베이스로
@consultant-kr 우리 회사 3년 포트폴리오 전략

# 산업 세부는 특화로
@consultant-kr-fintech 제안된 핀테크 사업부의 규제 적합성 심층 검토
@consultant-kr-healthcare 제안된 헬스 라인의 급여 전략 검토
```

---

## 🏗️ 각 에이전트의 출력 구조 차이

### 공통 (공우산 기본)
1. 논점 정의
2. 초기 가설
3. 사실 (공)
4. 해석 (우)
5. 선택지 (MECE)
6. 추천 시책 (산)
7. 실행 로드맵
8. 예상 리스크

### 산업별 추가 섹션

| 에이전트 | 추가 필수 섹션 |
|---|---|
| `fintech` | ⚠️ 규제 적합성 체크 (적용 법규·허가·샌드박스) |
| `healthcare` | ⚠️ 의료법·규제 적합성 + 💰 급여·수가 전략 |
| `construction` | 🏗️ 현장 적용성·KCS 체크 + 👥 발주처·타깃 계층 + 💰 조달 전략 |
| `ecommerce` | 🛒 채널 믹스 + 📦 풀필먼트·물류 계획 + 💰 수수료 계산 |

---

## 🔀 파생 · 커스터마이징 가이드

4개 기본 산업 외 다른 산업이 필요하면 복사해서 수정하세요.

추천 파생 후보:
- `consultant-kr-edutech` — 에듀테크·온라인 교육
- `consultant-kr-logistics` — 물류·유통 ·3PL
- `consultant-kr-manufacturing` — 제조·스마트팩토리
- `consultant-kr-media` — 미디어·콘텐츠·엔터
- `consultant-kr-automotive` — 자동차·모빌리티
- `consultant-kr-realestate` — 프롭테크·부동산
- `consultant-kr-foodtech` — 푸드테크·외식 SaaS
- `consultant-kr-gamedev` — 게임·웹3 게임

자세한 커스터마이징 방법은 `docs/CUSTOMIZING.md` 를 참고하세요.

---

## 🤝 기여

신규 산업 에이전트 또는 기존 에이전트의 업데이트(경쟁사·규제 · 가격 변동 반영)는 PR 환영합니다. [CONTRIBUTING.md](../../CONTRIBUTING.md) 참고.

---

**버전**: v1.0 (2026-04)  
**작성자**: gaebalai

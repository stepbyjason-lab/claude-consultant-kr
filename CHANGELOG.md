# 변경 이력 (Changelog)

이 프로젝트의 모든 주요 변경사항은 이 파일에 문서화됩니다.
형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/) 를 따르며,
버전 관리는 [Semantic Versioning](https://semver.org/lang/ko/) 을 따릅니다.

---

## [Unreleased]

### 계획
- Discord · Telegram 알림 Hook
- Humanize KR upstream pinning (특정 commit SHA 또는 tag 옵션)

### 결정 사항
- **Windows 네이티브 PowerShell 미지원 정책 확정** — 패키지의 핵심 가치인 Hook 4종이 bash 스크립트라 PowerShell 설치 스크립트만 추가해도 Hook 미작동으로 사용자 혼란 가중. WSL2 + Ubuntu 권장으로 정리. 향후 Node.js 기반 단일 설치 로직 재작성은 0.4.0+ 마일스톤에서 검토.

---

## [0.3.0] - 2026-04-25

### 추가
- **npm 패키지 배포 + npx 한 줄 설치**
  - `package.json` · `bin/cli.js` 신설 — Node.js 래퍼가 기존 bash 설치 스크립트를 위임
  - npm 패키지명: `consultant-kr-cli` (Anthropic 상표 회피 + 비공식 표기 명시)
  - GitHub 저장소명은 `claude-consultant-kr` 그대로 유지
  - `npx consultant-kr-cli@latest --local|--global|--check|--uninstall`
  - `npx consultant-kr-cli@latest industry --local --fintech --healthcare`
- **외부 연동: Humanize KR**
  - `scripts/install-humanize.sh` 신설 — [epoko77-ai/im-not-ai](https://github.com/epoko77-ai/im-not-ai) 의 한글 AI 티 제거 스킬을 GitHub raw URL 에서 동적 fetch
  - 라이선스 미명시 사실 명시적 고지, 사용자 동의 필수
  - `npx consultant-kr-cli@latest humanize --local --yes`
- `install.sh` 에 `--yes`/`-y` 플래그 추가 — CI 등 비대화형 환경 지원
- `release.sh` 에 npm 배포 단계 통합 (`npm whoami` 체크 + `npm publish --access public`)

### 수정
- `install-industry.sh` 의 associative array (`declare -A`) 를 함수 기반으로 변경
  - 영향: macOS 기본 bash 3.2 에서 `unbound variable` 에러로 동작 불가 → 정상 동작
- `package.json` description 표기 통일 ("맥켄지" → "맥킨지", 외래어 표기법 표준)
- `package.json` 의 `os` 제약 (`["darwin", "linux"]`) 제거
  - 영향: Windows 사용자가 `npx` 호출 시 패키지 설치 자체가 막히는 대신, `bin/cli.js` 의 친절한 안내 메시지를 보게 됨
- 한국어/영어 README 동기화 — Quick Start, 산업 특화, Humanize KR 섹션, 라이선스 고지를 양쪽에 일관되게 반영
- `.npmignore` 제거 — `package.json` 의 `files` 화이트리스트로 충분 (중복 제거)

---

## [0.2.0] - 2026-04-25

### 추가
- 산업 특화 파생 에이전트 4종 (`agents/industry/`)
  - `consultant-kr-fintech` — 핀테크·전자금융·가상자산·토큰증권
  - `consultant-kr-healthcare` — 헬스케어·디지털치료제·의료기기·원격의료
  - `consultant-kr-construction` — 건설·스마트건설·BIM·건설안전
  - `consultant-kr-ecommerce` — 이커머스·D2C·오픈마켓·크로스보더
- `scripts/install-industry.sh` — 대화형/플래그 기반 산업 에이전트 선택 설치
- 실전 예시 2종 추가
  - `examples/03-fintech-mydata-genz.md` — MyData 기반 Gen Z 자산관리 앱 분석
  - `examples/04-healthcare-dtx-insomnia.md` — 불면증 디지털치료제 시장 진입
- 산업 에이전트 종합 가이드 (`agents/industry/README.md`)

### 각 산업 에이전트 내장 컨텍스트

**핀테크**:
- 전자금융거래법, 특금법, 금보원 안전성 기준, 자본시장법, 신용정보법
- 규제 샌드박스·지정대리인·BaaS 모델 평가 프레임
- 10대 카테고리 경쟁사 매핑 (간편결제·송금·증권·보험·MyData·가상자산 등)
- 핀테크 특화 KPI (Take Rate · NIM · CAC · 불량률)

**헬스케어**:
- 의료법·의료기기법·생명윤리법·건강보험법
- 식약처 SaMD 1~4등급 인허가 절차
- HIRA 급여·비급여·선진입 후평가 전략
- 디지털치료제·AI 의료기기·원격의료·PHR·유전체 플레이어 매핑
- B2C·B2B·B2B2C·B2G 모델별 적합성 프레임

**건설**:
- 건설산업기본법·중대재해처벌법·KCS 표준시방서·BIM 의무화
- 발주자·원도급·전문건설 하도급 계층 이해
- 10대 건설사·중견·전문건설 플레이어 매핑
- 공공 조달(나라장터·혁신제품·R&D 실적) 진입 경로
- 현장 적용성 스크리닝 (통신·오프라인·먼지·착용장비)

**이커머스**:
- 전자상거래법·공정거래법·EPR·관세법
- 쿠팡·네이버·SSG·11번가·G마켓 수수료·정산 구조
- 카페24·아임웹·식스샵 쇼핑몰 구축 플레이어
- 풀필먼트(쿠팡 로켓그로스·네이버 NFA·3PL) 비교
- 카테고리별(패션·뷰티·신선·리셀) 특수성 반영

---

## [0.1.0] - 2026-04-25

### 추가
- 핵심 에이전트 `consultant-kr.md` — 맥킨지/BCG 사고 체계 + 한국 시장 컨텍스트
- 슬래시 커맨드 4종
  - `/analyze-business` — 전체 사업 전략 분석 + 자동 리포트 저장
  - `/design-pricing` — 원화 · VAT · 연간할인 반영 3단계 가격안
  - `/benchmark-competitors` — 국내 경쟁사 벤치마킹 (3C + SWOT)
  - `/prioritize-features` — RICE + 파레토 기반 우선순위 판단
- Hook 스크립트 4종
  - `load-context.sh` — 이전 리포트 컨텍스트 자동 주입
  - `inject-date.sh` — KST 현재 시각 자동 주입
  - `notify-on-report.sh` — 카카오워크 · Slack 웹훅 알림
  - `generate-blog-draft.sh` — Velog 초안 자동 생성 (옵트인)
- 원클릭 설치 스크립트 `scripts/install.sh` (--local / --global / --check / --uninstall)
- 한국어 · 영어 README
- 설치 · 사용 · 커스터마이징 가이드 문서

### 한국 시장 컨텍스트 내장
- 경쟁사 매핑: 아임웹, 식스샵, 카페24, 잔디, 카카오워크, 두레이, 토스페이먼츠, 포트원 등
- 클라우드: AWS Seoul (ap-northeast-2), NCP, KT Cloud
- 법 · 규제: PIPA, ISMS-P, CSAP, 전자금융거래법
- 가격: 원화 기준, VAT 별도 표기, 연간 결제 20% 할인 표준

---

## 기여자

- [@gaebalai](https://github.com/gaebalai) — 초기 버전 설계 및 개발

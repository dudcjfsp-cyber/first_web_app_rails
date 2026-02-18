# 세션 컨텍스트 요약 (2026-02-18)

## 1) 프로젝트 방향
- Rails on Ruby(RoR)로 신규 개발.
- 현재는 구현 전 설계 단계이며, 코드 구현은 아직 시작하지 않음.
- 기준 요구사항 원문은 `readme.md`에 반영되어 있음.

## 2) 확정된 핵심 설계 결정

### 인증/권한
- 사용자 로그인은 Google OAuth 2.0 사용.
- 최초 관리자(임시 admin)는 제작자 이메일 기준으로 자동 부여.
- 기준 키: `INITIAL_ADMIN_EMAIL`
- 로그인 계정과 역할:
  - 기본 역할은 `멤버`
  - `INITIAL_ADMIN_EMAIL`과 이메일 일치 시 최초 로그인에 한해 `관리자`
  - 이후 역할 변경은 관리자만 가능

### Google Sheet 연동 방식
- 로그인(OAuth)과 시트 작업 권한을 분리.
- 사용자 OAuth는 신원 확인(로그인) 용도만 사용.
- Google Sheet 읽기/쓰기/수정/삭제는 앱 전용 Service Account로만 수행.
- 운영 스프레드시트는 단일 `SPREADSHEET_ID` 사용.

### 입력/검증 규칙
- 형식: `업체명 제품명 갯수 [제품명 갯수]...`
- 업체명 정규화:
  - 앞뒤 공백 제거(trim)
  - 시트명 금지문자(`[`, `]`, `:`, `*`, `?`, `/`, `\`) 차단
  - 최대 30자 제한
  - 영문 알파벳 대문자 통일
- 갯수:
  - 정수만 허용
  - 숫자 외/소수 입력 시 거부
- 입력날짜:
  - UTC 고정 저장
  - 사용자 화면도 UTC 그대로 표시

### 데이터 정합성/충돌 처리
- `request_id(UUID)` 기반 멱등성으로 중복 제출 차단.
- `request_id` 미전송 요청은 `VALIDATION_ERROR`로 즉시 거부.
- `MASTER` + `[업체명]` 모두 성공해야 성공 처리(원자성).
- 한쪽만 성공하면 즉시 실패 후 보정.
- `record_id -> 시트명/행번호` 로컬 인덱스 테이블 사용, 불일치 시 재탐색으로 자동 보정.
- 동시 수정은 서버 수신시각 기준 LWW(Last-Write-Wins).

### 오류/실패 정책
- Google Sheet 반영 실패 시 즉시 실패 처리.
- 실패 시 데이터 저장하지 않음(부분 성공/지연 적재 없음).
- UI 팝업:
  - 제목: `[데이터 입력 실패]`
  - 하단: 실패 사유 표기(사용자 친화 메시지, 원본 예외 전문 직접 노출 금지)
- 내부 오류코드 표준:
  - `SHEET_TIMEOUT`
  - `SHEET_RATE_LIMIT`
  - `SHEET_NETWORK_ERROR`
  - `SHEET_PERMISSION_DENIED`
  - `VALIDATION_ERROR`

## 3) SLA 합의
- 처리 모델: 엄격 동기식(Strong Sync)
- 목표: 쓰기/수정/삭제 성공 요청 `P95 <= 1초`
- 실패 기준: 1초 내 반영 실패 시 즉시 실패 응답
- 가용성 목표: 월간 쓰기 성공률 99.5% 이상
- 데이터 일관성: 실패 요청은 저장하지 않음

## 4) 초기 구현과 병행 권장
- `dev/stg/prod` 환경 분리 (시트/OAuth 설정 분리)
- Service Account 키 비밀관리 및 주기적 교체
- 성공률/지연시간/오류코드 관측 대시보드
- 모킹 테스트와 실제 Google 연동 테스트 분리

## 5) 생성/수정된 파일
- 요구사항 문서: `readme.md`
- 구현 순서: `IMPLEMENTATION_BUILD_ORDER.md`
- 환경변수 템플릿: `.env.example`
- 키 발급/획득 안내 텍스트: `ENV_KEY_SOURCE_GUIDE.txt`
- 본 요약 문서: `SESSION_CONTEXT_SUMMARY.md`

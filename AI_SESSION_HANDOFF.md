# AI Session Handoff (2026-02-24)

## 1) 현재까지 구현 상태
- 목표 방향: Google Sheets 연동 전, 로컬 DB 기반 웹앱 기능을 먼저 완성하는 트랙으로 진행 중.
- 인증 정책: **Google OAuth 제거 완료**, 로컬 간편 로그인(이메일 + 비밀번호) 방식으로 전환 완료.
- 저장 방식: 입력 데이터는 DB(`records`)에 저장.
- 리포팅: UTC 날짜 필터 + CSV(엑셀 호환) 다운로드 구현 완료.

## 2) 이번 세션에서 완료한 핵심 작업
- OAuth 완전 제거
  - `omniauth-google-oauth2`, `omniauth-rails_csrf_protection` Gem 제거
  - `config/initializers/omniauth.rb` 삭제
  - `/auth/:provider/callback`, `/auth/failure` 라우트 제거
  - OAuth 관련 세션 테스트 제거
- 간편 로그인 유지/강화
  - `/login` (GET), `/login` (POST) 로컬 로그인
  - `SIMPLE_LOGIN_PASSWORD` 환경변수 도입
  - 미로그인 시 `require_sign_in`으로 로그인 페이지 리다이렉트
- 사용자 식별 컬럼 정리
  - `users.google_uid` -> `users.auth_uid`로 리네임
  - 관련 모델/fixtures/tests 반영
- 리포팅 기능 유지
  - UTC 날짜 필터
  - CSV 다운로드 (`/exports/records`)

## 3) 현재 기준 중요 동작
- 로그인 성공 시 루트(`/`) 진입 가능
- 메시지 전송 시 `request_id` 기반 저장 로직 동작
- 날짜 필터 조회 동작
- CSV 다운로드 동작
- 멤버/관리자 권한 정책(조회/수정 가능 범위 정책 로직)은 기존 서비스 테스트 기준 유지

## 4) 검증 결과
- (ASCII 경로 복사본 기준) 아래 테스트 통과:
  - `ruby bin/rails test test/controllers/sessions_controller_test.rb test/controllers/home_controller_test.rb test/controllers/messages_controller_test.rb test/controllers/exports_controller_test.rb test/models/user_test.rb`
  - 결과: `16 runs, 56 assertions, 0 failures`
- 브라우저 시나리오 스모크:
  - 로그인 POST: `302`
  - 메시지 POST: `302`
  - 루트 화면에 저장 행 표시 확인
  - CSV 다운로드: `200`, 헤더 확인

## 5) 다음 세션에서 바로 할 작업 (우선순위)
1. 문서 동기화
   - `readme.md`, `IMPLEMENTATION_BUILD_ORDER.md`, `SESSION_CONTEXT_SUMMARY.md`를 현재 코드 상태에 맞게 업데이트
   - 특히 OAuth 제거/로컬 로그인 전환 내용 반영
2. 실시간 반영 기능(Turbo Streams) 추가
   - 새 레코드 생성 시 동일 권한 범위 사용자 화면에 자동 반영
3. (선택) CSV -> XLSX 내보내기 전환
   - 실제 엑셀 형식 필요 시 gem 도입 후 변경

## 6) 작업 시 주의사항
- 현재 워크트리는 **미커밋 변경 상태**임. 작업 전 `git status` 확인 필수.
- Windows 환경에서 프로젝트 경로에 한글/공백이 포함되어 `bin/rails` 실행이 불안정할 수 있음.
- 서버 수동 테스트가 필요하면 ASCII 경로 복사본에서 실행 권장:
  - 예: `C:\Temp\webapp_rails_test`

## 7) 다음 AI를 위한 빠른 시작 명령
- 상태 확인:
  - `git status --short`
- (필요 시) ASCII 경로에서 준비:
  - `bundle install`
  - `ruby bin/rails db:prepare`
  - `ruby bin/rails test`
  - `ruby bin/rails server -b 127.0.0.1 -p 3001`

## 8) 이번 세션 주요 변경 파일
- 인증/세션
  - `app/controllers/sessions_controller.rb`
  - `app/controllers/application_controller.rb`
  - `app/views/sessions/new.html.erb`
  - `config/routes.rb`
- 사용자 모델/DB
  - `app/models/user.rb`
  - `db/migrate/20260224093000_rename_google_uid_to_auth_uid_on_users.rb`
  - `db/schema.rb`
- 리포팅/필터
  - `app/controllers/exports_controller.rb`
  - `app/services/utc_date_range_filter.rb`
  - `app/controllers/home_controller.rb`
  - `app/views/home/index.html.erb`
- 설정/의존성
  - `Gemfile`
  - `Gemfile.lock`
  - `.env.example`
  - `ENV_KEY_SOURCE_GUIDE.txt`
- 테스트
  - `test/controllers/sessions_controller_test.rb`
  - `test/controllers/home_controller_test.rb`
  - `test/controllers/messages_controller_test.rb`
  - `test/controllers/exports_controller_test.rb`
  - `test/models/user_test.rb`
  - `test/fixtures/users.yml`

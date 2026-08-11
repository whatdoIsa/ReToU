# ReToU CI/CD 가이드

## 구성

| 역할 | 도구 | 트리거 |
| --- | --- | --- |
| **CI** (빌드 검증) | GitHub Actions — `.github/workflows/ci.yml` | develop/main 푸시, PR |
| **CD** (TestFlight/배포) | **Xcode Cloud** (Apple 제공) | Xcode 또는 App Store Connect에서 설정 |

## CI — GitHub Actions (설정 완료, 바로 동작)

- develop/main으로의 모든 푸시와 PR마다 시뮬레이터 대상 빌드로 **컴파일이 깨지지 않았는지 검증**합니다.
- 서명·시크릿이 전혀 필요 없습니다.
- 같은 브랜치에 연속 푸시하면 이전 실행을 자동 취소해 macOS 러너 분을 아낍니다.
- 결과: GitHub 리포지토리 > **Actions** 탭.

> 💡 비공개 리포의 macOS 러너는 분 소모가 리눅스의 10배입니다 (무료 한도 월 2,000분 → macOS 실사용 약 200분). 트리거를 develop/main으로 한정해둔 이유입니다. 공개 리포는 무제한 무료.

## CD — Xcode Cloud (Apple 제공)

TestFlight/App Store 배포는 Apple의 Xcode Cloud를 사용합니다. 설정 방법:

1. Xcode에서 프로젝트 열기 → 메뉴 **Integrate > Create Workflow…**
2. 워크플로 설정 예시:
   - **시작 조건**: `main` 브랜치 푸시 (또는 태그)
   - **액션**: Archive - iOS
   - **사후 액션**: TestFlight (내부 테스팅) 배포
3. 서명·인증서·빌드 번호 증가를 Apple이 전부 자동 관리합니다.
4. 결과는 App Store Connect > Xcode Cloud 탭에서 확인.

무료 제공량: **월 25시간** (Apple Developer Program 포함) — 1인 개발 기준 충분합니다.

### 권장 흐름

```
feature 브랜치 → develop (GitHub CI가 빌드 검증)
develop → main 머지 (GitHub CI 통과 확인 후)
main 푸시 → Xcode Cloud가 아카이브 + TestFlight 업로드
검증 후 App Store Connect에서 심사 제출 (수동)
```

## 테스트에 관하여

아직 테스트 타깃이 없어 CI는 빌드 검증만 합니다.
테스트 타깃을 만들면 `ci.yml`에 `xcodebuild test` 스텝을 추가하세요 —
날짜 경계 로직(SafeDateManager)이 1순위 후보입니다.

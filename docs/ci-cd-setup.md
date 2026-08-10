# ReToU CI/CD 가이드 (GitHub Actions)

## 구성

| 워크플로 | 트리거 | 하는 일 |
| --- | --- | --- |
| `ci.yml` | develop/main 푸시, PR | 시뮬레이터 대상 빌드로 컴파일 검증 (서명 불필요, 시크릿 불필요) |
| `deploy-testflight.yml` | `v*` 태그 푸시 또는 수동 실행 | Release 아카이브 → App Store 서명 → TestFlight 업로드 |

## CI — 바로 동작

푸시하는 순간부터 동작합니다. 추가 설정 없음.
결과는 GitHub 리포지토리 > **Actions** 탭에서 확인.

## CD — 시크릿 3개 등록 필요 (최초 1회)

배포 워크플로는 App Store Connect API 키로 인증합니다.
**비밀번호·인증서 파일 업로드가 필요 없는** 가장 단순한 방식입니다.

### 1. App Store Connect API 키 만들기

1. [App Store Connect](https://appstoreconnect.apple.com) → **사용자 및 액세스** → **통합** 탭 → **App Store Connect API**
2. **팀 키** 섹션에서 ➕ 로 키 생성
   - 이름: `github-actions` (아무거나)
   - 액세스 권한: **App Manager**
3. 생성 직후 **API 키 다운로드** (.p8 파일 — 한 번만 받을 수 있으니 보관!)
4. 화면에 표시되는 **Key ID** 와 **Issuer ID** 를 메모

### 2. GitHub 시크릿 등록

리포지토리 > **Settings** > **Secrets and variables** > **Actions** > **New repository secret**:

| 이름 | 값 |
| --- | --- |
| `ASC_KEY_ID` | Key ID (예: `A1B2C3D4E5`) |
| `ASC_ISSUER_ID` | Issuer ID (UUID 형태) |
| `ASC_KEY_P8` | 다운로드한 .p8 파일을 텍스트 편집기로 열어 **내용 전체** 붙여넣기 (`-----BEGIN PRIVATE KEY-----` 부터 끝까지) |

### 3. 배포하기

```bash
# 방법 A: 버전 태그 푸시 (권장)
git tag v2.1.0
git push origin v2.1.0
```

방법 B: GitHub > Actions > "Deploy to TestFlight" > **Run workflow** (빌드 번호 직접 지정 가능)

빌드 번호는 자동으로 `YYYYMMDDHHMM` 형식(예: 202608011430)이 부여되어 항상 이전보다 커집니다.
업로드 후 5~30분 뒤 App Store Connect > TestFlight에 빌드가 나타납니다.

## 알아두면 좋은 것

- **클라우드 서명**: 첫 배포 실행 시 Xcode가 API 키로 클라우드 관리 Apple Distribution 인증서를 자동 생성/사용합니다. 만약 `No signing certificate` 오류가 나면 로컬 Xcode > Settings > Accounts > Manage Certificates에서 **Apple Distribution (Cloud Managed)** 인증서를 한 번 만들어주면 해결됩니다.
- **비용**: macOS 러너는 분당 소모가 리눅스의 **10배**입니다. 비공개 리포 무료 한도(월 2,000분)로는 macOS 실사용 약 200분 = CI 빌드 약 15~20회 수준. 이를 위해 CI에 `concurrency` 취소를 걸어뒀고, 트리거를 develop/main으로 한정했습니다. (공개 리포는 무제한 무료)
- **테스트**: 아직 테스트 타깃이 없어 CI는 빌드 검증만 합니다. 테스트 타깃을 만들면 `xcodebuild test` 스텝을 추가하세요 — 날짜 경계 로직(SafeDateManager)이 1순위 후보입니다.
- **스토어 제출**: TestFlight 업로드까지가 자동화 범위입니다. 심사 제출은 App Store Connect에서 버전에 빌드를 연결해 수동으로 진행합니다 (메타데이터·스크린샷 검토가 필요하므로 의도적으로 수동).

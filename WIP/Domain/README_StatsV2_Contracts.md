# Stats v2 & AI Insights Contracts (계약 명세)

## 📋 개요
이 문서는 Stats v2 프로젝트의 **계약(Contract)**을 정의합니다.  
이후 티켓 2~6에서는 **이 계약을 변경하지 않고, 확장만 허용**합니다.

## 🗂️ 파일 구조
```
Domain/
├── DTO/
│   ├── StatsDataContracts.swift      # Stats 전용 DTO
│   └── AIInsightsDataContracts.swift # AI Insights 전용 DTO
├── Navigation/
│   └── StatsNavigationActions.swift  # 딥링크 액션 정의
└── Analytics/
    └── CommonStates.swift            # 공통 상태 enum
```

## 📊 Stats Data Contracts

### 핵심 DTO
- **`MonthlySummaryDTO`**: 월별 요약 통계 (완료율, 평균 점수, 연속 기록 등)
- **`EmotionDistributionItemDTO`**: 감정 분포 (5단계 고정: joy, sadness, anger, fear, neutral)
- **`DailyMoodPointDTO`**: 일별 기분 점수 (차트용)
- **`HeatmapDayDTO`**: 히트맵 일별 데이터
- **`WeekdayStatDTO`**: 요일별 통계
- **`MonthComparisonDTO`**: 전월 대비 변화량
- **`StatsDataDTO`**: 전체 통계 컨테이너

### 데이터 무결성 규칙
1. 감정은 **5단계 고정** (0값 포함)
2. 날짜는 **"yyyy-MM-dd" 형식** 통일
3. 모든 DTO는 **유효성 검증** 포함
4. 옵셔널 데이터는 **명시적 nil 처리**

## 🤖 AI Insights Data Contracts

### 핵심 DTO
- **`InsightReportDTO`**: 구조화된 인사이트 리포트
  - summary: [String] (정확히 2문장)
  - patterns: [PatternDTO] (최소 3개)
  - actions: [ActionDTO] (최소 2개)
- **`PatternDTO`**: 패턴 분석 데이터 (유형, 신뢰도, 근거)
- **`ActionDTO`**: 실행 가능한 제안 (우선순위, 예상 효과, 소요 시간)

### AI 품질 보장
1. **신뢰도 점수** (0.0-1.0) 필수
2. **구조화된 출력** 강제 (배열 크기 검증)
3. **메타데이터 추적** (모델명, 생성 시간, 처리 시간)
4. **확장 가능한 enum** (기존 케이스 변경/삭제 금지)

## 🧭 Navigation Action Contracts

### Stats Navigation
- 월별/연간/전체 뷰 전환
- 드릴다운 (감정별, 요일별, 날짜별)
- 필터 및 비교 분석
- 공유/내보내기

### AI Insights Navigation  
- 인사이트 생성/재생성
- 패턴/액션 상세 뷰
- 액션 추적 (완료/건너뜀/미리 알림)
- 설정 및 커스터마이징

### 딥링크 규칙
- 모든 액션은 **유니크 actionId** 보유
- URL 안전 문자열 형식
- 확장 가능한 구조 (기존 ID 변경 금지)

## 🔄 Common State Contracts

### DataLoadingState (공통)
```swift
enum DataLoadingState {
    case loading, empty, loaded, error, unsupported
}
```

### StatsViewState
- 로딩, 데이터 준비, 필터 적용, 드릴다운, 오류, 빈 상태

### AIInsightsViewState  
- 생성 중, 준비, 재생성, 액션 추적, 오류, 데이터 부족

### 상태 전환 규칙
1. **단방향 상태 전환** (역방향 금지)
2. **오류 상태에서 복구 가능성** 명시
3. **사용자 상호작용 가능 여부** 제공

## ⚠️ 계약 준수 규칙

### 🔴 절대 금지 (이후 티켓에서)
- DTO 구조 변경 (프로퍼티 삭제/타입 변경)
- enum 케이스 삭제/변경
- actionId 형식 변경
- 상태 전환 로직 변경

### 🟢 허용 (이후 티켓에서)
- 새로운 DTO 추가
- enum 케이스 추가 (기존 순서 유지)
- 새로운 navigation action 추가
- 상태에 새로운 케이스 추가

### 📏 검증 방법
1. **빌드 성공**: 모든 파일 컴파일 가능
2. **타입 안전성**: 옵셔널 처리 및 타입 검증
3. **문서화**: 모든 공개 타입에 주석
4. **테스트 가능성**: Mock 및 Stub 지원

## 🎯 다음 티켓 가이드

### 티켓 2: StatsView 구현
- `StatsDataContracts.swift` 사용
- `StatsNavigationActions.swift` 구현
- `CommonStates.swift`의 StatsViewState 사용

### 티켓 3: AIInsightsView 구현  
- `AIInsightsDataContracts.swift` 사용
- `AIInsightsNavigationActions.swift` 구현
- `CommonStates.swift`의 AIInsightsViewState 사용

### 티켓 4~6: 세부 컴포넌트 구현
- 기존 계약 내에서 세부 구현
- 새로운 enum 케이스는 추가만 허용
- DTO 확장 시 새 파일로 분리

---

## 📋 체크리스트

### Contract 완성도
- [x] Stats DTO 정의 (7개 구조체)
- [x] AI Insights DTO 정의 (4개 구조체, 6개 enum)  
- [x] Navigation Actions 정의 (2개 enum, 8개 지원 타입)
- [x] Common States 정의 (5개 enum, 4개 구조체)
- [x] 문서화 완료

### 타입 안전성
- [x] 모든 DTO는 유효성 검증 포함
- [x] 옵셔널 처리 명시
- [x] enum은 CaseIterable 구현
- [x] 에러 타입은 LocalizedError 준수

### 확장성
- [x] enum 케이스 추가 가능 구조
- [x] DTO 확장 가능 설계  
- [x] Navigation action 확장 가능
- [x] 기존 계약 보호 메커니즘

---

*이 계약은 티켓 1에서 고정되었으며, 티켓 2~6에서는 변경하지 않습니다.*
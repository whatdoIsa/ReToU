import Foundation

/// "하루에 1개 기록" 규칙 검증을 위한 수동 테스트 시나리오
/// 날짜 경계, 타임존 변경, 수정 흐름에서의 안정성 확인
struct TestScenarios {
    
    // MARK: - 핵심 테스트 시나리오 목록
    
    static let scenarios: [TestScenario] = [
        
        // MARK: 1. 기본 CRUD 테스트
        TestScenario(
            id: "basic_create",
            title: "기본 회고 생성",
            description: "정상적인 회고 생성이 정확히 작동하는지 확인",
            steps: [
                "1. 앱 실행",
                "2. '오늘 회고 작성' 버튼 탭",
                "3. 감정 선택: 😊",
                "4. 내용 입력: '오늘은 좋은 하루였다'",
                "5. 저장 버튼 탭"
            ],
            expectedResult: "새로운 회고가 생성되고 목록에 표시됨",
            testType: .basic
        ),
        
        TestScenario(
            id: "duplicate_prevention",
            title: "중복 생성 방지 (같은 날)",
            description: "같은 날짜에 두 번째 회고 작성 시 업데이트로 처리",
            steps: [
                "1. 오늘 회고가 이미 존재하는 상태",
                "2. '회고 작성' 시도",
                "3. 다른 감정/내용으로 작성: 😢, '힘든 하루였다'",
                "4. 저장"
            ],
            expectedResult: "새로 생성되지 않고 기존 회고가 업데이트됨 (총 개수 변화 없음)",
            testType: .basic
        ),
        
        // MARK: 2. 날짜 경계 테스트 (Critical)
        TestScenario(
            id: "midnight_boundary",
            title: "자정 경계 테스트",
            description: "23:59에 작성한 회고와 00:01에 작성한 회고가 서로 다른 날로 처리",
            steps: [
                "1. 시스템 시간을 23:58로 설정",
                "2. 회고 작성 (감정: 😐, 내용: '밤늦게 작성')",
                "3. 저장 후 시스템 시간을 00:02로 변경",
                "4. 새로운 회고 작성 시도 (감정: 😊, 내용: '새벽 작성')"
            ],
            expectedResult: "두 개의 서로 다른 회고가 별도 날짜로 생성됨",
            testType: .boundary
        ),
        
        TestScenario(
            id: "date_change_during_edit",
            title: "편집 중 날짜 변경",
            description: "회고 편집 중에 자정을 넘어가는 상황",
            steps: [
                "1. 23:58에 회고 편집 시작",
                "2. 편집 화면에서 내용 수정 중",
                "3. 00:02에 저장 버튼 탭"
            ],
            expectedResult: "원래 날짜의 회고가 업데이트됨 (새로운 날짜로 이동하지 않음)",
            testType: .boundary
        ),
        
        // MARK: 3. 타임존 변경 테스트
        TestScenario(
            id: "timezone_change",
            title: "타임존 변경 안정성",
            description: "앱 실행 중 타임존이 변경되어도 날짜 키가 일관성 유지",
            steps: [
                "1. 서울 시간대(UTC+9)에서 회고 작성",
                "2. 설정에서 시간대를 뉴욕(UTC-5)으로 변경",
                "3. 앱 포그라운드로 복귀",
                "4. 같은 '현지 날짜'에 회고 작성 시도"
            ],
            expectedResult: "사용자 로컬 캘린더 기준으로 정상 처리됨",
            testType: .timezone
        ),
        
        TestScenario(
            id: "travel_scenario",
            title: "여행 시나리오 (다른 시간대)",
            description: "시간대가 다른 지역으로 이동 후 회고 작성",
            steps: [
                "1. 한국에서 1/12일 회고 작성",
                "2. 기기를 미국 시간대로 변경",
                "3. 미국 현지 시간 기준 1/12일에 회고 작성 시도"
            ],
            expectedResult: "각 지역의 현지 날짜 기준으로 별도 회고 생성 가능",
            testType: .timezone
        ),
        
        // MARK: 4. 시스템 날짜 조작 테스트
        TestScenario(
            id: "system_date_manipulation",
            title: "시스템 날짜 조작 방지",
            description: "사용자가 시스템 날짜를 변경해도 안정적 동작",
            steps: [
                "1. 1/10일 회고 작성",
                "2. 시스템 날짜를 1/5일로 변경",
                "3. 1/5일 회고 작성",
                "4. 시스템 날짜를 1/15일로 변경",
                "5. 1/10일 회고 수정 시도"
            ],
            expectedResult: "각 날짜별로 독립적인 회고 관리, 중복 없음",
            testType: .manipulation
        ),
        
        // MARK: 5. 수정 흐름 테스트
        TestScenario(
            id: "edit_flow_consistency",
            title: "수정 흐름 일관성",
            description: "수정 화면에서 저장 시 새로운 엔트리가 생성되지 않는지 확인",
            steps: [
                "1. 기존 회고 선택하여 편집",
                "2. 감정 변경: 😊 → 😢",
                "3. 내용 대폭 수정",
                "4. 저장"
            ],
            expectedResult: "기존 회고가 업데이트됨 (ID와 날짜 유지, updatedAt만 변경)",
            testType: .editing
        ),
        
        TestScenario(
            id: "multiple_edit_sessions",
            title: "여러 번 연속 수정",
            description: "같은 회고를 여러 번 수정해도 안정적 동작",
            steps: [
                "1. 회고 생성",
                "2. 첫 번째 수정 (감정 변경)",
                "3. 두 번째 수정 (내용 변경)",
                "4. 세 번째 수정 (감정+내용 모두 변경)"
            ],
            expectedResult: "매번 동일한 회고가 업데이트되며, 목록에서 개수 변화 없음",
            testType: .editing
        ),
        
        // MARK: 6. 엣지 케이스 테스트
        TestScenario(
            id: "empty_content_validation",
            title: "빈 내용 검증",
            description: "빈 내용이나 공백만 있는 경우 저장 방지",
            steps: [
                "1. 회고 작성 화면 진입",
                "2. 감정만 선택하고 내용은 비워둠",
                "3. 저장 시도",
                "4. 내용에 공백만 입력 후 저장 시도"
            ],
            expectedResult: "적절한 에러 메시지와 함께 저장 실패",
            testType: .validation
        ),
        
        TestScenario(
            id: "performance_large_dataset",
            title: "대용량 데이터셋 성능",
            description: "365개 회고가 있는 상태에서도 안정적 동작",
            steps: [
                "1. 1년치 회고 데이터 존재하는 상태",
                "2. 새로운 회고 작성",
                "3. 기존 회고 검색/필터링",
                "4. 월별 이동"
            ],
            expectedResult: "2초 이내 응답시간으로 원활한 동작",
            testType: .performance
        )
    ]
    
    // MARK: - 테스트 실행 가이드
    
    static func printTestGuide() {
        print("""
        
        🧪 "하루에 1개 기록" 규칙 검증 테스트 가이드
        ================================================
        
        📋 테스트 분류:
        • Basic: 기본 CRUD 동작 확인
        • Boundary: 날짜/시간 경계 케이스
        • Timezone: 시간대 변경 시나리오
        • Manipulation: 시스템 날짜 조작
        • Editing: 수정 플로우 안정성
        • Validation: 입력 검증
        • Performance: 성능 및 확장성
        
        ⚠️ 중요 확인 포인트:
        1. 같은 dateKey(YYYY-MM-DD)에 대해 항상 하나의 엔트리만 존재
        2. 수정 시 새로운 엔트리가 생성되지 않고 기존 엔트리 업데이트
        3. 날짜 경계에서도 정확한 날짜 구분
        4. 시간대 변경 후에도 일관성 유지
        
        """)
        
        for scenario in scenarios {
            print("📝 \(scenario.title) (\(scenario.testType.rawValue))")
            print("   \(scenario.description)")
            print("   기대 결과: \(scenario.expectedResult)")
            print("")
        }
    }
}

// MARK: - 테스트 시나리오 모델
struct TestScenario {
    let id: String
    let title: String
    let description: String
    let steps: [String]
    let expectedResult: String
    let testType: TestType
    
    enum TestType: String, CaseIterable {
        case basic = "Basic"
        case boundary = "Boundary"
        case timezone = "Timezone"
        case manipulation = "Manipulation"
        case editing = "Editing"
        case validation = "Validation"
        case performance = "Performance"
    }
}

// MARK: - 자동화 테스트용 헬퍼
extension TestScenarios {
    
    /// 핵심 비즈니스 로직 자동 검증
    @MainActor
    static func validateCoreLogic(with storage: ReflectionStorage) -> [String] {
        var results: [String] = []
        
        // 테스트 1: 같은 날짜 중복 방지
        let testDate = Date()
        let beforeCount = storage.reflections.count
        
        // 첫 번째 회고 추가
        _ = storage.add(content: "첫 번째", emotion: "😊", date: testDate)
        let afterFirstAdd = storage.reflections.count
        
        // 같은 날짜에 두 번째 회고 추가 (업데이트로 처리되어야 함)
        _ = storage.add(content: "두 번째", emotion: "😢", date: testDate)
        let afterSecondAdd = storage.reflections.count
        
        if afterFirstAdd == beforeCount + 1 && afterSecondAdd == afterFirstAdd {
            results.append("✅ 중복 방지: 같은 날짜에 업데이트 정상 작동")
        } else {
            results.append("❌ 중복 방지: 새로운 엔트리가 생성됨 (\(beforeCount) → \(afterFirstAdd) → \(afterSecondAdd))")
        }
        
        // 테스트 2: DateKey 일관성
        let date1 = Calendar.current.startOfDay(for: Date())
        let date2 = Calendar.current.date(byAdding: .hour, value: 23, to: date1)!
        let key1 = SafeDateManager.shared.generateDateKey(for: date1)
        let key2 = SafeDateManager.shared.generateDateKey(for: date2)
        
        if key1 == key2 {
            results.append("✅ DateKey 일관성: 같은 날의 다른 시간도 같은 키 생성")
        } else {
            results.append("❌ DateKey 일관성: \(key1) ≠ \(key2)")
        }
        
        return results
    }
}
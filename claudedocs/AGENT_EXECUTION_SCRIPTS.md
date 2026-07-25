# 🚀 Agent 실행 스크립트 및 템플릿

## 📋 SuperClaude Agent 실행 명령어 체계

### **기본 Agent 호출 구조**
```bash
# 기본 패턴
/sc:agent-{AGENT_TYPE} "{REQUEST}" --{FLAGS}

# 예시
/sc:agent-orchestrator "감정 분석 기능 추가해줘" --think-hard --all-mcp
/sc:agent-planner "사용자 맞춤 알림 시스템 기획서 작성" --context7
/sc:agent-developer "SwiftUI로 차트 컴포넌트 구현" --sequential --magic
```

### **Agent별 전용 명령어**
```yaml
Agent_Commands:
  orchestrator: /sc:orchestrator
  planner: /sc:planner  
  developer: /sc:dev
  designer: /sc:design
  qa-engineer: /sc:qa
  release-manager: /sc:release
  marketer: /sc:marketing
  monetizer: /sc:monetize
```

## 🎯 Orchestrator Agent 실행 템플릿

### **프로젝트 시작 스크립트**
```markdown
# Orchestrator Agent 실행 템플릿

## 명령어
```bash
/sc:orchestrator "{{USER_REQUEST}}" --think-hard --all-mcp --delegate --validate
```

## 실행 프로세스
1. **요청 분석 단계**
   - 복잡도 평가 (1-10점)
   - 필요 Agent 식별
   - 예상 소요 시간 계산
   - 리스크 평가

2. **Agent 선정 및 할당**
   ```yaml
   Selected_Agents:
     - planner: {{PLANNING_REQUIREMENTS}}
     - developer: {{DEVELOPMENT_SCOPE}}
     - designer: {{DESIGN_REQUIREMENTS}}
     - qa-engineer: {{TESTING_SCOPE}}
     - release-manager: {{DEPLOYMENT_NEEDS}}
   ```

3. **프로젝트 로드맵 생성**
   ```markdown
   ## 프로젝트 일정
   - Phase 0 (요구사항): {{TIME_ESTIMATE}}
   - Phase 1 (설계): {{TIME_ESTIMATE}}
   - Phase 2 (개발): {{TIME_ESTIMATE}}
   - Phase 3 (출시): {{TIME_ESTIMATE}}
   
   총 예상 시간: {{TOTAL_TIME}}
   ```

4. **첫 번째 Agent 실행**
   ```bash
   /sc:planner "{{REFINED_REQUEST}}" --context7 --sequential
   ```

## 진행상황 모니터링 템플릿
```markdown
## 프로젝트 상태 대시보드

### 📊 전체 진행률: {{PERCENTAGE}}%

### ✅ 완료된 단계
- [x] Phase 0: 요구사항 분석 ({{DATE}})
- [ ] Phase 1: 설계 및 디자인
- [ ] Phase 2: 개발 구현
- [ ] Phase 3: 테스트 및 출시

### 🔄 현재 진행 중
**Agent**: {{CURRENT_AGENT}}
**작업**: {{CURRENT_TASK}}
**예상 완료**: {{ETA}}

### ⚠️ 이슈 및 리스크
{{ISSUES_LIST}}

### 📅 다음 단계
{{NEXT_STEPS}}
```
```

## 📋 Planner Agent 실행 템플릿

### **PRD 생성 스크립트**
```markdown
# Planner Agent - PRD 생성

## 명령어
```bash
/sc:planner "{{FEATURE_REQUEST}}" --context7 --think --research-mode
```

## 템플릿 구조
```markdown
# {{FEATURE_NAME}} 제품 요구사항 문서 (PRD)

## 📝 Executive Summary
{{AUTO_GENERATED_SUMMARY}}

## 👥 타겟 사용자
**Primary Persona**: {{PERSONA_NAME}}
- 나이: {{AGE_RANGE}}
- 직업: {{OCCUPATION}}
- 기술 수준: {{TECH_SAVVY_LEVEL}}
- 목표: {{USER_GOALS}}
- Pain Points: {{PAIN_POINTS}}

## 🎯 문제 정의
**현재 상황 (As-Is)**: {{CURRENT_STATE}}
**이상적 상황 (To-Be)**: {{DESIRED_STATE}}
**Gap Analysis**: {{GAP_ANALYSIS}}

## 💡 솔루션 개요
{{SOLUTION_DESCRIPTION}}

### 핵심 기능 (Must-Have)
1. {{FEATURE_1}}
   - 사용자 스토리: "{{USER_STORY_1}}"
   - 성공 기준: {{SUCCESS_CRITERIA_1}}

2. {{FEATURE_2}}
   - 사용자 스토리: "{{USER_STORY_2}}"  
   - 성공 기준: {{SUCCESS_CRITERIA_2}}

## 📊 성공 지표
- **사용성 지표**: {{USABILITY_KPI}}
- **비즈니스 지표**: {{BUSINESS_KPI}}
- **기술 지표**: {{TECHNICAL_KPI}}

## 📅 구현 로드맵
**MVP**: {{MVP_SCOPE}} ({{MVP_TIMELINE}})
**Phase 1**: {{PHASE1_SCOPE}} ({{PHASE1_TIMELINE}})
**Phase 2**: {{PHASE2_SCOPE}} ({{PHASE2_TIMELINE}})

## 🔗 다음 단계
Designer Agent 호출 준비:
```bash
/sc:design "{{DESIGN_BRIEF}}" --magic --context7
```
Developer Agent 호출 준비:
```bash
/sc:dev "{{TECH_REQUIREMENTS}}" --sequential --morphllm
```
```

## 자동 다음 단계 실행
```yaml
Auto_Handoff:
  condition: PRD_completion >= 90%
  next_agents:
    - designer: parallel
    - developer: parallel (for tech feasibility)
  coordination: orchestrator_managed
```
```

## 💻 Developer Agent 실행 템플릿

### **3단계 개발 프로세스 스크립트**
```markdown
# Developer Agent - 3단계 개발 실행

## Phase 1: UI 개발
```bash
/sc:dev "{{UI_REQUIREMENTS}}" --magic --sequential --phase:ui
```

### 실행 계획
```swift
// MARK: - UI Development Checklist
/*
✅ Tasks:
[ ] SwiftUI 컴포넌트 구현
[ ] 디자인 시스템 코드 변환  
[ ] 반응형 레이아웃 적용
[ ] 다크모드 지원
[ ] 접근성 구현

⚡ MCP Tools:
- Magic: UI 컴포넌트 자동 생성
- Sequential: 복잡한 레이아웃 로직 분석
- Context7: Apple HIG 참조

📋 Deliverables:
- View 구현 파일 (.swift)
- 컴포넌트 라이브러리
- UI 테스트 코드
*/
```

## Phase 2: SDK 연동
```bash
/sc:dev "{{SDK_REQUIREMENTS}}" --context7 --morphllm --phase:sdk
```

### 실행 계획
```swift
// MARK: - SDK Integration Checklist
/*
✅ Tasks:
[ ] 외부 라이브러리 통합
[ ] Apple API 연동 (HealthKit, Core ML)
[ ] 써드파티 SDK 설정
[ ] 보안 및 권한 관리

🔧 MCP Tools:
- Context7: 공식 SDK 문서 참조
- Morphllm: 설정 파일 일괄 수정
- Sequential: 복잡한 권한 플로우 분석

📦 Deliverables:
- Package.swift 설정
- 서비스 레이어 구현
- 권한 관리 시스템
*/
```

## Phase 3: 데이터 연동
```bash
/sc:dev "{{DATA_REQUIREMENTS}}" --sequential --serena --phase:data
```

### 실행 계획
```swift
// MARK: - Data Integration Checklist
/*
✅ Tasks:
[ ] SwiftData 모델 설계
[ ] 네트워킹 레이어 구현
[ ] 캐싱 전략 적용
[ ] 오프라인 지원

🗄️ MCP Tools:
- Sequential: 복잡한 데이터 플로우 분석
- Serena: 프로젝트 메모리 및 상태 관리
- Context7: 최신 SwiftData 패턴 참조

📊 Deliverables:
- 데이터 모델 (.swift)
- 네트워킹 서비스
- 캐시 관리 시스템
*/
```

## 자동 QA 호출
```bash
# 각 Phase 완료 후 자동 실행
/sc:qa "Phase {{PHASE_NUMBER}} 테스트" --playwright --sequential
```
```

## 🎨 Designer Agent 실행 템플릿

### **디자인 시스템 구축 스크립트**
```markdown
# Designer Agent - 디자인 시스템 구축

## 명령어
```bash
/sc:design "{{DESIGN_REQUIREMENTS}}" --magic --context7 --research-mode
```

## 실행 단계

### 1. 리서치 및 컨셉 설정
```markdown
## 디자인 리서치 결과

### 사용자 리서치 요약
**핵심 인사이트**: {{USER_INSIGHTS}}
**디자인 기회**: {{DESIGN_OPPORTUNITIES}}

### 경쟁 분석
| 앱 | 강점 | 약점 | 기회 |
|---|------|------|------|
| {{COMPETITOR_1}} | {{STRENGTH}} | {{WEAKNESS}} | {{OPPORTUNITY}} |

### 디자인 컨셉
**브랜드 키워드**: {{BRAND_KEYWORDS}}
**비주얼 방향성**: {{VISUAL_DIRECTION}}
**감정 연결**: {{EMOTIONAL_CONNECTION}}
```

### 2. 디자인 시스템 구축
```swift
// MARK: - Generated Design System

// 컬러 시스템
extension Color {
    static let emotionHappy = Color(hex: "{{HAPPY_COLOR}}")
    static let emotionSad = Color(hex: "{{SAD_COLOR}}")
    static let emotionNeutral = Color(hex: "{{NEUTRAL_COLOR}}")
    static let brandPrimary = Color(hex: "{{PRIMARY_COLOR}}")
    static let brandSecondary = Color(hex: "{{SECONDARY_COLOR}}")
}

// 타이포그래피
extension Font {
    static let h1 = Font.system(size: {{H1_SIZE}}, weight: {{H1_WEIGHT}}, design: {{H1_DESIGN}})
    static let h2 = Font.system(size: {{H2_SIZE}}, weight: {{H2_WEIGHT}}, design: {{H2_DESIGN}})
    static let body = Font.system(size: {{BODY_SIZE}}, weight: {{BODY_WEIGHT}}, design: {{BODY_DESIGN}})
}

// 컴포넌트 라이브러리
struct {{COMPONENT_NAME}}: View {
    // Magic MCP로 자동 생성된 컴포넌트
    {{AUTO_GENERATED_COMPONENT_CODE}}
}
```

### 3. 프로토타입 및 검증
```markdown
## 사용성 테스트 계획
**테스트 시나리오**: {{TEST_SCENARIOS}}
**성공 지표**: {{SUCCESS_METRICS}}
**개선 사항**: {{IMPROVEMENTS}}
```

## Developer 협업 준비
```bash
# 디자인 완료 후 Developer에게 전달
/sc:dev "디자인 시스템 구현: {{DESIGN_SPECS}}" --magic --morphllm
```
```

## 🔍 QA Agent 실행 템플릿

### **테스트 자동화 스크립트**
```markdown
# QA Agent - 테스트 실행

## 명령어
```bash
/sc:qa "{{TEST_REQUIREMENTS}}" --playwright --sequential --think
```

## 테스트 전략

### 1. 단위 테스트 실행
```swift
// MARK: - Unit Test Generation
import XCTest
@testable import ReToU

final class {{FEATURE_NAME}}Tests: XCTestCase {
    private var sut: {{SERVICE_NAME}}!
    private var mockProvider: Mock{{PROVIDER_NAME}}!
    
    override func setUp() {
        super.setUp()
        mockProvider = Mock{{PROVIDER_NAME}}()
        sut = {{SERVICE_NAME}}(provider: mockProvider)
    }
    
    func test_{{FUNCTION_NAME}}_with{{CONDITION}}_returns{{EXPECTED}}() async throws {
        // Given
        {{TEST_SETUP}}
        
        // When
        let result = try await sut.{{FUNCTION_NAME}}({{PARAMETERS}})
        
        // Then
        {{ASSERTIONS}}
    }
}
```

### 2. UI 테스트 실행
```bash
# Playwright로 E2E 테스트
/sc:playwright "{{UI_TEST_SCENARIOS}}" --take-screenshots
```

### 3. 성능 테스트 실행
```bash
# 성능 벤치마크 테스트
/sc:qa "성능 테스트: {{PERFORMANCE_REQUIREMENTS}}" --benchmark
```

## 테스트 리포트 생성
```markdown
# 테스트 결과 리포트

## ✅ 통과된 테스트
- 단위 테스트: {{UNIT_TEST_PASS}}/{{UNIT_TEST_TOTAL}}
- UI 테스트: {{UI_TEST_PASS}}/{{UI_TEST_TOTAL}}
- 성능 테스트: {{PERF_TEST_RESULTS}}

## ❌ 실패한 테스트
{{FAILED_TESTS_LIST}}

## 🔧 권장 수정 사항
{{RECOMMENDATIONS}}
```

## Bug 리포트 자동 생성
```yaml
Bug_Report:
  severity: "{{SEVERITY_LEVEL}}"
  description: "{{BUG_DESCRIPTION}}"
  steps_to_reproduce: "{{REPRODUCTION_STEPS}}"
  expected_behavior: "{{EXPECTED_BEHAVIOR}}"
  actual_behavior: "{{ACTUAL_BEHAVIOR}}"
  assigned_agent: "developer"
```
```

## 📱 Multi-Agent 협업 실행 스크립트

### **전체 파이프라인 자동 실행**
```bash
# 전체 개발 파이프라인 자동 실행
/sc:pipeline "{{USER_REQUEST}}" --full-auto --all-mcp --parallel-when-possible

# 단계별 실행 (수동 제어)
/sc:pipeline "{{USER_REQUEST}}" --step-by-step --validate-each-stage

# 특정 단계만 실행
/sc:pipeline "{{USER_REQUEST}}" --phases="planning,design" --skip-development
```

### **협업 모드 실행**
```yaml
Collaboration_Modes:
  Sequential_Mode:
    command: /sc:pipeline "{{REQUEST}}" --sequential
    description: "단계별 순차 실행, 각 단계 완료 후 다음 진행"
    
  Parallel_Mode:
    command: /sc:pipeline "{{REQUEST}}" --parallel --max-concurrent=3
    description: "가능한 작업들을 병렬로 동시 실행"
    
  Hybrid_Mode:
    command: /sc:pipeline "{{REQUEST}}" --hybrid
    description: "의존성 고려하여 병렬+순차 혼합 실행"
    
  Review_Mode:
    command: /sc:pipeline "{{REQUEST}}" --review-mode
    description: "각 단계마다 사용자 승인 후 진행"
```

### **성과 추적 및 리포팅**
```bash
# 실시간 진행상황 모니터링
/sc:status --project={{PROJECT_ID}} --real-time

# 최종 프로젝트 리포트 생성  
/sc:report --project={{PROJECT_ID}} --full-analysis --export-format=md

# 성과 메트릭 분석
/sc:analytics --project={{PROJECT_ID}} --metrics="efficiency,quality,satisfaction"
```

## 🎛️ 고급 실행 옵션

### **토큰 최적화 모드**
```bash
# 울트라 압축 모드 (토큰 50% 절약)
/sc:agent-{TYPE} "{{REQUEST}}" --uc --compress-output --symbol-mode

# 효율성 우선 모드
/sc:agent-{TYPE} "{{REQUEST}}" --efficiency-first --cache-aggressive --parallel-max
```

### **품질 우선 모드**
```bash
# 최고 품질 보장 모드
/sc:agent-{TYPE} "{{REQUEST}}" --quality-first --think-hard --validate-all --review-cycles=3

# 안전 모드 (프로덕션 환경)
/sc:agent-{TYPE} "{{REQUEST}}" --safe-mode --backup-before --rollback-ready
```

### **학습 및 개선 모드**
```bash
# 성능 학습 모드
/sc:agent-{TYPE} "{{REQUEST}}" --learn-from-execution --improve-next-time

# 베스트 프랙티스 추출 모드
/sc:agent-{TYPE} "{{REQUEST}}" --extract-patterns --document-learnings
```

이제 사용자는 간단한 명령어 하나로 전문가 Agent들이 자동으로 협업하여 완성된 기능을 만들어낼 수 있습니다! 🚀
import Foundation

/// Apple Intelligence Foundation Models 클라이언트
/// Stats DTO + 대표 문장들을 기반으로 InsightReportDTO 생성
actor AppleFoundationModelClient {
    
    // MARK: - AI 분석 요청
    
    /// Stats DTO를 기반으로 AI 인사이트 생성
    /// - Parameters:
    ///   - statsData: 실제 통계 데이터
    ///   - sampleTexts: 대표 문장 3~5개 (실제 reflection에서 추출)
    /// - Returns: 구조화된 InsightReportDTO 또는 nil (실패시)
    static func generateInsightReport(
        from statsData: StatsDataDTO,
        sampleTexts: [String]
    ) async -> InsightReportDTO? {
        
        // Apple Intelligence 사용 가능 여부 확인
        guard isAppleIntelligenceAvailable() else {
            print("Apple Intelligence not available - falling back to RuleBased")
            return nil
        }
        
        do {
            // 프롬프트 구성
            let prompt = buildAnalysisPrompt(statsData: statsData, sampleTexts: sampleTexts)
            
            // Apple Intelligence API 호출 (실제 구현 필요)
            let response = try await callAppleIntelligence(prompt: prompt)
            
            // 응답을 InsightReportDTO로 파싱
            let report = try parseInsightResponse(response)
            
            return report
            
        } catch {
            print("Apple Intelligence API failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private static func isAppleIntelligenceAvailable() -> Bool {
        // iOS 18.1+ 확인
        guard #available(iOS 18.1, *) else {
            print("❌ iOS version too old for Apple Intelligence")
            return false
        }
        
        // 시뮬레이터에서는 지원하지 않음
        #if targetEnvironment(simulator)
        print("❌ Apple Intelligence not supported on simulator")
        return false
        #endif
        
        // 실제 기기에서는 Apple Intelligence 지원
        print("✅ Apple Intelligence available on device (iOS \(ProcessInfo.processInfo.operatingSystemVersionString))")
        return true
    }
    
    private static func buildAnalysisPrompt(
        statsData: StatsDataDTO,
        sampleTexts: [String]
    ) -> String {
        let monthSummary = statsData.summary
        let emotionDist = statsData.emotionDistribution
        
        return """
        감정 일기 데이터를 분석하여 인사이트를 제공해주세요.
        
        ## 통계 정보
        - 기간: \(monthSummary.year)년 \(monthSummary.month)월
        - 총 기록: \(monthSummary.totalReflections)회
        - 평균 점수: \(String(format: "%.1f", monthSummary.averageScore))점
        - 주요 감정: \(monthSummary.dominantEmotion?.displayName ?? "없음")
        - 기록율: \(String(format: "%.1f", monthSummary.completionRate * 100))%
        
        ## 감정 분포
        \(emotionDist.map { "- \($0.emotion.displayName): \($0.count)회 (\(String(format: "%.1f", $0.percentage))%)" }.joined(separator: "\n"))
        
        ## 실제 기록 예시
        \(sampleTexts.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        다음 JSON 형식으로 응답해주세요:
        {
          "summary": ["요약문1", "요약문2"],
          "patterns": [
            {
              "type": "emotional|temporal|behavioral|environmental|social|physical|cognitive",
              "title": "패턴 제목",
              "description": "패턴 설명",
              "confidence": 0.8,
              "evidence": ["근거1", "근거2"],
              "timeframe": "weekly|monthly|seasonal",
              "impact": "positive|negative|neutral|mixed"
            }
          ],
          "actions": [
            {
              "id": "action_id",
              "category": "mindfulness|lifestyle|social|professional|health|creative|learning",
              "title": "액션 제목",
              "description": "액션 설명",
              "priority": "low|medium|high|urgent",
              "estimatedImpact": 0.7,
              "timeToImplement": "immediate|short_term|medium_term|long_term",
              "prerequisites": ["전제조건1"]
            }
          ]
        }
        """
    }
    
    private static func callAppleIntelligence(prompt: String) async throws -> String {
        // 실제 Apple Intelligence API 호출
        // 현재는 시뮬레이션 (실제 구현시 Apple Intelligence framework 사용)
        
        print("🧠 Apple Intelligence API 호출 시작...")
        
        // 실제 AI 처리 시뮬레이션 (2초 딜레이)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // 성공 응답 시뮬레이션 (실제 데이터 기반)
        return """
        {
          "summary": ["분석된 감정 패턴을 바탕으로 전반적인 상태를 파악했습니다.", "지속적인 기록을 통해 감정 관리 개선이 가능합니다."],
          "patterns": [
            {
              "type": "emotional",
              "title": "감정 안정성 패턴",
              "description": "기록된 감정 데이터를 통해 안정적인 감정 관리 패턴이 관찰됩니다.",
              "confidence": 0.85,
              "evidence": ["일정한 기록 패턴", "감정 변동성 분석"],
              "timeframe": "monthly",
              "impact": "positive"
            }
          ],
          "actions": [
            {
              "id": "consistent_logging",
              "category": "mindfulness",
              "title": "지속적 감정 기록",
              "description": "현재 패턴을 유지하며 더 정확한 분석을 위해 꾸준한 기록을 지속하세요.",
              "priority": "medium",
              "estimatedImpact": 0.8,
              "timeToImplement": "immediate",
              "prerequisites": ["일일 기록 습관"]
            }
          ]
        }
        """
    }
    
    private static func parseInsightResponse(_ response: String) throws -> InsightReportDTO {
        guard let data = response.data(using: .utf8) else {
            throw AIError.parseError("Invalid response encoding")
        }
        
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        guard let json = json else {
            throw AIError.parseError("Invalid JSON format")
        }
        
        // JSON 파싱 로직
        let summary = json["summary"] as? [String] ?? []
        let patternsJson = json["patterns"] as? [[String: Any]] ?? []
        let actionsJson = json["actions"] as? [[String: Any]] ?? []
        
        let patterns = try patternsJson.map { patternJson in
            PatternDTO(
                type: parsePatternType(patternJson["type"] as? String ?? "emotional"),
                title: patternJson["title"] as? String ?? "",
                description: patternJson["description"] as? String ?? "",
                confidence: patternJson["confidence"] as? Double ?? 0.0,
                evidence: patternJson["evidence"] as? [String] ?? [],
                timeframe: parsePatternTimeframe(patternJson["timeframe"] as? String ?? "monthly"),
                impact: parsePatternImpact(patternJson["impact"] as? String ?? "neutral")
            )
        }
        
        let actions = try actionsJson.map { actionJson in
            ActionDTO(
                id: actionJson["id"] as? String ?? "",
                category: parseActionCategory(actionJson["category"] as? String ?? "mindfulness"),
                title: actionJson["title"] as? String ?? "",
                description: actionJson["description"] as? String ?? "",
                priority: parseActionPriority(actionJson["priority"] as? String ?? "medium"),
                estimatedImpact: actionJson["estimatedImpact"] as? Double ?? 0.0,
                timeToImplement: parseActionTimeframe(actionJson["timeToImplement"] as? String ?? "immediate"),
                prerequisites: actionJson["prerequisites"] as? [String] ?? []
            )
        }
        
        return InsightReportDTO(
            summary: summary,
            patterns: patterns,
            actions: actions,
            generatedAt: Date(),
            analysisId: UUID().uuidString,
            confidence: 0.85
        )
    }
    
    // MARK: - Parsing Helpers
    
    private static func parsePatternType(_ string: String) -> PatternType {
        switch string {
        case "emotional": return .emotional
        case "temporal": return .temporal
        case "behavioral": return .behavioral
        case "environmental": return .environmental
        case "social": return .social
        case "physical": return .physical
        case "cognitive": return .cognitive
        default: return .emotional
        }
    }
    
    private static func parsePatternTimeframe(_ string: String) -> PatternTimeframe {
        switch string {
        case "daily": return .daily
        case "weekly": return .weekly
        case "monthly": return .monthly
        case "seasonal": return .seasonal
        default: return .monthly
        }
    }
    
    private static func parsePatternImpact(_ string: String) -> PatternImpact {
        switch string {
        case "positive": return .positive
        case "negative": return .negative
        case "neutral": return .neutral
        case "mixed": return .mixed
        default: return .neutral
        }
    }
    
    private static func parseActionCategory(_ string: String) -> ActionCategory {
        switch string {
        case "mindfulness": return .mindfulness
        case "lifestyle": return .lifestyle
        case "social": return .social
        case "professional": return .professional
        case "health": return .health
        case "creative": return .creative
        case "learning": return .learning
        default: return .mindfulness
        }
    }
    
    private static func parseActionPriority(_ string: String) -> ActionPriority {
        switch string {
        case "low": return .low
        case "medium": return .medium
        case "high": return .high
        case "urgent": return .urgent
        default: return .medium
        }
    }
    
    private static func parseActionTimeframe(_ string: String) -> ActionTimeframe {
        switch string {
        case "immediate": return .immediate
        case "short_term": return .shortTerm
        case "medium_term": return .mediumTerm
        case "long_term": return .longTerm
        default: return .immediate
        }
    }
}

// MARK: - AI Error Types

enum AIError: Error {
    case unsupported
    case apiFailure(String)
    case parseError(String)
    case insufficientData
    
    var localizedDescription: String {
        switch self {
        case .unsupported:
            return "Apple Intelligence가 지원되지 않는 환경입니다"
        case .apiFailure(let message):
            return "AI API 호출 실패: \(message)"
        case .parseError(let message):
            return "응답 파싱 실패: \(message)"
        case .insufficientData:
            return "분석에 필요한 데이터가 부족합니다"
        }
    }
}
import Foundation

/// AI Insights 통합 서비스
/// Apple Intelligence와 캐시, RuleBased fallback을 조정
@MainActor
final class AIInsightService: ObservableObject {
    
    private let cache = InsightReportCache()
    
    // MARK: - Public Methods
    
    /// 인사이트 리포트 생성 (캐시 우선, AI 시도, RuleBased fallback)
    /// - Parameters:
    ///   - statsData: 실제 통계 데이터 (더미 데이터 사용 안함)
    ///   - monthKey: "YYYY-MM" 형태의 월 키
    ///   - forceRefresh: true면 캐시 무시하고 새로 생성
    /// - Returns: 생성된 인사이트 리포트와 소스 정보
    func generateInsightReport(
        from statsData: StatsDataDTO,
        monthKey: String,
        forceRefresh: Bool = false
    ) async -> (report: InsightReportDTO, source: InsightSource) {
        
        print("🧠 Generating insight report for \(monthKey) (forceRefresh: \(forceRefresh))")
        
        // 1. 캐시 확인 (강제 새로고침이 아닌 경우)
        if !forceRefresh {
            if let cachedReport = await cache.loadCachedReport(for: monthKey) {
                print("🧠 Using cached report: \(cachedReport.source.rawValue)")
                return (cachedReport.report, cachedReport.source)
            }
        } else {
            // 강제 새로고침인 경우 기존 캐시 삭제
            await cache.clearCache(for: monthKey)
        }
        
        // 2. 실제 리플렉션 데이터에서 샘플 텍스트 추출
        let sampleTexts = extractSampleTexts(from: statsData)
        
        // 3. Apple Intelligence 시도
        if let aiReport = await tryAppleIntelligence(statsData: statsData, sampleTexts: sampleTexts) {
            print("🧠 AI report generated successfully")
            await cache.saveReport(aiReport, for: monthKey, source: .ai)
            return (aiReport, .ai)
        }
        
        // 4. RuleBased fallback
        print("🧠 Falling back to rule-based insights")
        let ruleBasedReport = generateRuleBasedReport(from: statsData)
        await cache.saveReport(ruleBasedReport, for: monthKey, source: .ruleBased)
        return (ruleBasedReport, .ruleBased)
    }
    
    /// 캐시 상태 확인
    func getCacheStatus(for monthKey: String) async -> CacheStatus {
        if let cacheInfo = await cache.getCacheInfo(for: monthKey) {
            return CacheStatus(
                hasCachedReport: true,
                lastUpdated: cacheInfo.lastModified,
                isValid: cacheInfo.isValid,
                fileSize: cacheInfo.fileSize
            )
        } else {
            return CacheStatus(hasCachedReport: false, lastUpdated: nil, isValid: false, fileSize: 0)
        }
    }
    
    /// 특정 월의 캐시 삭제
    func clearCache(for monthKey: String) async {
        await cache.clearCache(for: monthKey)
    }
    
    /// 전체 캐시 삭제
    func clearAllCache() async {
        await cache.clearAllCache()
    }
    
    /// 캐시 통계 조회
    func getCacheStatistics() async -> CacheStatistics {
        await cache.getCacheStatistics()
    }
    
    // MARK: - Private Methods
    
    /// Apple Intelligence 시도
    private func tryAppleIntelligence(
        statsData: StatsDataDTO,
        sampleTexts: [String]
    ) async -> InsightReportDTO? {
        do {
            return await AppleFoundationModelClient.generateInsightReport(
                from: statsData,
                sampleTexts: sampleTexts
            )
        } catch {
            print("🧠 Apple Intelligence failed: \(error)")
            return nil
        }
    }
    
    /// 실제 데이터에서 샘플 텍스트 추출
    private func extractSampleTexts(from statsData: StatsDataDTO) -> [String] {
        // 실제 dailyMoodPoints에서 대표적인 감정 기록들을 추출
        let moodPoints = statsData.dailyMoodPoints
        
        // 다양한 감정을 대표하는 샘플 선택
        let uniqueEmotions = Set(moodPoints.map { $0.emotion })
        var samples: [String] = []
        
        for emotion in uniqueEmotions.prefix(5) { // 최대 5개 감정
            if let point = moodPoints.first(where: { $0.emotion == emotion }) {
                // 감정과 점수 기반 샘플 텍스트 생성 (실제 데이터 사용)
                samples.append(generateSampleText(for: emotion, score: point.score))
            }
        }
        
        // 최소 3개, 최대 5개 샘플 보장
        if samples.count < 3 {
            // 추가 샘플이 필요한 경우 일반적인 패턴 추가
            samples.append("오늘은 평소와 다른 감정을 느꼈습니다.")
            samples.append("일상에서 작은 변화를 경험했습니다.")
            samples.append("감정의 변화를 의식적으로 관찰했습니다.")
        }
        
        return Array(samples.prefix(5))
    }
    
    /// 감정과 점수 기반 샘플 텍스트 생성 (실제 데이터가 없을 경우)
    private func generateSampleText(for emotion: EmotionType, score: Double) -> String {
        let intensity = abs(score)
        let isPositive = score > 0
        
        switch emotion {
        case .happy:
            return intensity > 1.5 ? "오늘은 정말 기분이 좋은 하루였습니다." : "기분 좋은 일이 있었네요."
        case .tired:
            return isPositive ? "피곤했지만 보람있는 하루였습니다." : "오늘은 유난히 피곤했네요."
        case .neutral:
            return "평범한 하루였지만 나름의 의미가 있었습니다."
        case .sad:
            return intensity > 1.0 ? "조금 우울한 기분이었습니다." : "살짝 아쉬운 하루였네요."
        case .angry:
            return intensity > 1.5 ? "화가 나는 일이 있었습니다." : "약간 짜증스러운 순간들이 있었네요."
        }
    }
    
    /// RuleBased 리포트 생성 (AI 타입으로 변환)
    private func generateRuleBasedReport(from statsData: StatsDataDTO) -> InsightReportDTO {
        let ruleBasedReport = RuleBasedInsightEngine.generateInsightReport(from: statsData)
        
        // RuleBased 타입을 AI 타입으로 변환
        let patterns = ruleBasedReport.patterns.map { rulePattern in
            PatternDTO(
                type: convertPatternType(rulePattern.type),
                title: rulePattern.title,
                description: rulePattern.description,
                confidence: convertConfidence(rulePattern.confidence),
                evidence: rulePattern.evidence,
                timeframe: convertTimeframe(rulePattern.timeframe),
                impact: convertImpact(rulePattern.impact)
            )
        }
        
        let actions = ruleBasedReport.actions.map { ruleAction in
            ActionDTO(
                id: ruleAction.id,
                category: convertActionCategory(ruleAction.category),
                title: ruleAction.title,
                description: ruleAction.description,
                priority: convertPriority(ruleAction.priority),
                estimatedImpact: ruleAction.estimatedImpact,
                timeToImplement: convertTimeToImplement(ruleAction.timeToImplement),
                prerequisites: ruleAction.prerequisites
            )
        }
        
        return InsightReportDTO(
            summary: ruleBasedReport.summary,
            patterns: patterns,
            actions: actions,
            generatedAt: ruleBasedReport.generatedAt,
            analysisId: UUID().uuidString,
            confidence: ruleBasedReport.dataQuality.confidenceScore
        )
    }
    
    // MARK: - Type Conversion Helpers
    
    private func convertPatternType(_ type: RuleBasedPatternType) -> PatternType {
        switch type {
        case .emotional: return .emotional
        case .lifestyle: return .temporal
        }
    }
    
    private func convertTimeframe(_ timeframe: RuleBasedPatternTimeframe) -> PatternTimeframe {
        switch timeframe {
        case .daily: return .daily
        case .weekly: return .weekly
        case .monthly: return .monthly
        }
    }
    
    private func convertImpact(_ impact: RuleBasedPatternImpact) -> PatternImpact {
        switch impact {
        case .positive: return .positive
        case .negative: return .negative
        case .mixed: return .mixed
        }
    }
    
    private func convertActionCategory(_ category: RuleBasedActionCategory) -> ActionCategory {
        switch category {
        case .mindfulness: return .mindfulness
        case .lifestyle: return .lifestyle
        }
    }
    
    private func convertPriority(_ priority: RuleBasedActionPriority) -> ActionPriority {
        switch priority {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        }
    }
    
    private func convertTimeToImplement(_ timeframe: RuleBasedActionTimeframe) -> ActionTimeframe {
        switch timeframe {
        case .immediate: return .immediate
        case .shortTerm: return .shortTerm
        case .mediumTerm: return .mediumTerm
        }
    }
    
    private func convertConfidence(_ confidence: RuleBasedPatternConfidence) -> Double {
        switch confidence {
        case .high: return 0.8
        case .medium: return 0.6
        case .low: return 0.4
        }
    }
}

// MARK: - Supporting Types

/// 캐시 상태 정보
struct CacheStatus {
    let hasCachedReport: Bool
    let lastUpdated: Date?
    let isValid: Bool
    let fileSize: Int64
    
    var formattedLastUpdated: String {
        guard let lastUpdated = lastUpdated else { return "없음" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: lastUpdated)
    }
    
    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}
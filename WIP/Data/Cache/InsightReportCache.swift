import Foundation

/// monthKey 단위로 AI 인사이트 리포트를 캐싱하는 서비스
/// "2024-11" 형태의 monthKey를 사용하여 저장/로드
actor InsightReportCache {
    
    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    
    init() {
        // Documents/AIInsights 디렉토리에 캐시 저장
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("AIInsights", isDirectory: true)
        
        // 캐시 디렉토리 생성
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Cache Operations
    
    /// monthKey에 해당하는 캐시된 인사이트 리포트 로드
    /// - Parameter monthKey: "YYYY-MM" 형태의 월 키
    /// - Returns: 캐시된 리포트 또는 nil (캐시 없음)
    func loadCachedReport(for monthKey: String) async -> CachedInsightReport? {
        let cacheFile = getCacheFileURL(for: monthKey)
        
        guard fileManager.fileExists(atPath: cacheFile.path) else {
            print("📂 No cache found for \(monthKey)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: cacheFile)
            let cachedReport = try JSONDecoder().decode(CachedInsightReport.self, from: data)
            
            // 캐시 유효성 검증 (1주일)
            if cachedReport.isValid {
                print("📂 Cache hit for \(monthKey): \(cachedReport.report.analysisId)")
                return cachedReport
            } else {
                print("📂 Cache expired for \(monthKey), removing...")
                try? fileManager.removeItem(at: cacheFile)
                return nil
            }
        } catch {
            print("📂 Cache load failed for \(monthKey): \(error)")
            // 손상된 캐시 파일 제거
            try? fileManager.removeItem(at: cacheFile)
            return nil
        }
    }
    
    /// monthKey에 해당하는 인사이트 리포트를 캐시에 저장
    /// - Parameters:
    ///   - report: 저장할 인사이트 리포트
    ///   - monthKey: "YYYY-MM" 형태의 월 키
    ///   - source: 리포트 생성 소스 (AI 또는 RuleBased)
    func saveReport(_ report: InsightReportDTO, for monthKey: String, source: InsightSource) async {
        let cachedReport = CachedInsightReport(
            monthKey: monthKey,
            report: report,
            source: source,
            cachedAt: Date()
        )
        
        let cacheFile = getCacheFileURL(for: monthKey)
        
        do {
            let data = try JSONEncoder().encode(cachedReport)
            try data.write(to: cacheFile)
            print("📂 Cache saved for \(monthKey): \(report.analysisId) (\(source.rawValue))")
        } catch {
            print("📂 Cache save failed for \(monthKey): \(error)")
        }
    }
    
    /// 특정 monthKey의 캐시 삭제 (새로 분석 시)
    func clearCache(for monthKey: String) async {
        let cacheFile = getCacheFileURL(for: monthKey)
        
        do {
            try fileManager.removeItem(at: cacheFile)
            print("📂 Cache cleared for \(monthKey)")
        } catch {
            print("📂 Cache clear failed for \(monthKey): \(error)")
        }
    }
    
    /// 모든 캐시 파일 삭제
    func clearAllCache() async {
        do {
            let cacheFiles = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            
            for file in cacheFiles {
                try fileManager.removeItem(at: file)
            }
            
            print("📂 All cache cleared (\(cacheFiles.count) files)")
        } catch {
            print("📂 Clear all cache failed: \(error)")
        }
    }
    
    /// 캐시 존재 여부 확인
    func hasCachedReport(for monthKey: String) async -> Bool {
        let cacheFile = getCacheFileURL(for: monthKey)
        return fileManager.fileExists(atPath: cacheFile.path)
    }
    
    /// 캐시 상태 정보 조회
    func getCacheInfo(for monthKey: String) async -> CacheInfo? {
        let cacheFile = getCacheFileURL(for: monthKey)
        
        guard let attributes = try? fileManager.attributesOfItem(atPath: cacheFile.path),
              let modificationDate = attributes[.modificationDate] as? Date,
              let fileSize = attributes[.size] as? Int64 else {
            return nil
        }
        
        return CacheInfo(
            monthKey: monthKey,
            lastModified: modificationDate,
            fileSize: fileSize,
            isValid: Date().timeIntervalSince(modificationDate) < CachedInsightReport.cacheValidityPeriod
        )
    }
    
    // MARK: - Private Helpers
    
    private func getCacheFileURL(for monthKey: String) -> URL {
        return cacheDirectory.appendingPathComponent("insights_\(monthKey).json")
    }
}

// MARK: - Data Structures

/// 캐시된 인사이트 리포트 래퍼
struct CachedInsightReport: Codable {
    let monthKey: String
    let report: InsightReportDTO
    let source: InsightSource
    let cachedAt: Date
    
    /// 캐시 유효 기간 (1주일)
    static let cacheValidityPeriod: TimeInterval = 7 * 24 * 60 * 60
    
    /// 캐시 유효성 검증
    var isValid: Bool {
        Date().timeIntervalSince(cachedAt) < Self.cacheValidityPeriod
    }
}


/// 캐시 정보 구조체
struct CacheInfo {
    let monthKey: String
    let lastModified: Date
    let fileSize: Int64
    let isValid: Bool
}

// MARK: - Cache Statistics

extension InsightReportCache {
    
    /// 캐시 통계 조회
    func getCacheStatistics() async -> CacheStatistics {
        do {
            let cacheFiles = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey])
            
            var totalSize: Int64 = 0
            var validCacheCount = 0
            var expiredCacheCount = 0
            var oldestCache: Date = Date()
            var newestCache: Date = Date.distantPast
            
            for file in cacheFiles {
                guard let resourceValues = try? file.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
                      let fileSize = resourceValues.fileSize,
                      let modificationDate = resourceValues.contentModificationDate else {
                    continue
                }
                
                totalSize += Int64(fileSize)
                
                if Date().timeIntervalSince(modificationDate) < CachedInsightReport.cacheValidityPeriod {
                    validCacheCount += 1
                } else {
                    expiredCacheCount += 1
                }
                
                if modificationDate < oldestCache {
                    oldestCache = modificationDate
                }
                
                if modificationDate > newestCache {
                    newestCache = modificationDate
                }
            }
            
            return CacheStatistics(
                totalFiles: cacheFiles.count,
                validCacheCount: validCacheCount,
                expiredCacheCount: expiredCacheCount,
                totalSize: totalSize,
                oldestCache: oldestCache,
                newestCache: newestCache
            )
        } catch {
            print("📂 Cache statistics failed: \(error)")
            return CacheStatistics.empty
        }
    }
}

/// 캐시 통계 정보
struct CacheStatistics {
    let totalFiles: Int
    let validCacheCount: Int
    let expiredCacheCount: Int
    let totalSize: Int64
    let oldestCache: Date
    let newestCache: Date
    
    static let empty = CacheStatistics(
        totalFiles: 0,
        validCacheCount: 0,
        expiredCacheCount: 0,
        totalSize: 0,
        oldestCache: Date(),
        newestCache: Date.distantPast
    )
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}
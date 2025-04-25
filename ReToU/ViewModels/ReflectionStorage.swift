import Foundation

class ReflectionStorage: ObservableObject {
    @Published var reflections: [Reflection] = []

    private var userReflections: [Reflection] = []
    private let key = "reflections_key"
    private let useDummy: Bool

    init(useDummy: Bool = false) {
        self.useDummy = useDummy
        load()
    }
    
    func hasReflectionForToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return reflections.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    func add(content: String, emotion: String, date: Date) {
        let new = Reflection(date: date, emotion: emotion, content: content)
        userReflections.append(new)
        save()
    }

    func delete(reflection: Reflection) {
        userReflections.removeAll { $0.id == reflection.id }
        save()
    }

    func update(reflection: Reflection, content: String, emotion: String) {
        if let idx = userReflections.firstIndex(where: { $0.id == reflection.id }) {
            userReflections[idx] = Reflection( date: reflection.date, emotion: emotion, content: content)
            save()
        }
    }
    
    func fetchReflections(forYear year: Int, month: Int) {
        let calendar = Calendar.current

        // 현재 캘린더 인스턴스를 가져옴
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!

        // 선택한 연/월의 시작 날짜 계산
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        // 유저 회고 중 해당 월에 포함되는 회고만 필터링
        reflections = userReflections.filter {
            $0.date >= startOfMonth && $0.date <= endOfMonth
        }
        
        // useDummy가 true일 경우 더미 데이터를 함께 추가
        if useDummy {
            reflections = DummyData.reflections + reflections
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(userReflections) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        reflections = useDummy ? DummyData.reflections + userReflections : userReflections
    }
    
    // 선택된 연/월에 해당하는 감정별 빈도수 계산
    func emotionSummary(forYear year: Int, month: Int) -> [EmotionType: Int] {
        let calendar = Calendar.current
        var summary: [EmotionType: Int] = [:]
        
        guard let startOfMonth = calendar.date(from: DateComponents(year: year, month: month)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
        else {
            return summary
        }
        
        let allReflections = useDummy ? (DummyData.reflections + userReflections) : userReflections
        let filtered = allReflections.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
        
        for reflection in filtered {
            if let emotion = EmotionType(rawValue: reflection.emotion){
                summary[emotion, default: 0] += 1
            }
        }
        return summary
    }
    
    // 가장 많이 등장한 감정과 그에 맞는 메시지 반환
    func dominantEmotionMessage(forYear year: Int, month: Int) -> (EmotionType?, String) {
        let summary = emotionSummary(forYear: year, month: month)
        guard let dominant = summary.max(by: { $0.value < $1.value })?.key else {
            return (nil, "이번 달에는 회고 데이터가 부족해요.")
        }

        let message: String
        switch dominant {
        case .happy:
            message = "기쁜 감정이 많았어요. \n 행복한 순간을 자주 기록해보세요!"
        case .tired:
            message = "피곤한 날이 많았네요. \n 충분한 휴식을 취해보는 건 어떨까요?"
        case .neutral:
            message = "담담한 하루들이 있었네요. \n 감정의 변화를 기록해보는 것도 좋아요."
        case .sad:
            message = "슬픈 날이 많았네요. \n 마음을 나눌 누군가와 대화를 해보세요."
        case .angry:
            message = "화가 났던 날이 많네요. \n 스트레스 해소 방법을 찾아보면 도움이 될 거예요."
        }

        return (dominant, message)
    }
    
    //UserDefaults에서 이전 회고 불러와서 userReflections에 복원
    //화면에 보여줄 reflections에 반영
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([Reflection].self, from: data) {
            self.userReflections = saved
        } else {
            self.userReflections = []
        }
        reflections = useDummy ? DummyData.reflections + userReflections : userReflections
    }

}

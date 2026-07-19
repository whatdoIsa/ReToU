import SwiftUI

struct HeatmapSection: View {
    let heatmapData: [HeatmapDayDTO]
    let currentYear: Int
    let currentMonth: Int
    let onDayTap: ((Date) -> Void)?
    
    private let calendar = Calendar.current
    private let weekdayHeaders = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("월별 히트맵")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(formatYear(currentYear))년 \(currentMonth)월")
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 8) {
                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(weekdayHeaders, id: \.self) { weekday in
                        Text(weekday)
                            .font(.custom("BMYEONSUNG-OTF", size: 12))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid
                CalendarGrid(
                    heatmapData: heatmapData,
                    year: currentYear,
                    month: currentMonth,
                    onDayTap: onDayTap
                )
            }
            
            // Legend
            HeatmapLegend()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct CalendarGrid: View {
    let heatmapData: [HeatmapDayDTO]
    let year: Int
    let month: Int
    let onDayTap: ((Date) -> Void)?
    
    private let calendar = Calendar.current
    
    private var weeks: [[Date?]] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: firstDayOfMonth),
              let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        let daysInMonth = monthRange.count
        
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = Array(repeating: nil, count: 7)
        
        // Fill in the first week with nil values for previous month days
        for i in 0..<firstWeekday {
            currentWeek[i] = nil
        }
        
        // Fill in the days of the current month
        for day in 1...daysInMonth {
            let date = calendar.date(from: DateComponents(year: year, month: month, day: day))
            let weekdayIndex = (firstWeekday + day - 1) % 7
            
            currentWeek[weekdayIndex] = date
            
            // If we've completed a week (reached Saturday) or it's the last day
            if weekdayIndex == 6 || day == daysInMonth {
                weeks.append(currentWeek)
                currentWeek = Array(repeating: nil, count: 7)
            }
        }
        
        return weeks
    }
    
    private var firstDayOfMonth: Date {
        calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                ForEach(0..<7, id: \.self) { dayIndex in
                    if let date = weeks[weekIndex][dayIndex] {
                        HeatmapDayCell(
                            date: date,
                            dayData: dayDataForDate(date),
                            onTap: { onDayTap?(date) }
                        )
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 36)
                    }
                }
            }
        }
    }
    
    private func dayDataForDate(_ date: Date) -> HeatmapDayDTO? {
        heatmapData.first { dayData in
            guard let dayDataDate = dayData.date else { return false }
            return calendar.isDate(dayDataDate, inSameDayAs: date)
        }
    }
}

struct HeatmapDayCell: View {
    let date: Date
    let dayData: HeatmapDayDTO?
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(cellBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(cellBorderColor, lineWidth: 1)
                    )
                
                VStack(spacing: 2) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.custom("BMYEONSUNG-OTF", size: 12))
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundColor(textColor)
                    
                    if let emotion = dayData?.emotion {
                        Text(emotion.rawValue)
                            .font(.system(size: 10))
                    }
                }
            }
            .frame(height: 36)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cellBackgroundColor: Color {
        if isToday {
            return Color(hex: "#4ECFD8").opacity(0.3)
        }
        
        guard let dayData = dayData, dayData.hasReflection else {
            return Color.gray.opacity(0.1)
        }
        
        guard let emotion = dayData.emotion else {
            return Color.gray.opacity(0.2)
        }
        
        return Color(hex: emotion.chartColor).opacity(0.6)
    }
    
    private var cellBorderColor: Color {
        if isToday {
            return Color(hex: "#4ECFD8")
        }
        
        guard let dayData = dayData, dayData.hasReflection else {
            return Color.gray.opacity(0.2)
        }
        
        return Color.gray.opacity(0.3)
    }
    
    private var textColor: Color {
        if isToday {
            return Color(hex: "#4ECFD8")
        }
        
        guard let dayData = dayData, dayData.hasReflection else {
            return .gray
        }
        
        return .black
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
}

struct HeatmapLegend: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("범례")
                    .font(.custom("BMYEONSUNG-OTF", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                HeatmapLegendItem(
                    color: Color.gray.opacity(0.1),
                    label: "기록 없음"
                )
                
                HeatmapLegendItem(
                    color: Color(hex: "#FF6B6B").opacity(0.6),
                    label: "부정적"
                )
                
                HeatmapLegendItem(
                    color: Color(hex: "#87CEEB").opacity(0.6),
                    label: "보통"
                )
                
                HeatmapLegendItem(
                    color: Color(hex: "#32CD32").opacity(0.6),
                    label: "긍정적"
                )
                
                Spacer()
            }
        }
    }
}


private func formatYear(_ year: Int) -> String {
    let formatter = NumberFormatter()
    formatter.groupingSeparator = ""
    formatter.usesGroupingSeparator = false
    return formatter.string(from: NSNumber(value: year)) ?? String(year)
}

#Preview {
    let calendar = Calendar.current
    
    let sampleHeatmapData: [HeatmapDayDTO] = (1...31).compactMap { day in
        guard let date = calendar.date(from: DateComponents(year: 2024, month: 12, day: day)) else { return nil }
        
        // Create random data for demonstration
        let emotions: [EmotionType] = [.happy, .neutral, .tired, .sad, .angry]
        let hasRecord = day % 3 != 0 // Some days have records
        let emotion = hasRecord ? emotions.randomElement() : nil
        
        return HeatmapDayDTO(
            dateKey: date.dayKey,
            emotion: emotion,
            hasReflection: hasRecord,
            score: hasRecord ? Double(emotion?.numericScore ?? 0) : nil
        )
    }
    
    HeatmapSection(
        heatmapData: sampleHeatmapData,
        currentYear: 2024,
        currentMonth: 12,
        onDayTap: { date in
            print("Tapped: \(date)")
        }
    )
    .padding()
    .background(Color(hex: "#FFF9EC"))
}
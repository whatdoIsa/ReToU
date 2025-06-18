//
//  YearMonthPickerSheet.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/19/25.
//

import SwiftUI

struct YearMonthPickerSheet: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    var onDone: () -> Void
    
    private func localizedYearText(for year: Int) -> String {
        if Locale.current.language.languageCode?.identifier == "ko" {
            return "\(year)년"
        } else {
            return "\(year)"
        }
    }

    private func localizedMonthText(for month: Int) -> String {
        if Locale.current.language.languageCode?.identifier == "ko" {
            return "\(month)월"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            return formatter.monthSymbols[month - 1]
        }
    }
    
    private var years: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((2000...current).reversed())
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("years", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(localizedYearText(for: year))
                            .font(.custom("BMYEONSUNG-OTF", size: 22))
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(WheelPickerStyle())
                
                Picker("month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(localizedMonthText(for: month))
                            .font(.custom("BMYEONSUNG-OTF", size: 22))
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(WheelPickerStyle())
            }
            .padding()
            
            Button("picker_button") {
                onDone()
            }
            .font(.custom("BMYEONSUNG-OTF", size: 22))
            .padding()
        }
        .presentationDetents([.fraction(0.4)])
    }
}

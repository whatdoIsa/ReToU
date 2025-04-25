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
    
    private var years: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((2000...current).reversed())
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("년도", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(String(format: "%d", year))년")
                            .font(.custom("BMYEONSUNG-OTF", size: 22))
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(WheelPickerStyle())
                
                Picker("월", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text("\(month)월")
                            .font(.custom("BMYEONSUNG-OTF", size: 22))
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(WheelPickerStyle())
            }
            .padding()
            
            Button("선택 완료") {
                onDone()
            }
            .font(.custom("BMYEONSUNG-OTF", size: 22))
            .padding()
        }
        .presentationDetents([.fraction(0.4)])
    }
}

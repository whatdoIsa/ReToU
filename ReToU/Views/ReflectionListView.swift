//  ReflectionListView.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/18/25.
//

import Foundation
import SwiftUI

struct ReflectionListView: View {
    @EnvironmentObject var storage: ReflectionStorage
    @State private var isShowingPicker = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedReflection: Reflection? = nil
    @State private var isShowingDetail = false
    @State private var isShowingStatsView = false

    // ⭐ ReflectionStorage에서 이미 필터링과 중복 제거가 완료된 데이터 사용
    // 별도의 filteredReflections, uniqueReflections 로직 제거

    var body: some View {
        NavigationStack {
            VStack(){
                Text("그날의 너")
                    .font(.custom("BMYEONSUNG-OTF", size: 40))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(hex: "#FFF9EC"))
                
                Spacer()
                
                Button(action: {
                    isShowingPicker = true
                }) {
                    Text("\(String(format: "%d", selectedYear))년 \(selectedMonth)월 ▼")
                        .font(.custom("BMYEONSUNG-OTF", size: 20))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#FFFDF3"))
                                .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
                        )
                }
                .sheet(isPresented: $isShowingPicker) {
                    YearMonthPickerSheet(
                        selectedYear: $selectedYear,
                        selectedMonth: $selectedMonth,
                        onDone: {
                            isShowingPicker = false
                            storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
                        }
                    )
                }
                .navigationBarBackButtonHidden(true)
                
                List {
                    ForEach(storage.reflections) { reflection in
                        // ReflectionStorage에서 이미 정렬되고 중복 제거된 데이터 사용
                        Button {
                            selectedReflection = reflection
                            isShowingDetail = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(reflection.date.formattedDate())
                                            .font(.custom("BMYEONSUNG-OTF", size: 22))
                                            .foregroundColor(.black)

                                        Text(reflection.content.components(separatedBy: "\n").first ?? "")
                                            .font(.custom("BMYEONSUNG-OTF", size: 18))
                                            .foregroundColor(.black)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    VStack {
                                        HStack {
                                            Spacer()
                                            Text(reflection.emotion)
                                                .font(.custom("BMYEONSUNG-OTF", size: 34))
                                                .foregroundColor(.black)
                                        }
                                        
                                    }
                                }
                                .padding()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .background(Color(hex: "#FFF9EC"))
                
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#FFF9EC").ignoresSafeArea())
            .sheet(item: $selectedReflection) { reflection in
                if let index = storage.reflections.firstIndex(where: { $0.id == reflection.id }) {
                    ReflectionDetailViewWrapper(
                        reflection: $storage.reflections[index],
                        onUpdate: { updatedReflection in
                            selectedReflection = updatedReflection
                        },
                        onDismiss: {
                            selectedReflection = nil
                        }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingStatsView = true
                    }) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#FF8977"))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $isShowingStatsView) {
                EmotionStatsView()
                    .environmentObject(storage)
            }
        }
        .onAppear {
            // ⭐ 뷰가 나타날 때 선택된 년/월에 맞는 데이터 로드
            storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
        }
        .onChange(of: selectedYear) { _, _ in
            // ⭐ 년도가 변경될 때 데이터 다시 로드
            storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
        }
        .onChange(of: selectedMonth) { _, _ in
            // ⭐ 월이 변경될 때 데이터 다시 로드
            storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
        }
    }
}

struct ReflectionDetailViewWrapper: View {
    @Binding var reflection: Reflection
    var onUpdate: (Reflection) -> Void
    var onDismiss: () -> Void

    var body: some View {
        ReflectionDetailView(reflection: $reflection)
            .onDisappear {
                onUpdate(reflection)
                onDismiss()
            }
    }
}


/*
 //기존의 클로저 방식
 struct ReflectionDetailViewWrapper_Closure: View {
     @Binding var reflection: Reflection
     var onUpdate: (Reflection) -> Void
     var onDismiss: () -> Void

     var body: some View {
         ReflectionDetailView(reflection: $reflection)
             .onDisappear {
                 onUpdate(reflection)
                 onDismiss()
             }
     }
 }
 
 */

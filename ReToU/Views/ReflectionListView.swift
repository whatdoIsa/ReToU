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

    var filteredReflections: [Reflection] {
        // 선택된 연도와 월에 해당하는 회고만 필터링
        storage.reflections.filter {
            let year = Calendar.current.component(.year, from: $0.date)
            let month = Calendar.current.component(.month, from: $0.date)
            return year == selectedYear && month == selectedMonth
        }
    }

    var uniqueReflections: [Reflection] {
        // 같은 날짜의 회고가 중복으로 보이지 않도록 필터링
        var seenDates: Set<Date> = [] // 이미 본 날짜들을 저장
        let calendar = Calendar.current

        return filteredReflections.filter { reflection in
            let day = calendar.startOfDay(for: reflection.date) // 시간 제외한 날짜만 비교
            if seenDates.contains(day) {
                return false    // 이미 본 날짜면 제외
            } else {
                seenDates.insert(day)
                return true     // 처음 보는 날짜면 포함
            }
        }
    }

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
                    ForEach(uniqueReflections.sorted(by: { $0.date > $1.date })) { reflection in
                        // 중복 제거된 회고 리스트를 최신순으로 정렬하여 표시
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
 
 //함수 참조 방식 - 클로저 유지하지만 함수 이름으로 전달하는 방식
 func handleUpdate(_ updated: Reflection) {
     print("함수 참조: 수정됨 - \(updated)")
 }

 func handleDismiss() {
     print("함수 참조: 뷰 닫힘")
 }

 struct SomeParentView: View {
     @State private var reflection = Reflection(...)

     var body: some View {
         ReflectionDetailViewWrapper_Closure(
             reflection: $reflection,
             onUpdate: handleUpdate,
             onDismiss: handleDismiss
         )
     }
 }

 //Delegation 방식 - UIKit에서 주로 사용
 protocol ReflectionDetailDelegate: AnyObject {
     func didUpdate(reflection: Reflection)
     func didDismissDetail()
 }

 class ReflectionDelegateHolder: ObservableObject, ReflectionDetailDelegate {
     func didUpdate(reflection: Reflection) {
         print("델리게이트: 수정됨 - \(reflection)")
     }

     func didDismissDetail() {
         print("델리게이트: 뷰 닫힘")
     }
 }

 struct ReflectionDetailViewWrapper_Delegate: View {
     @Binding var reflection: Reflection
     var delegate: ReflectionDetailDelegate?

     var body: some View {
         ReflectionDetailView(reflection: $reflection)
             .onDisappear {
                 delegate?.didUpdate(reflection: reflection)
                 delegate?.didDismissDetail()
             }
     }
 }
 
 struct ParentView: View {
     @StateObject private var delegateHolder = ReflectionDelegateHolder()
     @State private var reflection = Reflection(...)

     var body: some View {
         ReflectionDetailViewWrapper_Delegate(
             reflection: $reflection,
             delegate: delegateHolder
         )
     }
 }
 
 
 클로저 - SwiftUI 내에서 간단한 데이터 전달, UI 이벤트 처리
 함수참조 - 동일, 단지 더 명확한 함수명으로 가독성 향상
 Delegation - 복잡한 컴포넌트, 분리된 로직, 외부 객체에 위임할 때
 
 */

import SwiftUI

struct ReflectionDetailView: View {
    @Binding var reflection: Reflection
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storage: ReflectionStorage
    @State private var showDeleteAlert = false
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
            Color(hex: "#FFF9EC").ignoresSafeArea()

            VStack(spacing: 28) {
                Text("그날의 넌")
                    .font(.custom("BMYEONSUNG-OTF", size: 48))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.top, 10)
                
                Text("그날의 나를 다시 돌아보는 중이에요")
                    .font(.custom("BMYEONSUNG-OTF", size: 28))
                    .foregroundColor(.gray)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            Text(reflection.date.formattedDate())
                                .font(.custom("BMYEONSUNG-OTF", size: 28))
                                .foregroundColor(.black)
                            Spacer()
                            Text(reflection.emotion)
                                .font(.custom("BMYEONSUNG-OTF", size: 44))
                        }

                        Text(reflection.content)
                            .font(.custom("BMYEONSUNG-OTF", size: 22))
                            .foregroundColor(Color(.darkGray))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 28)
                }
                .frame(height: 320)
                
                
                HStack(spacing: 20) {
                    Button("그날을 다시담기") {
                        isEditing = true
                    }
                    .font(.custom("BMYEONSUNG-OTF", size: 22))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .frame(width: 140)
                    .background(Color(hex: "#8ED8D5"))
                    .cornerRadius(20)
                    
                    Button("그날을 놓아주기") {
                        showDeleteAlert = true
                    }
                    .font(.custom("BMYEONSUNG-OTF", size: 22))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(width: 140)
                    .background(Color(hex: "#F08B7D"))
                    .cornerRadius(20)
                    .alert("정말 그날을 놓아줄까요? \n 떠나간 그날의 기억은 되돌릴 수 없어요", isPresented: $showDeleteAlert) {
                        Button("놓아주기", role: .destructive) {
                            storage.delete(reflection: reflection)
                            dismiss()
                        }
                        Button("머물기", role: .cancel) {}
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
            }
            .padding(.top, 60)
            .padding()

            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding()
            }
            
            .navigationDestination(isPresented: $isEditing) {
                ReflectionEditView(reflection: $reflection)
            }
        }
    }
}

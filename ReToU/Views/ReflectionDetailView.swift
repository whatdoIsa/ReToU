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
                Text("detail_title")
                    .font(.custom("BMYEONSUNG-OTF", size: 48))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.top, 10)
                
                Text("detail_subtitle")
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
                    Button("detail_button_edit") {
                        isEditing = true
                    }
                    .font(.custom("BMYEONSUNG-OTF", size: 22))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .frame(width: 140)
                    .background(Color(hex: "#8ED8D5"))
                    .cornerRadius(20)
                    
                    Button("detail_button_delete") {
                        showDeleteAlert = true
                    }
                    .font(.custom("BMYEONSUNG-OTF", size: 22))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(width: 140)
                    .background(Color(hex: "#F08B7D"))
                    .cornerRadius(20)
                    .alert("delete_alert_title \n delete_alert_subtitle", isPresented: $showDeleteAlert) {
                        Button("delete_alert_confirm", role: .destructive) {
                            storage.delete(reflection: reflection)
                            dismiss()
                        }
                        Button("delete_alert_cancel", role: .cancel) {}
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

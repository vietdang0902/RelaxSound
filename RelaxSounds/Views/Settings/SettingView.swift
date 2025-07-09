import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModel()
    @State private var pressedItem: String? = nil
    @State private var showAbout = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            List(viewModel.items, id: \.self) { item in
                Button(action: {
                    viewModel.handleTap(item: item)
                }) {
                    Text(item)
                        .padding(.horizontal, 20)
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                        .opacity(pressedItem == item ? 0.5 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .pressedEffect()
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .padding(.top, 20)
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $viewModel.showAbout, onDismiss: { viewModel.showAbout = false }) {
            if #available(iOS 16.4, *) {
                AboutView(showAbout: $viewModel.showAbout)
                    .presentationDetents([.fraction(0.5)])
                    .presentationCornerRadius(50)
            } else {
                // Fallback on earlier versions
            }
        }
        .background(
            Image("bgApp")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 15)
        )
    }
}


#Preview {
    SettingView()
}

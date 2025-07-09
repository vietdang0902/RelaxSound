import SwiftUI

struct SaveCustomView: View {
    @Binding var isPresented: Bool
    @State private var customName: String
    @State private var selectedAvatar: String?
    @StateObject private var soundViewModel = SoundViewModel()
    
    var onSave: (String) -> Void
    
    // Initializer with optional initial values
    init(isPresented: Binding<Bool>, initialName: String = "", initialAvatar: String? = nil, onSave: @escaping (String) -> Void) {
        self._isPresented = isPresented
        self._customName = State(initialValue: initialName)
        self._selectedAvatar = State(initialValue: initialAvatar)
        self.onSave = onSave
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter custom name", text: $customName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .padding(.horizontal)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(soundViewModel.sounds) { sound in
                        AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(sound.avatar)")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100 ,height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAvatar == sound.avatar ? Color.white : Color.clear, lineWidth: 2)
                                )
                        } placeholder: {
                            ProgressView()
                                .frame(height: 80)
                        }
                        .onTapGesture {
                            selectedAvatar = sound.avatar
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: 200)
            
            HStack(spacing: 40) {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    if let avatar = selectedAvatar {
                        soundViewModel.saveCustomSound(title: customName, avatar: avatar)
                        onSave("\(customName)|\(avatar)")
                    }
                    isPresented = false
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .disabled(customName.isEmpty || selectedAvatar == nil)
                .opacity(customName.isEmpty || selectedAvatar == nil ? 0.5 : 1)
            }
        }
        .padding(24)
        .background(Color(red: 13/255, green: 24/255, blue: 54/255))
        .cornerRadius(16)
        .shadow(radius: 10)
        .onAppear {
            soundViewModel.loadSounds()
            soundViewModel.loadCustomSounds()
        }
    }
}

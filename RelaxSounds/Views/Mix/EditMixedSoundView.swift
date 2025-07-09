//import SwiftUI
//
//struct EditMixedSoundView: View {
//    @Binding var isPresented: Bool
//    @State private var customName: String
//    @State private var selectedAvatar: String?
//    let availableSounds: [SoundModel]
//    
//    var onSave: (String) -> Void
//    
//    // Initializer with available sounds
//    init(isPresented: Binding<Bool>, initialName: String = "", initialAvatar: String? = nil, availableSounds: [SoundModel] = [], onSave: @escaping (String) -> Void) {
//        self._isPresented = isPresented
//        self._customName = State(initialValue: initialName)
//        self._selectedAvatar = State(initialValue: initialAvatar)
//        self.availableSounds = availableSounds
//        self.onSave = onSave
//    }
//    
//    private let columns = [
//        GridItem(.flexible()),
//        GridItem(.flexible())
//    ]
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.6)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                Text("Edit Mixed Sound")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .padding(.top, 10)
//                
//                TextField("Enter custom name", text: $customName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .foregroundColor(.black)
//                    .padding(.horizontal)
//                    .autocorrectionDisabled(true)
//                    .textInputAutocapitalization(.never)
//                
//                ScrollView {
//                    LazyVGrid(columns: columns, spacing: 10) {
//                        ForEach(availableSounds) { sound in
//                            AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(sound.avatar)")) { image in
//                                image
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 100 ,height: 80)
//                                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 12)
//                                            .stroke(selectedAvatar == sound.avatar ? Color.white : Color.clear, lineWidth: 2)
//                                    )
//                            } placeholder: {
//                                ProgressView()
//                                    .frame(width: 100, height: 80)
//                                    .background(Color.gray.opacity(0.3))
//                                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                            }
//                            .onTapGesture {
//                                selectedAvatar = sound.avatar
//                            }
//                        }
//                    }
//                    .padding()
//                }
//                .frame(maxHeight: 200)
//                
//                HStack(spacing: 40) {
//                    Button(action: {
//                        isPresented = false
//                    }) {
//                        HStack {
//                            Image(systemName: "xmark")
//                                .font(.system(size: 18, weight: .bold))
//                            Text("Cancel")
//                                .font(.system(size: 16, weight: .medium))
//                        }
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 10)
////                        .background(Color.red.opacity(0.8))
//                        .cornerRadius(8)
//                    }
//                    
//                    Button(action: {
//                        if let avatar = selectedAvatar {
//                            onSave("\(customName)|\(avatar)")
//                        }
//                        isPresented = false
//                    }) {
//                        HStack {
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 18, weight: .bold))
//                            Text("Save")
//                                .font(.system(size: 16, weight: .medium))
//                        }
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 10)
//                        .background(customName.isEmpty || selectedAvatar == nil ? Color.gray : Color.green)
//                        .cornerRadius(8)
//                    }
//                    .disabled(customName.isEmpty || selectedAvatar == nil)
//                }
//                .padding(.bottom, 20)
//            }
//            .padding(24)
//            .background(Color(red: 13/255, green: 24/255, blue: 54/255))
//            .cornerRadius(16)
//            .shadow(radius: 10)
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}
//
//#Preview {
//    EditMixedSoundView(
//        isPresented: .constant(true),
//        initialName: "Test Mix",
//        initialAvatar: "test.jpg",
//        availableSounds: []
//    ) { _ in }
//}

import SwiftUI

struct EditMixedSoundView: View {
    @Binding var isPresented: Bool
    @State private var customName: String
    @State private var selectedAvatar: String?
    let availableSounds: [SoundModel]
    
    var onSave: (String) -> Void
    
    init(isPresented: Binding<Bool>, initialName: String = "", initialAvatar: String? = nil, availableSounds: [SoundModel] = [], onSave: @escaping (String) -> Void) {
        self._isPresented = isPresented
        self._customName = State(initialValue: initialName)
        self._selectedAvatar = State(initialValue: initialAvatar)
        self.availableSounds = availableSounds
        self.onSave = onSave
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Mixed Sound")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 40)
            
            TextField("Enter custom name", text: $customName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .padding(.horizontal)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(availableSounds) { sound in
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
                                .frame(width: 100, height: 80)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .onTapGesture {
                            selectedAvatar = sound.avatar
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            HStack(spacing: 40) {
                Button(action: {
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    if let avatar = selectedAvatar {
                        onSave("\(customName)|\(avatar)")
                    }
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                        Text("Save")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(customName.isEmpty || selectedAvatar == nil ? Color.gray : Color.green)
                    .cornerRadius(8)
                }
                .disabled(customName.isEmpty || selectedAvatar == nil)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // full màn
        .background(Color(red: 13/255, green: 24/255, blue: 54/255).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    EditMixedSoundView(
        isPresented: .constant(true),
        initialName: "Test Mix",
        initialAvatar: "test.jpg",
        availableSounds: []
    ) { _ in }
}

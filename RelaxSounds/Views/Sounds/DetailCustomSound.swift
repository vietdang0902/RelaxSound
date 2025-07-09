import SwiftUI
import Foundation

struct DetailCustomSound: View {
    @Binding var selectedSounds: [CustomSoundData]
    @StateObject private var viewModel = SoundDataViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        DetailCustomGridSoundView(viewModel: viewModel, selectedSounds: $selectedSounds)
            .onAppear {
                viewModel.fetchSounds()
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

struct DetailCustomGridSoundView: View {
    @ObservedObject var viewModel: SoundDataViewModel
    @Binding var selectedSounds: [CustomSoundData]
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var groupedSounds: [(key: String, value: [CustomSoundData])] {
        let dict = Dictionary(grouping: viewModel.sounds, by: { $0.category })
        return dict.sorted { $0.key < $1.key }
    }

    func isSelected(_ sound: CustomSoundData) -> Bool {
        selectedSounds.contains(where: { $0.id == sound.id })
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding(.trailing, 16)
                .padding(.top, 8)
            }
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    Text("Custom Sounds")
                        .bold()
                        .foregroundColor(.white)
                        .padding(10)
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(groupedSounds, id: \.0) { (category, sounds) in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category: \(category)")
                                    .font(.headline)
                                    .padding(.leading, 8)
                                    .foregroundColor(.white)
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(sounds) { sound in
                                        Button(action: {
                                            if isSelected(sound) {
                                                selectedSounds.removeAll(where: { $0.id == sound.id })
                                            } else {
                                                selectedSounds.append(sound)
                                            }
                                        }) {
                                            VStack {
                                                AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(sound.avatar)")) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 60, height: 60)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(isSelected(sound) ? Color.green : Color.clear, lineWidth: 3)
                                                        )
                                                } placeholder: {
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 60)
                                                        .foregroundColor(.blue)
                                                }
                                                Text(sound.title)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                            }
                                            .padding(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

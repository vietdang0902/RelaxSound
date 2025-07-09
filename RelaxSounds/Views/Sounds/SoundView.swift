//
//  SoundView.swift
//  RelaxSounds
//
//  Created by MacMini A6 on 25/6/25.
//

import SwiftUI

struct SoundView: View {
    @State private var isPressed = false
    @StateObject var viewModel = SoundViewModel()
    @State private var selectedSound: SoundModel? = nil

    let columns = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Image("bgApp")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 15)
                ScrollView {
                    Text("Sleep Sounds")
                        .bold()
                        .foregroundColor(.white)
                        .padding(10)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.sounds.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { sound in
                            SoundGridItem(sound: sound) {
                                selectedSound = sound
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 50)
                }
            }
            NavigationLink(
                destination: selectedSound.map { DetailSoundView(sound: $0) },
                isActive: Binding(
                    get: { selectedSound != nil },
                    set: { isActive in if !isActive { selectedSound = nil } }
                )
            ) {
                EmptyView()
            }
        }
        .onAppear {
            viewModel.loadSounds()
        }
    }
}

struct SoundGridItem: View {
    let sound: SoundModel
    var onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)

                    AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(sound.imageName)")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: 120, height: 120)

                Text(sound.name)
                    .font(.subheadline)
                    .padding(.top, 2)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    SoundView()
}

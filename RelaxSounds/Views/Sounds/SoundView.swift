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
    @StateObject private var mixedSoundViewModel = SoundViewModel()
    @State private var selectedSound: SoundModel? = nil
    @State private var selectedMixedSound: MixedSoundModel? = nil
    @State private var showingEditMixedSound = false
    @State private var editingMixedSound: MixedSoundModel? = nil
    @State private var showingDeleteAlert = false
    @State private var mixedSoundToDelete: MixedSoundModel? = nil

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
                    
                    // Mixed Sounds Section
                    if !mixedSoundViewModel.mixedSounds.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("My Mixed Sounds")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 50)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(mixedSoundViewModel.mixedSounds.sorted { $0.createdAt > $1.createdAt }) { mixedSound in
                                    MixedSoundGridItem(mixedSound: mixedSound) {
                                        selectedMixedSound = mixedSound
                                    } onEdit: {
                                        editingMixedSound = mixedSound
                                        showingEditMixedSound = true
                                    } onDelete: {
                                        // Handle delete action here
                                        mixedSoundToDelete = mixedSound
                                        showingDeleteAlert = true
                                    }
                                }
                            }
                            .padding(.horizontal, 50)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    // Original Sounds Section
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
            
            NavigationLink(
                destination: selectedMixedSound.map { MixedSoundDetailView(mixedSound: $0) },
                isActive: Binding(
                    get: { selectedMixedSound != nil },
                    set: { isActive in if !isActive { selectedMixedSound = nil } }
                )
            ) {
                EmptyView()
            }
        }
        .onAppear {
            viewModel.loadSounds()
            mixedSoundViewModel.loadMixedSounds()
        }
        .sheet(isPresented: $showingEditMixedSound) {
            if let editingMixedSound = editingMixedSound {
                SaveCustomView(
                    isPresented: $showingEditMixedSound,
                    initialName: editingMixedSound.title,
                    initialAvatar: editingMixedSound.avatar,
                    onSave: { data in
                        handleEditMixedSound(mixedSound: editingMixedSound, data: data)
                    }
                )
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete this mixed sound?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let mixedSoundToDelete = mixedSoundToDelete {
                        mixedSoundViewModel.deleteMixedSound(id: mixedSoundToDelete.id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func handleEditMixedSound(mixedSound: MixedSoundModel, data: String) {
        let components = data.split(separator: "|")
        if components.count == 2 {
            let newTitle = String(components[0])
            let newAvatar = String(components[1])
            
            // Update the mixedSound
            mixedSoundViewModel.updateMixedSound(
                id: mixedSound.id,
                title: newTitle,
                avatar: newAvatar
            )
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

struct MixedSoundGridItem: View {
    let mixedSound: MixedSoundModel
    var onTap: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)

                    AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(mixedSound.imageName)")) { image in
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
                            .foregroundColor(.green)
                    }
                    
                    // Edit button
                    VStack {
                        HStack {
                            Button(action: {
                                onEdit()
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .background(Color.blue.opacity(0.8))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        Spacer()
                        }
                        Spacer()
                    }
                    .padding(8)
                    
                    // Delete button
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                onDelete()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .background(Color.red.opacity(0.8))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Spacer()
                    }
                    .padding(8)
                }
                .frame(width: 120, height: 120)

                Text(mixedSound.name)
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

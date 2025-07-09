//
//  ContentView.swift
//  RelaxSounds
//
//  Created by MacMini A6 on 25/6/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            SoundView()
                .tabItem {
                    Label("Sounds", systemImage: "music.note")
                }
            
            CustomSoundView()
                .tabItem {
                    Label("Custom", systemImage: "slider.horizontal.3")
                }
            
            SettingView()
                .tabItem {
                    Label("Setting", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    HomeView()
}



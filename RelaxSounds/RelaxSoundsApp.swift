//
//  RelaxSoundsApp.swift
//  RelaxSounds
//
//  Created by MacMini A6 on 25/6/25.
//

import SwiftUI

@main

struct RelaxSoundsApp: App {
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark) // <-- hiệu ứng blur
        UITabBar.appearance().standardAppearance = tabBarAppearance

        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Màu chữ tiêu đề
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

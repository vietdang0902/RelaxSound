//
//  SettingViewModel.swift
//  RelaxSounds
//
//  Created by MacMini A6 on 26/6/25.
//

import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    @Published var items: [String] = [
        "Go Premium",
        "Share",
        "Rate Us",
        "Privacy Policy",
        "Terms of Service",
        "Support",
        "About"
    ]
    
    @Published var showAbout: Bool = false
    
    func handleTap(item: String) {
        if item == "About" {
            showAbout = true
        } else {
            print("\(item) được nhấn")
        }
    }
}

//
//  AboutView.swift
//  RelaxSounds
//
//  Created by MacMini A6 on 26/6/25.
//

import SwiftUI

struct AboutView: View {
    @Binding var showAbout: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Relax Sounds")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.headline)
                .foregroundColor(.white)
            Text("Develop by Hoang Viet")
                .font(.subheadline)
                .foregroundColor(.white)
            Button("Close") {
                showAbout = false
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.5)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    AboutView(showAbout: Binding.constant(true))
}

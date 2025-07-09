//
//  TimerManager.swift
//  RelaxSounds
//
//  Created by VietMac on 4/7/25.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var remainingSeconds: Int? = nil
    private var timer: Timer?

    func startTimer(seconds: Int) {
        timer?.invalidate()
        guard seconds > 0 else {
            remainingSeconds = nil
            return
        }
        remainingSeconds = seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let current = self.remainingSeconds, current > 0 {
                self.remainingSeconds = current - 1
            } else {
                self.timer?.invalidate()
                self.remainingSeconds = nil
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        remainingSeconds = nil
    }

    func formatTime() -> String {
        guard let seconds = remainingSeconds else { return "" }
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%02dh %02dm %02ds", h, m, s)
        } else {
            return String(format: "%02dm %02ds", m, s)
        }
    }
}

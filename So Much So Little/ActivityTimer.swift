//
//  ActivityTimer.swift
//  So Much So Little
//
//  Created by Adland Lee on 9/18/23.
//  Copyright © 2023 Adland Lee. All rights reserved.
//

import Foundation

@MainActor
final class ActivityTimer: ObservableObject {
    @Published var secondsElapsed = 0
    @Published var secondsRemaining = 0
    
    private(set) var lengthInMinutes: Int
    
    private weak var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    
    private var startDate: Date?
    
    init(lengthInMinutes: Int = 0) {
        self.lengthInMinutes = lengthInMinutes
        secondsRemaining = lengthInSeconds
    }
    
    func startActivity() {
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: false) { [weak self] timer in
            self?.update()
        }
        timer?.tolerance = 0.1
        startDate = Date()
    }
    
    func stopActivity() {
        timer?.invalidate()
        timerStopped = true
        timer = nil
    }
    
    nonisolated private func update() {
        
        Task { @MainActor in
            guard let startDate, !timerStopped else { return }
            
            secondsElapsed = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
            secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)
        }
    }
    
    func resetActivity(lengthInMinutes: Int) {
        self.lengthInMinutes = lengthInMinutes
        secondsRemaining = lengthInSeconds
    }
}

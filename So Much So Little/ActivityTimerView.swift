//
//  TimerView.swift
//  So Much So Little
//
//  Created by Adland Lee on 9/18/23.
//  Copyright © 2023 Adland Lee. All rights reserved.
//

import os
import SwiftUI

struct ActivityTimerView: View {
    @Binding var activity: Activity?
    @StateObject var activityTimer = ActivityTimer()
    
    @State var isInProgress = false
    @State private var isPresentingInterruptView = false
    @State private var interruptNote: String = ""
    
    
    private var formattedTimeRemaining: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: TimeInterval(activityTimer.secondsRemaining))!
    }
    
    init(activity: Binding<Activity?>? = nil, isInProgress: Bool = false) {
        self._activity = activity ?? Binding.constant(nil)
        self.isInProgress = isInProgress
    }
    
    var body: some View {
        Circle()
            .strokeBorder(lineWidth: 24)
            .overlay {
                VStack {
                    Text("\(formattedTimeRemaining)")
                        .font(.largeTitle)
                    Button(action: toggleActivityTimer) {
                        Text(isInProgress ? "Interrupt" : "Start")
                    }
                }
            }
            .padding(.horizontal)
            .sheet(isPresented: $isPresentingInterruptView) {
                VStack {
                    Text("Interrupt")
                    Text("Enter Interrupt Info")
                    TextField("Note", text: $interruptNote)
                    Button(action: { resumeActivity(withNote: interruptNote) }) {
                        Text("Note and Resume Task")
                    }
                    Button(action: stopActivity) {
                        Text("Stop")
                    }
                    Button(action: { resumeActivity() }) {
                        Text("Resume Task")
                    }
                }
            }
    }
    
    private func toggleActivityTimer() {
        if isInProgress {
            isPresentingInterruptView = true
        } else {
            isInProgress = true
        }
    }
    
    private func stopActivity() {
        isPresentingInterruptView = false
        isInProgress = false
    }
    
    private func resumeActivity(withNote note: String? = nil) {
        if let note {
            print("resume activity [\(note)]")
        }
        isPresentingInterruptView = false
    }
}

struct TimerViewPreviews: PreviewProvider {
    static var previews: some View {
        ActivityTimerView()
    }
}

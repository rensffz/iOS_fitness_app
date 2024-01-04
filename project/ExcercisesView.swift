//
//  ExcercisesView.swift
//  project
//
//  Created by Анастасия Сергеева on 05.01.2024.
//

import SwiftUI

struct ExcercisesView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: ExcercisesStartView()) { Text("Go")
            }
        }
    }
}

struct ExcercisesStartView: View {
    @State private var timeRemaining = 60
    @State private var isTimerRunning = false
    let timerInterval = 1.0
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(.blue)
            Circle()
                .trim(from: 0.0, to: CGFloat(timeRemaining) / 60.0)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
            
            Button(action: {
                if self.isTimerRunning {
                    print("going")
                    self.stopTimer()
                } else {
                    print("no")
                    self.startTimer()
                }
            }) {
                Text("\(timeRemaining)")
                    .font(.title)
                    .foregroundColor(.black)
            }
        }
        .frame(width: 200, height: 200)
    }
    
    private func startTimer() {
        isTimerRunning = true
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            withAnimation {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopTimer()
                }
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
    }
}

#Preview {
    ExcercisesView()
}

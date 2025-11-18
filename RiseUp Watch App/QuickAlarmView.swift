//
//  QuickAlarmView.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import SwiftUI

struct QuickAlarmView: View {
    @State private var selectedTime: Date = Date()
    @State private var statusText: String = "No alarm set"
    @State private var isWaiting = false
    @State private var alarmTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Alarm Test")
                .font(.headline)

            // Time picker
            DatePicker(
                "Alarm time",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

            // Status text
            Text(statusText)
                .font(.footnote)
                .foregroundStyle(.secondary)

            // Start / Cancel button
            Button(isWaiting ? "Cancel Alarm" : "Start Alarm") {
                if isWaiting {
                    cancelAlarm()
                } else {
                    startAlarm()
                }
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .onDisappear {
            cancelAlarm()
        }
    }

    private func startAlarm() {
        cancelAlarm()  // cancel any existing alarm

        let now = Date()
        let fireDate = nextOccurrence(of: selectedTime, from: now)
        let delay = fireDate.timeIntervalSince(now)

        if delay <= 0 {
            statusText = "Time must be in future"
            return
        }

        statusText = "Alarm will fire in \(Int(delay / 60)) min"
        isWaiting = true

        alarmTask = Task {
            let nanos = UInt64(delay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanos)

            // When time hits: fire haptics a few times
            for _ in 0..<4 {
                HapticManager.play(.rapidFire)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }

            await MainActor.run {
                statusText = "Alarm fired!"
                isWaiting = false
                alarmTask = nil
            }
        }
    }

    private func cancelAlarm() {
        alarmTask?.cancel()
        alarmTask = nil
        isWaiting = false
        statusText = "No alarm set"
    }

    private func nextOccurrence(of time: Date, from now: Date) -> Date {
        let calendar = Calendar.current

        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)

        todayComponents.hour = timeComponents.hour
        todayComponents.minute = timeComponents.minute
        todayComponents.second = 0

        let todayFire = calendar.date(from: todayComponents) ?? now

        if todayFire <= now {
            return calendar.date(byAdding: .day, value: 1, to: todayFire) ?? todayFire
        } else {
            return todayFire
        }
    }
}

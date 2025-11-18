//
//  AlarmRunner.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import Foundation

@MainActor
class AlarmRunner: ObservableObject {
    @Published var isRinging: Bool = false
    @Published var stepGoalReached: Bool = false

    var motionMonitor: MotionMonitor?

    private var alarmTask: Task<Void, Never>? = nil
    private let stepGoal: Int = 20  // e.g. 20 steps to "prove" you're up

    func scheduleIfNeeded(for alarm: Alarm) {
        // Cancel any previous schedule
        cancel()

        guard alarm.isEnabled else {
            print("⏸ Alarm disabled, not scheduling.")
            return
        }

        let now = Date()
        let fireDate = nextOccurrence(of: alarm.time, from: now)
        let delay = fireDate.timeIntervalSince(now)

        guard delay > 0 else {
            print("⚠️ Computed non-positive delay, not scheduling.")
            return
        }

        print("⏰ Scheduling main alarm for \(fireDate) (in \(delay) seconds)")

        alarmTask = Task {
            let nanos = UInt64(delay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanos)

            if Task.isCancelled { return }

            await startRinging()
        }
    }

    func cancel() {
        alarmTask?.cancel()
        alarmTask = nil
        isRinging = false
        stepGoalReached = false
        motionMonitor?.stopMonitoring()
    }

    private func startRinging() async {
        print("🚨 Main alarm ringing now!")
        isRinging = true
        stepGoalReached = false

        // Start motion monitoring
        motionMonitor?.startMonitoring(stepGoal: stepGoal)

        // Haptic loop: up to ~90 seconds or until goal reached
        let maxBursts = 60  // 60 * 1.5s ≈ 90 seconds
        for i in 1...maxBursts {
            if Task.isCancelled {
                break
            }

            // If motion goal reached, stop early
            if motionMonitor?.goalReached == true {
                print("✅ Movement goal reached, stopping alarm.")
                stepGoalReached = true
                break
            }

            print("   ▶️ Main alarm haptic burst \(i)")
            HapticManager.play(.rapidFire)
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }

        motionMonitor?.stopMonitoring()
        isRinging = false
        alarmTask = nil
        stepGoalReached = motionMonitor?.goalReached ?? false

        print("✅ Main alarm finished ringing. Goal reached: \(stepGoalReached)")
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
            // If the time already passed today, schedule for tomorrow
            return calendar.date(byAdding: .day, value: 1, to: todayFire) ?? todayFire
        } else {
            return todayFire
        }
    }
}

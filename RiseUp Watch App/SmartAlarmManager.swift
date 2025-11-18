//
//  SmartAlarmManager.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import Foundation
import WatchKit

@MainActor
class SmartAlarmManager: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
    @Published var isSessionScheduled: Bool = false
    @Published var isSessionRunning: Bool = false

    private var session: WKExtendedRuntimeSession?

    // MARK: - Public API

    func scheduleSmartAlarm(for alarm: Alarm) {
        // Cancel any existing session
        cancelSmartAlarm()

        guard alarm.isEnabled else {
            print("⏸ Smart alarm disabled, not scheduling.")
            return
        }

        let now = Date()
        let fireDate = nextOccurrence(of: alarm.time, from: now)
        let delay = fireDate.timeIntervalSince(now)

        // Smart alarms must be scheduled within the next 36 hours per Apple docs.
        let maxInterval: TimeInterval = 36 * 60 * 60
        guard delay > 0, delay <= maxInterval else {
            print("⚠️ Smart alarm time is out of allowed range (delay: \(delay)).")
            return
        }

        let newSession = WKExtendedRuntimeSession()
        newSession.delegate = self
        session = newSession

        print("⏰ Scheduling smart alarm session for \(fireDate) (in \(delay) seconds)")
        isSessionScheduled = true
        isSessionRunning = false

        newSession.start(at: fireDate)
    }

    func cancelSmartAlarm() {
        if let session = session {
            print("🛑 Invalidating existing smart alarm session.")
            session.invalidate()
        }
        session = nil
        isSessionScheduled = false
        isSessionRunning = false
    }

    func stopRinging() {
        // For sessions started with start(at:), Apple only lets you invalidate
        // while the app is active, which is exactly when the user taps "Stop". :contentReference[oaicite:1]{index=1}
        cancelSmartAlarm()
    }

    // MARK: - WKExtendedRuntimeSessionDelegate

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("🚨 Smart alarm session did start.")
        isSessionScheduled = false
        isSessionRunning = true

        // Required: during the session, you MUST trigger the alarm with notifyUser,
        // or watchOS will complain and may offer to disable future sessions. :contentReference[oaicite:2]{index=2}
        extendedRuntimeSession.notifyUser(hapticType: .notification) { hapticPtr in
            // You can change the pattern each time by mutating pointee.
            hapticPtr.pointee = .notification
            // Return the interval (seconds) until the next haptic.
            return 2.0 // one notification tap every 2 seconds
        }
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("⌛️ Smart alarm session will expire soon.")
        // You could optionally ramp down or log.
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        print("✅ Smart alarm session invalidated. Reason: \(reason), error: \(String(describing: error))")
        isSessionScheduled = false
        isSessionRunning = false
        session = nil
    }

    // MARK: - Helpers

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

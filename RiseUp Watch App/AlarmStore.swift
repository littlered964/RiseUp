//
//  AlarmStore.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import Foundation
import Combine

@MainActor
class AlarmStore: ObservableObject {
    @Published var alarm: Alarm

    private let storageKey = "RiseUp.mainAlarm"

    init() {
        if let saved = Self.loadFromDefaults() {
            self.alarm = saved
        } else {
            // Default: next full hour from now
            let calendar = Calendar.current
            var comps = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
            comps.minute = 0
            comps.second = 0
            let defaultTime = calendar.date(from: comps) ?? Date()
            self.alarm = Alarm(time: defaultTime, isEnabled: false)
        }
    }

    func updateAlarm(time: Date, isEnabled: Bool) {
        alarm.time = time
        alarm.isEnabled = isEnabled
        saveToDefaults()
    }

    func setEnabled(_ enabled: Bool) {
        alarm.isEnabled = enabled
        saveToDefaults()
    }

    // MARK: - Persistence

    private func saveToDefaults() {
        do {
            let data = try JSONEncoder().encode(alarm)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("⚠️ Failed to encode alarm: \(error)")
        }
    }

    private static func loadFromDefaults() -> Alarm? {
        guard let data = UserDefaults.standard.data(forKey: "RiseUp.mainAlarm") else {
            return nil
        }
        do {
            return try JSONDecoder().decode(Alarm.self, from: data)
        } catch {
            print("⚠️ Failed to decode alarm from defaults: \(error)")
            return nil
        }
    }
}

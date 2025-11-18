//
//  Alarm.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import Foundation

struct Alarm: Identifiable, Codable, Equatable {
    let id: UUID
    var time: Date
    var isEnabled: Bool

    init(id: UUID = UUID(), time: Date, isEnabled: Bool = true) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
    }

    /// Returns a short, user-facing time string like "7:15 AM"
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

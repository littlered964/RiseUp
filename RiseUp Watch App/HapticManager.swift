//
//  HapticManager.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import WatchKit

enum HapticPattern {
    case singleTap
    case rapidFire
    case wave
}

struct HapticManager {
    static func play(_ pattern: HapticPattern) {
        let device = WKInterfaceDevice.current()

        switch pattern {
        case .singleTap:
            device.play(.notification)

        case .rapidFire:
            playRapidFire(on: device)

        case .wave:
            playWave(on: device)
        }
    }

    private static func playRapidFire(on device: WKInterfaceDevice) {
        Task {
            for _ in 0..<6 {
                device.play(.click)
                try? await Task.sleep(nanoseconds: 150_000_000) // 0.15 seconds
            }
        }
    }

    private static func playWave(on device: WKInterfaceDevice) {
        Task {
            // A wave-like sequence: soft → strong → soft
            let sequence: [WKHapticType] = [
                .click,
                .directionUp,
                .success,
                .directionDown,
                .click
            ]

            for type in sequence {
                device.play(type)
                try? await Task.sleep(nanoseconds: 220_000_000) // 0.22 seconds
            }
        }
    }
}

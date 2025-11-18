//
//  HapticTestView.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import SwiftUI

struct HapticTestView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Haptic Test")
                .font(.headline)

            Button("Single Tap") {
                HapticManager.play(.singleTap)
            }
            .buttonStyle(.bordered)

            Button("Rapid Fire") {
                HapticManager.play(.rapidFire)
            }
            .buttonStyle(.bordered)

            Button("Wave") {
                HapticManager.play(.wave)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
    }
}

//
//  ContentView.swift
//  RiseUp Watch App
//
//  Created by Bradley Krutz on 11/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("RiseUp")
                    .font(.title2)
                    .bold()

                Text("Haptic Alarm (Prototype)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                NavigationLink("Test Haptics") {
                    HapticTestView()
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
        }
    }
}

//
//  ContentView.swift
//  RiseUp Watch App
//
//  Created by Bradley Krutz on 11/17/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alarmStore: AlarmStore
    @EnvironmentObject var alarmRunner: AlarmRunner
    @EnvironmentObject var smartAlarmManager: SmartAlarmManager
    @EnvironmentObject var motionMonitor: MotionMonitor

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("RiseUp")
                    .font(.title2)
                    .bold()

                Text("Haptic Alarm")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                // Main alarm summary
                VStack(spacing: 4) {
                    Text(alarmStore.alarm.formattedTime)
                        .font(.largeTitle)
                        .bold()

                    Toggle(isOn: Binding(
                        get: { alarmStore.alarm.isEnabled },
                        set: { newValue in
                            alarmStore.setEnabled(newValue)

                            // Foreground fallback
                            alarmRunner.scheduleIfNeeded(for: alarmStore.alarm)

                            // Smart alarm session (may need entitlements on real device)
                            smartAlarmManager.scheduleSmartAlarm(for: alarmStore.alarm)
                        }
                    )) {
                        Text("Alarm Enabled")
                            .font(.caption)
                    }
                    .toggleStyle(.switch)
                }

                // Foreground alarm ringing + movement info
                if alarmRunner.isRinging {
                    VStack(spacing: 4) {
                        Text("Alarm ringing!")
                            .font(.caption2)
                            .foregroundStyle(.orange)

                        Text("Steps detected: \(motionMonitor.stepsSinceStart)")
                            .font(.caption2)

                        Text(alarmRunner.stepGoalReached
                                ? "Movement goal reached, you can stop the alarm."
                                : "Walk around until we detect enough steps.")
                            .font(.caption2)
                            .multilineTextAlignment(.center)

                        Button("I'm up, stop alarm") {
                            alarmRunner.cancel()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!alarmRunner.stepGoalReached)
                    }
                }

                // Smart alarm status (when entitlements are added + on real watch)
                if smartAlarmManager.isSessionRunning {
                    VStack(spacing: 4) {
                        Text("Smart alarm active")
                            .font(.caption2)
                            .foregroundStyle(.green)

                        Button("Stop Smart Alarm") {
                            smartAlarmManager.stopRinging()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                // Edit alarm settings
                NavigationLink("Edit Alarm") {
                    AlarmEditView()
                }
                .buttonStyle(.borderedProminent)

                // Dev tools / test screens
                NavigationLink("Quick Alarm Test") {
                    QuickAlarmView()
                }
                .buttonStyle(.bordered)

                NavigationLink("Test Haptics") {
                    HapticTestView()
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding()
            .onAppear {
                // On launch, schedule both paths if enabled
                alarmRunner.scheduleIfNeeded(for: alarmStore.alarm)
                smartAlarmManager.scheduleSmartAlarm(for: alarmStore.alarm)
            }
            .onChange(of: alarmStore.alarm) { newAlarm in
                alarmRunner.scheduleIfNeeded(for: newAlarm)
                smartAlarmManager.scheduleSmartAlarm(for: newAlarm)
            }
        }
    }
}

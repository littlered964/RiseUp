//
//  AlarmEditView.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import SwiftUI

struct AlarmEditView: View {
    @EnvironmentObject var alarmStore: AlarmStore
    @EnvironmentObject var alarmRunner: AlarmRunner
    @EnvironmentObject var smartAlarmManager: SmartAlarmManager
    @Environment(\.dismiss) private var dismiss

    @State private var tempTime: Date
    @State private var tempEnabled: Bool

    init() {
        _tempTime = State(initialValue: Date())
        _tempEnabled = State(initialValue: true)
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Edit Alarm")
                .font(.headline)

            DatePicker(
                "Alarm time",
                selection: $tempTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

            Toggle("Enabled", isOn: $tempEnabled)
                .toggleStyle(.switch)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    alarmStore.updateAlarm(time: tempTime, isEnabled: tempEnabled)

                    // Reschedule both engines
                    alarmRunner.scheduleIfNeeded(for: alarmStore.alarm)
                    smartAlarmManager.scheduleSmartAlarm(for: alarmStore.alarm)

                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            tempTime = alarmStore.alarm.time
            tempEnabled = alarmStore.alarm.isEnabled
        }
    }
}

//
//  RiseUpApp.swift
//  RiseUp Watch App
//
//  Created by Bradley Krutz on 11/17/25.
//

import SwiftUI

@main
struct RiseUp_Watch_AppApp: App {
    @StateObject private var alarmStore = AlarmStore()
    @StateObject private var alarmRunner = AlarmRunner()
    @StateObject private var smartAlarmManager = SmartAlarmManager()
    @StateObject private var motionMonitor = MotionMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmStore)
                .environmentObject(alarmRunner)
                .environmentObject(smartAlarmManager)
                .environmentObject(motionMonitor)
                .onAppear {
                    // Wire the motion monitor into the alarm runner
                    alarmRunner.motionMonitor = motionMonitor
                }
        }
    }
}

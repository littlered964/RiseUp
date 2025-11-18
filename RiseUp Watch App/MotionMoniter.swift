//
//  MotionMoniter.swift
//  RiseUp
//
//  Created by Bradley Krutz on 11/18/25.
//

import Foundation
import CoreMotion

@MainActor
class MotionMonitor: ObservableObject {
    @Published var stepsSinceStart: Int = 0
    @Published var goalReached: Bool = false

    private let pedometer = CMPedometer()
    private var baselineSteps: Int?
    private var stepGoal: Int = 0
    private var isMonitoring = false

    func startMonitoring(stepGoal: Int) {
        guard CMPedometer.isStepCountingAvailable() else {
            print("⚠️ Step counting not available on this device.")
            stepsSinceStart = 0
            goalReached = false
            return
        }

        print("🚶‍♂️ Starting motion monitoring with goal \(stepGoal) steps.")
        self.stepGoal = stepGoal
        self.stepsSinceStart = 0
        self.goalReached = false
        self.baselineSteps = nil
        self.isMonitoring = true

        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                print("⚠️ Pedometer error: \(error)")
                return
            }
            guard let data = data else { return }

            Task { @MainActor in
                if self.baselineSteps == nil {
                    self.baselineSteps = data.numberOfSteps.intValue
                }

                let currentTotal = data.numberOfSteps.intValue
                let base = self.baselineSteps ?? currentTotal
                let delta = max(currentTotal - base, 0)

                self.stepsSinceStart = delta
                self.goalReached = delta >= self.stepGoal

                print("🚶‍♀️ Steps since start: \(delta) (goal: \(self.stepGoal))")
            }
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        print("🛑 Stopping motion monitoring.")
        pedometer.stopUpdates()
        isMonitoring = false
    }
}

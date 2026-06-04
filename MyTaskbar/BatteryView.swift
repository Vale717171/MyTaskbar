import SwiftUI
import IOKit.ps

struct BatteryView: View {
    @State private var status = BatteryStatus.current()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if status.isAvailable {
                HStack(spacing: 5) {
                    Image(systemName: status.symbolName)
                        .font(.system(size: 12, weight: .semibold))
                    Text("\(status.percentage)%")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                }
                .foregroundColor(.white)
                .frame(width: 58, alignment: .trailing)
                .help(status.helpText)
            }
        }
        .onReceive(timer) { _ in
            status = BatteryStatus.current()
        }
    }
}

struct BatteryStatus: Equatable {
    let percentage: Int
    let isCharging: Bool
    let isFullyCharged: Bool
    let isAvailable: Bool

    var symbolName: String {
        if isCharging {
            return "battery.100.bolt"
        }

        switch percentage {
        case 80...100:
            return "battery.100"
        case 45..<80:
            return "battery.75"
        case 20..<45:
            return "battery.25"
        default:
            return "battery.0"
        }
    }

    var helpText: String {
        if isCharging {
            return "Batteria \(percentage)% - in carica"
        }
        if isFullyCharged {
            return "Batteria \(percentage)% - carica"
        }
        return "Batteria \(percentage)%"
    }

    static func current() -> BatteryStatus {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return BatteryStatus(percentage: 0, isCharging: false, isFullyCharged: false, isAvailable: false)
        }

        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any],
                  let type = description[kIOPSTypeKey] as? String,
                  type == kIOPSInternalBatteryType else {
                continue
            }

            let currentCapacity = description[kIOPSCurrentCapacityKey] as? Int ?? 0
            let maxCapacity = description[kIOPSMaxCapacityKey] as? Int ?? 100
            let percentage = maxCapacity > 0 ? Int((Double(currentCapacity) / Double(maxCapacity) * 100).rounded()) : 0
            let powerState = description[kIOPSPowerSourceStateKey] as? String
            let isCharging = powerState == kIOPSACPowerValue && percentage < 100
            let isFullyCharged = (description[kIOPSIsChargedKey] as? Bool) ?? percentage >= 100

            return BatteryStatus(
                percentage: min(max(percentage, 0), 100),
                isCharging: isCharging,
                isFullyCharged: isFullyCharged,
                isAvailable: true
            )
        }

        return BatteryStatus(percentage: 0, isCharging: false, isFullyCharged: false, isAvailable: false)
    }
}

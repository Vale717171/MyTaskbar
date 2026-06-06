import SwiftUI
import IOKit.ps

struct BatteryView: View {
    @State private var batteryLevel: Int = 100
    @State private var isCharging: Bool = false
    @State private var isPluggedIn: Bool = false
    
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: batteryIconName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.black.opacity(0.78))
            
            Text("\(batteryLevel)%")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.black.opacity(0.74))
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.white.opacity(0.24))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .onAppear(perform: updateBatteryInfo)
        .onReceive(timer) { _ in
            updateBatteryInfo()
        }
    }
    
    private var batteryIconName: String {
        if isPluggedIn {
            return isCharging ? "battery.100.bolt" : "battery.100"
        }
        
        switch batteryLevel {
        case 0...10:  return "battery.0"
        case 11...25: return "battery.25"
        case 26...50: return "battery.50"
        case 51...75: return "battery.75"
        default:      return "battery.100"
        }
    }
    
    private func updateBatteryInfo() {
        guard let powerSourcesInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else { return }
        guard let powerSourcesList = IOPSCopyPowerSourcesList(powerSourcesInfo)?.takeRetainedValue() as? [CFTypeRef] else { return }
        
        for powerSource in powerSourcesList {
            guard let description = IOPSGetPowerSourceDescription(powerSourcesInfo, powerSource)?.takeUnretainedValue() as? [String: Any] else { continue }
            
            // We only care about the internal battery
            if let type = description[kIOPSTypeKey] as? String, type != kIOPSInternalBatteryType {
                continue
            }
            
            if let currentCapacity = description[kIOPSCurrentCapacityKey] as? Int,
               let maxCapacity = description[kIOPSMaxCapacityKey] as? Int,
               maxCapacity > 0 {
                batteryLevel = Int((Double(currentCapacity) / Double(maxCapacity)) * 100.0)
            }
            
            if let charging = description[kIOPSIsChargingKey] as? Bool {
                isCharging = charging
            }
            
            if let powerSourceState = description[kIOPSPowerSourceStateKey] as? String {
                isPluggedIn = (powerSourceState == kIOPSACPowerValue)
            }
        }
    }
}

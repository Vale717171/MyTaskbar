import SwiftUI

struct ClockView: View {
    @State private var now = Date()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(now, format: .dateTime.hour().minute())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
            Text(now, format: .dateTime.day().month())
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .opacity(0.8)
        }
        .foregroundColor(.white)
        .monospacedDigit()
        .frame(width: 64, alignment: .trailing)
        .onReceive(timer) { value in
            now = value
        }
    }
}

import SwiftUI

struct TaskbarView: View {
    @StateObject private var viewModel = TaskbarViewModel()

    var body: some View {
        HStack(spacing: 10) {
            startButton

            Divider()
                .frame(height: 28)
                .overlay(Color.black.opacity(0.14))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.taskbarItems) { item in
                        TaskbarItemButton(item: item, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 2)
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                BatteryView()
                ClockView()
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 52)
        .background(
            ZStack {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active)
                LinearGradient(
                    colors: [Color(white: 0.80).opacity(0.96), Color(white: 0.73).opacity(0.94)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.black.opacity(0.12))
                .frame(height: 1)
        }
    }

    private var startButton: some View {
        Button(action: viewModel.toggleStartMenu) {
            HStack(spacing: 8) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text("Start")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.black.opacity(0.84))
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.28))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.black.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct TaskbarItemButton: View {
    let item: TaskbarItem
    let viewModel: TaskbarViewModel

    var body: some View {
        Button(action: { viewModel.bringItemToFrontOrLaunch(item) }) {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    if let icon = item.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    } else {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 24))
                    }

                    if item.isPinned && !item.isRunning {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.black.opacity(0.65))
                            .offset(x: 5, y: -3)
                    }
                }

                Capsule()
                    .fill(item.isFrontmost ? Color.black.opacity(0.78) : item.isRunning ? Color.black.opacity(0.32) : Color.clear)
                    .frame(width: item.isFrontmost ? 22 : 8, height: 3)
                    .animation(.easeInOut(duration: 0.15), value: item.isFrontmost)
            }
            .frame(width: 48, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(item.isFrontmost ? Color.white.opacity(0.34) : Color.white.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(Color.black.opacity(item.isFrontmost ? 0.14 : 0.06), lineWidth: 1)
            )
            .help(item.name)
        }
        .buttonStyle(.plain)
        .contextMenu {
            if item.isPinned {
                Button("Rimuovi dalla taskbar") {
                    viewModel.unpin(item)
                }
            } else {
                Button("Aggiungi alla taskbar") {
                    viewModel.pin(item)
                }
            }

            if item.isRunning, let app = item.runningApplication {
                Button("Porta in primo piano") {
                    viewModel.bringAppToFront(app)
                }
            }
        }
    }
}

import SwiftUI

struct TaskbarView: View {
    @StateObject private var viewModel = TaskbarViewModel()

    var body: some View {
        HStack(spacing: 10) {
            startButton

            Divider()
                .frame(height: 28)
                .overlay(Color.white.opacity(0.18))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.taskbarItems) { item in
                        TaskbarItemButton(item: item, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 2)
            }

            Spacer(minLength: 8)

            ClockView()
        }
        .padding(.horizontal, 10)
        .frame(height: 52)
        .background(
            ZStack {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active)
                LinearGradient(
                    colors: [Color.black.opacity(0.55), Color.black.opacity(0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.14))
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
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.13))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
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
                            .foregroundColor(.white.opacity(0.8))
                            .offset(x: 5, y: -3)
                    }
                }

                Capsule()
                    .fill(item.isFrontmost ? Color.white.opacity(0.95) : item.isRunning ? Color.white.opacity(0.45) : Color.clear)
                    .frame(width: item.isFrontmost ? 22 : 8, height: 3)
                    .animation(.easeInOut(duration: 0.15), value: item.isFrontmost)
            }
            .frame(width: 48, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(item.isFrontmost ? Color.white.opacity(0.22) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(Color.white.opacity(item.isFrontmost ? 0.25 : 0.08), lineWidth: 1)
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

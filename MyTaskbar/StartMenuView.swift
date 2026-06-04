import SwiftUI
import AppKit

struct StartMenuView: View {
    @ObservedObject var viewModel: TaskbarViewModel
    @State private var searchText = ""

    private var filteredApps: [AppInfo] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.installedApplications
        }

        return viewModel.installedApplications.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var pinnedApps: [AppInfo] {
        viewModel.pinnedApplicationIDs.compactMap { id in
            viewModel.installedApplications.first(where: { $0.id == id })
        }
    }

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active)
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.13).opacity(0.94),
                    Color(red: 0.02, green: 0.03, blue: 0.05).opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 16) {
                header
                searchField

                if !pinnedApps.isEmpty && searchText.isEmpty {
                    pinnedSection
                }

                allAppsSection
            }
            .padding(18)
        }
        .frame(width: 520, height: 620)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("MyTaskbar")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Menu Start sperimentale per macOS")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.65))
            }

            Spacer()

            Button(action: { NSApp.terminate(nil) }) {
                Image(systemName: "power")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.88))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.12))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .help("Chiudi MyTaskbar")

            ClockView()
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.65))
            TextField("Cerca applicazioni", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .tint(.white)
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        )
    }

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Aggiunte alla taskbar")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.75))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(pinnedApps) { app in
                    StartPinnedAppButton(app: app, viewModel: viewModel)
                }
            }
        }
    }

    private var allAppsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(searchText.isEmpty ? "Tutte le app" : "Risultati")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                Spacer()
                Text("\(filteredApps.count)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(filteredApps) { app in
                        StartMenuRow(app: app, viewModel: viewModel)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct StartPinnedAppButton: View {
    let app: AppInfo
    let viewModel: TaskbarViewModel

    var body: some View {
        Button(action: { viewModel.openApplication(at: app.url) }) {
            VStack(spacing: 8) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                }

                Text(app.name)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct StartMenuRow: View {
    let app: AppInfo
    let viewModel: TaskbarViewModel

    var body: some View {
        Button(action: { viewModel.openApplication(at: app.url) }) {
            HStack(spacing: 12) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }

                Text(app.name)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))

                Spacer()

                if viewModel.isPinned(app) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            if viewModel.isPinned(app) {
                Button("Rimuovi dalla taskbar") {
                    if let item = viewModel.taskbarItems.first(where: { $0.id == app.id }) {
                        viewModel.unpin(item)
                    }
                }
            } else {
                Button("Aggiungi alla taskbar") {
                    viewModel.pin(app)
                }
            }
        }
    }
}

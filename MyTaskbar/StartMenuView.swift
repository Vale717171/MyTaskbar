import SwiftUI
import AppKit

struct StartMenuView: View {
    @ObservedObject var viewModel: TaskbarViewModel
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool

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
                    Color(white: 0.80).opacity(0.96),
                    Color(white: 0.73).opacity(0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
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
                .stroke(Color.black.opacity(0.22), lineWidth: 1)
        )
        .onAppear {
            DispatchQueue.main.async {
                isSearchFieldFocused = true
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("MyTaskbar")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.88))
                Text("Menu Start sperimentale per macOS")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.58))
            }

            Spacer()

            Button(action: { NSApp.terminate(nil) }) {
                Image(systemName: "power")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black.opacity(0.78))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.08))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
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
                .foregroundColor(.black.opacity(0.50))
            TextField("Cerca applicazioni", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(.black.opacity(0.88))
                .tint(.black)
                .focused($isSearchFieldFocused)
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.10), lineWidth: 1)
        )
    }

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Aggiunte alla taskbar")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.black.opacity(0.66))

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
                    .foregroundColor(.black.opacity(0.66))
                Spacer()
                Text("\(filteredApps.count)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.46))
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
                    .foregroundColor(.black.opacity(0.82))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.26))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
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
                    .foregroundColor(.black.opacity(0.84))

                Spacer()

                if viewModel.isPinned(app) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.black.opacity(0.44))
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.white.opacity(0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
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

import SwiftUI
import AppKit

@MainActor
final class TaskbarViewModel: ObservableObject {
    @Published var runningApplications: [NSRunningApplication] = []
    @Published var installedApplications: [AppInfo] = []
    @Published var pinnedApplicationIDs: [String] = []
    @Published var frontmostApplicationIdentifier: String?

    private var startPanel: NSPanel?
    private var timer: Timer?
    private let pinnedDefaultsKey = "PinnedApplicationIDs"

    init() {
        loadInstalledApplications()
        loadPinnedApplications()
        updateRunningApplications()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateRunningApplications()
            }
        }
    }

    var taskbarItems: [TaskbarItem] {
        var items: [TaskbarItem] = []
        var usedIDs = Set<String>()

        for id in pinnedApplicationIDs {
            guard let appInfo = installedApplications.first(where: { $0.id == id }) else { continue }
            let runningApp = runningApplications.first { runningApp in
                if let bundleIdentifier = appInfo.bundleIdentifier {
                    return runningApp.bundleIdentifier == bundleIdentifier
                }
                return runningApp.bundleURL == appInfo.url
            }
            items.append(
                TaskbarItem(
                    appInfo: appInfo,
                    runningApplication: runningApp,
                    isPinned: true,
                    isFrontmost: runningApp?.bundleIdentifier == frontmostApplicationIdentifier
                )
            )
            usedIDs.insert(appInfo.id)
        }

        for app in runningApplications {
            let id = app.bundleIdentifier ?? "pid-\(app.processIdentifier)"
            if usedIDs.contains(id) { continue }
            items.append(TaskbarItem(runningApplication: app, isFrontmost: app.bundleIdentifier == frontmostApplicationIdentifier))
            usedIDs.insert(id)
        }

        return items
    }

    func bringItemToFrontOrLaunch(_ item: TaskbarItem) {
        if let app = item.runningApplication {
            activateOrReopen(app, fallbackURL: item.applicationURL)
            return
        }

        if let url = item.applicationURL {
            openApplication(at: url)
        }
    }

    func bringAppToFront(_ app: NSRunningApplication) {
        activateOrReopen(app, fallbackURL: app.bundleURL)
    }

    func openApplication(at url: URL) {
        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, error in
            if let error {
                print("Failed to open application at \(url.path): \(error.localizedDescription)")
            }
        }
    }

    func pin(_ app: AppInfo) {
        guard !pinnedApplicationIDs.contains(app.id) else { return }
        pinnedApplicationIDs.append(app.id)
        savePinnedApplications()
    }

    func pin(_ item: TaskbarItem) {
        if let bundleIdentifier = item.bundleIdentifier,
           let appInfo = installedApplications.first(where: { $0.bundleIdentifier == bundleIdentifier }) {
            pin(appInfo)
            return
        }

        if let url = item.applicationURL {
            pin(AppInfo(url: url))
        }
    }

    func unpin(_ item: TaskbarItem) {
        pinnedApplicationIDs.removeAll { $0 == item.id }
        savePinnedApplications()
    }

    func isPinned(_ app: AppInfo) -> Bool {
        pinnedApplicationIDs.contains(app.id)
    }

    func toggleStartMenu() {
        if let panel = startPanel, panel.isVisible {
            panel.close()
            startPanel = nil
        } else {
            showStartMenu()
        }
    }

    private func updateRunningApplications() {
        runningApplications = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }

        frontmostApplicationIdentifier = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }

    private func loadInstalledApplications() {
        let fileManager = FileManager.default
        let directories = [
            URL(fileURLWithPath: "/Applications"),
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
        ]

        var apps: [AppInfo] = []
        var seenIDs = Set<String>()

        for directory in directories {
            guard let urls = try? fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            for url in urls where url.pathExtension == "app" {
                let app = AppInfo(url: url)
                guard !seenIDs.contains(app.id) else { continue }
                apps.append(app)
                seenIDs.insert(app.id)
            }
        }

        installedApplications = apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func loadPinnedApplications() {
        let stored = UserDefaults.standard.stringArray(forKey: pinnedDefaultsKey)
        if let stored, !stored.isEmpty {
            pinnedApplicationIDs = stored
            return
        }

        let preferredBundleIDs = [
            "com.apple.Safari",
            "com.apple.finder",
            "com.apple.Terminal",
            "com.microsoft.VSCode"
        ]

        pinnedApplicationIDs = installedApplications
            .filter { app in
                guard let bundleIdentifier = app.bundleIdentifier else { return false }
                return preferredBundleIDs.contains(bundleIdentifier)
            }
            .map(\.id)
    }

    private func savePinnedApplications() {
        UserDefaults.standard.set(pinnedApplicationIDs, forKey: pinnedDefaultsKey)
    }

    private func activateOrReopen(_ app: NSRunningApplication, fallbackURL: URL?) {
        app.unhide()
        app.activate(options: [])

        if let bundleIdentifier = app.bundleIdentifier {
            runOpen(arguments: ["-b", bundleIdentifier])
            return
        }

        if let fallbackURL {
            runOpen(arguments: ["-a", fallbackURL.path])
        }
    }

    private func runOpen(arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = arguments
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            print("Failed to run open \(arguments.joined(separator: " ")): \(error.localizedDescription)")
        }
    }

    private func showStartMenu() {
        guard let taskbarWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == "MyTaskbarWindow" }) ?? NSApp.windows.first else { return }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 620),
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .popUpMenu
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = true

        let startView = StartMenuView(viewModel: self)
        panel.contentView = NSHostingView(rootView: startView)

        let screenFrame = taskbarWindow.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
        let panelX = max(screenFrame.minX + 12, taskbarWindow.frame.minX + 8)
        let panelY = taskbarWindow.frame.maxY + 8

        panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
        panel.makeKeyAndOrderFront(nil)
        startPanel = panel
    }
}

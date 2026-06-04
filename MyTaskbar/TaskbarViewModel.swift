import SwiftUI
import AppKit

@MainActor
class TaskbarViewModel: ObservableObject {
    @Published var runningApplications: [NSRunningApplication] = []
    private var startPanel: NSPanel?
    
    init() {
        updateRunningApplications()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateRunningApplications()
            }
        }
    }
    
    private func updateRunningApplications() {
        let apps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
        
        self.runningApplications = apps
    }
    
    func bringAppToFront(_ app: NSRunningApplication) {
        app.activate(options: .activateIgnoringOtherApps)
    }
    
    func toggleStartMenu() {
        if let panel = startPanel, panel.isVisible {
            panel.close()
            startPanel = nil
        } else {
            showStartMenu()
        }
    }
    
    private func showStartMenu() {
        guard let taskbarWindow = NSApp.windows.first else { return }
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 520),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .popUpMenu
        panel.backgroundColor = .black.withAlphaComponent(0.95)
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        
        let startView = StartMenuView(onAppSelected: { [weak self] url in
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
            self?.toggleStartMenu()
        })
        
        let hostingView = NSHostingView(rootView: startView)
        panel.contentView = hostingView
        
        let screenFrame = taskbarWindow.screen?.visibleFrame ?? NSScreen.main!.visibleFrame
        let panelX = screenFrame.midX - 210
        
        panel.setFrameOrigin(NSPoint(x: panelX, y: taskbarWindow.frame.maxY + 8))
        
        panel.makeKeyAndOrderFront(nil)
        startPanel = panel
    }
}
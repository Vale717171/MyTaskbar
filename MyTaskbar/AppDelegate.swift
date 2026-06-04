import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var taskbarWindow: NSWindow?
    private let originalDockAutohideKey = "OriginalDockAutohide"
    private var terminationSignalSources: [DispatchSourceSignal] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        installTerminationHandlers()
        hideDock()
        createTaskbarWindow()
    }

    func applicationWillTerminate(_ notification: Notification) {
        restoreDock()
    }

    private func createTaskbarWindow() {
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.visibleFrame
        let height: CGFloat = 52

        let window = NSWindow(
            contentRect: NSRect(x: screenRect.minX, y: screenRect.minY, width: screenRect.width, height: height),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.identifier = NSUserInterfaceItemIdentifier("MyTaskbarWindow")
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.isMovableByWindowBackground = false
        window.ignoresMouseEvents = false

        let hostingView = NSHostingView(rootView: TaskbarView())
        window.contentView = hostingView
        window.setFrameOrigin(NSPoint(x: screenRect.minX, y: screenRect.minY))
        window.orderFrontRegardless()

        taskbarWindow = window
    }

    private func hideDock() {
        let originalValue = readDockAutohide()
        UserDefaults.standard.set(originalValue, forKey: originalDockAutohideKey)

        guard originalValue != true else { return }
        writeDockAutohide(true)
    }

    private func restoreDock() {
        guard UserDefaults.standard.object(forKey: originalDockAutohideKey) != nil else { return }
        let originalValue = UserDefaults.standard.bool(forKey: originalDockAutohideKey)
        writeDockAutohide(originalValue)
        UserDefaults.standard.removeObject(forKey: originalDockAutohideKey)
    }

    private func readDockAutohide() -> Bool {
        let process = Process()
        let output = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = ["read", "com.apple.dock", "autohide"]
        process.standardOutput = output
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return false
        }

        let data = output.fileHandleForReading.readDataToEndOfFile()
        let value = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return value == "1" || value?.lowercased() == "true"
    }

    private func writeDockAutohide(_ enabled: Bool) {
        runProcess("/usr/bin/defaults", arguments: ["write", "com.apple.dock", "autohide", "-bool", enabled ? "true" : "false"])
        runProcess("/usr/bin/killall", arguments: ["Dock"])
    }

    private func runProcess(_ path: String, arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Failed to run \(path): \(error.localizedDescription)")
        }
    }

    private func installTerminationHandlers() {
        [SIGTERM, SIGINT].forEach { signalNumber in
            signal(signalNumber, SIG_IGN)

            let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .main)
            source.setEventHandler { [weak self] in
                self?.restoreDock()
                exit(signalNumber)
            }
            source.resume()
            terminationSignalSources.append(source)
        }
    }
}

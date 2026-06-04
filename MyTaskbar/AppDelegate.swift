import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var taskbarWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        createTaskbarWindow()
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
        window.level = .statusWindow
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
}

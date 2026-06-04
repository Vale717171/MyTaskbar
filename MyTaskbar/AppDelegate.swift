import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var taskbarWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        createTaskbarWindow()
    }
    
    private func createTaskbarWindow() {
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.visibleFrame
        let height: CGFloat = 44
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: screenRect.width, height: height),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.level = .statusWindow
        window.backgroundColor = NSColor.black.withAlphaComponent(0.85)
        window.isOpaque = false
        window.hasShadow = true
        window.isMovableByWindowBackground = false
        
        window.setFrameOrigin(NSPoint(x: 0, y: screenRect.minY))
        
        let hostingView = NSHostingView(rootView: TaskbarView())
        window.contentView = hostingView
        
        window.makeKeyAndOrderFront(nil)
        taskbarWindow = window
    }
}
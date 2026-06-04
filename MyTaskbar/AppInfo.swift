import AppKit
import Foundation

struct AppInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let url: URL
    let bundleIdentifier: String?
    let icon: NSImage?

    init(url: URL) {
        self.url = url
        self.name = url.deletingPathExtension().lastPathComponent
        self.bundleIdentifier = Bundle(url: url)?.bundleIdentifier
        self.id = Bundle(url: url)?.bundleIdentifier ?? url.path
        self.icon = NSWorkspace.shared.icon(forFile: url.path)
    }
}

struct TaskbarItem: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: NSImage?
    let bundleIdentifier: String?
    let applicationURL: URL?
    let runningApplication: NSRunningApplication?
    let isPinned: Bool
    let isRunning: Bool
    let isFrontmost: Bool

    init(appInfo: AppInfo, runningApplication: NSRunningApplication?, isPinned: Bool, isFrontmost: Bool) {
        self.id = appInfo.id
        self.name = appInfo.name
        self.icon = runningApplication?.icon ?? appInfo.icon
        self.bundleIdentifier = appInfo.bundleIdentifier
        self.applicationURL = appInfo.url
        self.runningApplication = runningApplication
        self.isPinned = isPinned
        self.isRunning = runningApplication != nil
        self.isFrontmost = isFrontmost
    }

    init(runningApplication: NSRunningApplication, isFrontmost: Bool) {
        let bundleID = runningApplication.bundleIdentifier
        self.id = bundleID ?? "pid-\(runningApplication.processIdentifier)"
        self.name = runningApplication.localizedName ?? bundleID ?? "App"
        self.icon = runningApplication.icon
        self.bundleIdentifier = bundleID
        self.applicationURL = runningApplication.bundleURL
        self.runningApplication = runningApplication
        self.isPinned = false
        self.isRunning = true
        self.isFrontmost = isFrontmost
    }
}
